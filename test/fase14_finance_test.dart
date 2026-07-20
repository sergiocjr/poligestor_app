import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/finance/data/finance_cache.dart';
import 'package:poligestor_app/features/finance/data/finance_contracts.dart';
import 'package:poligestor_app/features/finance/data/finance_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 14 finance paths', () {
    test('exposes official /v1/finance namespace', () {
      const m = AuthMode.staff;
      expect(m.financeRootPath, '/v1/finance');
      expect(m.financeDashboardPath, '/v1/finance/dashboard');
      expect(m.financeIndicatorsPath, '/v1/finance/indicators');
      expect(m.financeBalancePath, '/v1/finance/balance');
      expect(m.financeRevenuesPath, '/v1/finance/revenues');
      expect(m.financeExpensesPath, '/v1/finance/expenses');
      expect(m.financeBankAccountsPath, '/v1/finance/bank-accounts');
      expect(m.financeCategoriesPath, '/v1/finance/categories');
      expect(m.financeCostCentersPath, '/v1/finance/cost-centers');
      expect(m.financeSuppliersPath, '/v1/finance/suppliers');
      expect(m.financeContractsPath, '/v1/finance/contracts');
      expect(m.financeRefundsPath, '/v1/finance/refunds');
      expect(m.financeAdvancesPath, '/v1/finance/advances');
      expect(m.financeFundsPath, '/v1/finance/funds');
      expect(m.financeBudgetPath, '/v1/finance/budget');
      expect(m.financeBudgetExecutionPath, '/v1/finance/budget-execution');
      expect(m.financeAccountabilityPath, '/v1/finance/accountability');
      expect(m.financeReceiptsPath, '/v1/finance/receipts');
      expect(m.financeAttachmentsPath, '/v1/finance/attachments');
      expect(m.financeApprovalsPath, '/v1/finance/approvals');
      expect(m.financeReconciliationPath, '/v1/finance/reconciliation');
      expect(m.financeCashFlowPath, '/v1/finance/cash-flow');
      expect(m.financePayablesPath, '/v1/finance/payables');
      expect(m.financeReceivablesPath, '/v1/finance/receivables');
      expect(m.financeAlertsPath, '/v1/finance/alerts');
      expect(m.financeHistoryPath, '/v1/finance/history');
      expect(m.financeFiltersPath, '/v1/finance/filters');
      expect(m.financeSearchPath, '/v1/finance/search');
      expect(m.financeReportsPath, '/v1/finance/reports');
      expect(m.financeExportsPath, '/v1/finance/exports');
    });
  });

  group('finance LIVE contracts', () {
    test('no live slugs until VPS publishes', () {
      expect(kFinanceLiveSlugs, isEmpty);
      expect(financePathLive('dashboard'), isFalse);
      expect(financePathLive('cash-flow'), isFalse);
    });
  });

  group('finance models', () {
    test('parses dashboard summary', () {
      final d = FinanceDashboard.fromJson({
        'data': {
          'summary': {
            'balance': 1500.5,
            'revenues': 3000,
            'expenses': 1499.5,
            'alerts': 2,
          },
        },
      });
      expect(d.balance, 1500.5);
      expect(d.alerts, 2);
    });

    test('parses finance item', () {
      final item = FinanceItem.fromJson({
        'id': '1',
        'title': 'Despesa combustível',
        'amount': 120.0,
        'status': 'paid',
        'category': 'Transporte',
      });
      expect(item.title, 'Despesa combustível');
      expect(item.amount, 120.0);
      expect(item.category, 'Transporte');
    });
  });

  group('finance cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = FinanceCache();
      await cache.putMap('demo', 'dashboard', {
        'data': {
          'summary': {'balance': 1},
        },
      });
      expect(await cache.getMap('other', 'dashboard'), isNull);
      expect(await cache.getMap('demo', 'dashboard'), isNotNull);
    });
  });

  group('deep links finance', () {
    test('poligestor://gestao-financeira resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://gestao-financeira',
        ),
      );
      expect(target?.location, '/home/finance');
    });

    test('poligestor://financeiro/cash-flow', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://financeiro/cash-flow',
        ),
      );
      expect(target?.location, '/home/finance/cash-flow');
    });
  });
}
