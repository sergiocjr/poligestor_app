import 'package:flutter_test/flutter_test.dart';
import 'package:poligestor_app/core/auth/auth_mode.dart';
import 'package:poligestor_app/features/documents/data/documents_cache.dart';
import 'package:poligestor_app/features/documents/data/documents_contracts.dart';
import 'package:poligestor_app/features/documents/data/documents_models.dart';
import 'package:poligestor_app/features/notifications/data/push_payload.dart';
import 'package:poligestor_app/features/notifications/domain/notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthMode Fase 13 documents paths', () {
    test('exposes official /v1/documents namespace', () {
      const m = AuthMode.staff;
      expect(m.documentsRootPath, '/v1/documents');
      expect(m.documentsListPath, '/v1/documents/list');
      expect(m.documentsSearchPath, '/v1/documents/search');
      expect(m.documentsFiltersPath, '/v1/documents/filters');
      expect(m.documentsCategoriesPath, '/v1/documents/categories');
      expect(m.documentsFavoritesPath, '/v1/documents/favorites');
      expect(m.documentsHistoryPath, '/v1/documents/history');
      expect(m.documentsTimelinePath, '/v1/documents/timeline');
      expect(m.documentsViewerPath, '/v1/documents/viewer');
      expect(m.documentsSignaturesPath, '/v1/documents/signatures');
      expect(m.documentsApprovalsPath, '/v1/documents/approvals');
      expect(m.documentsSharePath, '/v1/documents/share');
      expect(m.documentsTemplatesPath, '/v1/documents/templates');
      expect(m.documentsDownloadPath, '/v1/documents/download');
      expect(m.documentsUploadPath, '/v1/documents/upload');
      expect(m.documentsAttachmentsPath, '/v1/documents/attachments');
      expect(m.documentsItemPath('abc'), '/v1/documents/abc');
    });
  });

  group('documents LIVE contracts', () {
    test('marks all published hub slugs as live', () {
      expect(kDocumentsLiveSlugs, isNotEmpty);
      expect(documentsPathLive('list'), isTrue);
      expect(documentsPathLive('search'), isTrue);
      expect(documentsPathLive('viewer'), isTrue);
      expect(documentsPathLive('upload'), isTrue);
      expect(documentsPathLive('attachments'), isTrue);
      expect(documentsPathLive('unknown'), isFalse);
    });
  });

  group('documents models', () {
    test('parses document item and pdf flag', () {
      final item = DocumentItem.fromJson({
        'id': '1',
        'title': 'Ata.pdf',
        'mime_type': 'application/pdf',
        'category': 'Atas',
        'status': 'approved',
        'favorite': true,
      });
      expect(item.title, 'Ata.pdf');
      expect(item.isPdf, isTrue);
      expect(item.favorite, isTrue);
      expect(item.category, 'Atas');
    });

    test('parses list from documents key', () {
      final list = asDocsMapList({
        'documents': [
          {'id': '2', 'name': 'Ofício'},
        ],
      });
      expect(list, hasLength(1));
      expect(DocumentItem.fromJson(list.first).title, 'Ofício');
    });
  });

  group('documents cache', () {
    test('does not leak between tenants', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = DocumentsCache();
      await cache.putMap('demo', 'list', {
        'data': [
          {'id': '1', 'title': 'Doc'},
        ],
      });
      expect(await cache.getMap('other', 'list'), isNull);
      expect(await cache.getMap('demo', 'list'), isNotNull);
    });
  });

  group('deep links documents', () {
    test('poligestor://gestao-documental resolves hub', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://gestao-documental',
        ),
      );
      expect(target?.location, '/home/documents');
    });

    test('poligestor://documentos/viewer', () {
      const router = NotificationRouter();
      final target = router.resolve(
        const PushPayload(
          type: PushEventType.systemNotice,
          deepLink: 'poligestor://documentos/viewer',
        ),
      );
      expect(target?.location, '/home/documents/viewer');
    });
  });
}
