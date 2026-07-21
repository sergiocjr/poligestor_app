import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/advanced_ai/data/advanced_ai_cache.dart';
import 'package:poligestor_app/features/advanced_ai/data/advanced_ai_contracts.dart';
import 'package:poligestor_app/features/advanced_ai/data/advanced_ai_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 18 IA Avançada paths', () {
    test('exposes official /v1/ai namespace for hub', () {
      const m = AuthMode.staff;
      expect(m.advancedAiRootPath, '/v1/ai');
      expect(m.aiChatPath, '/v1/ai/chat');
      expect(m.aiConversationsPath, '/v1/ai/conversations');
      expect(m.aiHistoryPath, '/v1/ai/history');
      expect(m.advancedAiBriefingsPath, '/v1/ai/briefings');
      expect(m.advancedAiPromptsPath, '/v1/ai/prompts');
      expect(m.advancedAiSummaryPath, '/v1/ai/summary');
      expect(m.advancedAiSuggestionsPath, '/v1/ai/suggestions');
      expect(m.advancedAiFeedbackPath, '/v1/ai/feedback');
      expect(m.advancedAiSecretaryPath, '/v1/ai/secretary');
      expect(m.advancedAiVirtualSecretaryPath, '/v1/ai/virtual-secretary');
      expect(
        m.advancedAiParliamentaryAdvisorPath,
        '/v1/ai/parliamentary-advisor',
      );
      expect(m.advancedAiPoliticalAnalystPath, '/v1/ai/political-analyst');
      expect(m.advancedAiFinancialAnalystPath, '/v1/ai/financial-analyst');
      expect(
        m.advancedAiCommunicationAdvisorPath,
        '/v1/ai/communication-advisor',
      );
      expect(m.advancedAiLegalAdvisorPath, '/v1/ai/legal-advisor');
      expect(m.advancedAiStrategicPlanningPath, '/v1/ai/strategic-planning');
      expect(m.advancedAiDashboardPath, '/v1/ai/dashboard');
      expect(m.advancedAiHubPath, '/v1/ai/hub');
      expect(m.advancedAiSearchPath, '/v1/ai/search');
      expect(m.advancedAiSettingsPath, '/v1/ai/settings');
      expect(m.advancedAiPromptLibraryPath, '/v1/ai/prompt-library');
      expect(m.advancedAiSummariesPath, '/v1/ai/summaries');
      expect(m.advancedAiBriefingSingularPath, '/v1/ai/briefing');
      expect(m.advancedAiInsightsPath, '/v1/ai/insights');
      expect(m.aiAgentsCatalogPath, '/v1/ai/agents');
    });
  });

  group('IA Avançada LIVE contracts', () {
    test('marks VPS live slugs and agent roles', () {
      expect(kAdvancedAiLiveSlugs.length, 13);
      expect(advancedAiPathLive('dashboard'), isTrue);
      expect(advancedAiPathLive('chat'), isTrue);
      expect(advancedAiPathLive('conversations'), isTrue);
      expect(advancedAiPathLive('history'), isTrue);
      expect(advancedAiPathLive('briefings'), isTrue);
      expect(advancedAiPathLive('prompts'), isTrue);
      expect(advancedAiPathLive('agents'), isTrue);
      expect(advancedAiPathLive('hub'), isTrue);
      expect(advancedAiPathLive('team'), isTrue);
      expect(advancedAiPathLive('handoffs'), isTrue);
      expect(advancedAiPathLive('summary'), isTrue);
      expect(advancedAiPathLive('suggestions'), isTrue);
      expect(advancedAiPathLive('feedback'), isTrue);
      expect(advancedAiPathLive('secretary'), isTrue);
      expect(advancedAiPathLive('parliamentary-advisor'), isTrue);
      expect(advancedAiPathLive('legal-advisor'), isTrue);
      expect(advancedAiAgentSlugForHub('secretary'), 'secretary');
      expect(
        advancedAiAgentSlugForHub('parliamentary-advisor'),
        'parliamentary_advisor',
      );
      expect(advancedAiPathLive('financial-analyst'), isFalse);
      expect(advancedAiPathLive('settings'), isFalse);
      expect(advancedAiPathLive('search'), isFalse);
    });
  });

  group('IA Avançada models', () {
    test('parses item', () {
      final item = AdvancedAiItem.fromJson({
        'id': 'p1',
        'title': 'Prompt de boas-vindas',
        'role': 'assistente',
        'status': 'active',
        'body': 'Texto do prompt',
      });
      expect(item.title, 'Prompt de boas-vindas');
      expect(item.role, 'assistente');
      expect(item.summary, 'Texto do prompt');
    });

    test('parses chat reply', () {
      final reply = AaiChatReply.fromJson({
        'conversation_id': 'c1',
        'message': {'role': 'assistant', 'content': 'Olá!'},
      });
      expect(reply.conversationId, 'c1');
      expect(reply.message.content, 'Olá!');
    });

    test('flattens briefings bullets into list rows', () {
      final rows = asAdvancedAiMapList({
        'bullets': ['Item A', 'Item B'],
      });
      expect(rows.length, 2);
      expect(rows.first['title'], 'Item A');
    });
  });

  group('IA Avançada cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = AdvancedAiCache();
      await cache.putMap('demo', 'prompts', {
        'data': [
          {'id': '1', 'title': 'A'},
        ],
      });
      expect(await cache.getMap('other', 'prompts'), isNull);
      expect(await cache.getMap('demo', 'prompts'), isNotNull);
    });
  });

  group('deep links IA Avançada', () {
    test('poligestor://ia-avancada resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://ia-avancada',
        ),
      );
      expect(target?.location, '/home/advanced-ai');
    });

    test('poligestor://advanced-ai/prompts', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://advanced-ai/prompts',
        ),
      );
      expect(target?.location, '/home/advanced-ai/prompts');
    });

    test('poligestor://ia_avancada/chat', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://ia_avancada/chat',
        ),
      );
      expect(target?.location, '/home/advanced-ai/chat');
    });
  });
}
