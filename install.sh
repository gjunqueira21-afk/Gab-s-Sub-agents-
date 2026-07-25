#!/usr/bin/env bash
#
# Gab's Sub-agents — instalador
# Time de 9 subagentes de finanças + jurídico (CredIA / Álamos / Ihus / Trading B3)
#
# Destinos:
#   claude  → Claude Code : agents/*.md → ~/.claude/agents
#                           commands/atualizar-agents.md → ~/.claude/commands
#   codex   → Codex CLI   : codex/agents/*.toml → ~/.codex/agents
#                           codex/AGENTS-snippet.md → anexado ao ~/.codex/AGENTS.md
#   hermes  → Hermes      : hermes/hermes-agents.json → ~/.hermes/
#   all     → todos os destinos acima
#
# Uso:
#   ./install.sh claude              # instala no Claude Code (nível de usuário)
#   ./install.sh claude --project    # instala no projeto atual (./.claude/)
#   ./install.sh codex
#   ./install.sh hermes
#   ./install.sh all
#   ./install.sh --list              # lista os agents disponíveis
#   ./install.sh claude --uninstall  # remove os agents instalados
#   ./install.sh hermes --dir /caminho/custom   # destino personalizado
#
# Instalação manual passo a passo: veja MANUAL.md
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$REPO_DIR/agents"
COMMANDS_DIR="$REPO_DIR/commands"
CODEX_SRC="$REPO_DIR/codex"
HERMES_SRC="$REPO_DIR/hermes"

MARK_BEGIN='<!-- BEGIN gab-sub-agents -->'
MARK_END='<!-- END gab-sub-agents -->'

TARGET=""
PROJECT=false
UNINSTALL=false
LIST=false
CUSTOM_DIR=""

# ---------- helpers ----------

