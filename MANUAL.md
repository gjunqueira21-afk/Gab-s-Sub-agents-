# Manual de Instalação — Gab's Sub-agents

Time de 9 subagentes de finanças + jurídico (CredIA / Álamos / Ihus / Trading B3), com processo de instalação para **Claude Code**, **Codex CLI** e **Hermes**.

> Atalho: tudo abaixo pode ser feito de uma vez com `./install.sh claude`, `./install.sh codex`, `./install.sh hermes` ou `./install.sh all`. Este manual documenta o processo **manual**, passo a passo, para quem quer entender ou personalizar cada etapa.

## Os 9 agents

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

Formatos por plataforma:

- **Claude Code**: `agents/*.md` (Markdown com frontmatter YAML, nomes em kebab-case: `fidc-economics`)
- **Codex CLI**: `codex/agents/*.toml` (TOML com `developer_instructions`, nomes em snake_case: `fidc_economics`)
- **Hermes**: `hermes/hermes-agents.json` (JSON único com os 9 agentes)

---

## 1. Claude Code

### 1.1 Instalar os agents

```bash
mkdir -p ~/.claude/agents
cp agents/github-deep-research.md agents/fidc-economics.md agents/credito-analyst.md \
   agents/backtest-analyst.md agents/equity-research-br.md agents/equity-research-us.md \
   agents/macro-economist.md agents/quant-data-engineer.md agents/juridico-societario.md \
   ~/.claude/agents/
```

Para instalar **apenas em um projeto** (em vez do nível de usuário), troque `~/.claude/agents` por `.claude/agents` na raiz do projeto.

### 1.2 Instalar o comando de atualização

```bash
mkdir -p ~/.claude/commands
cp commands/atualizar-agents.md ~/.claude/commands/
```

### 1.3 Ativar o gatilho em linguagem natural

Adicione esta linha ao seu `~/.claude/CLAUDE.md` (crie o arquivo se não existir):

```
Quando eu disser "atualize meus agents", execute o comando /atualizar-agents (meu time personalizado de subagentes).
```

### 1.4 Verificar

Abra o Claude Code e rode `/agents` — os 9 devem aparecer. Teste a delegação: *"Use o subagente juridico-societario para comparar holding × PF na estrutura da Ihus."*

### 1.5 Atualização dos agents

- **Manual**: diga "atualize meus agents" ou rode `/atualizar-agents`. Para um subconjunto: `/atualizar-agents fidc` (economiza tokens).
- **Automática (dia 1º de cada mês)**: o Claude Code não acorda sozinho — quem dispara é o cron. Na VPS/máquina com Claude Code autenticado, `crontab -e`:

```cron
0 8 1 * * cd $HOME && claude -p "/atualizar-agents" --permission-mode acceptEdits >> $HOME/agents-update.log 2>&1
```

(`acceptEdits` permite que os agentes editem os próprios arquivos sem prompt de permissão. Confira o log no primeiro mês.)

### 1.6 Ajustes finos

- `model: opus` no frontmatter dos pesados (`fidc-economics`, `juridico-societario`, `backtest-analyst`) para mais profundidade; `model: haiku` no `github-deep-research` para varreduras baratas.
- Sem linha `tools:` no frontmatter, o agente herda TODAS as ferramentas da sessão, incluindo MCP servers (ex.: MCP do Postgres para `backtest-analyst` e `quant-data-engineer`) — é assim que os arquivos já vêm.
- Exporte `GITHUB_TOKEN` e `FRED_API_KEY` no ambiente antes de abrir o Claude Code.

### 1.7 Desinstalar

```bash
cd ~/.claude/agents && rm github-deep-research.md fidc-economics.md credito-analyst.md \
   backtest-analyst.md equity-research-br.md equity-research-us.md \
   macro-economist.md quant-data-engineer.md juridico-societario.md
rm ~/.claude/commands/atualizar-agents.md
```

---

## 2. Codex CLI

O Codex usa agentes em TOML com `developer_instructions` + um snippet no `AGENTS.md` global que ensina a sessão principal a delegar (Spawn) e a rodar o fluxo de atualização.

### 2.1 Instalar os agents

```bash
mkdir -p ~/.codex/agents
cp codex/agents/*.toml ~/.codex/agents/
```

(Se você usa `CODEX_HOME` personalizado, troque `~/.codex` por ele. Para escopo de projeto, use `.codex/agents/` na raiz do projeto.)

### 2.2 Anexar o snippet ao AGENTS.md

Anexe o conteúdo de `codex/AGENTS-snippet.md` ao final do seu `~/.codex/AGENTS.md` (crie se não existir):

```bash
cat codex/AGENTS-snippet.md >> ~/.codex/AGENTS.md
```

O snippet registra os 9 agents para delegação via Spawn e define o fluxo "atualize meus agents" (a sessão principal spawna cada agente, coleta o retorno e edita a seção "Base dinâmica" do TOML correspondente).

### 2.3 Verificar

Abra o Codex e peça algo que case com a description de um agente (ex.: *"avalie o waterfall deste FIDC"*) — a sessão deve delegar ao `fidc_economics`. Ou diga "atualize meus agents".

### 2.4 Desinstalar

```bash
cd ~/.codex/agents && rm backtest_analyst.toml credito_analyst.toml equity_research_br.toml \
   equity_research_us.toml fidc_economics.toml github_deep_research.toml \
   juridico_societario.toml macro_economist.toml quant_data_engineer.toml
```

