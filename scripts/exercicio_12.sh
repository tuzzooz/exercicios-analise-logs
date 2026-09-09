#!/bin/bash
# ==============================================================================
# Exercicio 12 - Pacotes Removidos do Sistema
# 
# Objetivo: Identificar todos os pacotes de software que foram removidos
#           ou purgados do sistema, exibindo data, hora, acao e versao.
#
# Arquivo de log apropriado: /var/log/dpkg.log (Debian/Ubuntu)
# ==============================================================================

LOG_FILE="/var/log/dpkg.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "Erro: Arquivo de log de pacotes $LOG_FILE nao encontrado."
    echo "Nota: Este script foi projetado para sistemas baseados em Debian/Ubuntu."
    exit 1
fi

echo "================================================================================"
echo "Relatorio: Pacotes Removidos ou Purgados do Sistema"
echo "Arquivo analisado: $LOG_FILE"
echo "================================================================================"
printf "%-19s | %-10s | %-32s | %s\n" "DATA/HORA" "ACAO" "NOME DO PACOTE" "VERSAO"
echo "--------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. grep -E "status (removed|purge)":
#    - 'removed': indica que os binarios e bibliotecas do pacote foram desinstalados.
#    - 'purge': indica a remocao total, incluindo arquivos de configuracao do pacote.
# 2. awk '{ ... }':
#    - $1, $2: Data e Hora do evento.
#    - $3: Tipo de acao ('removed' ou 'purge').
#    - $4: Nome do pacote com ou sem a arquitetura (:amd64).
#    - $5: Versao que foi removida.
# 3. sort -r:
#    - Exibe as remocoes em ordem cronologica reversa (mais recentes primeiro).

grep -E "status (removed|purge)" "$LOG_FILE" \
    | awk '{
        data_hora = $1 " " $2;
        acao = ($3 == "removed") ? "REMOVIDO" : "PURGADO";
        pacote = $4;
        versao = $5;
        printf "%-19s | %-10s | %-32s | %s\n", data_hora, acao, pacote, versao;
    }' \
    | sort -r

echo "================================================================================"
