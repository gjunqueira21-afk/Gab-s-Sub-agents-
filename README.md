# Agents Financas — Time de Subagentes

Nove especialistas de IA + comando de atualização, calibrados para o stack (Bun/Hono/TS + Python, Postgres, VPS). Empacotados para três runtimes: **Claude Code** (fonte da verdade), **Codex** (TOML) e **Hermes** (JSON).

| Agente | Especialidade |
|---|---|
| `github-deep-research` | Varredura profunda no GitHub: repositórios, novas techs, avaliação e POC |
| `fidc-economics` | Matemático PhD de FIDC: waterfall, subordinação, excess spread, stress, CVM 175 |
| `credito-analyst` | Mercado de crédito BR + US: modalidades, spreads, inadimplência, funding |
| `backtest-analyst` | Validação de backtests: métricas, anti-overfitting, custos B3, pairs/cointegração |
| `equity-research-br` | Research de ações B3 com mesas setoriais |
| `equity-research-us` | Research de ações US com mesas setoriais |
| `macro-economist` | Macro BR/US: Copom, Fed, curvas — e a transmissão para as decisões |
| `quant-data-engineer` | Pipelines de dados: BCB, FRED, CVM, B3, SEC → Postgres |
| `juridico-societario` | Societário, fundos/veículos, planejamento tributário LÍCITO, regulatório, sucessão |

Todos os agentes têm no fim do arquivo: **Radar GitHub** (buscam ferramentas/repos da área durante as tarefas) e **Protocolo de auto-atualização** (pesquisam ~35 dias de novidades e editam a própria seção "Base dinâmica").

## Estrutura do repositório

```
claude-code/agents/      9 agentes .md (formato nativo Claude Code — FONTE DA VERDADE)
claude-code/commands/    /atualizar-agents (slash command)
codex/agents/            9 agentes .toml (custom agents do Codex)
codex/AGENTS-snippet.md  bloco para colar no ~/.codex/AGENTS.md (gatilho "atualize meus agents")
hermes/skills/           9 skills SKILL.md (Hermes Agent da Nous Research / Hostinger VPS)
hermes/AGENTS-snippet.md bloco para o AGENTS.md do workspace do Hermes
hermes/                  + hermes-agents.json e md-to-hermes.ts (export genérico .md → JSON)
install.sh               instalador automático (claude | codex | hermes | all)
MANUAL.md                instalação manual passo a passo + troubleshooting
```

## Instalação rápida (script)

```bash
chmod +x install.sh
./install.sh --list      # ver os agents
./install.sh claude      # ou: codex | hermes | all
```

Opções: `--project` (instala no projeto atual em vez do nível de usuário), `--dir /caminho` (destino customizado), `--uninstall`. As seções abaixo mostram o processo manual equivalente; o passo a passo completo com verificação e solução de problemas está no [MANUAL.md](MANUAL.md).

## Instalação — Claude Code

```bash
mkdir -p ~/.claude/agents ~/.claude/commands
cp claude-code/agents/*.md ~/.claude/agents/
cp claude-code/commands/atualizar-agents.md ~/.claude/commands/
```

E adicione ao `~/.claude/CLAUDE.md`:

```
Quando eu disser "atualize meus agents", execute o comando /atualizar-agents (meu time personalizado de subagentes).
```

## Instalação — Codex

```bash
mkdir -p ~/.codex/agents
cp codex/agents/*.toml ~/.codex/agents/
cat codex/AGENTS-snippet.md >> ~/.codex/AGENTS.md
```

Uso: `Spawn fidc_economics to ...` (nomes com underscore). No Codex, quem edita os TOMLs na atualização é a sessão principal (sandbox dos filhos pode bloquear escrita fora do workspace). Opcional: fixe `model = "..."` por agente no TOML.

## Instalação — Hermes

**Hermes Agent (Nous Research / VPS da Hostinger)** usa skills auto-descobertas em `~/.hermes/skills/`. Na máquina/VPS onde o Hermes roda:

```bash
mkdir -p ~/.hermes/skills
cp -r hermes/skills/* ~/.hermes/skills/
cat hermes/AGENTS-snippet.md >> ~/.hermes/AGENTS.md
```

Reinicie o Hermes para carregar. Atalho no VPS da Hostinger: mande o próprio Hermes se instalar — *"Clone este repositório e rode ./install.sh hermes"* (detalhes e caminho do volume Docker no [MANUAL.md](MANUAL.md)).

**Export genérico**: `hermes/hermes-agents.json` traz `name`, `description`, `tools` e `system_prompt` de cada agente. Ajustes no lado do Hermes: mapear os nomes de tools para as equivalentes do framework e trocar o caminho do Protocolo de auto-atualização para onde o Hermes guarda os prompts. Para re-sincronizar após qualquer atualização dos .md:

```bash
cd hermes && bun md-to-hermes.ts ../claude-code/agents
```

## Atualização

- **Manual**: "atualize meus agents" ou `/atualizar-agents` (subconjunto: `/atualizar-agents fidc`).
- **Automática, dia 1º de cada mês** (o disparo é do cron, numa máquina com Claude Code autenticado):

```cron
0 8 1 * * cd $HOME && claude -p "/atualizar-agents" --permission-mode acceptEdits >> $HOME/agents-update.log 2>&1
```

Depois de uma atualização, commite as mudanças das "Bases dinâmicas" e regenere o JSON do Hermes.

## Ajustes finos

- `model: opus` no frontmatter dos pesados (`fidc-economics`, `juridico-societario`, `backtest-analyst`); `model: haiku` no `github-deep-research` para varreduras baratas.
- Remova a linha `tools:` de um agente para herdar TODAS as ferramentas da sessão, incluindo MCP servers (ex.: MCP do Postgres para `backtest-analyst` e `quant-data-engineer`).
- Exporte `GITHUB_TOKEN` e `FRED_API_KEY` no ambiente.

## Notas

- Os agentes verificam tudo na fonte (APIs, filings, leis) — em crédito, tributário e macro, memória de modelo desatualiza em semanas.
- `juridico-societario` só faz planejamento **lícito** (elisão); todo output é documento de trabalho interno — implementação exige advogado (OAB) e contador.
- Formatos: https://code.claude.com/docs/en/sub-agents · https://developers.openai.com/codex/subagents
