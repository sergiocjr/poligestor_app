/// Suporte a dados explícitos de demonstração, quando solicitado.
library;

class DemoRepositorySupport {
  DemoRepositorySupport._();

  static const ageLabel = 'Dados de referência';

  static const bannerTitle = 'Dados disponíveis';

  static const bannerMessage =
      'Os dados são apresentados conforme disponibilizados pelo serviço.';

  static bool isDemoRoot(Map<String, dynamic> root) =>
      root['meta'] is Map && (root['meta'] as Map)['demo'] == true;

  /// Preserva integralmente as respostas LIVE, inclusive quando vazias.
  static Map<String, dynamic> coerceRoot(
    String path,
    Map<String, dynamic> root,
  ) => root;

  static String? ageForRoot(Map<String, dynamic> root) =>
      isDemoRoot(root) ? ageLabel : null;

  static bool isDemoId(dynamic id) =>
      id?.toString().startsWith('demo-') ?? false;

  static Map<String, dynamic> rootFor(String path) {
    if (path.contains('/dashboard') || _slugOf(path) == 'dashboard') {
      return summaryRoot(path);
    }
    if (path.contains('/filters')) {
      return filtersRoot(path);
    }
    return listRoot(path);
  }

  static Map<String, dynamic> listRoot(String path, {int count = 5}) {
    return {
      'data': List<Map<String, dynamic>>.generate(
        count,
        (i) => itemFor(path, index: i),
      ),
      'meta': {'demo': true},
    };
  }

  static Map<String, dynamic> summaryRoot(String path) {
    return {
      'data': {
        'product': 'poligestor',
        'namespace': _namespaceOf(path),
        'summary': {
          'total': 24,
          'active': 18,
          'pending': 3,
          'completed': 15,
          'open': 6,
          'users': 12,
          'companies': 2,
          'offices': 1,
          'sessions': 4,
          'articles': 20,
          'mentions': 8,
          'alerts': 2,
          'sources_active': 5,
        },
        'items': List<Map<String, dynamic>>.generate(
          4,
          (i) => itemFor(path, index: i),
        ),
      },
      'meta': {'demo': true},
    };
  }

  static Map<String, dynamic> filtersRoot(String path) {
    return {
      'data': [
        {'id': 'volta-redonda', 'label': 'Volta Redonda', 'group': 'city'},
        {
          'id': 'jornal-local',
          'label': 'Jornal Regional Demo',
          'group': 'source',
        },
        {'id': '7d', 'label': 'Últimos 7 dias', 'group': 'period'},
        {'id': 'mandato', 'label': 'Mandato', 'group': 'topic'},
      ],
      'meta': {'demo': true},
    };
  }

  static Map<String, dynamic> firstItem(String path) => itemFor(path, index: 0);

  static List<Map<String, dynamic>> listItems(String path, {int count = 5}) =>
      List.generate(count, (i) => itemFor(path, index: i));

  static Map<String, dynamic> itemFor(String path, {required int index}) {
    final slug = _slugOf(path);
    final titles = _titlesFor(path);
    final title = titles[index % titles.length];
    final id = 'demo-$slug-$index';
    final when = DateTime.now().toUtc().subtract(Duration(hours: index * 6));
    final iso = when.toIso8601String();
    return {
      'id': id,
      'uuid': id,
      'title': title,
      'name': title,
      'headline': title,
      'body': 'Texto ilustrativo — $title.',
      'summary': 'Resumo ilustrativo sobre $title na região de Volta Redonda.',
      'description': 'Registro de demonstração do PoliGestor.',
      'status': index.isEven ? 'active' : 'published',
      'city': 'Volta Redonda',
      'region': 'Sul Fluminense',
      'source': 'Imprensa Regional Demo',
      'source_name': 'Imprensa Regional Demo',
      'category': 'mandato',
      'topic': 'mandato',
      'url': 'https://example.com/demo/$slug/$index',
      'canonical_url': 'https://example.com/demo/$slug/$index',
      'image_url': null,
      'published_at': iso,
      'created_at': iso,
      'starts_at': iso,
      'start_at': iso,
      'ends_at': iso,
      'updated_at': iso,
      'mentions_politician': path.contains('mention') || index == 0,
      'severity': index == 0 ? 'high' : 'medium',
      'demo': true,
    };
  }

  static String _slugOf(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'item';
    return parts.last;
  }

  static String _namespaceOf(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return parts[1];
    return 'poligestor';
  }

