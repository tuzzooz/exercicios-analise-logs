#!/bin/bash
# ==============================================================================
# Exercicio 19 - Erros e Avisos de um Servico Especifico
# 
# Objetivo: Buscar por qualquer mensagem de erro ou aviso (error, warning)
#           gerada por um servico em execucao (exemplo padrao: sshd ou cron).
#
# Arquivo de log apropriado: /var/log/syslog (Debian/Ubuntu) ou
#                            /var/log/messages (RHEL/CentOS)
#                            (Tambem consulta /var/log/auth.log caso o servico seja sshd)
# ==============================================================================

# Permite passar o servico desejado via argumento de linha de comando; padrao: sshd
SERVICO="${1:-sshd}"

LOG_FILE="/var/log/syslog"

# Se o servico escolhido for sshd e existir auth.log com dados mais detalhados, podemos usa-lo
if [ "$SERVICO" = "sshd" ] && [ -r "/var/log/auth.log" ]; then
    LOG_FILE="/var/log/auth.log"
elif [ ! -f "$LOG_FILE" ] && [ -f "/var/log/messages" ]; then
    LOG_FILE="/var/log/messages"
fi

if [ ! -r "$LOG_FILE" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de log $LOG_FILE."
    echo "Dica: Execute o script com sudo."
    exit 1
fi

echo "================================================================================"
echo "Relatorio: Erros e Avisos do Servico '$SERVICO'"
echo "Arquivo analisado: $LOG_FILE"
echo "================================================================================"

# Raciocinio da expressao regular:
# 1. '-i': ignora diferencas entre maiusculas e minusculas (Case-Insensitive),
#          capturando 'Error', 'ERROR', 'Warning', 'WARN', etc.
# 2. '-E': regex estendida:
#    - '${SERVICO}(\[[0-9]+\])?:': identifica o servico acompanhado ou nao do PID.
#    - '.*(error|warn|warning|fatal|critical|failed)': procura ocorrencias de gravidade
#      na mensagem emitida pelo servico.

RESULTADOS=$(grep -iE "${SERVICO}(\[[0-9]+\])?:.*(error|warn|warning|fatal|critical|failed)" "$LOG_FILE")

if [ -n "$RESULTADOS" ]; then
    echo "$RESULTADOS" | awk '{
        data_hora = $1 " " $2 " " $3;
        linha = $0;
        sub(/^.*[a-zA-Z0-9_\-]+: /, "", linha);
        
        # Identifica se e erro ou aviso para destacar
        tipo = "AVISO/INFO";
        if (linha ~ /error|fatal|fail|crit/i) {
            tipo = "ERRO";
        } else if (linha ~ /warn/i) {
            tipo = "AVISO";
        }
        
        printf "%-16s | %-10s | %s\n", data_hora, tipo, linha;
    }'
else
    echo "Nenhuma mensagem de erro ou aviso encontrada para o servico '$SERVICO'."
fi

TOTAL=$(echo "$RESULTADOS" | grep -v "^$" | wc -l)
echo "--------------------------------------------------------------------------------"
echo "Total de alertas encontrados: $TOTAL"
echo "================================================================================"
