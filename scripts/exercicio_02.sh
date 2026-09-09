#!/bin/bash
# ==============================================================================
# Exercicio 2 - Logins Bem-Sucedidos
# 
# Objetivo: Gerar um relatorio com todos os logins bem-sucedidos no sistema,
#           incluindo o nome do usuario e a data/hora do acesso.
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

echo "================================================================================"
echo "Relatorio: Logins Bem-Sucedidos no Sistema"
echo "Arquivo analisado: $LOG_FILE"
echo "================================================================================"
printf "%-16s | %-20s | %-16s | %s\n" "DATA/HORA" "USUARIO" "IP ORIGEM" "METODO"
echo "--------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. grep -E "Accepted (password|publickey)":
#    - Filtra as linhas do sshd indicando sucesso na autenticacao por senha ou chave publica.
# 2. awk '{ ... }':
#    - $1, $2, $3: Mes, Dia e Hora do evento (ex: "Sep 9 14:15:00").
#    - $9: Nome do usuario autenticado com sucesso.
#    - $11: Endereco IP de onde partiu a conexao.
#    - $6: Metodo utilizado (password ou publickey).
#    - printf: Formata em colunas alinhadas para montar o relatorio.

grep -E "Accepted (password|publickey)" "$LOG_FILE" \
    | awk '{
        data_hora = $1 " " $2 " " $3;
        usuario = $9;
        ip = $11;
        metodo = $6;
        printf "%-16s | %-20s | %-16s | %s\n", data_hora, usuario, ip, metodo;
    }'

echo "================================================================================"
