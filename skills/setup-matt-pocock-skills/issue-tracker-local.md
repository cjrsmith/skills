# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md` (the Notes / Decisions-so-far / Fog body).
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records `claimed`/`resolved`.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for files that are open, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, then append a context pointer (gist + link) to the map's Decisions-so-far in `map.md`.

## Horizon operations

Used by `/horizon`. The **board** is a file with one **card** file per idea.

- **Board**: `.scratch/horizons/<product-slug>/board.md` (the Frame / Backbone / Releases / Status body).
- **Card**: `.scratch/horizons/<product-slug>/cards/NN-<slug>.md`, numbered from `01`. The first line is the title in the user's words; then `Activity:`, `Release:`, `Level:` lines (blank when unset; blank `Activity:` is **unplaced**) and a `Status:` line of `open` / `built`; then any context and `Detail of: <task>` for a detail.
- **Set a coordinate**: edit the line.
- **Low-res view**: `head -5` every card file; never read whole bodies.
- **Built**: set `Status: built`.
- **Destination block**: `.scratch/horizons/<product-slug>/R<n>-destination.md`, linked from the Releases table.
- **View**: `grep -l "Activity: <slug>" cards/*.md` is a column; `grep -l "Release: R1"` is a row.
