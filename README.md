# Gab's Sub-agents

Coleção de sub-agents com um instalador que os copia para o **Claude Code**, o **Codex CLI** ou o **Hermes**.

## Como usar

```bash
git clone https://github.com/gjunqueira21-afk/gab-s-sub-agents-.git
cd gab-s-sub-agents-
chmod +x install.sh

./install.sh --list      # ver os agents disponíveis
./install.sh claude      # instalar no Claude Code (~/.claude/agents)
./install.sh codex       # instalar no Codex CLI (~/.codex/prompts)
./install.sh hermes      # instalar no Hermes (~/.hermes/agents)
./install.sh all         # instalar em todos
```

Opções úteis:

| Opção | O que faz |
|---|---|
| `--project` | Com `claude`: instala no projeto atual (`./.claude/agents`) em vez do nível de usuário |
| `--dir /caminho` | Instala em um diretório personalizado (útil para o Hermes) |
| `--uninstall` | Remove os agents deste repositório do destino escolhido |
| `--list` | Lista os agents e suas descrições |

> Funciona em Linux e macOS. No Windows, use pelo Git Bash ou WSL.

## Como cada destino funciona

- **Claude Code** — os arquivos são copiados como estão para `~/.claude/agents/` (formato nativo de sub-agents: Markdown com frontmatter YAML). Eles aparecem no comando `/agents` e o Claude os usa automaticamente conforme a `description`.
- **Codex CLI** — o Codex não tem sub-agents nativos, então cada agent vira um *custom prompt* em `~/.codex/prompts/`. Dentro do Codex, ative com `/nome-do-agent`.
- **Hermes** — cópia direta dos arquivos para `~/.hermes/agents/` (ou o diretório que você indicar com `--dir`, ou pela variável `HERMES_HOME`).

## Como adicionar seus próprios agents

1. Crie um arquivo `.md` na pasta [`agents/`](agents/) seguindo o modelo em [`agents/_template.md`](agents/_template.md):

```markdown
---
name: meu-agent
description: Quando este agent deve ser usado.
---

Você é um especialista em... (system prompt do agent)
```

2. Rode `./install.sh <destino>` de novo. Pronto.

Os agents `revisor-de-codigo` e `documentador` incluídos são exemplos iniciais — substitua ou apague à vontade.
