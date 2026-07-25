#!/usr/bin/env bash
#
# Gab's Sub-agents — instalador
#
# Instala os agents da pasta ./agents nos seguintes destinos:
#
#   claude  → Claude Code   (~/.claude/agents ou ./.claude/agents com --project)
#   codex   → Codex CLI     (~/.codex/prompts, como custom prompts /nome)
#   hermes  → Hermes        (~/.hermes/agents, ou defina HERMES_HOME)
#   all     → todos os destinos acima
#
# Uso:
#   ./install.sh claude              # instala no Claude Code (nível de usuário)
#   ./install.sh claude --project    # instala no projeto atual (./.claude/agents)
#   ./install.sh codex
#   ./install.sh hermes
#   ./install.sh all
#   ./install.sh --list              # lista os agents disponíveis
#   ./install.sh claude --uninstall  # remove os agents instalados
#   ./install.sh hermes --dir /caminho/custom   # destino personalizado
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$REPO_DIR/agents"

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
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# Lista os arquivos de agent (ignora o template)
agent_files() {
  find "$AGENTS_DIR" -maxdepth 1 -name '*.md' ! -name '_template.md' | sort
}

# Extrai um campo simples ("name:" ou "description:") do frontmatter YAML
frontmatter_field() { # $1=arquivo $2=campo
  awk -v field="$2" '
    NR==1 && $0=="---" { in_fm=1; next }
    in_fm && $0=="---" { exit }
    in_fm && $0 ~ "^"field":" {
      sub("^"field":[[:space:]]*", ""); print; exit
    }
  ' "$1"
}

# Corpo do agent sem o frontmatter
agent_body() { # $1=arquivo
  awk '
    NR==1 && $0=="---" { in_fm=1; next }
    in_fm && $0=="---" { in_fm=0; body=1; next }
    body { print }
    !in_fm && !body && NR==1 { print; body=1 }
  ' "$1"
}

list_agents() {
  local f name desc count=0
  say "Agents disponíveis em $AGENTS_DIR:"
  say ""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="$(frontmatter_field "$f" name)"
    desc="$(frontmatter_field "$f" description)"
    printf '  \033[36m%-28s\033[0m %s\n' "${name:-$(basename "$f" .md)}" "${desc:-—}"
    count=$((count + 1))
  done <<< "$(agent_files)"
  say ""
  say "Total: $count agent(s)"
  [ "$count" -gt 0 ] || warn "Adicione seus agents como arquivos .md na pasta agents/ (veja agents/_template.md)"
}

# ---------- instaladores ----------

install_claude() {
  local dest
  if $PROJECT; then dest="$PWD/.claude/agents"; else dest="$HOME/.claude/agents"; fi
  [ -n "$CUSTOM_DIR" ] && dest="$CUSTOM_DIR"

  if $UNINSTALL; then remove_from "$dest" "Claude Code"; return; fi

  mkdir -p "$dest"
  say "Instalando no Claude Code → $dest"
  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    cp "$f" "$dest/$(basename "$f")"
    ok "$(basename "$f")"
  done <<< "$(agent_files)"
  say ""
  say "Pronto! No Claude Code, os agents aparecem automaticamente."
  say "Use /agents para ver e gerenciar, ou peça: \"use o agent <nome> para ...\""
}

install_codex() {
  # O Codex CLI não tem sub-agents nativos; instalamos como custom prompts,
  # invocáveis com /<nome> dentro do Codex.
  local dest="${CODEX_HOME:-$HOME/.codex}/prompts"
  [ -n "$CUSTOM_DIR" ] && dest="$CUSTOM_DIR"

  if $UNINSTALL; then remove_from "$dest" "Codex CLI"; return; fi

  mkdir -p "$dest"
  say "Instalando no Codex CLI → $dest"
  local f name desc out
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="$(frontmatter_field "$f" name)"
    desc="$(frontmatter_field "$f" description)"
    out="$dest/$(basename "$f")"
    {
      printf '# Agent: %s\n' "${name:-$(basename "$f" .md)}"
      [ -n "$desc" ] && printf '# Quando usar: %s\n' "$desc"
      printf '\nAssuma o papel descrito abaixo para esta tarefa.\n\n'
      agent_body "$f"
    } > "$out"
    ok "$(basename "$f")  (use /$(basename "$f" .md) no Codex)"
  done <<< "$(agent_files)"
  say ""
  say "Pronto! Dentro do Codex, digite /<nome-do-agent> para ativar."
}

install_hermes() {
  local dest="${HERMES_HOME:-$HOME/.hermes}/agents"
  [ -n "$CUSTOM_DIR" ] && dest="$CUSTOM_DIR"

  if $UNINSTALL; then remove_from "$dest" "Hermes"; return; fi

  mkdir -p "$dest"
  say "Instalando no Hermes → $dest"
  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    cp "$f" "$dest/$(basename "$f")"
    ok "$(basename "$f")"
  done <<< "$(agent_files)"
  say ""
  say "Pronto! Se o seu Hermes usa outro diretório, rode novamente com:"
  say "  ./install.sh hermes --dir /caminho/dos/agents"
}

remove_from() { # $1=dir $2=nome do destino
  local dir="$1" label="$2" f removed=0
  [ -d "$dir" ] || { warn "$label: diretório $dir não existe, nada a remover."; return; }
  say "Removendo agents de $label → $dir"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ -f "$dir/$(basename "$f")" ]; then
      rm "$dir/$(basename "$f")"
      ok "removido $(basename "$f")"
      removed=$((removed + 1))
    fi
  done <<< "$(agent_files)"
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

count="$(agent_files | grep -c . || true)"
if [ "$count" -eq 0 ] && ! $UNINSTALL; then
  die "nenhum agent encontrado em agents/. Adicione arquivos .md (veja agents/_template.md)."
fi

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
