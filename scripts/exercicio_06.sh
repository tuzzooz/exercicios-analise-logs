#!/bin/bash
# ==============================================================================
# Exercicio 6 - Ultimo Boot do Sistema
# 
# Objetivo: Identificar quando o sistema foi inicializado pela ultima vez,
#           exibindo a data e a hora exata do ultimo boot.
#
# Arquivo de log apropriado: /var/log/wtmp (consultado via utilitario 'last')
#                            ou alternativamente /var/log/syslog
# ==============================================================================

LOG_WTMP="/var/log/wtmp"
LOG_SYSLOG="/var/log/syslog"

echo "============================================================"
echo "Relatorio: Ultima Inicializacao do Sistema (Boot)"
echo "============================================================"

# Metodo 1 (Principal): Consulta direta ao arquivo binario de auditoria /var/log/wtmp
# O /var/log/wtmp registra todas as inicializacoes (reboot), desligamentos e logins.
# O utilitario padrao do Linux para ler esse log e o 'last'.
if [ -r "$LOG_WTMP" ]; then
    echo "Fonte primária: $LOG_WTMP (lido via last)"
    
    # Raciocinio:
    # 1. last -F -n 1 reboot:
    #    - '-F': exibe datas e horarios completos com segundos e ano.
    #    - '-n 1': limita apenas ao registro mais recente.
    #    - 'reboot': filtra apenas eventos de boot do sistema registrados no wtmp.
    # 2. grep "^reboot": garante que pegamos a linha do evento e ignoramos o rodape do wtmp.
    # 3. awk '{print ...}': formata os campos contendo dia da semana, mes, dia, hora e ano.
    
    ULTIMO_BOOT=$(last -F -n 1 reboot | grep "^reboot" | awk '{print $5, $6, $7, $8, $9}')
    
    if [ -n "$ULTIMO_BOOT" ]; then
        echo "Data e Hora do Ultimo Boot: $ULTIMO_BOOT"
    else
        echo "Nenhum registro de reboot encontrado no $LOG_WTMP."
    fi
else
    # Metodo 2 (Fallback via syslog textual):
    # Procura no /var/log/syslog pela mensagem de inicializacao do kernel ou systemd.
    if [ -r "$LOG_SYSLOG" ]; then
        echo "Fonte alternativa: $LOG_SYSLOG"
        
        # Raciocinio:
        # Busca no syslog pela inicializacao do kernel ('Linux version') ou subida do systemd
        REGISTRO=$(grep -E "(Linux version|systemd\[1\]: Starting)" "$LOG_SYSLOG" | tail -n 1)
        DATA_HORA=$(echo "$REGISTRO" | awk '{print $1, $2, $3}')
        echo "Data e Hora do Ultimo Boot (syslog): $DATA_HORA"
    else
        echo "Erro: Nao foi possivel acessar nem $LOG_WTMP nem $LOG_SYSLOG."
        echo "Dica: Execute o script com privilegios de superusuario (sudo)."
        exit 1
    fi
fi

# Informacao complementar via uptime do kernel
if [ -f "/proc/uptime" ]; then
    UPTIME_SEGUNDOS=$(awk '{print int($1)}' /proc/uptime)
    DIAS=$((UPTIME_SEGUNDOS / 86400))
    HORAS=$(( (UPTIME_SEGUNDOS % 86400) / 3600 ))
    MINUTOS=$(( (UPTIME_SEGUNDOS % 3600) / 60 ))
    echo "Tempo de atividade atual: ${DIAS}d ${HORAS}h ${MINUTOS}m"
fi

echo "============================================================"
