/// Rótulos de UI em Português do Brasil.
/// Mapeia valores brutos da API sem alterar contratos.
library;

String uiSeverityLabel(String? raw) {
  return switch ((raw ?? '').toLowerCase().trim()) {
    'critical' || 'critica' || 'crítica' => 'Crítica',
    'high' || 'alta' => 'Alta',
    'medium' || 'med' || 'média' || 'media' => 'Média',
    'low' || 'baixa' => 'Baixa',
    'warning' || 'warn' || 'atenção' || 'atencao' => 'Atenção',
    'info' || 'informational' => 'Informativo',
    '' => '—',
    _ => raw!,
  };
}

String uiPriorityLabel(String? raw) {
  return switch ((raw ?? '').toLowerCase().trim()) {
    'critical' || 'urgente' => 'Urgente',
    'high' || 'alta' => 'Alta',
    'medium' || 'média' || 'media' || 'normal' => 'Média',
    'low' || 'baixa' => 'Baixa',
    '' => '—',
    _ => raw!,
  };
}

String uiStatusLabel(String? raw) {
  final s = (raw ?? '').toLowerCase().trim();
  return switch (s) {
    'pending' || 'aguardando' => 'Pendente',
    'open' || 'aberto' || 'recebido' => 'Aberto',
    'closed' || 'fechado' => 'Fechado',
    'resolved' || 'resolvido' => 'Resolvido',
    'completed' ||
    'concluido' ||
    'concluído' ||
    'done' ||
    'success' => 'Concluído',
    'running' || 'in_progress' || 'busy' => 'Em execução',
    'em_andamento' => 'Em andamento',
    'paused' || 'pausado' => 'Pausado',
    'failed' || 'error' || 'erro' || 'failure' => 'Falhou',
    'active' || 'enabled' || 'ativa' || 'ativo' => 'Ativo',
    'inactive' || 'disabled' || 'inativa' || 'inativo' => 'Inativo',
    'draft' || 'rascunho' => 'Rascunho',
    'online' => 'Conectado',
    'offline' => 'Desconectado',
    'idle' => 'Aguardando',
    'queued' || 'queue' || 'na_fila' => 'Na fila',
    'cancelled' || 'canceled' || 'cancelado' => 'Cancelado',
    'acknowledged' => 'Reconhecido',
    'waiting_citizen' || 'aguardando_cidadao' => 'Aguardando cidadão',
    '' => '—',
    _ => raw!,
  };
}

String uiOnlineLabel(bool online) => online ? 'Conectado' : 'Desconectado';

String uiTrendLabel(String? raw) {
  return switch ((raw ?? '').toLowerCase().trim()) {
    'up' || 'rising' || 'alta' || 'crescendo' => 'Alta',
    'down' || 'falling' || 'baixa' || 'caindo' => 'Baixa',
    'stable' || 'flat' || 'estavel' || 'estável' => 'Estável',
    '' => '—',
    _ => raw!,
  };
}

/// Chip de disponibilidade de contrato.
String uiContractChip({required bool available}) => 'Ativo';
