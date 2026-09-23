# Issue tracker: GitHub

Issues and specs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v`; `gh` does this automatically when run inside a clone.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` then keep only `authorAssociation` of `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE` (drop `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either: resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue (`gh api` on the sub-issues endpoint). Where sub-issues aren't enabled, add the child to a task list in the map body and put `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies**, the canonical, UI-visible representation. Add an edge with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#number` or `node_id`). GitHub reports `issue_dependencies_summary.blocked_by` (open blockers only, the live gate). Where dependencies aren't available, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children (`gh issue list --state open`, scoped to the map's sub-issues / task list), drop any with an open blocker (`issue_dependencies_summary.blocked_by > 0`, or an open issue in the `Blocked by` line) or an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.

## Horizon operations

Used by `/horizon`. The **board** is a GitHub Project; **cards** are real issues added to it. Needs the `project` token scope: `gh auth refresh -s project` once per machine. `<owner>` is the user or org that owns the project (`@me` for the current user); it may differ from the repo's owner.

- **Board**: `gh project create --owner <owner> --title "<product>"`. The board body lives in the project README: write it with `gh project edit <n> --owner <owner> --readme "$(cat body.md)"`, read it with `gh project view <n> --owner <owner> --format json --jq .readme`. Find boards by title with `gh project list --owner <owner> --format json`. Record the owner and number in the board body's Status line so any repo can find it.
- **Coordinates** are single-select fields: `gh project field-create <n> --owner <owner> --name Activity --data-type SINGLE_SELECT --single-select-options "<activity>,<activity>,…"` with the options **in backbone order**, likewise `Release` (`R1,R2,R3,Later`) and `Level` (`task,detail`). The CLI cannot append or reorder options on an existing field; do that with the GraphQL `updateProjectV2Field` mutation, passing the full option list in the new order (`gh project field-list <n> --owner <owner> --format json` gives the field id). Redrawing the backbone is that mutation on `Activity`.
- **Card**: a real issue, never a draft item (drafts cannot be linked from a Wayfinder map or closed by a PR). Create it in the repo the user is in unless they name another: `gh issue create --title "<idea, user's words>" --body "<context; Detail of: <task> if a detail>" --label horizon:card`, then attach with `gh project item-add <n> --owner <owner> --url <issue-url>`. Cards may come from any repo the owner can reach.
- **Set a coordinate**: `gh project item-edit <n> --owner <owner> --url <issue-url> --field Activity --value "<option>"`; one field per call. **Unplaced** is an empty `Activity`.
- **Low-res view**: `gh project item-list <n> --owner <owner> -L 500 --format json`, then `jq` each item to title, state and its `Activity`/`Release`/`Level` values; never fetch bodies. Filter with `--query`, e.g. `--query "release:R1"` or `--query "no:activity"`.
- **Built**: `gh issue close <url>`. A closed card stays on the board with its coordinates.
- **Destination block**: post as a comment on the first card of the release, or as the README's final section if the user prefers; link it from the Releases table.
- **View**: the CLI cannot create views. Once, in the browser, add a **Board** view grouped by `Activity` with `Release` as swimlanes; column order follows the option order. A human dragging a card between swimlanes is a cut the next session reads back.
