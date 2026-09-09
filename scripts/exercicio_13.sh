#!/bin/bash
# ==============================================================================
# Exercicio 13 - Rastreio de Comandos de Gerenciamento de Pacotes
# 
# Objetivo: Rastrear a execucao de comandos de gerenciamento de pacotes
#           (apt, apt-get ou dpkg), mostrando o usuario que executou e a acao.
#
# Arquivos de log apropriados:
#   1. /var/log/auth.log (audita chamadas com sudo de apt/apt-get/dpkg)
#   2. /var/log/apt/history.log (historico detalhado de operacoes do APT)
# ==============================================================================

LOG_AUTH="/var/log/auth.log"
LOG_APT="/var/log/apt/history.log"

echo "================================================================================================"
echo "Relatorio: Rastreio de Comandos de Pacotes (apt, apt-get, dpkg)"
echo "================================================================================================"
printf "%-16s | %-15s | %-12s | %s\n" "DATA/HORA" "USUARIO" "GERENCIADOR" "ACAO / PARAMETROS"
echo "------------------------------------------------------------------------------------------------"

# Raciocinio da pipeline (via /var/log/auth.log):
# Como o gerenciamento de pacotes exige root, os administradores executam via sudo.
# 1. grep -E "sudo:.*COMMAND=.*/(apt|apt-get|dpkg)":
#    - Filtra as chamadas de sudo para os binarios de pacotes.
# 2. sed -E:
#    - Extrai timestamp, usuario que rodou o sudo, o binario (apt/dpkg) e a acao.
# 3. awk:
#    - Exibe em colunas formatadas.

if [ -r "$LOG_AUTH" ]; then
    grep -E "sudo:.*COMMAND=.*/(apt|apt-get|dpkg)" "$LOG_AUTH" \
        | sed -E 's/^([A-Za-z]{3} +[0-9]+ [0-9:]+) [^ ]+ sudo:[ ]*([^ ]+) :.*COMMAND=.*(apt|apt-get|dpkg) (.*)$/\1 | \2 | \3 | \4/' \
        | awk -F " \\| " '{printf "%-16s | %-15s | %-12s | %s\n", $1, $2, $3, $4}'
elif [ -r "$LOG_APT" ]; then
    # Alternativa lendo blocos do /var/log/apt/history.log
    echo "Consultando fonte alternativa: $LOG_APT"
    awk '
        /^Start-Date:/ { data = $2 " " $3 }
        /^Commandline:/ { sub(/^Commandline: /, ""); cmd = $0 }
        /^Requested-By:/ { sub(/^Requested-By: /, ""); user = $0 }
        /^End-Date:/ {
            if (cmd != "") {
                printf "%-19s | %-15s | %s\n", data, user, cmd;
            }
            cmd = ""; user = "";
        }
    ' "$LOG_APT"
else
    echo "Erro: Nao foi possivel acessar os logs de auditoria."
    echo "Dica: Execute o script com sudo."
    exit 1
fi

echo "================================================================================================"
