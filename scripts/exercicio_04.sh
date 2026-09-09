#!/bin/bash
# ==============================================================================
# Exercicio 4 - Logins Rejeitados por Outros Motivos
# 
# Objetivo: Identificar tentativas de login rejeitadas por motivos alem da senha
#           incorreta, tais como usuarios inexistentes, falta de permissao ou
#           contas bloqueadas/expiradas.
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

echo "===================================================================================================="
echo "Relatorio: Logins Rejeitados (Usuarios Inexistentes / Sem Permissao / Bloqueios)"
echo "Arquivo analisado: $LOG_FILE"
echo "===================================================================================================="
printf "%-16s | %-25s | %s\n" "DATA/HORA" "MOTIVO IDENTIFICADO" "DETALHE DO LOG"
echo "----------------------------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. grep -iE: busca por padroes comuns de rejeicao de autenticacao que nao sao falhas de senha simples:
#    - "invalid user": tentativas de login usando contas inexistentes.
#    - "not allowed": usuario restrito por diretivas de seguranca (ex: AllowUsers no sshd).
#    - "access denied": bloqueios via modulo pam_access ou politicas de grupo.
#    - "account.*(locked|expired)": contas que foram suspensas ou com prazo expirado.
# 2. awk '{ ... }':
#    - Analisa a linha e classifica o motivo correspondente para tornar o relatorio intuitivo.
#    - Formata a data/hora ($1, $2, $3), o motivo detectado e um resumo da mensagem.

grep -iE "invalid user|not allowed|access denied|account.*(locked|expired)" "$LOG_FILE" \
    | awk '{
        data_hora = $1 " " $2 " " $3;
        linha_completa = $0;
        
        # Categorizacao do motivo atraves de correspondencia com regex
        motivo = "Outro motivo de bloqueio";
        if (linha_completa ~ /invalid user/i) {
            motivo = "Usuario inexistente";
        } else if (linha_completa ~ /not allowed/i) {
            motivo = "Acesso nao permitido (Politica)";
        } else if (linha_completa ~ /access denied/i) {
            motivo = "Permissao negada (PAM/Access)";
        } else if (linha_completa ~ /expired/i) {
            motivo = "Conta expirada";
        } else if (linha_completa ~ /locked/i) {
            motivo = "Conta bloqueada";
        }

        # Extrai a partir do identificador do processo/mensagem para exibicao limpa
        sub(/^.*[a-zA-Z0-9_\-]+: /, "", linha_completa);
        if (length(linha_completa) > 55) {
            linha_completa = substr(linha_completa, 1, 52) "...";
        }

        printf "%-16s | %-25s | %s\n", data_hora, motivo, linha_completa;
    }'

echo "===================================================================================================="
