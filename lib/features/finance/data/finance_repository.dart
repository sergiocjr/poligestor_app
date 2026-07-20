import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_mode.dart';
import '../../identity/data/identity_models.dart';
import 'finance_cache.dart';
import 'finance_models.dart';

/// Gestão Financeira — namespace oficial `/v1/finance/*` (Fase 14).
class FinanceRepository {
  FinanceRepository(this._api, {FinanceCache? cache})
    : _cache = cache ?? FinanceCache();

  final ApiClient _api;
  final FinanceCache _cache;
  static const _staff = AuthMode.staff;

  bool _pending(int? c) => c == 404 || c == 405 || c == 501 || c == 503;

  Map<String, dynamic> _rootOf(dynamic data, Map<String, dynamic>? meta) {
    final root = <String, dynamic>{
      'data': data is Map ? asFinanceMap(data) : data,
    };
    if (meta != null) root['meta'] = meta;
    return root;
  }

  Future<T> _cachedGet<T>({
    required String tenantSlug,
    required String cacheKey,
    required String path,
    required T Function(
      Map<String, dynamic> root, {
      bool fromCache,
      String? age,
    })
    parse,
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) async {
    try {
      final envelope = await _api.getEnvelope<dynamic>(
        path,
        mode: _staff,
        query: query,
        parse: (raw) => raw,
      );
      final root = _rootOf(envelope.data, envelope.meta);
      await _cache.putMap(tenantSlug, cacheKey, root);
      return parse(root, fromCache: false, age: null);
    } on ApiException catch (e) {
      if (_pending(e.statusCode)) {
        throw EndpointUnavailableException(path, statusCode: e.statusCode);
      }
      if (allowCache) {
        final cached = await _cache.getMap(tenantSlug, cacheKey);
        if (cached != null) {
          return parse(cached.data, fromCache: true, age: cached.ageLabel);
        }
      }
      rethrow;
    } catch (e) {
      if (e is EndpointUnavailableException) rethrow;
      if (allowCache) {
        final cached = await _cache.getMap(tenantSlug, cacheKey);
        if (cached != null) {
          return parse(cached.data, fromCache: true, age: cached.ageLabel);
        }
      }
      rethrow;
    }
  }

  List<FinanceItem> _itemsOf(Map<String, dynamic> root) {
    final data = root['data'];
    final list = data is List
        ? asFinanceMapList(data)
        : asFinanceMapList(asFinanceMap(data));
    return list.map(FinanceItem.fromJson).toList(growable: false);
  }

  Future<List<FinanceItem>> _list(
    String tenantSlug,
    String cacheKey,
    String path, {
    Map<String, dynamic>? query,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: cacheKey,
    path: path,
    query: query,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => _itemsOf(root),
  );

  Future<FinanceDashboard> dashboard({
    required String tenantSlug,
    bool allowCache = true,
  }) => _cachedGet(
    tenantSlug: tenantSlug,
    cacheKey: 'dashboard',
    path: _staff.financeDashboardPath,
    allowCache: allowCache,
    parse: (root, {fromCache = false, age}) => FinanceDashboard.fromJson(
      root,
      fromCache: fromCache,
      ageLabel: age,
    ),
  );

  Future<List<FinanceItem>> indicators({required String tenantSlug}) =>
      _list(tenantSlug, 'indicators', _staff.financeIndicatorsPath);

  Future<List<FinanceItem>> balance({required String tenantSlug}) =>
      _list(tenantSlug, 'balance', _staff.financeBalancePath);

  Future<List<FinanceItem>> revenues({required String tenantSlug}) =>
      _list(tenantSlug, 'revenues', _staff.financeRevenuesPath);

  Future<List<FinanceItem>> expenses({required String tenantSlug}) =>
      _list(tenantSlug, 'expenses', _staff.financeExpensesPath);

  Future<List<FinanceItem>> bankAccounts({required String tenantSlug}) =>
      _list(tenantSlug, 'bank_accounts', _staff.financeBankAccountsPath);

  Future<List<FinanceItem>> categories({required String tenantSlug}) =>
      _list(tenantSlug, 'categories', _staff.financeCategoriesPath);

  Future<List<FinanceItem>> costCenters({required String tenantSlug}) =>
      _list(tenantSlug, 'cost_centers', _staff.financeCostCentersPath);

  Future<List<FinanceItem>> suppliers({required String tenantSlug}) =>
      _list(tenantSlug, 'suppliers', _staff.financeSuppliersPath);

  Future<List<FinanceItem>> contracts({required String tenantSlug}) =>
      _list(tenantSlug, 'contracts', _staff.financeContractsPath);

  Future<List<FinanceItem>> refunds({required String tenantSlug}) =>
      _list(tenantSlug, 'refunds', _staff.financeRefundsPath);

  Future<List<FinanceItem>> advances({required String tenantSlug}) =>
      _list(tenantSlug, 'advances', _staff.financeAdvancesPath);

  Future<List<FinanceItem>> funds({required String tenantSlug}) =>
      _list(tenantSlug, 'funds', _staff.financeFundsPath);

  Future<List<FinanceItem>> budget({required String tenantSlug}) =>
      _list(tenantSlug, 'budget', _staff.financeBudgetPath);

  Future<List<FinanceItem>> budgetExecution({required String tenantSlug}) =>
      _list(
        tenantSlug,
        'budget_execution',
        _staff.financeBudgetExecutionPath,
      );

  Future<List<FinanceItem>> accountability({required String tenantSlug}) =>
      _list(tenantSlug, 'accountability', _staff.financeAccountabilityPath);

  Future<List<FinanceItem>> receipts({required String tenantSlug}) =>
      _list(tenantSlug, 'receipts', _staff.financeReceiptsPath);

  Future<List<FinanceItem>> attachments({required String tenantSlug}) =>
      _list(tenantSlug, 'attachments', _staff.financeAttachmentsPath);

  Future<List<FinanceItem>> approvals({required String tenantSlug}) =>
      _list(tenantSlug, 'approvals', _staff.financeApprovalsPath);

  Future<List<FinanceItem>> reconciliation({required String tenantSlug}) =>
      _list(tenantSlug, 'reconciliation', _staff.financeReconciliationPath);

  Future<List<FinanceItem>> cashFlow({required String tenantSlug}) =>
      _list(tenantSlug, 'cash_flow', _staff.financeCashFlowPath);

  Future<List<FinanceItem>> payables({required String tenantSlug}) =>
      _list(tenantSlug, 'payables', _staff.financePayablesPath);

  Future<List<FinanceItem>> receivables({required String tenantSlug}) =>
      _list(tenantSlug, 'receivables', _staff.financeReceivablesPath);

  Future<List<FinanceItem>> alerts({required String tenantSlug}) =>
      _list(tenantSlug, 'alerts', _staff.financeAlertsPath);

  Future<List<FinanceItem>> history({required String tenantSlug}) =>
      _list(tenantSlug, 'history', _staff.financeHistoryPath);

  Future<List<FinanceItem>> filters({required String tenantSlug}) =>
      _list(tenantSlug, 'filters', _staff.financeFiltersPath);

  Future<List<FinanceItem>> search({
    required String tenantSlug,
    required String query,
  }) => _list(
    tenantSlug,
    'search_${query.hashCode}',
    _staff.financeSearchPath,
    query: {'q': query},
  );

  Future<List<FinanceItem>> reports({required String tenantSlug}) =>
      _list(tenantSlug, 'reports', _staff.financeReportsPath);

  Future<List<FinanceItem>> exports({required String tenantSlug}) =>
      _list(tenantSlug, 'exports', _staff.financeExportsPath);
}
