#!/bin/bash
# ==============================================================================
# Exercicio 11 - Pacotes Instalados na Ultima Semana
# 
# Objetivo: Filtrar o log de pacotes do sistema e listar os pacotes instalados
#           nos ultimos 7 dias, acompanhados da respectiva data de instalacao.
#
# Arquivo de log apropriado: /var/log/dpkg.log (Debian/Ubuntu)
# ==============================================================================

LOG_FILE="/var/log/dpkg.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "Erro: Arquivo de log de pacotes $LOG_FILE nao encontrado."
    echo "Nota: Este script foi projetado para sistemas baseados em Debian/Ubuntu."
    exit 1
fi

# Calcula a data de corte de 7 dias atras no formato ISO (YYYY-MM-DD)
DATA_CORTE=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d 2>/dev/null)

if [ -z "$DATA_CORTE" ]; then
    # Fallback caso 'date -d' nao esteja disponivel
    DATA_CORTE=$(date +%Y-%m-%d)
fi

echo "================================================================================"
echo "Relatorio: Pacotes Instalados nos Ultimos 7 Dias (Desde $DATA_CORTE)"
echo "Arquivo analisado: $LOG_FILE"
echo "================================================================================"
printf "%-19s | %-35s | %s\n" "DATA/HORA" "NOME DO PACOTE" "VERSAO"
echo "--------------------------------------------------------------------------------"

# Raciocinio da pipeline:
# 1. cat "$LOG_FILE": se existir o log rotacionado anterior (dpkg.log.1), podemos incluir ambos.
# 2. grep "status installed":
#    - No dpkg.log, o evento 'status installed' indica conclusao bem-sucedida da instalacao.
# 3. awk -v limite="$DATA_CORTE" '{ ... }':
#    - Como o dpkg.log utiliza datas no padrao YYYY-MM-DD, a comparacao alfabetica
#      $1 >= limite filtra com precisao os registros dos ultimos 7 dias.
#    - $1, $2: Data e Hora da instalacao.
#    - $4: Nome do pacote instalado.
#    - $5: Versao do pacote.

ARQUIVOS_LOG=("$LOG_FILE")
[ -f "${LOG_FILE}.1" ] && ARQUIVOS_LOG+=("${LOG_FILE}.1")

cat "${ARQUIVOS_LOG[@]}" \
    | grep "status installed" \
    | awk -v limite="$DATA_CORTE" '
        $1 >= limite {
            data_hora = $1 " " $2;
            pacote = $4;
            versao = $5;
            printf "%-19s | %-35s | %s\n", data_hora, pacote, versao;
        }
    ' \
    | sort -r

echo "================================================================================"