say()  { printf '%s\n' "$*"; }
ok()   { printf '  \033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[31mErro:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

agent_files() {
  find "$AGENTS_DIR" -maxdepth 1 -name '*.md' ! -name '_template.md' | sort
}

codex_agent_files() {
  find "$CODEX_SRC/agents" -maxdepth 1 -name '*.toml' | sort
}

# Extrai um campo simples do frontmatter YAML (remove aspas externas, se houver)
frontmatter_field() { # $1=arquivo $2=campo
  awk -v field="$2" '
    NR==1 && $0=="---" { in_fm=1; next }
    in_fm && $0=="---" { exit }
    in_fm && $0 ~ "^"field":" {
      sub("^"field":[[:space:]]*", ""); print; exit
    }
  ' "$1" | sed 's/^"//; s/"$//; s/\\"/"/g'
}

list_agents() {
  local f name desc count=0
  say "Agents disponíveis em $AGENTS_DIR:"
  say ""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="$(frontmatter_field "$f" name)"
    desc="$(frontmatter_field "$f" description)"
    printf '  \033[36m%-24s\033[0m %.90s...\n' "${name:-$(basename "$f" .md)}" "${desc:-—}"
    count=$((count + 1))
  done <<< "$(agent_files)"
  say ""
  say "Total: $count agent(s) + comando /atualizar-agents"
}

# ---------- Claude Code ----------

install_claude() {
  local agents_dest commands_dest
  if $PROJECT; then
    agents_dest="$PWD/.claude/agents"; commands_dest="$PWD/.claude/commands"
  else
    agents_dest="$HOME/.claude/agents"; commands_dest="$HOME/.claude/commands"
  fi
  [ -n "$CUSTOM_DIR" ] && { agents_dest="$CUSTOM_DIR/agents"; commands_dest="$CUSTOM_DIR/commands"; }

  if $UNINSTALL; then
    remove_files "$agents_dest" "Claude Code (agents)" "$(agent_files)"
    [ -f "$commands_dest/atualizar-agents.md" ] && rm "$commands_dest/atualizar-agents.md" \
      && ok "removido atualizar-agents.md de $commands_dest" || true
    return
  fi

  mkdir -p "$agents_dest" "$commands_dest"
  say "Instalando no Claude Code → $agents_dest"
  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    cp "$f" "$agents_dest/$(basename "$f")"
    ok "$(basename "$f")"
  done <<< "$(agent_files)"
  cp "$COMMANDS_DIR/atualizar-agents.md" "$commands_dest/atualizar-agents.md"
  ok "atualizar-agents.md → $commands_dest (comando /atualizar-agents)"
  say ""
  say "Pronto! Verifique com /agents dentro do Claude Code."
  say "Dica: adicione ao seu ~/.claude/CLAUDE.md a linha:"
  say '  Quando eu disser "atualize meus agents", execute o comando /atualizar-agents (meu time personalizado de subagentes).'
}

# ---------- Codex CLI ----------

install_codex() {
  local root="${CODEX_HOME:-$HOME/.codex}"
  [ -n "$CUSTOM_DIR" ] && root="$CUSTOM_DIR"
  local agents_dest="$root/agents"
  local agents_md="$root/AGENTS.md"

  if $UNINSTALL; then
    remove_files "$agents_dest" "Codex CLI (agents)" "$(codex_agent_files)"
    if [ -f "$agents_md" ] && grep -qF "$MARK_BEGIN" "$agents_md"; then
      awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
        $0==b {skip=1; next} $0==e {skip=0; next} !skip' "$agents_md" > "$agents_md.tmp" \
        && mv "$agents_md.tmp" "$agents_md"
      ok "bloco gab-sub-agents removido de $agents_md"
    fi
    return
  fi

  mkdir -p "$agents_dest"
  say "Instalando no Codex CLI → $agents_dest"
  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    cp "$f" "$agents_dest/$(basename "$f")"
    ok "$(basename "$f")"
  done <<< "$(codex_agent_files)"

  if [ -f "$agents_md" ] && grep -qF "$MARK_BEGIN" "$agents_md"; then
    warn "snippet já presente em $agents_md (nada a fazer)"
  else
    {
      [ -f "$agents_md" ] && [ -s "$agents_md" ] && printf '\n'
      printf '%s\n' "$MARK_BEGIN"
      cat "$CODEX_SRC/AGENTS-snippet.md"
      printf '%s\n' "$MARK_END"
    } >> "$agents_md"
    ok "snippet anexado a $agents_md"
  fi
  say ""
  say "Pronto! No Codex, os agents ficam disponíveis para Spawn; diga \"atualize meus agents\" para o fluxo de atualização."
}

# ---------- Hermes ----------

install_hermes() {
  local dest="${HERMES_HOME:-$HOME/.hermes}"
  [ -n "$CUSTOM_DIR" ] && dest="$CUSTOM_DIR"

  if $UNINSTALL; then
    [ -f "$dest/hermes-agents.json" ] && rm "$dest/hermes-agents.json" \
      && ok "removido hermes-agents.json de $dest" \
      || warn "hermes-agents.json não encontrado em $dest"
    return
  fi

  mkdir -p "$dest"
  say "Instalando no Hermes → $dest"
  # Regenera o JSON a partir dos .md se o bun estiver disponível; senão usa o commitado
  if command -v bun >/dev/null 2>&1; then
    (cd "$HERMES_SRC" && bun md-to-hermes.ts "$AGENTS_DIR" >/dev/null) \
      && ok "hermes-agents.json regenerado a partir de agents/*.md" \
      || warn "falha ao regenerar; usando o JSON commitado"
  fi
  cp "$HERMES_SRC/hermes-agents.json" "$dest/hermes-agents.json"
  ok "hermes-agents.json ($(grep -c '"name"' "$HERMES_SRC/hermes-agents.json") agentes)"
  say ""
  say "Pronto! Importe/aponte o Hermes para $dest/hermes-agents.json."
  say "Se o seu Hermes usa outro diretório: ./install.sh hermes --dir /caminho"
}

# ---------- uninstall genérico ----------

remove_files() { # $1=dir $2=label $3=lista de arquivos-fonte
  local dir="$1" label="$2" files="$3" f removed=0
  [ -d "$dir" ] || { warn "$label: diretório $dir não existe, nada a remover."; return; }
  say "Removendo agents de $label → $dir"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ -f "$dir/$(basename "$f")" ]; then
      rm "$dir/$(basename "$f")"
      ok "removido $(basename "$f")"
      removed=$((removed + 1))
    fi
  done <<< "$files"
  [ "$removed" -gt 0 ] || warn "nenhum agent deste repositório encontrado em $dir"
}

# ---------- parsing de argumentos ----------

while [ $# -gt 0 ]; do
  case "$1" in
    claude|codex|hermes|all) TARGET="$1" ;;
    --project)   PROJECT=true ;;
    --uninstall) UNINSTALL=true ;;
    --list)      LIST=true ;;
    --dir)       shift; CUSTOM_DIR="${1:-}"; [ -n "$CUSTOM_DIR" ] || die "--dir requer um caminho" ;;
    -h|--help)   usage ;;
    *) die "opção desconhecida: $1 (use --help)" ;;
  esac
  shift
done

[ -d "$AGENTS_DIR" ] || die "pasta agents/ não encontrada em $REPO_DIR"

if $LIST; then list_agents; exit 0; fi
[ -n "$TARGET" ] || usage

case "$TARGET" in
  claude) install_claude ;;
  codex)  install_codex ;;
  hermes) install_hermes ;;
  all)
    install_claude
    say ""
    install_codex
    say ""
    install_hermes
    ;;
esac
