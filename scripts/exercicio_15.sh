#!/bin/bash
# ==============================================================================
# Exercicio 15 - Filtro de Log por Horario (14h as 15h)
# 
# Objetivo: Filtrar um arquivo de log (/var/log/syslog) para exibir apenas
#           os eventos ocorridos entre as 14h e 15h de um dia especifico.
#
# Arquivo de log apropriado: /var/log/syslog (ou /var/log/auth.log)
# ==============================================================================

LOG_FILE="/var/log/syslog"

# Permite passar a data como primeiro argumento; se nao informada, usa a data atual
# Formato esperado padrao syslog: "Mês Dia" (ex: "Sep  9" ou "Sep 10")
DATA_ESPECIFICA="${1:-$(date '+%b %e')}"

if [ ! -r "$LOG_FILE" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de log $LOG_FILE."
    echo "Dica: Execute o script com sudo."
    exit 1
fi

echo "================================================================================"
echo "Relatorio: Eventos Ocorridos Entre 14:00:00 e 14:59:59"
echo "Arquivo analisado: $LOG_FILE"
echo "Data filtrada:     '$DATA_ESPECIFICA'"
echo "================================================================================"

# Raciocinio da regex:
# 1. '^': Ancora no inicio da linha para garantir que a data corresponda ao timestamp de emissao.
# 2. '${DATA_ESPECIFICA}': Corresponde ao dia selecionado.
# 3. ' 14:[0-5][0-9]:[0-5][0-9]':
#    - '14:' captura todas as mensagens das 14 horas.
#    - '[0-5][0-9]' garante minutos validos de 00 a 59.
#    - '[0-5][0-9]' garante segundos validos de 00 a 59.
# 4. Tambem cobre o formato ISO 8601 (ex: 2026-09-09T14:xx:xx) comum em versoes mais novas do systemd.

grep -E "(^${DATA_ESPECIFICA} 14:[0-5][0-9]:[0-5][0-9]|T14:[0-5][0-9]:[0-5][0-9])" "$LOG_FILE"

TOTAL=$(grep -c -E "(^${DATA_ESPECIFICA} 14:[0-5][0-9]:[0-5][0-9]|T14:[0-5][0-9]:[0-5][0-9])" "$LOG_FILE")
echo "--------------------------------------------------------------------------------"
echo "Total de eventos encontrados na faixa das 14h: $TOTAL"
echo "================================================================================"
