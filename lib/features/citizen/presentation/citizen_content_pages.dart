import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/mock_news.dart';

class CitizenNewsListPage extends StatelessWidget {
  const CitizenNewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MockNewsCatalog.items;
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Notícias')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${item.category} · ${dateFmt.format(item.publishedAt)}',
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/citizen/news/${item.id}'),
            ),
          );
        },
      ),
    );
  }
}

class CitizenNewsDetailPage extends StatelessWidget {
  const CitizenNewsDetailPage({super.key, required this.newsId});

  final String newsId;

  @override
  Widget build(BuildContext context) {
    final item = MockNewsCatalog.byId(newsId);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notícia')),
        body: const Center(child: Text('Notícia não encontrada.')),
      );
    }

    final dateFmt = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Notícia')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            item.category,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            dateFmt.format(item.publishedAt),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.content,
            style: const TextStyle(height: 1.45, fontSize: 16),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}

class CitizenNeighborhoodPage extends StatelessWidget {
  const CitizenNeighborhoodPage({
    super.key,
    required this.neighborhoodLabel,
    this.unreadNotifications = 0,
  });

  final String neighborhoodLabel;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final parts = neighborhoodLabel.split('·').map((e) => e.trim()).toList();
    final bairro = parts.isNotEmpty ? parts.first : neighborhoodLabel;
    final cidade = parts.length > 1 ? parts.sublist(1).join(' · ') : null;
    final hasAlerts = unreadNotifications > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Bairro')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            bairro.isEmpty ? 'Seu bairro' : bairro,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (cidade != null && cidade.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              cidade,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(
                hasAlerts
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
              ),
              title: Text(
                hasAlerts
                    ? '$unreadNotifications aviso(s) disponível(is)'
                    : 'Nenhum aviso no momento',
              ),
              subtitle: Text(
                hasAlerts
                    ? 'Toque para ver as notificações'
                    : 'Quando houver avisos do bairro, eles aparecem aqui.',
              ),
              trailing: hasAlerts ? const Icon(Icons.chevron_right) : null,
              onTap: hasAlerts
                  ? () => context.go('/citizen/notifications')
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          if (!hasAlerts)
            const SoftEmptyNotice(
              message:
                  'Ainda não há conteúdos extras do bairro. Em breve: serviços e oportunidades da região.',
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}

class SoftEmptyNotice extends StatelessWidget {
  const SoftEmptyNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Text(message, style: const TextStyle(height: 1.4)),
    );
  }
}

/// Detalhe simples de compromisso (reutiliza dados já carregados).
class CitizenAppointmentDetailPage extends StatelessWidget {
  const CitizenAppointmentDetailPage({
    super.key,
    required this.title,
    this.when,
    this.location,
    this.status,
    this.description,
  });

  final String title;
  final String? when;
  final String? location;
  final String? status;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compromisso')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (when != null) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_rounded),
              title: Text(when!),
            ),
          ],
          if (location != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(location!),
            ),
          ],
          if (status != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(status!),
            ),
          ],
          if (description != null && description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description!, style: const TextStyle(height: 1.4)),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
              context.push('/citizen/agenda');
            },
            child: const Text('Ver agenda completa'),
          ),
        ],
      ),
    );
  }
}
