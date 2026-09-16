import '../../core/models/finance.dart';

List<FinanceTransaction> demoTransactions() {
  final date = DateTime(2026, 9, 16);
  FinanceDocument doc(
    String id,
    String supplier,
    String ref,
    int amount, [
    double confidence = .96,
  ]) => FinanceDocument(
    id: id,
    supplier: supplier,
    reference: ref,
    amountPence: amount,
    confidence: confidence,
    date: date,
  );
  FinanceTransaction tx(
    String id,
    String name,
    int amount,
    String ref,
    String category,
    ReconciliationStatus status,
    FinanceDocument? document,
  ) => FinanceTransaction(
    id: id,
    merchant: name,
    amountPence: amount,
    reference: ref,
    category: category,
    date: date,
    status: status,
    document: document,
    audit: [
      AuditEvent(
        entityId: id,
        action: 'imported',
        summary: 'Synthetic transaction added to demo workspace',
        actorType: 'system',
        actorLabel: 'Cherry demo',
        timestamp: date,
      ),
      if (document != null)
        AuditEvent(
          entityId: id,
          action: 'suggested',
          summary: 'Demo document candidate identified; awaiting review',
          actorType: 'ai',
          actorLabel: 'Demo matching engine',
          timestamp: date.add(const Duration(minutes: 1)),
        ),
    ],
  );
  return [
    tx(
      't1',
      'Northstar Studio',
      125000,
      'INV-1042',
      'Client income',
      ReconciliationStatus.suggestedMatch,
      doc('d1', 'Northstar Studio', 'INV-1042', 125000),
    ),
    tx(
      't2',
      'Paper & Co',
      -34800,
      'SUP-209',
      'Supplies',
      ReconciliationStatus.matched,
      doc('d2', 'Paper & Co', 'SUP-209', 34800),
    ),
    tx(
      't3',
      'Cloud Office',
      -7999,
      'SOFT-88',
      'Software',
      ReconciliationStatus.amountMismatch,
      doc('d3', 'Cloud Office', 'SOFT-88', 8999),
    ),
    tx(
      't4',
      'Station Road Cafe',
      -12450,
      'EXP-24',
      'Travel & meals',
      ReconciliationStatus.missingDocument,
      null,
    ),
    tx(
      't5',
      'Paper & Co',
      -34800,
      'SUP-209',
      'Supplies',
      ReconciliationStatus.duplicateCandidate,
      doc('d4', 'Paper & Co', '', 34800),
    ),
    tx(
      't6',
      'Local courier',
      -4200,
      'SHIP-7',
      'Delivery',
      ReconciliationStatus.needsReview,
      doc('d5', 'Local courier', '', 4200, .52),
    ),
    tx(
      't7',
      'Workspace rent',
      -65000,
      'RENT-09',
      'Premises',
      ReconciliationStatus.missingDocument,
      null,
    ),
  ];
}
