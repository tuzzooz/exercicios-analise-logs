#!/bin/bash
# ==============================================================================
# Exercicio 7 - Eventos de Desligamento e Reinicializacao
# 
# Objetivo: Encontrar e listar todos os eventos de desligamento (shutdown)
#           ou reinicializacao (reboot) do sistema.
#
# Arquivo de log apropriado: /var/log/wtmp (analisado via 'last -x')
#                            ou /var/log/syslog
# ==============================================================================

LOG_WTMP="/var/log/wtmp"

echo "========================================================================================"
echo "Relatorio: Eventos de Desligamento (Shutdown) e Reinicializacao (Reboot)"
echo "Fonte principal: $LOG_WTMP (utilizando 'last -x')"
echo "========================================================================================"
printf "%-12s | %-16s | %-32s | %s\n" "TIPO" "INICIO" "TERMINO / ESTADO" "DURACAO"
echo "----------------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. last -x -f "$LOG_WTMP":
#    - O parametro '-x' inclui linhas de controle de sistema como shutdown e runlevel changes.
# 2. grep -E "^(reboot|shutdown)":
#    - Utiliza expressao regular para filtrar apenas linhas que comecem exatamente com 'reboot' ou 'shutdown'.
# 3. awk:
#    - Analisa cada linha do last e extrai o tipo de evento, timestamp de inicio e termino.
#    - Normaliza a exibicao para um formato tabular legivel.

if [ -r "$LOG_WTMP" ]; then
    last -x -f "$LOG_WTMP" \
        | grep -E "^(reboot|shutdown)" \
        | awk '{
            tipo = toupper($1);
            data_inicio = $5 " " $6 " " $7;
            estado = $8 " " $9 " " $10;
            duracao = $NF;
            printf "%-12s | %-16s | %-32s | %s\n", tipo, data_inicio, estado, duracao;
        }'
else
    # Fallback caso o wtmp nao esteja disponivel ou sem permissao
    LOG_SYSLOG="/var/log/syslog"
    if [ -r "$LOG_SYSLOG" ]; then
        echo "Lendo eventos de desligamento/reboot via $LOG_SYSLOG:"
        grep -E "systemd-shutdown|systemd\[1\]: (Starting Reboot|Starting Power-Off|Shutting down)" "$LOG_SYSLOG" \
            | awk '{print $1, $2, $3, "-", substr($0, index($0,$5))}'
    else
        echo "Erro: Permissao negada ou arquivos de log nao encontrados."
        echo "Dica: Execute o script com sudo."
        exit 1
    fi
fi

echo "========================================================================================"
