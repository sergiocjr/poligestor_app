import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/api/api_exception.dart';
import 'package:poligestor_app/core/ux/user_messages.dart';
import 'package:poligestor_app/features/notifications/data/notifications_repository.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';
import 'package:poligestor_app/features/protocols/data/protocol_navigation.dart';
import 'package:poligestor_app/shared/widgets/app_states.dart';

void main() {
  group('ProtocolNavigationTarget', () {
    test('prioriza protocol_id válido', () {
      final t = ProtocolNavigationTarget.resolve(
        protocolId: 'abc-uuid-1',
        protocolNumber: 'PG-2026-001',
        link: '/portal/solicitacoes/ignored',
      );
      expect(t, isNotNull);
      expect(t!.protocolId, 'abc-uuid-1');
      expect(t.source, 'protocol_id');
      expect(t.citizenDetailPath, '/citizen/requests/abc-uuid-1');
    });

    test('não trata número PG- como protocol_id', () {
      final t = ProtocolNavigationTarget.resolve(
        protocolId: 'PG-2026-100',
        protocolNumber: null,
        link: null,
      );
      expect(t, isNotNull);
      expect(t!.source, 'protocol_number');
      expect(t.protocolId, 'PG-2026-100');
    });

    test('converte link web em rota interna', () {
      final t = ProtocolNavigationTarget.resolve(
        protocolId: null,
        protocolNumber: null,
        link: 'https://app.example.com/portal/solicitacoes/99',
      );
      expect(t, isNotNull);
      expect(t!.protocolId, '99');
      expect(t.source, 'link');
      expect(t.citizenDetailPath, '/citizen/requests/99');
    });

    test('payload sem protocolo retorna null', () {
      expect(
        ProtocolNavigationTarget.resolve(
          protocolId: null,
          protocolNumber: null,
          link: '/portal/home',
        ),
        isNull,
      );
    });
  });

  group('UserMessages.forProtocolError', () {
    test('nunca usa mensagem genérica de sincronização', () {
      expect(
        UserMessages.forProtocolError(ApiException(message: 'x', statusCode: 404)),
        UserMessages.protocolNotFound,
      );
      expect(
        UserMessages.forProtocolError(ApiException(message: 'x', statusCode: 403)),
        UserMessages.protocolNoAccess,
      );
      expect(
        UserMessages.forProtocolError(ApiException(message: 'x', statusCode: 500)),
        UserMessages.protocolOpenFailed,
      );
      expect(
        UserMessages.forProtocolError(
          ApiException(message: 'Falha de conexão', statusCode: null),
        ),
        UserMessages.offline,
      );
      expect(
        UserMessages.forProtocolError(Exception('timeout')),
        isNot(UserMessages.syncFailed),
      );
      expect(
        UserMessages.forProtocolError(ApiException(message: 'x', statusCode: 401)),
        isNot(UserMessages.syncFailed),
      );
    });
  });

  group('AppNotification protocol fields', () {
    test('não usa data.id genérico como protocol_id', () {
      final n = AppNotification.fromJson({
        'id': 55,
        'title': 'Nova mensagem',
        'type': 'new_message',
        'data': {
          'id': 55,
          'protocol_id': 'proto-9',
          'protocol_number': 'PG-2026-009',
        },
        'link': '/portal/solicitacoes/proto-9',
      });
      expect(n.protocolId, 'proto-9');
      expect(n.protocolNumber, 'PG-2026-009');
      final target = ProtocolNavigationTarget.resolve(
        protocolId: n.protocolId,
        protocolNumber: n.protocolNumber,
        link: n.link,
      );
      expect(target!.protocolId, 'proto-9');
    });

    test('fallback por protocol_number e link', () {
      final n = AppNotification.fromJson({
        'id': 1,
        'title': 'Aviso',
        'data': {'protocol_number': 'PG-2026-010'},
        'link': '/portal/protocols/uuid-10',
      });
      // fromJson já extrai id do link quando protocol_id ausente
      expect(n.protocolId, 'uuid-10');
      final target = ProtocolNavigationTarget.resolve(
        protocolId: n.protocolId,
        protocolNumber: n.protocolNumber,
        link: n.link,
      );
      expect(target!.protocolId, 'uuid-10');
      expect(target.citizenDetailPath, '/citizen/requests/uuid-10');
    });

    test('fallback só com protocol_number', () {
      final target = ProtocolNavigationTarget.resolve(
        protocolId: null,
        protocolNumber: 'PG-2026-010',
        link: null,
      );
      expect(target!.source, 'protocol_number');
      expect(target.protocolId, 'PG-2026-010');
    });
  });

  group('ProtocolDetail parse defensivo', () {
    test('campos opcionais ausentes não quebram', () {
      final detail = ProtocolDetail.fromJson({
        'id': 'min-1',
        'title': 'Mínimo',
      });
      expect(detail.messages, isEmpty);
      expect(detail.history, isEmpty);
      expect(detail.attachments, isEmpty);
      expect(detail.rating, isNull);
      expect(detail.unreadCount, 0);
      expect(detail.hasUnread, isFalse);
      expect(detail.awaitingCitizen, isFalse);
      expect(detail.canRate, isFalse);
    });

    test('comments/timeline/attachments/links null viram fallback', () {
      final detail = ProtocolDetail.fromJson({
        'id': 2,
        'title': 'Nullables',
        'comments': null,
        'timeline': null,
        'attachments': null,
        'links': null,
        'category': null,
        'rating': null,
        'last_public_message': null,
        'unread_count': null,
        'has_new_message': null,
        'awaiting_citizen': null,
        'can_reply': null,
        'can_attach': null,
        'can_rate': null,
      });
      expect(detail.messages, isEmpty);
      expect(detail.history, isEmpty);
      expect(detail.attachments, isEmpty);
      expect(detail.markReadUrl, isNull);
      expect(detail.rateUrl, isNull);
    });

    test('item inválido em comments não derruba parse', () {
      final detail = ProtocolDetail.fromJson({
        'id': 3,
        'title': 'Com lixo',
        'comments': [
          'string-invalida',
          {'id': 1, 'body': 'ok', 'author_role': 'staff'},
          {'id': 2}, // sem body
        ],
        'timeline': [
          123,
          {'id': 'h1', 'kind': 'received', 'created_at': '2026-07-18T10:00:00Z'},
        ],
        'attachments': [
          'x',
          {'id': 'a1', 'name': 'f.jpg', 'url': 'https://x/f.jpg'},
        ],
      });
      expect(detail.messages, hasLength(1));
      expect(detail.history, hasLength(1));
      expect(detail.attachments, hasLength(1));
    });
  });

  group('Request detail UI nunca vazia', () {
    testWidgets('loading mostra skeleton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Detalhes da solicitação')),
            body: const ColoredBox(
              color: Colors.white,
              child: SizedBox(
                key: Key('request_detail_loading'),
                height: 200,
                child: Center(child: Text('skeleton')),
              ),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('request_detail_loading')), findsOneWidget);
      expect(find.text('Detalhes da solicitação'), findsOneWidget);
    });

    testWidgets('erro mostra mensagem e tentar novamente', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Detalhes da solicitação')),
            body: AppErrorState(
              key: const Key('request_detail_error'),
              message: UserMessages.forProtocolError(
                ApiException(message: 'nf', statusCode: 404),
              ),
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      expect(find.text(UserMessages.protocolNotFound), findsOneWidget);
      expect(find.text(UserMessages.syncFailed), findsNothing);
      expect(find.text('Tentar novamente'), findsOneWidget);
      await tester.tap(find.text('Tentar novamente'));
      expect(retried, isTrue);
    });

    testWidgets('sucesso mínimo renderiza conteúdo', (tester) async {
      final detail = ProtocolDetail.fromJson({
        'id': 'ok',
        'title': 'Título OK',
        'number': 'PG-2026-OK',
        'status': 'recebido',
        'description': 'Desc',
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Detalhes da solicitação')),
            body: ListView(
              children: [
                Text(detail.title),
                Text(detail.number ?? ''),
                Text(ProtocolStatusLabel.pt(detail.status)),
                Text(detail.description ?? ''),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Título OK'), findsOneWidget);
      expect(find.text('PG-2026-OK'), findsOneWidget);
      expect(find.text('Desc'), findsOneWidget);
    });
  });
}
