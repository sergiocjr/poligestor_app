import '../../../shared/widgets/ui_kit.dart';

/// Fonte mock explícita — não misturar com dados da API.
class MockNewsCatalog {
  MockNewsCatalog._();

  static final items = <NewsItem>[
    NewsItem(
      id: 'news-1',
      title: 'Mutirão de limpeza neste sábado',
      summary:
          'Equipes percorrem as principais avenidas do Taquaral a partir das 8h.',
      content:
          'A prefeitura e o gabinete organizam um mutirão de limpeza no próximo sábado. '
          'As equipes começam às 8h nas principais avenidas do Taquaral e seguem pelos '
          'trechos com maior acúmulo de resíduos. Moradores podem colaborar separando '
          'entulho reciclável e disponibilizando-o na calçada até às 7h30.',
      category: 'Bairro',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NewsItem(
      id: 'news-2',
      title: 'Abertas as inscrições para capacitação',
      summary:
          'Cursos gratuitos de qualificação profissional com vagas limitadas.',
      content:
          'Estão abertas as inscrições para cursos gratuitos de qualificação profissional. '
          'As vagas são limitadas e priorizam moradores da região. Interessados devem '
          'levar documento com foto e comprovante de residência no ponto de atendimento '
          'do gabinete, de segunda a sexta, das 9h às 17h.',
      category: 'Oportunidades',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NewsItem(
      id: 'news-3',
      title: 'Iluminação reforçada em pontos críticos',
      summary:
          'Novos postes foram instalados em trechos com maior circulação noturna.',
      content:
          'Novos postes de iluminação foram instalados em trechos com maior circulação '
          'noturna. A ação faz parte do plano de segurança e acessibilidade do bairro. '
          'Moradores podem continuar reportando pontos escuros pelo assistente ou pela '
          'área de solicitações do aplicativo.',
      category: 'Cidade',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static NewsItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
