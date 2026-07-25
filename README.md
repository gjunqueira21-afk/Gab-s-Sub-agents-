# Gab's Sub-agents — Time de Finanças + Jurídico

Nove subagentes especialistas (CredIA / Álamos / Ihus / Trading B3) + comando de atualização, com **instalador para Claude Code, Codex CLI e Hermes**. Calibrados para o stack Bun/Hono/TS + Python, Postgres, VPS.

| Agente | Especialidade |
|---|---|
| `github-deep-research` | Varredura profunda no GitHub: repositórios, novas techs, avaliação e POC |
| `fidc-economics` | Matemático PhD de FIDC: waterfall, subordinação, excess spread, stress, CVM 175 |
| `credito-analyst` | Mercado de crédito BR + US: modalidades, spreads, inadimplência, funding |
| `backtest-analyst` | Validação de backtests: métricas, anti-overfitting, custos B3, pairs/cointegração |
| `equity-research-br` | Research de ações B3 com mesas setoriais |
| `equity-research-us` | Research de ações US com mesas setoriais |
| `macro-economist` | Macro BR/US: Copom, Fed, curvas — e a transmissão para suas decisões |
| `quant-data-engineer` | Pipelines de dados: BCB, FRED, CVM, B3, SEC → Postgres |
| `juridico-societario` | Societário, fundos/veículos, planejamento tributário lícito, regulatório, sucessão |

Todos os agentes têm, no fim do arquivo:
- **Radar GitHub**: buscam ativamente no GitHub ferramentas/repos que ajudem na tarefa em andamento (com crivo de licença, atividade e fit de stack).
- **Protocolo de auto-atualização**: pesquisam as novidades de ~35 dias da sua área e editam a própria seção **Base dinâmica** do arquivo (nunca o frontmatter nem as seções fixas).

## Instalação rápida

```bash
git clone https://github.com/gjunqueira21-afk/gab-s-sub-agents-.git
cd gab-s-sub-agents-
chmod +x install.sh

./install.sh --list      # ver os agents
./install.sh claude      # Claude Code : agents + comando /atualizar-agents
./install.sh codex       # Codex CLI   : TOMLs + snippet no AGENTS.md
./install.sh hermes      # Hermes      : hermes-agents.json
./install.sh all         # todos
```

| Opção | O que faz |
|---|---|
| `--project` | Com `claude`: instala no projeto atual (`./.claude/`) em vez do nível de usuário |
| `--dir /caminho` | Destino personalizado (útil para Hermes e `CODEX_HOME` alternativo) |
| `--uninstall` | Remove os agents deste repositório do destino escolhido |
| `--list` | Lista os agents e suas descrições |

> Funciona em Linux e macOS. No Windows, use Git Bash ou WSL.
> **Instalação manual passo a passo** (e solução de problemas): veja o [MANUAL.md](MANUAL.md).

## Estrutura do repositório

```
agents/                  # 9 agents em Markdown (formato nativo do Claude Code)
commands/                # /atualizar-agents (comando do Claude Code)
codex/agents/            # os mesmos 9 em TOML (formato do Codex CLI)
codex/AGENTS-snippet.md  # snippet para o ~/.codex/AGENTS.md (Spawn + atualização)
hermes/                  # conversor md-to-hermes.ts + hermes-agents.json gerado
install.sh               # instalador para os três destinos
MANUAL.md                # instalação manual passo a passo
```

## Como usar no dia a dia (Claude Code)

- **Delegação automática**: descreva a tarefa; o `description` de cada agente guia o Claude a delegar sozinho.
- **Invocação explícita**: "Use o subagente juridico-societario para comparar holding × PF na estrutura da Ihus."
- **Encadeamento**: "macro-economist atualiza o cenário de Selic; depois fidc-economics reprecifica o funding; depois juridico-societario avalia se a estrutura de cessão continua ótima."

## Como atualizar os agents

- **Manual**: diga "atualize meus agents" ou rode `/atualizar-agents` no Claude Code. Para um subconjunto: `/atualizar-agents fidc` (economiza tokens). No Codex, diga "atualize meus agents" (o snippet do AGENTS.md define o fluxo).
- **Automático, todo dia 1º do mês** — via cron na VPS/máquina com Claude Code autenticado (`crontab -e`):

```cron
0 8 1 * * cd $HOME && claude -p "/atualizar-agents" --permission-mode acceptEdits >> $HOME/agents-update.log 2>&1
```

Depois de qualquer atualização dos `.md`, regenere o JSON do Hermes: `cd hermes && bun md-to-hermes.ts ../agents` (ou rode `./install.sh hermes`, que regenera automaticamente se o Bun estiver instalado).

## Ajustes finos

- `model: opus` no frontmatter dos pesados (`fidc-economics`, `juridico-societario`, `backtest-analyst`) para mais profundidade; `model: haiku` no `github-deep-research` para varreduras baratas.
- Sem linha `tools:` no frontmatter, o agente herda TODAS as ferramentas da sessão, incluindo MCP servers (ex.: MCP do Postgres para `backtest-analyst` e `quant-data-engineer`).
- Exporte `GITHUB_TOKEN` e `FRED_API_KEY` no ambiente antes de abrir o Claude Code.

## Notas

- Os agentes foram escritos para **verificar tudo na fonte** (APIs, filings, leis) — em crédito, tributário e macro, memória de modelo desatualiza em semanas.
- `juridico-societario` só faz planejamento **lícito** (elisão) e todo output dele é documento de trabalho interno: implementação exige advogado (OAB) e contador.
- Formato de subagentes e comandos: https://code.claude.com/docs/en/sub-agents
