# Exercícios: Análise de Logs Internos do Sistema

Resolução dos exercícios práticos de análise e auditoria de logs internos do Linux (`/var/log`). Cada atividade possui um script shell independente na pasta `scripts/`, contendo comentários detalhados que explicam o raciocínio, os comandos utilizados (`grep`, `awk`, `sed`, `sort`, `uniq`, etc.) e as expressões regulares aplicadas.

---

## Estrutura dos Exercícios

| Ex. | Categoria | Descrição | Arquivo em `/var/log` | Script |
|:---:|:---|:---|:---|:---|
| **01** | Tentativas de Senha Incorreta | Listar usuários com tentativas de senha incorreta e quantidade de falhas | `/var/log/auth.log` | [`scripts/exercicio_01.sh`](scripts/exercicio_01.sh) |
| **02** | Tentativas de Senha Incorreta | Relatório de logins bem-sucedidos (usuário e data/hora) | `/var/log/auth.log` | [`scripts/exercicio_02.sh`](scripts/exercicio_02.sh) |
| **03** | Tentativas de Senha Incorreta | Auditoria de uso do comando sudo (usuário, data/hora e comando) | `/var/log/auth.log` | [`scripts/exercicio_03.sh`](scripts/exercicio_03.sh) |
| **04** | Tentativas de Senha Incorreta | Identificar logins rejeitados por outros motivos (inexistentes, permissão) | `/var/log/auth.log` | [`scripts/exercicio_04.sh`](scripts/exercicio_04.sh) |
| **06** | Atividade do Sistema | Identificar a data e hora do último boot | `/var/log/wtmp` | [`scripts/exercicio_06.sh`](scripts/exercicio_06.sh) |
| **07** | Atividade do Sistema | Listar todos os eventos de desligamento (shutdown) e reinicialização | `/var/log/wtmp` | [`scripts/exercicio_07.sh`](scripts/exercicio_07.sh) |
| **08** | Atividade do Sistema | Listar serviços iniciados ou parados recentemente com data | `/var/log/syslog` | [`scripts/exercicio_08.sh`](scripts/exercicio_08.sh) |
| **11** | Pacotes e Segurança | Pacotes instalados na última semana com a data | `/var/log/dpkg.log` | [`scripts/exercicio_11.sh`](scripts/exercicio_11.sh) |
| **12** | Pacotes e Segurança | Identificar todos os pacotes que foram removidos do sistema | `/var/log/dpkg.log` | [`scripts/exercicio_12.sh`](scripts/exercicio_12.sh) |
| **13** | Pacotes e Segurança | Rastrear comandos de pacotes (apt, apt-get, dpkg), usuário e ação | `/var/log/auth.log` | [`scripts/exercicio_13.sh`](scripts/exercicio_13.sh) |
| **14** | Tempo de Atividade | Diferença entre o último evento de boot e desligamento | `/var/log/wtmp` | [`scripts/exercicio_14.sh`](scripts/exercicio_14.sh) |
| **15** | Tempo de Atividade | Filtrar eventos ocorridos entre as 14h e 15h de um dia específico | `/var/log/syslog` | [`scripts/exercicio_15.sh`](scripts/exercicio_15.sh) |
| **16** | Falhas Críticas e Erros | Serviço gerando maior quantidade de logs (ordem decrescente) | `/var/log/syslog` | [`scripts/exercicio_16.sh`](scripts/exercicio_16.sh) |
| **17** | Falhas Críticas e Erros | Extrair usuário e método de autenticação de cada login falho | `/var/log/auth.log` | [`scripts/exercicio_17.sh`](scripts/exercicio_17.sh) |
| **18** | Falhas Críticas e Erros | Monitorar tentativas de login falhas em tempo real | `/var/log/auth.log` | [`scripts/exercicio_18.sh`](scripts/exercicio_18.sh) |
| **19** | Falhas Críticas e Erros | Buscar mensagens de erro ou aviso (error, warning) de um serviço | `/var/log/syslog` | [`scripts/exercicio_19.sh`](scripts/exercicio_19.sh) |
| **20** | Falhas Críticas e Erros | Calcular o tempo total que um usuário permaneceu logado | `/var/log/wtmp` | [`scripts/exercicio_20.sh`](scripts/exercicio_20.sh) |

---

## Como Executar

### 1. Permissões de Execução
No terminal Linux, conceda permissão de execução aos scripts:

```bash
chmod +x scripts/*.sh
```

### 2. Executando os Scripts
Como arquivos em `/var/log` (como `auth.log` e `syslog`) contêm dados sensíveis do sistema operacional, a maioria das leituras requer privilégios de superusuário (`sudo`):

```bash
# Exemplos:
sudo ./scripts/exercicio_01.sh
sudo ./scripts/exercicio_02.sh
sudo ./scripts/exercicio_03.sh

# Scripts com parametros opcionais:
sudo ./scripts/exercicio_15.sh "Sep  9"
sudo ./scripts/exercicio_19.sh cron
sudo ./scripts/exercicio_20.sh nome_do_usuario
```
