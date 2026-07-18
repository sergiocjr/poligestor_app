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

  String get devicesPath => switch (this) {
        AuthMode.staff => '/v1/devices',
        AuthMode.portal => '/v1/portal/devices',
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

  String get aiChatPath => switch (this) {
        AuthMode.staff => '/v1/ai/chat',
        AuthMode.portal => '/v1/portal/ai/chat',
      };
}
