#!/bin/bash
# ==============================================================================
# Exercicio 8 - Servicos Iniciados ou Parados Recentemente
# 
# Objetivo: Listar a data, hora e o nome dos servicos (services) que tiveram
#           seu status alterado (iniciados ou parados).
#
# Arquivo de log apropriado: /var/log/syslog (Debian/Ubuntu) ou
#                            /var/log/messages (RHEL/CentOS)
# ==============================================================================

LOG_FILE="/var/log/syslog"

if [ ! -f "$LOG_FILE" ] && [ -f "/var/log/messages" ]; then
    LOG_FILE="/var/log/messages"
fi

if [ ! -r "$LOG_FILE" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de log em $LOG_FILE."
    echo "Dica: Execute o script com sudo para ter permissao de acesso aos logs."
    exit 1
fi

echo "========================================================================================"
echo "Relatorio: Alteracoes Recentes de Status de Servicos (Systemd)"
echo "Arquivo analisado: $LOG_FILE"
echo "========================================================================================"
printf "%-16s | %-10s | %s\n" "DATA/HORA" "STATUS" "SERVICO"
echo "----------------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. grep -E "systemd\[1\]: (Started|Stopped)":
#    - Filtra as mensagens emitidas pelo systemd (PID 1) quando uma unidade de servico
#      completa sua transicao de inicializacao ou parada.
# 2. sed -E 's/.../.../':
#    - Grupo 1: '^([A-Za-z]{3} +[0-9]+ [0-9:]+)' captura a data e hora do evento.
#    - '[^ ]+ systemd\[1\]: ' descarta o nome do host e o identificador do daemon.
#    - Grupo 2: '(Started|Stopped)' captura o status resultante (Iniciado ou Parado).
#    - Grupo 3: '(.*)\.' captura o nome/descricao do servico antes do ponto final.
# 3. tail -n 50:
#    - Exibe as 50 alteracoes mais recentes (pode ser ajustado conforme a necessidade).
# 4. awk:
#    - Formata a saida em colunas organizadas.

grep -E "systemd\[1\]: (Started|Stopped)" "$LOG_FILE" \
    | tail -n 50 \
    | sed -E 's/^([A-Za-z]{3} +[0-9]+ [0-9:]+) [^ ]+ systemd\[1\]: (Started|Stopped) (.*)\./\1 | \2 | \3/' \
    | awk -F " \\| " '{printf "%-16s | %-10s | %s\n", $1, $2, $3}'

echo "========================================================================================"
