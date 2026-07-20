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
  /// LIVE VPS: `GET /v1/finance/accounts`
  String get financeBankAccountsPath => '/v1/finance/accounts';
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
  /// LIVE VPS: `GET /v1/finance/cashflow`
  String get financeCashFlowPath => '/v1/finance/cashflow';
  String get financePayablesPath => '/v1/finance/payables';
  String get financeReceivablesPath => '/v1/finance/receivables';
  String get financeAlertsPath => '/v1/finance/alerts';
  String get financeHistoryPath => '/v1/finance/history';
  String get financeFiltersPath => '/v1/finance/filters';
  String get financeSearchPath => '/v1/finance/search';
  String get financeReportsPath => '/v1/finance/reports';
  String get financeExportsPath => '/v1/finance/exports';
  /// LIVE VPS: `GET /v1/finance/transactions`
  String get financeTransactionsPath => '/v1/finance/transactions';
  /// LIVE VPS: `GET /v1/finance/payments`
  String get financePaymentsPath => '/v1/finance/payments';

  // --- Fase 15: Comunicação Institucional (staff) — `/v1/communication/*` ---
  String get institutionalCommunicationRootPath => '/v1/communication';
  String get institutionalCommunicationFeedPath => '/v1/communication/feed';
  String get institutionalCommunicationAnnouncementsPath =>
      '/v1/communication/announcements';
  String get institutionalCommunicationCampaignsPath =>
      '/v1/communication/campaigns';
  String get institutionalCommunicationMediaPath => '/v1/communication/media';
  String get institutionalCommunicationPublicationsPath =>
      '/v1/communication/publications';
  String get institutionalCommunicationSchedulePath =>
      '/v1/communication/schedule';
  String get institutionalCommunicationPushPath => '/v1/communication/push';
  String get institutionalCommunicationEmailPath => '/v1/communication/email';
  String get institutionalCommunicationWhatsappPath =>
      '/v1/communication/whatsapp';
  String get institutionalCommunicationHistoryPath =>
      '/v1/communication/history';
  String get institutionalCommunicationSearchPath =>
      '/v1/communication/search';
  String get institutionalCommunicationFiltersPath =>
      '/v1/communication/filters';
  String get institutionalCommunicationSharePath => '/v1/communication/share';
  String get institutionalCommunicationReportsPath =>
      '/v1/communication/reports';

  // --- Fase 16: CRM Político (staff) — `/v1/crm/*` ---
  String get crmRootPath => '/v1/crm';
  String get crmDashboardPath => '/v1/crm/dashboard';
  String get crmLeadersPath => '/v1/crm/leaders';
  String get crmSupportersPath => '/v1/crm/supporters';
  String get crmVotersPath => '/v1/crm/voters';
  String get crmVolunteersPath => '/v1/crm/volunteers';
  String get crmTeamPath => '/v1/crm/team';
  String get crmEntitiesPath => '/v1/crm/entities';
  String get crmAssociationsPath => '/v1/crm/associations';
  String get crmChurchesPath => '/v1/crm/churches';
  String get crmCompaniesPath => '/v1/crm/companies';
  String get crmInfluencersPath => '/v1/crm/influencers';
  String get crmSegmentationPath => '/v1/crm/segmentation';
  String get crmTagsPath => '/v1/crm/tags';
  String get crmGroupsPath => '/v1/crm/groups';
  String get crmRegionsPath => '/v1/crm/regions';
  String get crmNeighborhoodsPath => '/v1/crm/neighborhoods';
  String get crmElectoralZonesPath => '/v1/crm/electoral-zones';
  String get crmRelationshipHistoryPath => '/v1/crm/relationship-history';
  String get crmInteractionsPath => '/v1/crm/interactions';
  String get crmVisitsPath => '/v1/crm/visits';
  String get crmCallsPath => '/v1/crm/calls';
  String get crmMessagesPath => '/v1/crm/messages';
  String get crmMeetingsPath => '/v1/crm/meetings';
  String get crmLinkedDemandsPath => '/v1/crm/linked-demands';
  String get crmLinkedProtocolsPath => '/v1/crm/linked-protocols';
  String get crmCampaignsPath => '/v1/crm/campaigns';
  String get crmTasksPath => '/v1/crm/tasks';
  String get crmRemindersPath => '/v1/crm/reminders';
  String get crmSupportLevelPath => '/v1/crm/support-level';
  String get crmInfluencePotentialPath => '/v1/crm/influence-potential';
  String get crmRelationshipsPath => '/v1/crm/relationships';
  String get crmImportPath => '/v1/crm/import';
  String get crmExportPath => '/v1/crm/export';
  String get crmSearchPath => '/v1/crm/search';
  String get crmFiltersPath => '/v1/crm/filters';
  String get crmIndicatorsPath => '/v1/crm/indicators';
  String get crmReportsPath => '/v1/crm/reports';

  // --- Fase 17: Gestão Eleitoral (staff) — `/v1/elections/*` ---
  String get electionsRootPath => '/v1/elections';
  String get electionsDashboardPath => '/v1/elections/dashboard';
  String get electionsPreCampaignPath => '/v1/elections/pre-campaign';
  String get electionsCampaignsPath => '/v1/elections/campaigns';
  String get electionsCandidatesPath => '/v1/elections/candidates';
  String get electionsCoordinationPath => '/v1/elections/coordination';
  String get electionsTeamsPath => '/v1/elections/teams';
  String get electionsCanvassersPath => '/v1/elections/canvassers';
  String get electionsVolunteersPath => '/v1/elections/volunteers';
  String get electionsLeadersPath => '/v1/elections/leaders';
  String get electionsSupportersPath => '/v1/elections/supporters';
  String get electionsGoalsPath => '/v1/elections/goals';
  String get electionsRegionsPath => '/v1/elections/regions';
  String get electionsNeighborhoodsPath => '/v1/elections/neighborhoods';
  String get electionsElectoralZonesPath => '/v1/elections/electoral-zones';
  String get electionsElectoralSectionsPath =>
      '/v1/elections/electoral-sections';
  String get electionsPollingStationsPath => '/v1/elections/polling-stations';
  String get electionsMapPath => '/v1/elections/map';
  String get electionsCampaignAgendaPath => '/v1/elections/campaign-agenda';
  String get electionsEventsPath => '/v1/elections/events';
  String get electionsWalksPath => '/v1/elections/walks';
  String get electionsMeetingsPath => '/v1/elections/meetings';
  String get electionsVisitsPath => '/v1/elections/visits';
  String get electionsRalliesPath => '/v1/elections/rallies';
  String get electionsMobilizationsPath => '/v1/elections/mobilizations';
  String get electionsCampaignMaterialsPath =>
      '/v1/elections/campaign-materials';
  String get electionsInventoryPath => '/v1/elections/inventory';
  String get electionsDistributionPath => '/v1/elections/distribution';
  String get electionsMaterialRequestsPath =>
      '/v1/elections/material-requests';
  String get electionsPollsPath => '/v1/elections/polls';
  String get electionsScenariosPath => '/v1/elections/scenarios';
  String get electionsVoteIntentionPath => '/v1/elections/vote-intention';
  String get electionsRejectionPath => '/v1/elections/rejection';
  String get electionsComparativesPath => '/v1/elections/comparatives';
  String get electionsProjectionsPath => '/v1/elections/projections';
  String get electionsRegionalPerformancePath =>
      '/v1/elections/regional-performance';
  String get electionsAccountabilityPath => '/v1/elections/accountability';
  String get electionsRevenuesPath => '/v1/elections/revenues';
  String get electionsExpensesPath => '/v1/elections/expenses';
  String get electionsDonationsPath => '/v1/elections/donations';
  String get electionsSuppliersPath => '/v1/elections/suppliers';
  String get electionsReceiptsPath => '/v1/elections/receipts';
  String get electionsReportsPath => '/v1/elections/reports';
  String get electionsExportsPath => '/v1/elections/exports';
  String get electionsSearchPath => '/v1/elections/search';
  String get electionsFiltersPath => '/v1/elections/filters';

  // --- Fase 18: IA Avançada (staff) — namespace oficial `/v1/ai/*` ---
  String get advancedAiRootPath => '/v1/ai';
  String get advancedAiBriefingsPath => '/v1/ai/briefings';
  String get advancedAiPromptsPath => '/v1/ai/prompts';
  String get advancedAiSummaryPath => '/v1/ai/summary';
  String get advancedAiSuggestionsPath => '/v1/ai/suggestions';
  String get advancedAiFeedbackPath => '/v1/ai/feedback';
  String get advancedAiSecretaryPath => '/v1/ai/secretary';
  String get advancedAiVirtualSecretaryPath => '/v1/ai/virtual-secretary';
  String get advancedAiParliamentaryAdvisorPath =>
      '/v1/ai/parliamentary-advisor';
  String get advancedAiPoliticalAnalystPath => '/v1/ai/political-analyst';
  String get advancedAiFinancialAnalystPath => '/v1/ai/financial-analyst';
  String get advancedAiCommunicationAdvisorPath =>
      '/v1/ai/communication-advisor';
  String get advancedAiLegalAdvisorPath => '/v1/ai/legal-advisor';
  String get advancedAiStrategicPlanningPath => '/v1/ai/strategic-planning';
  String get advancedAiDashboardPath => '/v1/ai/dashboard';
  String get advancedAiHubPath => '/v1/ai/hub';
  String get advancedAiSearchPath => '/v1/ai/search';
  String get advancedAiSettingsPath => '/v1/ai/settings';
  String get advancedAiPromptLibraryPath => '/v1/ai/prompt-library';
  String get advancedAiSummariesPath => '/v1/ai/summaries';
  String get advancedAiBriefingSingularPath => '/v1/ai/briefing';
  String get advancedAiInsightsPath => '/v1/ai/insights';

  // --- Fase 19: Administração do Sistema (staff) — `/v1/admin/*` ---
  String get adminRootPath => '/v1/admin';
  String get adminDashboardPath => '/v1/admin/dashboard';
  String get adminCompaniesPath => '/v1/admin/companies';
  String get adminOfficesPath => '/v1/admin/offices';
  String get adminUsersPath => '/v1/admin/users';
  String get adminProfilesPath => '/v1/admin/profiles';
  String get adminRolesPath => '/v1/admin/roles';
  String get adminPermissionsPath => '/v1/admin/permissions';
  String get adminTeamsPath => '/v1/admin/teams';
  String get adminDepartmentsPath => '/v1/admin/departments';
  String get adminSettingsPath => '/v1/admin/settings';
  String get adminLicensingPath => '/v1/admin/licensing';
  String get adminSubscriptionsPath => '/v1/admin/subscriptions';
  String get adminLogsPath => '/v1/admin/logs';
  String get adminAuditPath => '/v1/admin/audit';
  String get adminSessionsPath => '/v1/admin/sessions';
  String get adminApiKeysPath => '/v1/admin/api-keys';
  String get adminIntegrationsPath => '/v1/admin/integrations';
  String get adminWebhooksPath => '/v1/admin/webhooks';
  String get adminBackupPath => '/v1/admin/backup';
  String get adminMonitoringPath => '/v1/admin/monitoring';
  String get adminHealthPath => '/v1/admin/health';
  String get adminEmailSettingsPath => '/v1/admin/email-settings';
  String get adminNotificationSettingsPath =>
      '/v1/admin/notification-settings';
  String get adminStorageSettingsPath => '/v1/admin/storage-settings';
  String get adminReportsPath => '/v1/admin/reports';
  String get adminExportsPath => '/v1/admin/exports';
  String get adminSearchPath => '/v1/admin/search';
  String get adminFiltersPath => '/v1/admin/filters';

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
