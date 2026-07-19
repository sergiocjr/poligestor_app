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
          {'id': 'h3', 'kind': 'internal_note', 'title': 'Nota interna'},
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

    test('parse do contrato real portal (fixture API)', () {
      final envelope = {
        'data': {
          'id': '5f3d010e-1dc6-44ab-957c-b8df9febc611',
          'number': 'PG-2026-000008',
          'subject': 'cachorro / animal abandonado',
          'title': 'cachorro / animal abandonado',
          'description': 'cachorro / animal abandonado',
          'status': 'recebido',
          'priority': 'medium',
          'category': {
            'id': '7208b2f1-90b7-463c-b3ee-8e741363851b',
            'name': 'Proteção animal',
            'slug': 'protecao-animal',
          },
          'address': 'Rua das Flores, próximo ao número 20.',
          'deadline_label': 'Dentro do prazo',
          'due_at': '2026-07-20T05:49:31-03:00',
          'can_rate': false,
          'can_reply': true,
          'awaiting_citizen': false,
          'has_new_message': true,
          'unread_messages': 2,
          'unread_count': 2,
          'last_public_message': 'Vamos verificar o local.',
          'last_updated_at': '2026-07-18T17:52:37-03:00',
          'created_at': '2026-07-18T02:49:30-03:00',
          'updated_at': '2026-07-18T17:52:37-03:00',
          'links': {
            'read':
                '/api/v1/portal/protocols/5f3d010e-1dc6-44ab-957c-b8df9febc611/read',
            'rate': null,
          },
          'timeline': [
            {
              'id': '2177dd5c-e3ad-4646-882b-6399763e47e5',
              'type': 'created',
              'title': 'Solicitação recebida',
              'description':
                  'Sua solicitação foi registrada e receberá um número de protocolo.',
              'created_at': '2026-07-18T02:49:30-03:00',
            },
            {
              'id': 'h2',
              'type': 'comment_added',
              'title': 'Nova mensagem',
              'created_at': '2026-07-18T17:52:38-03:00',
            },
          ],
          'comments': [
            {
              'id': '73d72ae6-f1ac-47d4-80d7-7b5734f62563',
              'body': 'Complemento validacao fase 6 cidadao.',
              'author': 'you',
              'created_at': '2026-07-18T17:52:38-03:00',
            },
          ],
          'attachments': [],
        },
      };

      final detail = ProtocolDetail.fromJson(
        Map<String, dynamic>.from(envelope['data'] as Map),
      );
      expect(detail.number, 'PG-2026-000008');
      expect(detail.category, 'Proteção animal');
      expect(detail.address, contains('Flores'));
      expect(detail.deadlineLabel, 'Dentro do prazo');
      expect(detail.showUnreadBadge, isTrue);
      expect(detail.lastMessagePreview, contains('verificar'));
      expect(detail.markReadUrl, contains('/read'));
      expect(detail.rateUrl, isNull);
      expect(detail.canRate, isFalse);
      expect(detail.messages, hasLength(1));
      expect(detail.messages.single.isFromCabinet, isFalse);
      expect(detail.messages.single.authorName, 'Você');
      expect(detail.history, hasLength(2));
      expect(detail.history.first.title, 'Solicitação recebida');
      expect(
        detail.history.first.createdAt!.isBefore(
          detail.history.last.createdAt!,
        ),
        isTrue,
      );
    });

    test('notificação usa data.protocol_id e link /portal/solicitacoes', () {
      final n = AppNotification.fromJson({
        'id': '861c0494-2203-4f20-b6d7-b1cad25dd91c',
        'type': 'protocol_received',
        'title': 'Solicitação recebida',
        'body': 'Protocolo PG-2026-000008 registrado com sucesso.',
        'data': {
          'protocol_id': '5f3d010e-1dc6-44ab-957c-b8df9febc611',
          'number': 'PG-2026-000008',
        },
        'link': '/portal/solicitacoes/5f3d010e-1dc6-44ab-957c-b8df9febc611',
        'read_at': null,
      });
      expect(n.protocolId, '5f3d010e-1dc6-44ab-957c-b8df9febc611');
    });

    test('create payload inclui data_consent', () {
      final json = CreateProtocolInput(
        subject: 'Teste',
        description: 'Desc',
        category: 'ajuda',
      ).toJson();
      expect(json['data_consent'], isTrue);
      expect(json['subject'], 'Teste');
    });

    test('status usa linguagem simples', () {
      expect(
        ProtocolStatusLabel.pt('aguardando_cidadao'),
        'Aguardando cidadão',
      );
      expect(ProtocolStatusLabel.pt('em_analise'), 'Em análise');
      expect(ProtocolStatusLabel.pt('em_execucao'), 'Em execução');
      expect(ProtocolStatusLabel.pt('arquivado'), 'Arquivado');
      expect(ProtocolStatusLabel.pt('novo'), 'Novo');
      expect(ProtocolPriorityLabel.pt('high'), 'Alta');
      expect(
        ProtocolStatusLabel.display(
          status: 'recebido',
          statusLabel: 'Recebido pelo gabinete',
        ),
        'Recebido pelo gabinete',
      );
    });

    test('lista destaca não lidas e preview', () {
      final item = ProtocolSummary.fromJson({
        'id': 1,
        'title': 'Iluminação',
        'number': '9',
        'status': 'em_andamento',
        'status_label': 'Em andamento',
        'unread_count': 2,
        'last_message_preview': 'Vamos verificar amanhã.',
        'updated_at': '2026-07-18T16:00:00Z',
      });
      expect(item.showUnreadBadge, isTrue);
      expect(item.lastMessagePreview, contains('verificar'));
      expect(item.displayStatus, 'Em andamento');
    });

    test('anexo reconhece PDF áudio e vídeo', () {
      expect(
        ProtocolAttachment(
          id: 1,
          name: 'doc.pdf',
          mimeType: 'application/pdf',
        ).kindLabel,
        'PDF',
      );
      expect(
        ProtocolAttachment(
          id: 2,
          name: 'voz.m4a',
          mimeType: 'audio/mp4',
        ).isAudio,
        isTrue,
      );
      expect(
        ProtocolAttachment(
          id: 3,
          name: 'clip.mp4',
          mimeType: 'video/mp4',
        ).isVideo,
        isTrue,
      );
    });

    test('avaliação com can_rate sem link não é rejeitada no model', () {
      final detail = ProtocolDetail.fromJson({
        'id': 'abc',
        'title': 'X',
        'status': 'resolvido',
        'can_rate': true,
        'links': {'rate': null},
      });
      expect(detail.canRate, isTrue);
      expect(detail.rateUrl, isNull);
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
      final msg = UserMessages.fromError(
        Exception('401 Unauthenticated stack'),
      );
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

    testWidgets('histórico e conversa sem overflow em 360dp scale 1.5', (
      tester,
    ) async {
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

    testWidgets('avaliação não duplica envio sem autorização de edição', (
      tester,
    ) async {
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