  static List<String> _titlesFor(String path) {
    if (path.contains('/news')) {
      return const [
        'Obras de infraestrutura avançam em Volta Redonda',
        'Gabinete acompanha entrega de equipamentos na região',
        'Audiência pública sobre mobilidade urbana',
        'Investimentos em saúde no bairro Aterrado',
        'Parceria institucional fortalece mandato local',
      ];
    }
    if (path.contains('/communication') || path.contains('/institutional')) {
      return const [
        'Comunicado oficial — pauta da semana',
        'Nota à imprensa sobre obras entregues',
        'Campanha de escuta nas comunidades',
        'Boletim institucional do gabinete',
        'Agenda de publicações do mês',
      ];
    }
    if (path.contains('/crm')) {
      return const [
        'Liderança comunitária — Centro',
        'Apoiador — bairro Retiro',
        'Voluntário — ação de rua',
        'Entidade parceira — associação local',
        'Interação registrada — visita',
      ];
    }
    if (path.contains('/elections') || path.contains('/elec')) {
      return const [
        'Meta regional — Zona Sul',
        'Equipe de campo — bairro 05',
        'Material de campanha aprovado',
        'Projeção de votos — atualizada',
        'Prestação de contas — trimestre',
      ];
    }
    if (path.contains('/events') ||
        path.contains('/agenda') ||
        path.contains('/appointments')) {
      return const [
        'Audiência pública — transporte',
        'Reunião com lideranças locais',
        'Entrega de equipamentos — escola',
        'Plantão de atendimento — sábado',
        'Sessão solene — câmara municipal',
      ];
    }
    if (path.contains('/finance')) {
      return const [
        'Pagamento autorizado — fornecedor',
        'Alerta de fluxo de caixa',
        'Transação — material de escritório',
        'Relatório mensal consolidado',
        'Centro de custo — gabinete',
      ];
    }
    if (path.contains('/documents')) {
      return const [
        'Ofício nº 128/2026 — solicitação',
        'Memorando interno — equipe',
        'Contrato social — revisão',
        'Ata de reunião — assinada',
        'Modelo — despacho padrão',
      ];
    }
    if (path.contains('/integrations')) {
      return const [
        'Integração Gov.br — demonstração',
        'WhatsApp Business — fila simulada',
        'Google Calendar — agenda demo',
        'Webhook de teste — recebido',
        'Diário Oficial — monitoramento',
      ];
    }
    if (path.contains('/security')) {
      return const [
        'Sessão ativa — navegador Chrome',
        'Alerta — tentativa de login',
        'Consentimento LGPD — atualizado',
        'Política de senha — revisada',
        'Exportação de dados — solicitada',
      ];
    }
    if (path.contains('/admin') || path.contains('/platform')) {
      return const [
        'Usuário operador — ativo',
        'Gabinete demo — configurado',
        'Papel administrador — atribuído',
        'Registro de auditoria — login',
        'Assinatura do plano — vigente',
      ];
    }
    if (path.contains('/works')) {
      return const [
        'Obra — pavimentação Rua 12',
        'Fiscalização — creche municipal',
        'Medição — etapa concluída',
        'Relatório fotográfico — obra',
        'Mapa de obras — região sul',
      ];
    }
    if (path.contains('/grants') || path.contains('/agreements')) {
      return const [
        'Convênio — iluminação pública',
        'Execução financeira — 78%',
        'Prestação de contas — enviada',
        'Documentação complementar',
        'Indicador — meta atingida',
      ];
    }
    if (path.contains('/ai') || path.contains('/chat')) {
      return const [
        'Briefing diário — gabinete',
        'Sugestão de resposta — protocolo',
        'Resumo de conversa — cidadão',
        'Prompt salvo — atendimento',
        'Feedback positivo — operador',
      ];
    }
    if (path.contains('/strategy')) {
      return const [
        'Meta trimestral — aprovação',
        'Indicador — satisfação cidadã',
        'Comparativo regional — mapa',
        'Projeção — demandas por bairro',
        'Painel estratégico — resumo',
      ];
    }
    if (path.contains('/parliament')) {
      return const [
        'Emenda parlamentar — educação',
        'Promessa de campanha — saúde',
        'Indicador — entregas no mandato',
        'Linha do tempo — votações',
        'Anexo — projeto de lei',
      ];
    }
    if (path.contains('/intelligence') || path.contains('/territorial')) {
      return const [
        'Bairro Aterrado — demandas altas',
        'Tendência — saúde em alta',
        'Projeção — atendimentos julho',
        'Mapa de calor — região sul',
        'KPI — tempo médio resposta',
      ];
    }
    if (path.contains('/automation')) {
      return const [
        'Regra — protocolo vencido',
        'Gatilho — nova menção imprensa',
        'Execução — notificação enviada',
        'Agendamento — resumo semanal',
        'Aprovação pendente — operador',
      ];
    }
    return const [
      'Registro demonstrativo 1',
      'Registro demonstrativo 2',
      'Registro demonstrativo 3',
      'Registro demonstrativo 4',
      'Registro demonstrativo 5',
    ];
  }
}
