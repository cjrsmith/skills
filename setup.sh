#!/usr/bin/env bash
#
# Install this repo as the source of truth for agent instructions and skills.
#
# Clone anywhere, run ./setup.sh, and every supported tool reads this repo
# through symlinks. Re-runnable: it reports what is already correct and only
# touches what is not. Anything real it would overwrite is backed up first.
#
#   ./setup.sh              install
#   ./setup.sh --dry-run    show what would change, touch nothing
#   ./setup.sh --status     show the current state of every link
#   ./setup.sh --uninstall  remove only the links this script created

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
MASTER="$REPO/AGENTS.md"
SKILLS="$REPO/skills"

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Native instruction file for each tool. Add a line to onboard a new tool.
INSTRUCTION_TARGETS=(
  "Claude Code:$CLAUDE_DIR/CLAUDE.md"
  "Codex:$CODEX_DIR/AGENTS.md"
  "OpenCode:$CONFIG_DIR/opencode/AGENTS.md"
)

# Tools that read a directory of skills, one symlink per skill. Both use the
# same layout: a directory with a SKILL.md. Add a line to onboard a new tool.
SKILL_TARGETS=(
  "Claude Code:$CLAUDE_DIR/skills"
  "Codex:$CODEX_DIR/skills"
)

# Skills shipped by the OS rather than this repo; linked only if present.
SYSTEM_SKILLS="/usr/share/omarchy/default/agents/skills"

MODE=install
DRY=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY=1 ;;
    --status)    MODE=status ;;
    --uninstall) MODE=uninstall ;;
    -h|--help)   sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

