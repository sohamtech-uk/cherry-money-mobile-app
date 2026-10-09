import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../../core/models/finance.dart';
import '../../core/network/api_client.dart';
import '../../core/revenuecat/revenuecat_service.dart';
import '../../core/revenuecat/subscription_state.dart';
import '../../core/storage/secure_storage_service.dart';
import '../demo/demo_data.dart';

final workspaceProvider = ChangeNotifierProvider<Workspace>(
  (ref) => Workspace(),
);

class Workspace extends ChangeNotifier {
  final SubscriptionRepository subscriptions;
  final ApiClient api;
  Workspace({SubscriptionRepository? subscriptions, ApiClient? api})
    : subscriptions = subscriptions ?? RevenueCatService(const AppConfig()),
      api = api ?? ApiClient(const AppConfig(), const SecureStorageService());
  bool demo = false, signedIn = false, busy = false;
  Plan plan = Plan.launch;
  int used = 0;
  String error = '';
  MobileMfaRequired? mfaChallenge;
  Map<String, dynamic>? liveDashboard;
  List<FinanceTransaction> transactions = [];
  Map<String, dynamic>? liveFinance;
  String financeError = '';
  bool financeBusy = false;
  int _session = 0;
  int get sessionGeneration => _session;
  final List<Map<String, String>> cherryHistory = [];

  Future<void> loadFinance() async {
    if (!signedIn || demo || financeBusy) return;
    final session = _session;
    financeBusy = true;
    financeError = '';
    notifyListeners();
    try {
      final result = await api.financeRequest(
        'webmcp/bootstrap',
        query: {'limit': 100},
      );
      if (session == _session) liveFinance = result;
    } on ApiException catch (e) {
      if (session == _session) financeError = e.message;
    } finally {
      if (session == _session) {
        financeBusy = false;
        notifyListeners();
      }
    }
  }

  void _resetFinance() {
    _session++;
    liveFinance = null;
    financeError = '';
    financeBusy = false;
    cherryHistory.clear();
  }

  bool get hasAccess => demo || signedIn;
  int get remaining => (allowanceFor(plan) - used).clamp(0, allowanceFor(plan));
  int get reconciled => transactions
      .where((t) => t.status == ReconciliationStatus.reconciled)
      .length;
  int get attention => transactions
      .where((t) => t.status != ReconciliationStatus.reconciled)
      .length;
  Future<void> startDemo() async {
    mfaChallenge = null;
    _resetFinance();
    demo = true;
    signedIn = false;
    liveDashboard = null;
    error = '';
    transactions = demoTransactions();
    await _loadUsage();
    notifyListeners();
  }

  Future<void> login(String email, String password) =>
      _authenticate(() => api.login(email, password));

  Future<void> loginWithGoogle(String idToken) =>
      _authenticate(() => api.googleLogin(idToken));

  Future<void> loginWithApple(String idToken) =>
      _authenticate(() => api.appleLogin(idToken));

  Future<void> verifyMfa(String code) async {
    final pending = mfaChallenge;
    if (pending == null || busy) return;
    if (DateTime.now().isAfter(pending.expiresAt)) {
      cancelMfa();
      error = 'The authenticator request expired. Please sign in again.';
      notifyListeners();
      return;
    }
    await _authenticate(
      () => api.verifyMfa(pending.challengeToken, code),
      verifying: true,
    );
  }

  void cancelMfa() {
    if (busy) return;
    mfaChallenge = null;
    error = '';
    notifyListeners();
  }

