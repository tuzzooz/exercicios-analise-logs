#!/bin/bash
# ==============================================================================
# Exercicio 20 - Tempo de Permanencia de Usuario Logado
# 
# Objetivo: Utilizar as informacoes de login e logout para calcular o tempo
#           total que um usuario permaneceu logado no sistema.
#
# Arquivo de log apropriado: /var/log/wtmp (analisado via utilitario 'last')
# ==============================================================================

LOG_WTMP="/var/log/wtmp"

# Permite especificar o usuario via argumento; se nao informado, usa o usuario atual
USUARIO_ALVO="${1:-$USER}"

if [ ! -r "$LOG_WTMP" ]; then
    echo "Erro: Nao foi possivel ler o arquivo de auditoria em $LOG_WTMP."
    echo "Dica: Execute o script com sudo."
    exit 1
fi

echo "================================================================================"
echo "Relatorio: Historico de Sessoes e Tempo Logado do Usuario: '$USUARIO_ALVO'"
echo "Arquivo analisado: $LOG_WTMP"
echo "================================================================================"
printf "%-12s | %-10s | %-16s | %-16s | %s\n" "USUARIO" "TERMINAL" "LOGIN" "LOGOUT" "DURACAO"
echo "--------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. last -R "$USUARIO_ALVO" -f "$LOG_WTMP":
#    - '-R': omite a coluna de hostname/IP para evitar desalinhamento.
#    - Filtra diretamente as entradas associadas ao usuario informado no arquivo wtmp.
# 2. grep -v -E "(wtmp begins|reboot|shutdown|^$)":
#    - Descarta o rodape informativo do wtmp e registros de reinicializacao.
# 3. awk '{ ... }':
#    - Extrai terminal, data/hora de login e logout.
#    - Localiza o campo de duracao delimitado por parenteses ex: '(01:30)'.
#    - Acumula matematicamente as horas e minutos de todas as sessoes concluidas.
#    - Exibe no bloco END o tempo total consolidado em horas e minutos.

last -R "$USUARIO_ALVO" -f "$LOG_WTMP" \
    | grep -v -E "(wtmp begins|reboot|shutdown|^$)" \
    | awk '
        BEGIN {
            minutos_totais = 0;
            sessoes_fechadas = 0;
            sessoes_ativas = 0;
        }
        {
            usuario = $1;
            terminal = $2;
            data_login = $3 " " $4 " " $5 " " $6;
            
            # Linha de sessao ainda ativa
            if ($0 ~ /still logged in/) {
                sessoes_ativas++;
                printf "%-12s | %-10s | %-16s | %-16s | %s\n", usuario, terminal, data_login, "Em andamento", "Ativa";
                next;
            }

            # Procura pelo campo de duracao entre parenteses: (HH:MM) ou (D+HH:MM)
            duracao_str = "";
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^\([0-9]/) {
                    duracao_str = $i;
                    gsub(/[()]/, "", duracao_str);
                    break;
                }
            }

            data_logout = $(i-1);

            if (duracao_str != "") {
                sessoes_fechadas++;
                
                # Trata sessoes que duraram mais de um dia: (dias+horas:minutos)
                dias = 0;
                tempo_hm = duracao_str;
                if (duracao_str ~ /\+/) {
                    split(duracao_str, partes_dias, "+");
                    dias = partes_dias[1];
                    tempo_hm = partes_dias[2];
                }

                split(tempo_hm, arr_hm, ":");
                horas = arr_hm[1];
                mins = arr_hm[2];

                minutos_totais += (dias * 1440) + (horas * 60) + mins;

                printf "%-12s | %-10s | %-16s | %-16s | %s\n", usuario, terminal, data_login, data_logout, duracao_str;
            }
        }
        END {
            print "--------------------------------------------------------------------------------";
            horas_totais = int(minutos_totais / 60);
            mins_restantes = minutos_totais % 60;
            printf "Resumo para '\''%s'\'':\n", "'"$USUARIO_ALVO"'";
            printf "  - Sessoes concluidas analisadas: %d\n", sessoes_fechadas;
            printf "  - Sessoes ainda ativas:          %d\n", sessoes_ativas;
            printf "  - Tempo total logado:            %d horas e %d minutos (%d minutos no total)\n", horas_totais, mins_restantes, minutos_totais;
        }
    '

echo "================================================================================"
