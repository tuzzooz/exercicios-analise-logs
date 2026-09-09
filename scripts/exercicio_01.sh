#!/bin/bash
# ==============================================================================
# Exercicio 1 - Tentativas de Senha Incorreta
# 
# Objetivo: Listar todos os usuarios que tentaram fazer login com a senha
#           incorreta, exibindo o nome do usuario e a quantidade de falhas.
#
# Arquivo de log apropriado: /var/log/auth.log (Debian/Ubuntu) ou
#                            /var/log/secure (RHEL/CentOS/Fedora)
# ==============================================================================

# Definicao do arquivo de log padrao
LOG_FILE="/var/log/auth.log"

# Fallback caso esteja em distribuicao baseada em RedHat
if [ ! -f "$LOG_FILE" ] && [ -f "/var/log/secure" ]; then
    LOG_FILE="/var/log/secure"
fi

# Verifica se o arquivo de log existe e se temos permissao de leitura
if [ ! -r "$LOG_FILE" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de log em $LOG_FILE."
    echo "Dica: Execute o script com sudo para ter permissao de acesso aos logs."
    exit 1
fi

echo "============================================================"
echo "Relatorio: Tentativas de Login com Senha Incorreta"
echo "Arquivo analisado: $LOG_FILE"
echo "============================================================"
printf "%-25s | %s\n" "USUARIO" "TENTATIVAS FALHAS"
echo "------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. grep -E "Failed password": filtra apenas linhas que indicam falha de autenticacao por senha no sshd.
# 2. sed -E 's/.*Failed password for (invalid user )?([^ ]+).*/\2/':
#    - Utiliza expressao regular com grupo de captura para extrair somente o usuario.
#    - '(invalid user )?' trata tanto usuarios existentes quanto inexistentes que tentaram login.
#    - '([^ ]+)' captura a palavra referente ao nome de usuario.
#    - '\2' substitui toda a linha apenas pelo nome do usuario capturado.
# 3. sort: ordena a lista alfabeticamente (obrigatorio antes do uniq).
# 4. uniq -c: conta as ocorrencias repetidas de cada usuario.
# 5. sort -nr: ordena numericamente de forma decrescente (quem teve mais falhas aparece primeiro).
# 6. awk: formata a saida organizando as colunas alinhadas.

grep -E "Failed password" "$LOG_FILE" \
    | sed -E 's/.*Failed password for (invalid user )?([^ ]+).*/\2/' \
    | sort \
    | uniq -c \
    | sort -nr \
    | awk '{printf "%-25s | %d\n", $2, $1}'

echo "============================================================"
