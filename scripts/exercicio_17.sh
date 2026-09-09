#!/bin/bash
# ==============================================================================
# Exercicio 17 - Login Falho com Usuario e Metodo de Autenticacao
# 
# Objetivo: Para cada tentativa de login falho, extrair o nome do usuario
#           e o metodo de autenticacao correspondente (ex: ssh, su, login, sudo).
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

echo "========================================================================================"
echo "Relatorio: Tentativas de Login Falhas com Usuario e Metodo de Autenticacao"
echo "Arquivo analisado: $LOG_FILE"
echo "========================================================================================"
printf "%-16s | %-15s | %-20s | %s\n" "DATA/HORA" "METODO" "USUARIO" "DETALHE"
echo "----------------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. grep -E: seleciona linhas que indicam falha de autenticacao:
#    - "Failed password": falha no daemon sshd.
#    - "authentication failure": falha de autenticacao via modulos PAM (su, sudo, login, ssh).
#    - "FAILED LOGIN": falha no login em console local (tty).
#    - "FAILED SU": tentativa negada de troca de usuario via comando su.
# 2. awk '{ ... }':
#    - Extrai o timestamp ($1, $2, $3).
#    - Detecta o servico/metodo de autenticacao analisando a linha.
#    - Extrai com regex o nome do usuario correspondente a cada caso.

grep -E "(Failed password|authentication failure|FAILED LOGIN|FAILED SU)" "$LOG_FILE" \
    | awk '{
        data_hora = $1 " " $2 " " $3;
        linha = $0;
        metodo = "desconhecido";
        usuario = "-";
        detalhe = "";

        if (linha ~ /sshd/) {
            metodo = "ssh";
            if (match(linha, /Failed password for (invalid user )?([^ ]+)/, arr)) {
                usuario = arr[2];
            }
        } else if (linha ~ /su(\[[0-9]+\])?:/) {
            metodo = "su";
            if (match(linha, /user=([^ ]+)/, arr)) {
                usuario = arr[1];
            } else if (match(linha, /FAILED SU \(to ([^)]+)\) ([^ ]+)/, arr)) {
                usuario = arr[1] " (por " arr[2] ")";
            }
        } else if (linha ~ /sudo:/) {
            metodo = "sudo";
            if (match(linha, /user=([^ ]+)/, arr)) {
                usuario = arr[1];
            }
        } else if (linha ~ /login(\[[0-9]+\])?:/) {
            metodo = "console/tty";
            if (match(linha, /FOR '\''([^'\'']+)'\''/, arr)) {
                usuario = arr[1];
            } else if (match(linha, /user=([^ ]+)/, arr)) {
                usuario = arr[1];
            }
        }

        # Se nao identificou pelo bloco anterior, tenta extrair padrao generico PAM 'user='
        if (usuario == "-" && match(linha, /user=([^ ]+)/, arr)) {
            usuario = arr[1];
        }

        printf "%-16s | %-15s | %-20s | %s\n", data_hora, metodo, usuario, "Falha de autenticacao";
    }'

echo "========================================================================================"
