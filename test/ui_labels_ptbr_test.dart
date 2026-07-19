import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/shared/i18n/ui_labels.dart';

void main() {
  group('ui_labels PT-BR', () {
    test('severity', () {
      expect(uiSeverityLabel('high'), 'Alta');
      expect(uiSeverityLabel('critical'), 'Crítica');
      expect(uiSeverityLabel('medium'), 'Média');
    });

    test('status', () {
      expect(uiStatusLabel('pending'), 'Pendente');
      expect(uiStatusLabel('running'), 'Em execução');
      expect(uiStatusLabel('completed'), 'Concluído');
      expect(uiStatusLabel('offline'), 'Desconectado');
    });

    test('contract chip', () {
      expect(uiContractChip(available: true), 'Ativo');
      expect(uiContractChip(available: false), 'Em preparação');
    });
  });
}
