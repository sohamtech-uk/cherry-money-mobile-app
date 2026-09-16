enum ReconciliationStatus {
  matched('Matched'),
  suggestedMatch('Suggested match'),
  needsReview('Needs review'),
  missingDocument('Missing document'),
  amountMismatch('Amount mismatch'),
  duplicateCandidate('Possible duplicate'),
  reconciled('Reconciled');

  final String label;
  const ReconciliationStatus(this.label);
}

class AuditEvent {
  final String id, actorType, actorLabel, action, entityType, entityId, summary;
  final DateTime timestamp;
  final Map<String, Object?> metadata;
  AuditEvent({
    required this.entityId,
    required this.action,
    required this.summary,
    this.actorType = 'user',
    this.actorLabel = 'You',
    this.entityType = 'transaction',
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now(),
       id = '${DateTime.now().microsecondsSinceEpoch}-$entityId-$action';
}

class FinanceDocument {
  final String id, supplier, reference;
  final int amountPence;
  final double confidence;
  final DateTime date;
  const FinanceDocument({
    required this.id,
    required this.supplier,
    required this.reference,
    required this.amountPence,
    required this.confidence,
    required this.date,
  });
}

class FinanceTransaction {
  final String id, merchant, reference, category;
  final int amountPence;
  final DateTime date;
  final ReconciliationStatus status;
  final FinanceDocument? document;
  final List<AuditEvent> audit;
  const FinanceTransaction({
    required this.id,
    required this.merchant,
    required this.reference,
    required this.category,
    required this.amountPence,
    required this.date,
    required this.status,
    this.document,
    this.audit = const [],
  });
  FinanceTransaction update(
    ReconciliationStatus status,
    AuditEvent event, {
    FinanceDocument? document,
  }) => FinanceTransaction(
    id: id,
    merchant: merchant,
    reference: reference,
    category: category,
    amountPence: amountPence,
    date: date,
    status: status,
    document: document ?? this.document,
    audit: [...audit, event],
  );
}

class MatchResult {
  final double confidence;
  final ReconciliationStatus status;
  final List<String> reasons;
  const MatchResult(this.confidence, this.status, this.reasons);
}

MatchResult evaluateMatch(
  FinanceTransaction transaction,
  FinanceDocument? document,
) {
  if (document == null) {
    return const MatchResult(0, ReconciliationStatus.missingDocument, [
      'No supporting document',
    ]);
  }
  if (transaction.status == ReconciliationStatus.duplicateCandidate) {
    return const MatchResult(.5, ReconciliationStatus.duplicateCandidate, [
      'A similar payment needs a duplicate check',
    ]);
  }
  if (transaction.amountPence.abs() != document.amountPence) {
    return const MatchResult(.3, ReconciliationStatus.amountMismatch, [
      'Document and transaction amounts differ',
    ]);
  }
  var score = .5;
  final reasons = ['Amount match'];
  if (transaction.date.difference(document.date).inDays.abs() <= 1) {
    score += .15;
    reasons.add('Date within 1 day');
  }
  if (transaction.merchant.toLowerCase() == document.supplier.toLowerCase()) {
    score += .15;
    reasons.add('Supplier name match');
  }
  if (document.reference.isNotEmpty &&
      document.reference == transaction.reference) {
    score += .2;
    reasons.add('Invoice reference found');
  }
  if (document.confidence < .8) {
    score *= document.confidence;
    reasons.add('Extraction needs checking');
  }
  return MatchResult(
    score,
    score >= .8
        ? ReconciliationStatus.suggestedMatch
        : ReconciliationStatus.needsReview,
    reasons,
  );
}
