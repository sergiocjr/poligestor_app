import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:poligestor_app/features/regional_news/data/news_cache.dart';
import 'package:poligestor_app/features/regional_news/data/news_contracts.dart';
import 'package:poligestor_app/features/regional_news/data/news_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 24 News paths', () {
    test('exposes official /v1/news namespace', () {
      const m = AuthMode.staff;
      expect(m.newsRootPath, '/v1/news');
      expect(m.newsDashboardPath, '/v1/news/dashboard');
      expect(m.newsRecentPath, '/v1/news/recent');
      expect(m.newsFeedPath, '/v1/news/feed');
      expect(m.newsSearchPath, '/v1/news/search');
      expect(m.newsFiltersPath, '/v1/news/filters');
      expect(m.newsMentionsPath, '/v1/news/mentions');
      expect(m.newsFavoritesPath, '/v1/news/favorites');
      expect(m.newsAlertsPath, '/v1/news/alerts');
      expect(m.newsSourcesPath, '/v1/news/sources');
      expect(m.newsItemPath('abc'), '/v1/news/abc');
    });
  });

  group('News LIVE contracts', () {
    test('kNewsLiveSlugs matches VPS audit 2026-07-20', () {
      expect(newsPathLive('dashboard'), isTrue);
      expect(newsPathLive('mentions'), isTrue);
      expect(newsPathLive('favorites'), isTrue);
      expect(newsPathLive('alerts'), isTrue);
      expect(newsPathLive('sources'), isTrue);
      expect(newsPathLive('detail'), isTrue);
      expect(newsPathLive('recent'), isFalse);
      expect(newsPathLive('feed'), isFalse);
      expect(newsPathLive('search'), isFalse);
      expect(newsPathLive('filters'), isFalse);
      expect(kNewsLiveSlugs.length, 6);
    });
  });

  group('News models', () {
    test('parses metadata without keeping full body', () {
      final item = RegionalNewsItem.fromJson({
        'id': '1',
        'title': 'Obra no centro',
        'summary': 'Resumo curto',
        'content': 'CORPO COMPLETO NAO DEVE VIRAR CAMPO',
        'source': 'Jornal Local',
        'city': 'Demo',
        'mentions_politician': true,
        'canonical_url': 'https://example.com/noticia',
        'published_at': '2026-07-20T12:00:00Z',
      });
      expect(item.title, 'Obra no centro');
      expect(item.summary, 'Resumo curto');
      expect(item.source, 'Jornal Local');
      expect(item.mentionsPolitician, isTrue);
      expect(item.originalUrl, 'https://example.com/noticia');
      expect(item.raw.containsKey('content'), isTrue);
    });

    test('mention row maps article_id as id', () {
      final item = RegionalNewsItem.fromJson({
        'id': 'mention-1',
        'article_id': 'article-1',
        'match_type': 'city',
        'matched_term': 'Volta Redonda',
      });
      expect(item.id, 'article-1');
      expect(item.mentionsPolitician, isTrue);
    });

    test('cache strips article body keys', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = NewsCache();
      await cache.putMap('demo', 'recent', {
        'data': [
          {
            'id': '1',
            'title': 'A',
            'content': 'full',
            'body': 'full2',
            'summary': 'ok',
          },
        ],
      });
      final stored = await cache.getMap('demo', 'recent');
      expect(stored, isNotNull);
      final row = (stored!.data['data'] as List).first as Map;
      expect(row.containsKey('content'), isFalse);
      expect(row.containsKey('body'), isFalse);
      expect(row['summary'], 'ok');
    });
  });

  group('deep links News', () {
    test('poligestor://noticias resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://noticias',
        ),
      );
      expect(target?.location, '/home/news');
    });

    test('poligestor://news/abc', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://news/abc',
        ),
      );
      expect(target?.location, '/home/news/abc');
    });
  });
}