if [ -t 1 ]; then
  BOLD=$'\e[1m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; DIM=$'\e[2m'; RESET=$'\e[0m'
else
  BOLD=; GREEN=; YELLOW=; DIM=; RESET=
fi

BACKUP_DIR="$REPO/backups/setup-$(date -u +%Y%m%dT%H%M%SZ)"
linked=0; already=0; backed_up=0; removed=0; skipped=0

note() { printf '  %s%s%s %s\n' "$2" "$1" "$RESET" "$3"; }

# link SOURCE LINKNAME LABEL
link() {
  local src="$1" dest="$2" label="$3"

  if [ ! -e "$src" ]; then
    note "skip   " "$DIM" "$label ${DIM}(missing in repo: $src)"
    skipped=$((skipped + 1))
    return
  fi

  if [ -L "$dest" ] && [ "$(readlink -- "$dest")" = "$src" ]; then
    note "ok     " "$DIM" "$label"
    already=$((already + 1))
    return
  fi

  local action="link"
  if [ -L "$dest" ]; then
    action="relink ${DIM}(was -> $(readlink -- "$dest"))${RESET}"
  elif [ -e "$dest" ]; then
    action="replace ${DIM}(real file backed up)${RESET}"
  fi

  if [ "$DRY" = 1 ]; then
    note "would  " "$YELLOW" "$label  $action"
    linked=$((linked + 1))
    return
  fi

  # Back up anything real. A symlink carries no content worth keeping.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    mv -- "$dest" "$BACKUP_DIR/$(echo "${dest#"$HOME"/}" | tr / _)"
    backed_up=$((backed_up + 1))
  fi

  mkdir -p "$(dirname -- "$dest")"
  ln -sfn -- "$src" "$dest"
  note "linked " "$GREEN" "$label  ${DIM}$action${RESET}"
  linked=$((linked + 1))
}

# unlink LINKNAME LABEL - removes only if it points into this repo.
unlink_ours() {
  local dest="$1" label="$2"
  if [ -L "$dest" ] && case "$(readlink -- "$dest")" in "$REPO"/*) true ;; *) false ;; esac; then
    if [ "$DRY" = 1 ]; then
      note "would  " "$YELLOW" "remove $label"
    else
      rm -- "$dest"
      note "removed" "$GREEN" "$label"
    fi
    removed=$((removed + 1))
  fi
}

# status LINKNAME LABEL
status_of() {
  local dest="$1" label="$2" state
  if [ -L "$dest" ]; then
    state="-> $(readlink -- "$dest")"
    [ -e "$dest" ] || state="$state ${YELLOW}(broken)${RESET}"
  elif [ -e "$dest" ]; then
    state="${YELLOW}real file, not a link${RESET}"
  else
    state="${DIM}absent${RESET}"
  fi
  printf '  %-14s %s\n' "$label" "$state"
}

printf '\n%sagents repo%s  %s\n\n' "$BOLD" "$RESET" "$REPO"

if [ "$MODE" = status ]; then
  printf '%sInstructions%s\n' "$BOLD" "$RESET"
  for entry in "${INSTRUCTION_TARGETS[@]}"; do
    status_of "${entry#*:}" "${entry%%:*}"
  done
  for entry in "${SKILL_TARGETS[@]}"; do
    dest="${entry#*:}"
    printf '\n%sSkills%s  %s  (%s)\n' "$BOLD" "$RESET" "${entry%%:*}" "$dest"
    ours=0; foreign=0
    for path in "$dest"/*; do
      [ -e "$path" ] || [ -L "$path" ] || continue
      if [ -L "$path" ] && case "$(readlink -- "$path")" in "$REPO"/*) true ;; *) false ;; esac; then
        ours=$((ours + 1))
      else
        foreign=$((foreign + 1))
        status_of "$path" "$(basename -- "$path")"
      fi
    done
    printf '  %s%s linked from this repo%s\n' "$DIM" "$ours" "$RESET"
    [ "$foreign" -gt 0 ] && printf '  %s%s not from this repo (listed above)%s\n' "$DIM" "$foreign" "$RESET"
  done
  echo
  exit 0
fi

if [ "$MODE" = uninstall ]; then
  printf '%sInstructions%s\n' "$BOLD" "$RESET"
  for entry in "${INSTRUCTION_TARGETS[@]}"; do
    unlink_ours "${entry#*:}" "${entry%%:*}"
  done
  for entry in "${SKILL_TARGETS[@]}"; do
    printf '\n%sSkills%s  %s\n' "$BOLD" "$RESET" "${entry%%:*}"
    for path in "${entry#*:}"/*; do
      [ -L "$path" ] || continue
      unlink_ours "$path" "$(basename -- "$path")"
    done
  done
  if [ "$DRY" = 1 ]; then
    printf '\n%s%s would be removed. Dry run: nothing was changed.%s\n\n' "$YELLOW" "$removed" "$RESET"
  else
    printf '\n%s removed. Backups in %s were left alone.\n\n' "$removed" "$REPO/backups"
  fi
  exit 0
fi

printf '%sInstructions%s  (AGENTS.md)\n' "$BOLD" "$RESET"
for entry in "${INSTRUCTION_TARGETS[@]}"; do
  link "$MASTER" "${entry#*:}" "${entry%%:*}"
done

printf '\n%sSkills%s\n' "$BOLD" "$RESET"
for entry in "${SKILL_TARGETS[@]}"; do
  [ "$DRY" = 1 ] || mkdir -p "${entry#*:}"
done

for path in "$SKILLS"/*; do
  [ -d "$path" ] || continue
  name="$(basename -- "$path")"
  if [ ! -f "$path/SKILL.md" ]; then
    note "skip   " "$DIM" "$name ${DIM}(no SKILL.md)"
    skipped=$((skipped + 1))
    continue
  fi
  for entry in "${SKILL_TARGETS[@]}"; do
    link "$path" "${entry#*:}/$name" "$name ${DIM}-> ${entry%%:*}${RESET}"
  done
done

if [ -d "$SYSTEM_SKILLS" ]; then
  printf '\n%sSystem skills%s  (%s)\n' "$BOLD" "$RESET" "$SYSTEM_SKILLS"
  for path in "$SYSTEM_SKILLS"/*; do
    [ -d "$path" ] || continue
    name="$(basename -- "$path")"
    for entry in "${SKILL_TARGETS[@]}"; do
      link "$path" "${entry#*:}/$name" "$name ${DIM}-> ${entry%%:*}${RESET}"
    done
  done
fi

printf '\n%s%d linked, %d already correct' "$BOLD" "$linked" "$already"
[ "$backed_up" -gt 0 ] && printf ', %d backed up' "$backed_up"
[ "$skipped" -gt 0 ] && printf ', %d skipped' "$skipped"
printf '%s\n' "$RESET"
[ "$backed_up" -gt 0 ] && printf '%sBackups: %s%s\n' "$DIM" "$BACKUP_DIR" "$RESET"
[ "$DRY" = 1 ] && printf '%sDry run. Nothing was changed.%s\n' "$YELLOW" "$RESET"
printf '%sStart a fresh session in each tool to pick up changes.%s\n\n' "$DIM" "$RESET"
