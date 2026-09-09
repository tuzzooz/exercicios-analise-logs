#!/bin/bash
# ==============================================================================
# Exercicio 18 - Monitoramento de Falhas de Login em Tempo Real
# 
# Objetivo: Monitorar as tentativas de login com falha em tempo real,
#           exibindo a linha de log imediatamente apos o evento acontecer.
#
# Arquivo de log apropriado: /var/log/auth.log (Debian/Ubuntu) ou
#                            /var/log/secure (RHEL/CentOS/Fedora)
# ==============================================================================

LOG_FILE="/var/log/auth.log"

if [ ! -f "$LOG_FILE" ] && [ -f "/var/log/secure" ]; then
    LOG_FILE="/var/log/secure"
fi

if [ ! -r "$LOG_FILE" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de log em $LOG_FILE."
    echo "Dica: Execute o script com sudo."
    exit 1
fi

echo "================================================================================"
echo "Monitoramento em Tempo Real: Tentativas de Login Falhas"
echo "Arquivo monitorado: $LOG_FILE"
echo "Pressione [Ctrl+C] para interromper o monitoramento."
echo "================================================================================"

# Captura sinal de interrupcao (SIGINT / Ctrl+C) para encerramento gracioso
trap 'echo -e "\nMonitoramento finalizado pelo usuario."; exit 0' SIGINT

# Raciocinio dos comandos aplicados:
# 1. tail -F -n 0 "$LOG_FILE":
#    - '-F' (follow by name and retry): continua acompanhando o arquivo mesmo que
#      ocorra rotacao de logs (logrotate) e o arquivo seja recriado.
#    - '-n 0': inicia a captura apenas a partir dos novos eventos gerados em tempo real.
# 2. grep --line-buffered -E "...":
#    - '--line-buffered': instrui o grep a descarregar imediatamente cada linha para
#      a saida padrao (stdout), evitando que o buffer de 4KB do pipe retenha as
#      mensagens e atrase a visualizacao em tempo real.
#    - '-E': expressao regular estendida cobrindo falhas em sshd, PAM, tty e su.

tail -F -n 0 "$LOG_FILE" \
    | grep --line-buffered -E "(Failed password|authentication failure|FAILED LOGIN|FAILED SU)"
