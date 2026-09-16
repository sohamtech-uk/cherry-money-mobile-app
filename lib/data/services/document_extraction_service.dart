import '../../core/models/finance.dart';

abstract class DocumentExtractionService {
  Future<FinanceDocument> extract();
}

class DemoDocumentExtractionService implements DocumentExtractionService {
  @override
  Future<FinanceDocument> extract() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return FinanceDocument(
      id: 'capture-${DateTime.now().microsecondsSinceEpoch}',
      supplier: 'Station Road Cafe',
      reference: 'EXP-24',
      amountPence: 12450,
      confidence: .94,
      date: DateTime(2026, 9, 16),
    );
  }
}
