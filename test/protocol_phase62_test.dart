import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/ux/user_messages.dart';
import 'package:poligestor_app/features/citizen/presentation/widgets/protocol_attendance_widgets.dart';
import 'package:poligestor_app/features/notifications/data/notifications_repository.dart';
import 'package:poligestor_app/features/protocols/data/protocol_models.dart';
import 'package:poligestor_app/features/protocols/data/protocols_repository.dart';

void main() {
  group('ProtocolDetail parsing (fase 6.2)', () {
    test('parseia conversa pública e oculta notas internas', () {
      final detail = ProtocolDetail.fromJson({
        'id': 7,
        'title': 'Buraco na rua',
        'number': '2026-001',
        'status': 'aguardando_cidadao',
        'priority': 'high',
        'category': 'denuncia',
        'created_at': '2026-07-18T10:00:00Z',
        'updated_at': '2026-07-18T15:00:00Z',
        'description': 'Há um buraco perigoso',
        'address': 'Rua das Flores, 100',
        'assignee_public': {'name': 'Gabinete — Atendimento'},
        'deadline_label': 'Até sexta-feira',
        'pending_question': 'Pode enviar uma foto do local?',
        'messages': [
          {
            'id': 1,
            'body': 'Olá, recebemos sua solicitação.',
            'author_name': 'Gabinete',
            'author_role': 'staff',
            'created_at': '2026-07-18T11:00:00Z',
            'is_unread': true,
          },
          {
            'id': 2,
            'body': 'nota interna secreta',
            'is_internal': true,
            'author_role': 'staff',
          },
          {
            'id': 3,
            'body': 'Segue a foto.',
            'author_name': 'Maria',
            'author_role': 'citizen',
            'created_at': '2026-07-18T12:00:00Z',
          },
        ],
        'history': [
          {
            'id': 'h1',
            'kind': 'received',
            'created_at': '2026-07-18T10:00:00Z',
          },
          {
            'id': 'h2',
            'kind': 'aguardando_cidadao',
            'created_at': '2026-07-18T14:00:00Z',
          },
          {
            'id': 'h3',
            'kind': 'internal_note',
            'title': 'Nota interna',
          },
        ],
        'attachments': [
          {
            'id': 'a1',
            'name': 'foto.jpg',
            'url': 'https://example.com/foto.jpg',
            'mime_type': 'image/jpeg',
          },
        ],
        'can_rate': false,
        'links': {
          'mark_read': '/v1/portal/protocols/7/read',
          'rate': '/v1/portal/protocols/7/rating',
        },
      });

      expect(detail.number, '2026-001');
      expect(detail.address, 'Rua das Flores, 100');
      expect(detail.publicAssignee, 'Gabinete — Atendimento');
      expect(detail.deadlineLabel, 'Até sexta-feira');
      expect(detail.isAwaitingCitizen, isTrue);
      expect(detail.pendingQuestion, contains('foto'));
      expect(detail.messages, hasLength(2));
      expect(detail.messages.any((m) => m.body.contains('secreta')), isFalse);
      expect(detail.messages.first.isFromCabinet, isTrue);
      expect(detail.messages.first.isUnread, isTrue);
      expect(detail.history, hasLength(2));
      expect(detail.history.first.title, 'Solicitação recebida');
      expect(detail.attachments.single.isImage, isTrue);
      expect(detail.markReadUrl, '/v1/portal/protocols/7/read');
      expect(detail.rateUrl, '/v1/portal/protocols/7/rating');
    });

    test('comments legado vira conversa e filtra interno', () {
      final detail = ProtocolDetail.fromJson({
        'id': 1,
        'title': 'Teste',
        'comments': [
          {'id': 1, 'body': 'Público', 'author_role': 'staff'},
          {'id': 2, 'body': 'Interno', 'visibility': 'internal'},
        ],
      });
      expect(detail.messages, hasLength(1));
      expect(detail.messages.single.body, 'Público');
    });

    test('status usa linguagem simples', () {
      expect(
        ProtocolStatusLabel.pt('aguardando_cidadao'),
        'Aguardando informação',
      );
      expect(ProtocolStatusLabel.pt('em_analise'), 'Em análise');
      expect(ProtocolPriorityLabel.pt('high'), 'Alta');
    });

    test('lista destaca não lidas e preview', () {
      final item = ProtocolSummary.fromJson({
        'id': 1,
        'title': 'Iluminação',
        'number': '9',
        'status': 'em_andamento',
        'unread_count': 2,
        'last_message_preview': 'Vamos verificar amanhã.',
        'updated_at': '2026-07-18T16:00:00Z',
      });
      expect(item.showUnreadBadge, isTrue);
      expect(item.lastMessagePreview, contains('verificar'));
    });
  });

  group('Notificações', () {
    test('classifica tipo e extrai protocol id do link', () {
      final n = AppNotification.fromJson({
        'id': 3,
        'title': 'Nova resposta do gabinete',
        'body': 'Há uma mensagem nova',
        'type': 'new_reply',
        'link': '/citizen/requests/42',
        'created_at': '2026-07-18T12:00:00Z',
      });
      expect(n.kind, NotificationKind.newReply);
      expect(n.protocolId, '42');
      expect(n.kindLabel, 'Nova resposta');
    });
  });

  group('UserMessages', () {
    test('não expõe códigos técnicos', () {
      final msg = UserMessages.fromError(Exception('401 Unauthenticated stack'));
      expect(msg.contains('401'), isFalse);
      expect(msg.toLowerCase().contains('exception'), isFalse);
      expect(
        UserMessages.fromError(
          const ProtocolFeatureUnavailable(UserMessages.ratingUnavailable),
        ),
        UserMessages.ratingUnavailable,
      );
    });
  });

  group('Widgets de atendimento', () {
    testWidgets('banner aguardando cidadão', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProtocolAwaitingBanner(
              question: 'Pode confirmar o endereço?',
            ),
          ),
        ),
      );
      expect(
        find.textContaining('precisa de mais informações'),
        findsOneWidget,
      );
      expect(find.text('Pode confirmar o endereço?'), findsOneWidget);
    });

    testWidgets('histórico e conversa sem overflow em 360dp scale 1.5',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 900),
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ProtocolHistorySection(
                    events: [
                      ProtocolHistoryEvent(
                        id: 1,
                        title: 'Solicitação recebida',
                        description: 'Registramos seu pedido',
                        createdAt: DateTime(2026, 7, 18, 10),
                        kind: 'received',
                      ),
                      ProtocolHistoryEvent(
                        id: 2,
                        title: 'Aguardando informação',
                        createdAt: DateTime(2026, 7, 18, 14),
                        kind: 'aguardando_cidadao',
                      ),
                    ],
                  ),
                  ProtocolConversationPanel(
                    messages: [
                      ProtocolMessage(
                        id: 1,
                        body: 'Olá, precisamos de mais detalhes do local.',
                        authorName: 'Gabinete',
                        isFromCabinet: true,
                        isUnread: true,
                        createdAt: DateTime(2026, 7, 18, 14),
                      ),
                      ProtocolMessage(
                        id: 2,
                        body: 'Claro, posso enviar agora.',
                        authorName: 'Você',
                        createdAt: DateTime(2026, 7, 18, 14, 30),
                      ),
                    ],
                    composer: const TextField(
                      decoration: InputDecoration(labelText: 'Mensagem'),
                    ),
                  ),
                  ProtocolRatingCard(
                    canRate: true,
                    canEdit: false,
                    existing: null,
                    busy: false,
                    onSubmit: (s, r, c) async {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Solicitação recebida'), findsOneWidget);
      expect(find.text('Como foi o atendimento?'), findsOneWidget);
    });

    testWidgets('avaliação não duplica envio sem autorização de edição',
        (tester) async {
      var submits = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtocolRatingCard(
              canRate: false,
              canEdit: false,
              existing: ProtocolRating(stars: 5, resolved: true),
              busy: false,
              onSubmit: (s, r, c) async => submits++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(UserMessages.ratingSent), findsOneWidget);
      expect(find.text('Enviar avaliação'), findsNothing);
      expect(submits, 0);
    });
  });
}