  Future<void> _authenticate(
    Future<dynamic> Function() authenticate, {
    bool verifying = false,
  }) async {
    if (busy) return;
    if (!verifying) mfaChallenge = null;
    busy = true;
    error = '';
    notifyListeners();
    try {
      await authenticate();
      mfaChallenge = null;
      await acceptVerifiedSession();
    } on MobileMfaRequired catch (challenge) {
      _resetFinance();
      transactions = [];
      liveDashboard = null;
      mfaChallenge = challenge;
      signedIn = false;
      demo = false;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> acceptVerifiedSession() async {
    _resetFinance();
    demo = false;
    signedIn = true;
    transactions = [];
    liveDashboard = null;
    await loadLive();
  }

  Future<void> loadLive() async {
    error = '';
    busy = true;
    notifyListeners();
    try {
      liveDashboard = await api.dashboard();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    mfaChallenge = null;
    _resetFinance();
    if (signedIn) {
      try {
        await api.logout();
      } catch (_) {
        /* local credentials are cleared in finally */
      }
    }
    demo = false;
    signedIn = false;
    transactions = [];
    liveDashboard = null;
    error = '';
    notifyListeners();
  }

  String get _usageKey {
    final now = DateTime.now();
    return 'demo_usage_${now.year}_${now.month}';
  }

  Future<void> _loadUsage() async {
    used = (await SharedPreferences.getInstance()).getInt(_usageKey) ?? 0;
  }

  Future<bool> _consume() async {
    await _loadUsage();
    if (!canProcess(plan, used)) {
      return false;
    }
    used++;
    await (await SharedPreferences.getInstance()).setInt(_usageKey, used);
    return true;
  }

  void setPlan(Plan value) {
    plan = value;
    notifyListeners();
  }

  Future<void> refreshPlan() async {
    try {
      plan = await subscriptions.refresh();
    } catch (_) {
      plan = Plan.launch;
    }
    notifyListeners();
  }

  Future<bool> approve(String id) async {
    if (!demo) {
      return false;
    }
    final index = transactions.indexWhere((t) => t.id == id);
    if (index < 0) {
      return false;
    }
    final transaction = transactions[index];
    if (transaction.status == ReconciliationStatus.reconciled) {
      return true;
    }
    final match = evaluateMatch(transaction, transaction.document);
    if ([
      ReconciliationStatus.missingDocument,
      ReconciliationStatus.amountMismatch,
      ReconciliationStatus.duplicateCandidate,
    ].contains(match.status)) {
      return false;
    }
    if (!await _consume()) {
      notifyListeners();
      return false;
    }
    transactions[index] = transaction.update(
      ReconciliationStatus.reconciled,
      AuditEvent(
        entityId: id,
        action: 'approved',
        summary:
            'You approved the document match. Demo reconciliation completed.',
        metadata: {'confidence': match.confidence},
      ),
    );
    notifyListeners();
    return true;
  }

  void reject(String id) => _decision(
    id,
    'rejected',
    'You rejected this suggested match. Review required.',
  );
  void exception(String id) => _decision(
    id,
    'exception',
    'You marked this transaction as an exception.',
  );
  void _decision(String id, String action, String summary) {
    if (!demo) {
      return;
    }
    final i = transactions.indexWhere((t) => t.id == id);
    if (i < 0) {
      return;
    }
    transactions[i] = transactions[i].update(
      ReconciliationStatus.needsReview,
      AuditEvent(entityId: id, action: action, summary: summary),
    );
    notifyListeners();
  }

  bool chooseTransaction(String sourceId, String targetId) {
    if (!demo || sourceId == targetId) {
      return false;
    }
    final from = transactions.indexWhere((t) => t.id == sourceId);
    final to = transactions.indexWhere((t) => t.id == targetId);
    if (from < 0 ||
        to < 0 ||
        transactions[from].document == null ||
        transactions[to].document != null ||
        transactions[from].status == ReconciliationStatus.reconciled) {
      return false;
    }
    final source = transactions[from];
    final target = transactions[to];
    final document = source.document!;
    transactions[to] = target.update(
      evaluateMatch(target, document).status,
      AuditEvent(
        entityId: targetId,
        action: 'linked',
        summary:
            'You selected document ${document.id}. Approval is still required.',
      ),
      document: document,
    );
    transactions[from] = FinanceTransaction(
      id: source.id,
      merchant: source.merchant,
      reference: source.reference,
      category: source.category,
      amountPence: source.amountPence,
      date: source.date,
      status: ReconciliationStatus.missingDocument,
      possibleDuplicate: source.possibleDuplicate,
      audit: [
        ...source.audit,
        AuditEvent(
          entityId: sourceId,
          action: 'unlinked',
          summary: 'You moved the document to $targetId.',
        ),
      ],
    );
    notifyListeners();
    return true;
  }

  Future<bool> capture(FinanceDocument document, String targetId) async {
    if (!demo) {
      return false;
    }
    final i = transactions.indexWhere((t) => t.id == targetId);
    if (i < 0 || transactions[i].status == ReconciliationStatus.reconciled) {
      return false;
    }
    if (!await _consume()) {
      notifyListeners();
      return false;
    }
    final transaction = transactions[i];
    transactions[i] = transaction.update(
      evaluateMatch(transaction, document).status,
      AuditEvent(
        entityId: targetId,
        action: 'captured',
        summary:
            'Demo extraction attached for review. No financial document was uploaded.',
        metadata: {
          'document_id': document.id,
          'extraction_confidence': document.confidence,
        },
      ),
      document: document,
    );
    notifyListeners();
    return true;
  }
}
