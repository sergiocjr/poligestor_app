import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/smart_assistant/data/smart_assistant_models.dart';

void main() {
  group('AuthMode sprint 10.5 paths', () {
    test('exposes staff assistant hub contracts', () {
      const m = AuthMode.staff;
      expect(m.aiChatPath, '/v1/ai/chat');
      expect(m.aiConversationsPath, '/v1/ai/conversations');
      expect(m.aiHistoryPath, '/v1/ai/history');
      expect(m.aiFavoritesPath, '/v1/ai/favorites');
      expect(m.aiQuestionsPath, '/v1/ai/questions');
      expect(m.aiSharePath, '/v1/ai/share');
      expect(m.mandateSuggestionsPath, '/v1/mandate/suggestions');
      expect(m.mandatePrioritiesPath, '/v1/mandate/priorities');
      expect(m.mandateSummaryDailyPath, '/v1/mandate/summary/daily');
      expect(m.mandateSummaryWeeklyPath, '/v1/mandate/summary/weekly');
      expect(m.mandateBriefingPath, '/v1/mandate/briefing');
      expect(m.mandateBriefingsPath, '/v1/mandate/briefings');
      expect(m.mandateInsightsPath, '/v1/mandate/insights');
    });
  });

  group('smart assistant models', () {
    test('parses briefing bullets', () {
      final b = SaBriefingView.fromJson({
        'scope': 'daily',
        'generated_at': '2026-07-19T06:30:11-03:00',
        'bullets': [
          'Um',
          {'text': 'Dois'},
        ],
      });
      expect(b.bullets, ['Um', 'Dois']);
      expect(b.scope, 'daily');
      expect(b.generatedAt, isNotNull);
    });

    test('parses chat reply and conversations', () {
      final reply = SaChatReply.fromJson({
        'conversation_id': 'c1',
        'message': {'role': 'assistant', 'content': 'Olá gabinete'},
      });
      expect(reply.conversationId, 'c1');
      expect(reply.message.content, 'Olá gabinete');
      expect(reply.message.isUser, isFalse);

      final list = asMapList({
        'data': [
          {'id': 1, 'title': 'Sessão', 'message_count': 3},
        ],
      }).map(SaConversationItem.fromJson).toList();
      expect(list.single.title, 'Sessão');
      expect(list.single.messageCount, 3);
    });

    test('parses insights items', () {
      final items = asMapList({
        'items': [
          {
            'id': 'i1',
            'title': 'Atrasos',
            'body': 'Há 6 atrasados',
            'priority': 'attention',
            'type': 'overdue_pressure',
          },
        ],
      }).map(SaInsightItem.fromJson).toList();
      expect(items.single.title, 'Atrasos');
      expect(items.single.priority, 'attention');
    });
  });

  group('deep links assistant', () {
    test('poligestor://assistant resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://assistant',
        ),
      );
      expect(target?.location, '/home/chat');
    });

    test('poligestor://assistente/gabinete resolves chat', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://assistente/gabinete',
        ),
      );
      expect(target?.location, '/home/chat/gabinete');
    });
  });
}
