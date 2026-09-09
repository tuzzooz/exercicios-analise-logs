#!/bin/bash
# ==============================================================================
# Exercicio 14 - Analise de Tempo de Atividade (Boot vs Desligamento)
# 
# Objetivo: Analisar a diferenca de tempo entre o ultimo evento de boot
#           e o evento de desligamento (shutdown) registrado no sistema.
#
# Arquivo de log apropriado: /var/log/wtmp (consultado via 'last -x -F')
# ==============================================================================

LOG_WTMP="/var/log/wtmp"

echo "================================================================================"
echo "Relatorio: Diferenca entre Ultimo Boot e Evento de Desligamento"
echo "Arquivo analisado: $LOG_WTMP"
echo "================================================================================"

if [ ! -r "$LOG_WTMP" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de auditoria em $LOG_WTMP."
    echo "Dica: Execute o script com sudo."
    exit 1
fi

# Raciocinio:
# 1. last -x -F -f "$LOG_WTMP":
#    - Lista os registros de boot e shutdown com datas completas (incluindo ano e segundos).
# 2. Extrai a data do ultimo reboot e do ultimo shutdown:

LINHA_BOOT=$(last -x -F -f "$LOG_WTMP" reboot | head -n 1)
LINHA_SHUTDOWN=$(last -x -F -f "$LOG_WTMP" shutdown | head -n 1)

DATA_BOOT_STR=$(echo "$LINHA_BOOT" | awk '{print $5, $6, $7, $8, $9}')
DATA_SHUTDOWN_STR=$(echo "$LINHA_SHUTDOWN" | awk '{print $5, $6, $7, $8, $9}')

echo "Ultimo Boot registrado:       $DATA_BOOT_STR"
echo "Ultimo Shutdown registrado:   $DATA_SHUTDOWN_STR"
echo "--------------------------------------------------------------------------------"

# Conversao para Epoch Timestamp (segundos desde 1970) para calculo matematico
TS_BOOT=$(date -d "$DATA_BOOT_STR" +%s 2>/dev/null)
TS_SHUTDOWN=$(date -d "$DATA_SHUTDOWN_STR" +%s 2>/dev/null)

if [ -n "$TS_BOOT" ] && [ -n "$TS_SHUTDOWN" ]; then
    # Calcula a diferenca absoluta em segundos
    if [ "$TS_BOOT" -ge "$TS_SHUTDOWN" ]; then
        DIF_SEGUNDOS=$((TS_BOOT - TS_SHUTDOWN))
        echo "Intervalo: O sistema foi iniciado apos o ultimo desligamento."
        echo "Tempo decorrido entre o desligamento e o novo boot (Downtime):"
    else
        DIF_SEGUNDOS=$((TS_SHUTDOWN - TS_BOOT))
        echo "Intervalo: O ultimo registro foi um desligamento apos o boot."
        echo "Tempo que o sistema permaneceu ligado ate desligar (Uptime da sessao):"
    fi

    # Conversao de segundos em Dias, Horas, Minutos e Segundos
    DIAS=$((DIF_SEGUNDOS / 86400))
    HORAS=$(( (DIF_SEGUNDOS % 86400) / 3600 ))
    MINUTOS=$(( (DIF_SEGUNDOS % 3600) / 60 ))
    SEGUNDOS=$((DIF_SEGUNDOS % 60))

    printf "-> %d dias, %d horas, %d minutos e %d segundos (%d segundos no total)\n" \
        "$DIAS" "$HORAS" "$MINUTOS" "$SEGUNDOS" "$DIF_SEGUNDOS"
else
    echo "Nao foi possivel converter as datas para calculo diferencial."
fi

echo "--------------------------------------------------------------------------------"
if [ -f "/proc/uptime" ]; then
    UPTIME_KERNEL=$(awk '{print int($1)}' /proc/uptime)
    echo "Tempo de atividade atual do sistema (Uptime corrente): $((UPTIME_KERNEL / 3600))h $(((UPTIME_KERNEL % 3600) / 60))m"
fi
echo "================================================================================"
