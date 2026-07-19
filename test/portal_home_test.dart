import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/api/api_exception.dart';
import 'package:poligestor_app/core/ux/user_messages.dart';
import 'package:poligestor_app/features/citizen/data/portal_home_models.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';

Map<String, dynamic> sampleHomeJson({bool emptyLists = false}) {
  return {
    'user': {
      'id': 'u1',
      'nome': 'Cidadão Demo',
      'foto': null,
      'bairro': 'Taquaral',
      'cidade': 'Campinas',
    },
    'summary': {
      'protocolos_abertos': 1,
      'protocolos_andamento': 2,
      'protocolos_resolvidos': 3,
      'notificacoes_nao_lidas': 4,
      'proximos_compromissos': 1,
    },
    'quick_actions': emptyLists
        ? []
        : [
            {
              'key': 'ajuda',
              'title': 'Solicitar ajuda',
              'description': 'Abra um atendimento',
              'icon': 'help',
            },
          ],
    'recent_protocols': emptyLists
        ? []
        : [
            {
              'id': 'p1',
              'protocolo': 'PG-2026-000001',
              'titulo': 'Poste apagado',
              'categoria': 'iluminacao',
              'status': 'em_andamento',
              'ultima_atualizacao': '2026-07-18T03:32:22-03:00',
            },
          ],
    'appointments': emptyLists
        ? []
        : [
            {
              'id': 'a1',
              'title': 'Atendimento presencial',
              'type': 'appointment',
              'status': 'scheduled',
              'starts_at': '2026-07-19T14:30:00-03:00',
              'ends_at': '2026-07-19T15:00:00-03:00',
              'location': 'Gabinete',
            },
          ],
    'notifications': emptyLists
        ? []
        : [
            {
              'id': 'n1',
              'type': 'info',
              'title': 'Bem-vindo',
              'body': 'Olá',
              'data': null,
              'link': '/portal',
              'read_at': null,
              'created_at': '2026-07-17T00:31:39-03:00',
            },
          ],
    'assistant': {'message': 'Como posso ajudar você hoje?'},
  };
}

/// Espelha a deduplicação do [PortalHomeRepository] para teste isolado.
class _InFlightHomeLoader {
  _InFlightHomeLoader(this._delegate);

  final Future<PortalHomeData> Function() _delegate;
  Future<PortalHomeData>? _inFlight;
  int attempts = 0;

  Future<PortalHomeData> load() {
    if (_inFlight != null) return _inFlight!;
    _inFlight = () async {
      attempts++;
      return _delegate();
    }().whenComplete(() => _inFlight = null);
    return _inFlight!;
  }
}

void main() {
  group('PortalHomeData.fromJson', () {
    test('parse completo da resposta', () {
      final home = PortalHomeData.fromJson(sampleHomeJson());

      expect(home.user.nome, 'Cidadão Demo');
      expect(home.user.firstName, 'Cidadão');
      expect(home.user.bairro, 'Taquaral');
      expect(home.user.cidade, 'Campinas');
      expect(home.user.neighborhoodLabel, 'Taquaral · Campinas');

      expect(home.summary.protocolosAbertos, 1);
      expect(home.summary.protocolosAndamento, 2);
      expect(home.summary.protocolosResolvidos, 3);
      expect(home.summary.notificacoesNaoLidas, 4);
      expect(home.summary.proximosCompromissos, 1);

      expect(home.quickActions, hasLength(1));
      expect(home.quickActions.first.key, 'ajuda');
      expect(
        home.quickActions.first.toRequestCategory().label,
        'Solicitar ajuda',
      );

      expect(home.recentProtocols, hasLength(1));
      expect(home.recentProtocols.first.number, 'PG-2026-000001');
      expect(home.recentProtocols.first.title, 'Poste apagado');
      expect(
        ProtocolStatusLabel.pt(home.recentProtocols.first.status),
        'Em execução',
      );
      expect(ProtocolStatusLabel.pt('recebido'), 'Recebida');

      expect(home.appointments, hasLength(1));
      expect(home.appointments.first.location, 'Gabinete');
      expect(home.notifications, hasLength(1));
      expect(home.notifications.first.isUnread, isTrue);
      expect(home.assistant.message, 'Como posso ajudar você hoje?');
    });

    test('carregamento com sucesso (mapeamento Home)', () {
      final home = PortalHomeData.fromJson(sampleHomeJson());
      final actions = home.quickActions.isNotEmpty
          ? home.quickActions.map((e) => e.toRequestCategory()).toList()
          : RequestCategory.all;

      expect(actions, isNotEmpty);
      expect(home.recentProtocols, isNotEmpty);
      expect(home.summary.notificacoesNaoLidas, greaterThan(0));
    });

    test('resposta com listas vazias usa fallback de ações', () {
      final home = PortalHomeData.fromJson(sampleHomeJson(emptyLists: true));
      expect(home.quickActions, isEmpty);
      expect(home.recentProtocols, isEmpty);
      expect(home.appointments, isEmpty);
      expect(home.notifications, isEmpty);

      final actions = home.quickActions.isNotEmpty
          ? home.quickActions.map((e) => e.toRequestCategory()).toList()
          : RequestCategory.all;
      expect(actions, RequestCategory.all);
    });

    test('resposta inválida / parcial', () {
      final home = PortalHomeData.fromJson(<String, dynamic>{});
      expect(home.user.nome, 'Cidadão');
      expect(home.quickActions, isEmpty);
      expect(home.recentProtocols, isEmpty);
      expect(home.assistant.message, contains('ajudar'));
    });
  });

  group('mensagens amigáveis', () {
    test('não expõe 401 técnico', () {
      final msg = UserMessages.fromError(
        ApiException(message: 'Unauthenticated.', statusCode: 401),
      );
      expect(msg.toLowerCase().contains('401'), isFalse);
      expect(msg.toLowerCase().contains('unauthenticated'), isFalse);
      expect(
        UserMessages.homeUpdateFailed,
        'Não foi possível atualizar seus dados.',
      );
    });

    test('erro de rede', () {
      expect(
        UserMessages.fromError(
          ApiException(message: 'Sem conexão com o servidor.'),
        ),
        UserMessages.offline,
      );
    });
  });

  group('dedupe / refresh', () {
    test('ausência de chamadas duplicadas em voo', () async {
      var slowDone = false;
      final loader = _InFlightHomeLoader(() async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        slowDone = true;
        return PortalHomeData.fromJson(sampleHomeJson());
      });

      final a = loader.load();
      final b = loader.load();
      expect(identical(a, b), isTrue);

      final results = await Future.wait([a, b]);
      expect(slowDone, isTrue);
      expect(loader.attempts, 1);
      expect(results[0].user.nome, 'Cidadão Demo');
    });

    test('pull-to-refresh dispara nova carga após a anterior', () async {
      final loader = _InFlightHomeLoader(() async {
        return PortalHomeData.fromJson(sampleHomeJson());
      });

      await loader.load();
      expect(loader.attempts, 1);
      await loader.load();
      expect(loader.attempts, 2);
    });

    test('propaga erro de rede do delegate', () async {
      final loader = _InFlightHomeLoader(() async {
        throw ApiException(message: 'Sem conexão com o servidor.');
      });
      await expectLater(loader.load(), throwsA(isA<ApiException>()));
      expect(loader.attempts, 1);
    });
  });
}
