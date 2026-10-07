# Estado local durante todo o ciclo de vida deste laboratório de operador único.
# Preserve backups privados independentes; nunca publique arquivos de estado.
terraform {
  backend "local" {}
}
