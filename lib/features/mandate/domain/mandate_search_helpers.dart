/// Helpers de busca do mandato (testáveis sem UI).
bool mandateSearchQueryReady(String query) => query.trim().length >= 2;

Duration mandateSearchDebounce() => const Duration(milliseconds: 400);
