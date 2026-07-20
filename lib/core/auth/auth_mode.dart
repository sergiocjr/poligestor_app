enum AuthMode {
  staff,
  portal;

  String get label => switch (this) {
    AuthMode.staff => 'Operador',
    AuthMode.portal => 'Cidadão',
  };

  String get loginPath => switch (this) {
    AuthMode.staff => '/v1/auth/login',
    AuthMode.portal => '/v1/portal/auth/login',
  };

  String get refreshPath => switch (this) {
    AuthMode.staff => '/v1/auth/refresh',
    AuthMode.portal => '/v1/portal/auth/refresh',
  };

  String get mePath => switch (this) {
    AuthMode.staff => '/v1/auth/me',
    AuthMode.portal => '/v1/portal/auth/me',
  };

  /// Alias de registro: `POST …/devices` (contrato também aceita `/devices/register`).
  String get devicesPath => switch (this) {
    AuthMode.staff => '/v1/devices',
    AuthMode.portal => '/v1/portal/devices',
  };

  String get devicesRegisterPath => switch (this) {
    AuthMode.staff => '/v1/devices/register',
    AuthMode.portal => '/v1/portal/devices/register',
  };

  String get devicesCurrentPath => switch (this) {
    AuthMode.staff => '/v1/devices/current',
    AuthMode.portal => '/v1/portal/devices/current',
  };

  String get protocolsPath => switch (this) {
    AuthMode.staff => '/v1/protocols',
    AuthMode.portal => '/v1/portal/protocols',
  };

  String get eventsPath => switch (this) {
    AuthMode.staff => '/v1/events',
    AuthMode.portal => '/v1/portal/appointments',
  };

  String get notificationsPath => switch (this) {
    AuthMode.staff => '/v1/notifications',
    AuthMode.portal => '/v1/portal/notifications',
  };

  String get notificationsUnreadCountPath => '$notificationsPath/unread-count';

  String get notificationsReadAllPath => '$notificationsPath/read-all';

  String notificationReadPath(dynamic id) => '$notificationsPath/$id/read';

  String get notificationPreferencesPath => switch (this) {
    AuthMode.staff => '/v1/notification-preferences',
    AuthMode.portal => '/v1/portal/notification-preferences',
  };

  String protocolReadPath(dynamic id) => '$protocolsPath/$id/read';

  /// Canal privado do usuário autenticado (contrato Reverb).
  String privateUserChannel(dynamic userId) => switch (this) {
    AuthMode.staff => 'private-user.$userId',
    AuthMode.portal => 'private-portal-user.$userId',
  };

  String get aiChatPath => switch (this) {
    AuthMode.staff => '/v1/ai/chat',
    AuthMode.portal => '/v1/portal/assistant/message',
  };

  // --- Sprint 10.5: Assistente Inteligente (staff hub) ---
  String get aiConversationsPath => '/v1/ai/conversations';
  String get aiHistoryPath => '/v1/ai/history';
  String get aiFavoritesPath => '/v1/ai/favorites';
  String get aiQuestionsPath => '/v1/ai/questions';
  String get aiSharePath => '/v1/ai/share';
  String get mandateSuggestionsPath => '/v1/mandate/suggestions';
  String get mandatePrioritiesPath => '/v1/mandate/priorities';
  String get mandateSummaryDailyPath => '/v1/mandate/summary/daily';
  String get mandateSummaryWeeklyPath => '/v1/mandate/summary/weekly';

  // --- Sprint 10.6: Automação Inteligente (staff) — namespace dedicado (ainda pending VPS) ---
  String get automationsRootPath => '/v1/automations';
  String get automationsDashboardPath => '/v1/automations/dashboard';
  String get automationsExecutionsPath => '/v1/automations/executions';
  String get automationsApprovalsPath => '/v1/automations/approvals';
  String get automationsAlertsPath => '/v1/automations/alerts';
  String get automationsMetricsPath => '/v1/automations/metrics';
  String get automationsSchedulePath => '/v1/automations/schedule';
  String get automationsLogsPath => '/v1/automations/logs';
  String automationPath(String id) => '/v1/automations/$id';
  String get automationsAutonomyPath => '/v1/automations/autonomy';

  // --- Sprint 10.7: Painel Estratégico (staff) ---
  String get strategyRootPath => '/v1/strategy';
  String get strategyDashboardPath => '/v1/strategy/dashboard';
  String get strategyKpisPath => '/v1/strategy/kpis';
  String get strategyHeatmapPath => '/v1/strategy/heatmap';
  String get strategyTrendsPath => '/v1/strategy/trends';
  String get strategyGoalsPath => '/v1/strategy/goals';
  String get strategyAlertsPath => '/v1/strategy/alerts';
  String get strategyComparePath => '/v1/strategy/compare';
  String get strategyForecastsPath => '/v1/strategy/forecasts';
  String get strategyRegionsPath => '/v1/strategy/regions';
  String get strategyNeighborhoodsPath => '/v1/strategy/neighborhoods';
  String get strategyReportsPath => '/v1/strategy/reports';
  String get strategyMapPath => '/v1/strategy/map';
  String get strategyIndicatorsPath => '/v1/strategy/indicators';
  String get strategyPredictionsPath => '/v1/strategy/predictions';

  // --- Fase 14: Gestão Financeira do Mandato (staff) — `/v1/finance/*` ---
  String get financeRootPath => '/v1/finance';
  String get financeDashboardPath => '/v1/finance/dashboard';
  String get financeIndicatorsPath => '/v1/finance/indicators';
  String get financeBalancePath => '/v1/finance/balance';
  String get financeRevenuesPath => '/v1/finance/revenues';
  String get financeExpensesPath => '/v1/finance/expenses';
  String get financeBankAccountsPath => '/v1/finance/bank-accounts';
  String get financeCategoriesPath => '/v1/finance/categories';
  String get financeCostCentersPath => '/v1/finance/cost-centers';
  String get financeSuppliersPath => '/v1/finance/suppliers';
  String get financeContractsPath => '/v1/finance/contracts';
  String get financeRefundsPath => '/v1/finance/refunds';
  String get financeAdvancesPath => '/v1/finance/advances';
  String get financeFundsPath => '/v1/finance/funds';
  String get financeBudgetPath => '/v1/finance/budget';
  String get financeBudgetExecutionPath => '/v1/finance/budget-execution';
  String get financeAccountabilityPath => '/v1/finance/accountability';
  String get financeReceiptsPath => '/v1/finance/receipts';
  String get financeAttachmentsPath => '/v1/finance/attachments';
  String get financeApprovalsPath => '/v1/finance/approvals';
  String get financeReconciliationPath => '/v1/finance/reconciliation';
  String get financeCashFlowPath => '/v1/finance/cash-flow';
  String get financePayablesPath => '/v1/finance/payables';
  String get financeReceivablesPath => '/v1/finance/receivables';
  String get financeAlertsPath => '/v1/finance/alerts';
  String get financeHistoryPath => '/v1/finance/history';
  String get financeFiltersPath => '/v1/finance/filters';
  String get financeSearchPath => '/v1/finance/search';
  String get financeReportsPath => '/v1/finance/reports';
  String get financeExportsPath => '/v1/finance/exports';

  // --- Fase 13: Gestão Documental (staff) — namespace oficial `/v1/documents/*` ---
  String get documentsRootPath => '/v1/documents';
  /// Lista oficial publicada: `GET /v1/documents/list` (também existe `GET /v1/documents`).
  String get documentsListPath => '/v1/documents/list';
  String documentsItemPath(String id) => '/v1/documents/$id';
  String get documentsSearchPath => '/v1/documents/search';
  String get documentsFiltersPath => '/v1/documents/filters';
  String get documentsCategoriesPath => '/v1/documents/categories';
  String get documentsFavoritesPath => '/v1/documents/favorites';
  String get documentsHistoryPath => '/v1/documents/history';
  String get documentsTimelinePath => '/v1/documents/timeline';
  String get documentsViewerPath => '/v1/documents/viewer';
  String get documentsSignaturesPath => '/v1/documents/signatures';
  String get documentsApprovalsPath => '/v1/documents/approvals';
  String get documentsSharePath => '/v1/documents/share';
  String get documentsTemplatesPath => '/v1/documents/templates';
  String get documentsDownloadPath => '/v1/documents/download';
  String get documentsUploadPath => '/v1/documents/upload';
  String get documentsAttachmentsPath => '/v1/documents/attachments';

  // --- Fase 12: Inteligência Territorial (staff) — namespace oficial `/v1/intelligence/*` ---
  String get intelligenceRootPath => '/v1/intelligence';
  String get intelligenceDashboardPath => '/v1/intelligence/dashboard';
  String get intelligenceBiPath => '/v1/intelligence/bi';
  String get intelligenceKpisPath => '/v1/intelligence/kpis';
  String get intelligenceIndicatorsPath => '/v1/intelligence/indicators';
  String get intelligenceChartsPath => '/v1/intelligence/charts';
  String get intelligenceHeatmapPath => '/v1/intelligence/heatmap';
  String get intelligenceMapPath => '/v1/intelligence/map';
  String get intelligenceNeighborhoodsPath => '/v1/intelligence/neighborhoods';
  String get intelligenceRegionsPath => '/v1/intelligence/regions';
  String get intelligenceElectoralZonesPath => '/v1/intelligence/electoral-zones';
  String get intelligenceLeadershipsPath => '/v1/intelligence/leaderships';
  String get intelligenceDemandsPath => '/v1/intelligence/demands';
  String get intelligenceWorksPath => '/v1/intelligence/works';
  String get intelligenceProtocolsPath => '/v1/intelligence/protocols';
  String get intelligenceAttendancesPath => '/v1/intelligence/attendances';
  String get intelligenceComparativesPath => '/v1/intelligence/comparatives';
  String get intelligenceEvolutionPath => '/v1/intelligence/evolution';
  String get intelligenceTrendsPath => '/v1/intelligence/trends';
  String get intelligenceProjectionsPath => '/v1/intelligence/projections';
  String get intelligenceFiltersPath => '/v1/intelligence/filters';
  String get intelligenceExportsPath => '/v1/intelligence/exports';

  // --- Sprint 10.8: Painel Parlamentar (staff) ---
  String get parliamentRootPath => '/v1/parliament';
  String get parliamentDashboardPath => '/v1/parliament/dashboard';
  String get parliamentBillsPath => '/v1/parliament/bills';
  String parliamentBillPath(String id) => '/v1/parliament/bills/$id';
  String get parliamentProjectsPath => '/v1/parliament/projects';
  String parliamentProjectPath(String id) => '/v1/parliament/projects/$id';
  String get parliamentIndicationsPath => '/v1/parliament/indications';
  String parliamentIndicationPath(String id) =>
      '/v1/parliament/indications/$id';
  String get parliamentRequestsPath => '/v1/parliament/requests';
  String parliamentRequestPath(String id) => '/v1/parliament/requests/$id';
  String get parliamentMotionsPath => '/v1/parliament/motions';
  String parliamentMotionPath(String id) => '/v1/parliament/motions/$id';
  String get parliamentAmendmentsPath => '/v1/parliament/amendments';
  String parliamentAmendmentPath(String id) => '/v1/parliament/amendments/$id';
  String get parliamentAgendaPath => '/v1/parliament/agenda';
  String get parliamentSessionsPath => '/v1/parliament/sessions';
  String parliamentSessionPath(String id) => '/v1/parliament/sessions/$id';
  String get parliamentVotesPath => '/v1/parliament/votes';
  String get parliamentPromisesPath => '/v1/parliament/promises';
  String get parliamentSupportBasePath => '/v1/parliament/support-base';
  String get parliamentDemandsPath => '/v1/parliament/demands';
  String get parliamentSearchPath => '/v1/parliament/search';
  String get parliamentTimelinePath => '/v1/parliament/timeline';
  String get parliamentHistoryPath => '/v1/parliament/history';
  String get parliamentAttachmentsPath => '/v1/parliament/attachments';

  // --- Sprint 10.9: Painel Obras (staff) — namespace dedicado (ainda pending VPS) ---
  String get worksRootPath => '/v1/works';
  String get worksDashboardPath => '/v1/works/dashboard';
  String get worksListPath => '/v1/works/projects';
  String worksItemPath(String id) => '/v1/works/projects/$id';
  String get worksDemandsPath => '/v1/works/demands';
  String get worksInspectionsPath => '/v1/works/inspections';
  String get worksSchedulePath => '/v1/works/schedule';
  String get worksMapPath => '/v1/works/map';
  String get worksTimelinePath => '/v1/works/timeline';
  String get worksPhotosPath => '/v1/works/photos';
  String get worksAttachmentsPath => '/v1/works/attachments';
  String get worksChecklistPath => '/v1/works/checklist';
  String get worksIndicatorsPath => '/v1/works/indicators';
  String get worksReportsPath => '/v1/works/reports';
  String get worksSearchPath => '/v1/works/search';

  // --- Sprint 11.0: Painel de Convênios (staff) — namespace LIVE `/v1/grants/*` ---
  String get agreementsRootPath => '/v1/grants';
  String get agreementsDashboardPath => '/v1/grants/dashboard';
  String get agreementsListPath => '/v1/grants/agreements';
  String agreementsItemPath(String id) => '/v1/grants/agreements/$id';
  String get agreementsResourcesPath => '/v1/grants/resources';
  String get agreementsProjectsPath => '/v1/grants/projects';
  String get agreementsExecutionPath => '/v1/grants/execution';
  String get agreementsAccountabilityPath => '/v1/grants/accountability';
  String get agreementsSchedulePath => '/v1/grants/schedule';
  String get agreementsTimelinePath => '/v1/grants/timeline';
  String get agreementsDocumentsPath => '/v1/grants/documents';
  String get agreementsAttachmentsPath => '/v1/grants/attachments';
  String get agreementsIndicatorsPath => '/v1/grants/indicators';
  String get agreementsReportsPath => '/v1/grants/reports';
  String get agreementsSearchPath => '/v1/grants/search';

  // --- Fase 11: Gestão Institucional — Painel de Eventos (staff) — namespace `/v1/events` ---
  String get eventsRootPath => '/v1/events';
  String get eventsDashboardPath => '/v1/events/dashboard';
  String get eventsListPath => '/v1/events';
  String eventsItemPath(String id) => '/v1/events/$id';
  String get eventsAgendaPath => '/v1/events/agenda';
  String get eventsCalendarPath => '/v1/events/calendar';
  String get eventsAudiencesPath => '/v1/events/audiences';
  String get eventsMeetingsPath => '/v1/events/meetings';
  String get eventsParticipantsPath => '/v1/events/participants';
  String get eventsInvitesPath => '/v1/events/invites';
  String get eventsAttendancePath => '/v1/events/attendance';
  String get eventsCheckInPath => '/v1/events/check-in';
  String get eventsCheckOutPath => '/v1/events/check-out';
  String get eventsQrCodePath => '/v1/events/qr-code';
  String get eventsGalleryPath => '/v1/events/gallery';
  String get eventsPhotosPath => '/v1/events/photos';
  String get eventsVideosPath => '/v1/events/videos';
  String get eventsDocumentsPath => '/v1/events/documents';
  String get eventsCertificatesPath => '/v1/events/certificates';
  String get eventsTimelinePath => '/v1/events/timeline';
  String get eventsReportsPath => '/v1/events/reports';
  String get eventsIndicatorsPath => '/v1/events/indicators';
  String get eventsSearchPath => '/v1/events/search';
  String get eventsMapPath => '/v1/events/map';

  // --- Fase 8: Mandato (staff) ---
  String get mandateExecutivePath => '/v1/mandate/executive';
  String get mandateMapPath => '/v1/mandate/map';
  String get mandateTeamPath => '/v1/mandate/team';
  String get mandateNeighborhoodsPath => '/v1/mandate/neighborhoods';
  String get mandateSubjectsPath => '/v1/mandate/subjects';
  String get mandateSearchPath => '/v1/mandate/search';
  String get mandateReportsPath => '/v1/mandate/reports';
  String get mandateTvPath => '/v1/mandate/tv';
  String get mandateAgendaPath => '/v1/mandate/agenda';
  String get mandateBriefingPath => '/v1/mandate/briefing';

  // --- Fase 9: Inteligência do mandato (staff) ---
  String get mandateAnalyticsPath => '/v1/mandate/analytics';
  String get mandateTrendsPath => '/v1/mandate/trends';
  String get mandateInsightsPath => '/v1/mandate/insights';
  String get mandateBriefingsPath => '/v1/mandate/briefings';

  // --- Sprint 10.1: Equipe Virtual (staff) ---
  String get virtualTeamRootPath => '/v1/virtual-team';
  String get virtualTeamDashboardPath => '/v1/virtual-team/dashboard';
  String get virtualTeamAgentsPath => '/v1/virtual-team/agents';
  String virtualTeamAgentPath(String slug) => '/v1/virtual-team/agents/$slug';
  String virtualTeamAgentTasksPath(String slug) =>
      '/v1/virtual-team/agents/$slug/tasks';
  String virtualTeamAgentExecutionsPath(String slug) =>
      '/v1/virtual-team/agents/$slug/executions';
  String virtualTeamAgentLogsPath(String slug) =>
      '/v1/virtual-team/agents/$slug/logs';
  String virtualTeamAgentMetricsPath(String slug) =>
      '/v1/virtual-team/agents/$slug/metrics';
  String virtualTeamAgentTimelinePath(String slug) =>
      '/v1/virtual-team/agents/$slug/timeline';
  String get virtualTeamTasksPath => '/v1/virtual-team/tasks';
  String get virtualTeamExecutionsPath => '/v1/virtual-team/executions';
  String get virtualTeamEventsPath => '/v1/virtual-team/events';
  String get virtualTeamMemoryPath => '/v1/virtual-team/memory';
  String get virtualTeamLearningPath => '/v1/virtual-team/learning';
  String get virtualTeamQueuePath => '/v1/virtual-team/queue';
  String get virtualTeamLogsPath => '/v1/virtual-team/logs';
  String get virtualTeamAuditPath => '/v1/virtual-team/audit';
  String get virtualTeamSearchPath => '/v1/virtual-team/search';
  String get virtualTeamMetricsPath => '/v1/virtual-team/metrics';
  String get virtualTeamTimelinePath => '/v1/virtual-team/timeline';
  String get virtualTeamAlertsPath => '/v1/virtual-team/alerts';
  String get virtualTeamHandoffsPath => '/v1/virtual-team/handoffs';
  // Catálogo legado (namespace /v1/ai)
  String get aiAgentsCatalogPath => '/v1/ai/agents';
  String get aiTeamPath => '/v1/ai/team';
  String get aiHandoffsPath => '/v1/ai/handoffs';

  // --- Sprint 10.2: Identidade / sessão ---
  String get logoutPath => switch (this) {
    AuthMode.staff => '/v1/auth/logout',
    AuthMode.portal => '/v1/portal/auth/logout',
  };

  String get sessionsPath => switch (this) {
    AuthMode.staff => '/v1/auth/sessions',
    AuthMode.portal => '/v1/portal/auth/sessions',
  };

  String sessionPath(String sessionId) => '$sessionsPath/$sessionId';

  String get sessionsRevokeAllPath => '$sessionsPath/revoke-all';

  String get authProvidersPath => switch (this) {
    AuthMode.staff => '/v1/auth/providers',
    AuthMode.portal => '/v1/portal/auth/providers',
  };

  String get registerPath => switch (this) {
    AuthMode.staff => '/v1/auth/register',
    AuthMode.portal => '/v1/portal/auth/register',
  };

  String get forgotPasswordPath => switch (this) {
    AuthMode.staff => '/v1/auth/forgot-password',
    AuthMode.portal => '/v1/portal/auth/forgot-password',
  };

  String get resetPasswordPath => switch (this) {
    AuthMode.staff => '/v1/auth/reset-password',
    AuthMode.portal => '/v1/portal/auth/reset-password',
  };

  String get linkedAccountsPath => switch (this) {
    AuthMode.staff => '/v1/auth/linked-accounts',
    AuthMode.portal => '/v1/portal/auth/linked-accounts',
  };

  String get profilePath => switch (this) {
    AuthMode.staff => '/v1/auth/profile',
    AuthMode.portal => '/v1/portal/auth/profile',
  };

  String get oauthGooglePath => switch (this) {
    AuthMode.staff => '/v1/auth/google',
    AuthMode.portal => '/v1/portal/auth/google',
  };

  String get oauthApplePath => switch (this) {
    AuthMode.staff => '/v1/auth/apple',
    AuthMode.portal => '/v1/portal/auth/apple',
  };

  String get oauthGovBrPath => switch (this) {
    AuthMode.staff => '/v1/auth/govbr',
    AuthMode.portal => '/v1/portal/auth/govbr',
  };

  /// Branding do tenant (portal — rota detectada na VPS).
  String get brandingPath => '/v1/portal/branding';

  /// Resolução de organização (pública — rota detectada na VPS).
  String get tenantsResolvePath => '/v1/identity/tenants/resolve';

  /// Central de Comunicação (PoliGestor) — contratos LIVE staff.
  String get communicationChannelsPath => '/v1/channels';
  String get communicationTemplatesPath => '/v1/templates';
  String get communicationCampaignsPath => '/v1/campaigns';

  /// Omnichannel LIVE (Sprint 10.4 sync).
  String get communicationConversationsPath => '/v1/omnichannel/conversations';
  String get communicationQueuePath => '/v1/omnichannel/queue';
  String get communicationOperatorsPath => '/v1/omnichannel/operators';
}
