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
}
