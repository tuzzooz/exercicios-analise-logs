#!/bin/bash
# ==============================================================================
# Exercicio 3 - Auditoria do Uso do Sudo
# 
# Objetivo: Auditar o uso do comando sudo, exibindo o usuario que executou
#           o comando, a data/hora do evento e o comando executado.
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
    echo "Dica: Execute o script com sudo para ter permissao de acesso aos logs."
    exit 1
fi

echo "================================================================================================"
echo "Relatorio: Auditoria de Comandos Executados via Sudo"
echo "Arquivo analisado: $LOG_FILE"
echo "================================================================================================"
printf "%-16s | %-15s | %s\n" "DATA/HORA" "USUARIO" "COMANDO EXECUTADO"
echo "------------------------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. grep -E "sudo:.*COMMAND=":
#    - Procura por entradas geradas pelo processo do sudo que registraram a execucao de comandos.
# 2. sed -E 's/.../.../':
#    - Grupo 1: '^([A-Za-z]{3} +[0-9]+ [0-9:]+)' captura a data e hora (ex: Sep 9 10:20:00).
#    - '[^ ]+ sudo:[ ]*' descarta o hostname e o rotulo do servico.
#    - Grupo 2: '([^ ]+)' captura o nome do usuario que invocou o sudo.
#    - ' : .*COMMAND=' salta informacoes intermediarias (TTY, PWD, USER alvo).
#    - Grupo 3: '(.*)$' captura a linha inteira do comando executado.
#    - A substituicao reformata a linha em colunas claras.

grep -E "sudo:.*COMMAND=" "$LOG_FILE" \
    | sed -E 's/^([A-Za-z]{3} +[0-9]+ [0-9:]+) [^ ]+ sudo:[ ]*([^ ]+) :.*COMMAND=(.*)$/\1 | \2 | \3/' \
    | awk -F " \\| " '{printf "%-16s | %-15s | %s\n", $1, $2, $3}'

echo "================================================================================================"