E remova o bloco correspondente do `~/.codex/AGENTS.md` (se instalou com `install.sh`, o bloco fica entre os marcadores `<!-- BEGIN gab-sub-agents -->` e `<!-- END gab-sub-agents -->`).

---

## 3. Hermes Agent (Nous Research — VPS da Hostinger)

O Hermes Agent usa **skills**: pastas em `~/.hermes/skills/<nome>/` com um `SKILL.md` (Markdown com frontmatter YAML, padrão agentskills.io). Ele auto-descobre todas as pastas na inicialização. Os 9 agents já estão convertidos nesse formato em `hermes/skills/`.

### 3.1 Instalar (na máquina/VPS onde o Hermes roda)

```bash
mkdir -p ~/.hermes/skills
cp -r hermes/skills/* ~/.hermes/skills/
```

E anexe o snippet de instruções ao `AGENTS.md` do workspace do Hermes (define a delegação automática e o fluxo "atualize meus agents"):

```bash
cat hermes/AGENTS-snippet.md >> ~/.hermes/AGENTS.md
```

Reinicie o Hermes Agent para ele descobrir as skills novas.

### 3.2 No VPS da Hostinger (jeito mais fácil)

O Hermes tem acesso ao terminal do próprio VPS — você pode pedir para **ele mesmo** se instalar. Mande esta mensagem para o seu Hermes (via Telegram/WhatsApp/interface web):

> Clone o repositório https://github.com/gjunqueira21-afk/Gab-s-Sub-agents- (branch claude/agents-claude-code-cnn7p6), entre na pasta e rode `./install.sh hermes`. Depois confirme que as 9 skills novas aparecem no seu diretório de skills.

Alternativa manual: acesse o VPS pelo **Browser Terminal** do hPanel (ou SSH) e rode:

```bash
git clone -b claude/agents-claude-code-cnn7p6 https://github.com/gjunqueira21-afk/Gab-s-Sub-agents-.git
cd Gab-s-Sub-agents- && ./install.sh hermes
```

> No deploy Docker da Hostinger, o diretório de dados do Hermes pode ser um volume montado em outro caminho. Descubra com `docker inspect <container> | grep -A3 Mounts` e use `./install.sh hermes --dir /caminho/do/volume`.

### 3.3 Verificar

Pergunte ao Hermes: *"quais skills você tem instaladas?"* — as 9 devem aparecer. Teste: *"use a skill fidc-economics para explicar o waterfall de um FIDC com subordinação de 20%"*.

### 3.4 Desinstalar

```bash
cd ~/.hermes/skills && rm -rf github-deep-research fidc-economics credito-analyst \
   backtest-analyst equity-research-br equity-research-us macro-economist \
   quant-data-engineer juridico-societario
```

E remova o bloco entre `<!-- BEGIN gab-sub-agents -->` e `<!-- END gab-sub-agents -->` do `~/.hermes/AGENTS.md` (o `./install.sh hermes --uninstall` faz os dois passos).

### 3.5 Export genérico (outros "Hermes")

Para qualquer outra ferramenta que aceite agentes em JSON, o repositório também traz `hermes/hermes-agents.json` (gerado pelo conversor `hermes/md-to-hermes.ts`, que requer [Bun](https://bun.sh): `cd hermes && bun md-to-hermes.ts ../agents`). Cada objeto tem `name`, `description`, `tools` e `system_prompt`.

---

## 4. Solução de problemas

| Sintoma | Causa provável | Correção |
|---|---|---|
| Agents não aparecem no `/agents` do Claude Code | Arquivos fora de `~/.claude/agents` ou frontmatter inválido | Confira o caminho e se o arquivo começa com `---` na primeira linha |
| Claude não delega sozinho | `description` é o que guia a delegação | Invoque explicitamente ("Use o subagente X...") ou ajuste a description |
| "atualize meus agents" não dispara | Falta a linha no `~/.claude/CLAUDE.md` | Refaça o passo 1.3 |
| Codex não delega | Snippet não está no `AGENTS.md` em uso | Confirme `~/.codex/AGENTS.md` (global) ou o `AGENTS.md` do projeto |
| Cron não roda a atualização | Claude Code sem autenticação no ambiente do cron | Rode `claude` manualmente uma vez na máquina e confira `$HOME/agents-update.log` |
| Hermes não vê as skills novas | Skills copiadas com o agente rodando, ou volume Docker em outro caminho | Reinicie o Hermes; no Docker da Hostinger, confirme o caminho do volume (passo 3.2) |

## 5. Notas

- Os agentes foram escritos para **verificar tudo na fonte** (APIs, filings, leis) — em crédito, tributário e macro, memória de modelo desatualiza em semanas.
- Todos têm ao final: **Radar GitHub** (busca ativa de ferramentas/repos com crivo de licença, atividade e fit de stack) e **Protocolo de auto-atualização** (pesquisam ~35 dias de novidades e editam a própria seção **Base dinâmica** — nunca o frontmatter nem as seções fixas).
- `juridico-societario` só faz planejamento **lícito** (elisão); todo output é documento de trabalho interno — implementação exige advogado (OAB) e contador.
- Formato de subagentes e comandos do Claude Code: https://code.claude.com/docs/en/sub-agents
