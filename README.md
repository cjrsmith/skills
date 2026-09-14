# agents

My source of truth for agent instructions and skills, shared across Claude Code,
Codex and OpenCode, and across machines.

Nothing here is copied anywhere. Every tool reads these files through symlinks,
so editing a file in this repo takes effect everywhere immediately — no sync
step, no drift. Commit, push, pull on the next machine, and it's the same setup.

## Install

```bash
git clone git@github.com:cjrsmith/skills.git ~/.agents
cd ~/.agents && ./setup.sh
```

Clone it wherever you like — `setup.sh` resolves its own location, so `~/.agents`
is a convention, not a requirement. Then start a fresh session in each tool;
running sessions keep the instructions they started with.

```
./setup.sh              install, or repair whatever has drifted
./setup.sh --status     show what every link currently points at
./setup.sh --dry-run    show what would change, touch nothing
./setup.sh --uninstall  remove the links, leaving other tools' files alone
```

The script is re-runnable and conservative. It reports links that are already
correct rather than rewriting them, only ever removes symlinks it owns, and
moves any *real* file it would overwrite into `backups/` first.

## Layout

```
AGENTS.md    global instructions, read by every tool
skills/      one directory per skill, each with a SKILL.md
setup.sh     the installer
backups/     local recovery state (gitignored)
```

## What gets linked where

`AGENTS.md` is the single instruction file behind all three tools:

| Tool        | Native path                   |
| ----------- | ----------------------------- |
| Claude Code | `~/.claude/CLAUDE.md`         |
| Codex       | `~/.codex/AGENTS.md`          |
| OpenCode    | `~/.config/opencode/AGENTS.md` |

`CLAUDE_CONFIG_DIR`, `CODEX_HOME` and `XDG_CONFIG_HOME` are honoured if set.

Each `skills/<name>/` is linked individually into `~/.claude/skills/<name>`, so
skills installed by other means sit alongside these untouched. If this machine
has Omarchy, its system skills are linked in from
`/usr/share/omarchy/default/agents/skills` too.

Because instructions are one shared file, every tool sees byte-identical text.
There is no place for tool-specific rules; a tool that needs its own has to move
back to a real file of its own.

## Adding a skill

Create `skills/<name>/SKILL.md` with frontmatter:

```markdown
---
name: my-skill
description: What it does, and when an agent should reach for it.
---
```

Then `./setup.sh` to link it, and commit. A directory without a `SKILL.md` is
skipped, so drafts can sit in the tree until they're ready.

## Onboarding another tool

Add one line to `INSTRUCTION_TARGETS` in `setup.sh`:

```bash
"Tool name:$CONFIG_DIR/tool/AGENTS.md"
```

## Credits

Many of these skills started from [Matt Pocock's](https://github.com/mattpocock)
collection and have been edited for my own use.
