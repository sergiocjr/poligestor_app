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
      expect(m.financeIndicatorsPath, '/v1/finance/dashboard');
      expect(m.financeBalancePath, '/v1/finance/accounts');
      expect(m.financeRevenuesPath, '/v1/finance/transactions');
      expect(m.financeExpensesPath, '/v1/finance/transactions');
      expect(m.financeBankAccountsPath, '/v1/finance/accounts');
      expect(m.financeCategoriesPath, '/v1/finance/categories');
      expect(m.financeCostCentersPath, '/v1/finance/cost-centers');
      expect(m.financeSuppliersPath, '/v1/finance/payees');
      expect(m.financeContractsPath, '/v1/finance/transactions');
      expect(m.financeRefundsPath, '/v1/finance/payments');
      expect(m.financeAdvancesPath, '/v1/finance/payments');
      expect(m.financeFundsPath, '/v1/finance/budgets');
      expect(m.financeBudgetPath, '/v1/finance/budgets');
      expect(m.financeBudgetExecutionPath, '/v1/finance/budgets');
      expect(m.financeAccountabilityPath, '/v1/finance/reports');
      expect(m.financeReceiptsPath, '/v1/finance/payments');
      expect(m.financeAttachmentsPath, '/v1/finance/transactions');
      expect(m.financeApprovalsPath, '/v1/finance/payments');
      expect(m.financeReconciliationPath, '/v1/finance/cashflow');
      expect(m.financeCashFlowPath, '/v1/finance/cashflow');
      expect(m.financePayablesPath, '/v1/finance/transactions');
      expect(m.financeReceivablesPath, '/v1/finance/transactions');
      expect(m.financeAlertsPath, '/v1/finance/alerts');
      expect(m.financeHistoryPath, '/v1/finance/transactions');
      expect(m.financeFiltersPath, '/v1/finance/categories');
      expect(m.financeSearchPath, '/v1/finance/transactions');
      expect(m.financeReportsPath, '/v1/finance/reports');
      expect(m.financeExportsPath, '/v1/finance/reports');
      expect(m.financeTransactionsPath, '/v1/finance/transactions');
      expect(m.financePaymentsPath, '/v1/finance/payments');
    });
  });

  group('finance LIVE contracts', () {
    test('marks published VPS paths as live', () {
      expect(
        kFinanceLiveSlugs,
        containsAll([
          'dashboard',
          'categories',
          'cost-centers',
          'suppliers',
          'budget',
          'alerts',
          'reports',
          'bank-accounts',
          'cash-flow',
          'transactions',
          'payments',
        ]),
      );
      expect(financePathLive('dashboard'), isTrue);
      expect(financePathLive('transactions'), isTrue);
      expect(financePathLive('suppliers'), isTrue);
      expect(financePathLive('budget'), isTrue);
      expect(kFinanceLiveSlugs.length, 32);
      expect(financePathLive('balance'), isTrue);
      expect(financePathLive('exports'), isTrue);
    });
  });

  group('AuthMode Fase 14 LIVE path names', () {
    test('uses published VPS path spellings', () {
      const m = AuthMode.staff;
      expect(m.financeBankAccountsPath, '/v1/finance/accounts');
      expect(m.financeCashFlowPath, '/v1/finance/cashflow');
      expect(m.financeTransactionsPath, '/v1/finance/transactions');
      expect(m.financePaymentsPath, '/v1/finance/payments');
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
