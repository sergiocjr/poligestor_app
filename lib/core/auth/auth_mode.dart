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

  String get notificationsUnreadCountPath =>
      '$notificationsPath/unread-count';

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
  String get aiConversationsPath => '/v1/ai/conversations';

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
}
