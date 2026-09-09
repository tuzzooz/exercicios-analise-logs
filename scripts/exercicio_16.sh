#!/bin/bash
# ==============================================================================
# Exercicio 16 - Servico com Maior Quantidade de Logs
# 
# Objetivo: Contar a frequencia de mensagens geradas por cada servico/processo
#           no sistema e lista-las em ordem decrescente.
#
# Arquivo de log apropriado: /var/log/syslog (Debian/Ubuntu) ou
#                            /var/log/messages (RHEL/CentOS)
# ==============================================================================

LOG_FILE="/var/log/syslog"

if [ ! -f "$LOG_FILE" ] && [ -f "/var/log/messages" ]; then
    LOG_FILE="/var/log/messages"
fi

if [ ! -r "$LOG_FILE" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de log $LOG_FILE."
    echo "Dica: Execute o script com sudo."
    exit 1
fi

echo "============================================================"
echo "Ranking: Frequencia de Mensagens de Log por Servico"
echo "Arquivo analisado: $LOG_FILE"
echo "============================================================"
printf "%-30s | %s\n" "SERVICO / PROCESSO" "TOTAL DE MENSAGENS"
echo "------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. awk '{print $5}':
#    - No formato padrao do syslog, a quinta coluna contem a identificacao
#      do servico ou programa emissor (ex: "sshd[1234]:", "systemd[1]:", "CRON[56]:").
# 2. sed -E 's/(\[[0-9]+\])?:?$//':
#    - Expressao regular para higienizar o nome:
#      - '(\[[0-9]+\])?': remove o identificador de PID entre colchetes.
#      - ':?$': remove os dois-pontos finais, deixando apenas o nome puro do servico.
# 3. grep -v "^$":
#    - Remove linhas em branco que possam surgir de entradas malformadas.
# 4. sort:
#    - Ordena os nomes alfabeticamente para permitir o agrupamento.
# 5. uniq -c:
#    - Conta quantas vezes cada servico gerou uma linha de log.
# 6. sort -nr:
#    - Ordena de maneira numerica e reversa para exibir o lider no topo.
# 7. head -n 20:
#    - Limita aos 20 servicos mais volumosos.
# 8. awk:
#    - Formata a apresentacao final.

awk '{print $5}' "$LOG_FILE" \
    | sed -E 's/(\[[0-9]+\])?:?$//' \
    | grep -v "^$" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -n 20 \
    | awk '{printf "%-30s | %d\n", $2, $1}'

echo "============================================================"
