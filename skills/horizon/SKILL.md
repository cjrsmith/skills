---
name: horizon
description: Capture every idea for a large product onto a story-map board on your issue tracker, cut the next release as a walking skeleton, and emit its destination for /wayfinder. One board per product, revisited release after release.
disable-model-invocation: true
argument-hint: "[board] [capture | cut | emit | status | \"a card to append\"]"
---

A product too big to hold in one head, and the ideas keep coming: every screen, every actor, every "oh and also". Horizon is where they land. It keeps a **story map** of the whole product as a **board** on the issue tracker, so nothing is ever re-explained, and it **cuts** one **release** at a time from that map: a thin **walking skeleton** through every activity rather than a deep build of one. Each release then leaves through **`/wayfinder`**, which charts the decisions; Horizon holds the *what*, Wayfinder the *how*.

## Fit check

Story mapping needs someone doing things in order to reach an outcome. The someone can be a customer, a developer, a service, or you running a batch of simulations at 3am. Work with no actor and no sequence (a data-structure migration, a wide rename, a dependency upgrade) has phases, not journeys: send it straight to `/wayfinder`, whose destination can be a change made in place.

## Harvest, don't judge

Horizon's capture is **divergent**: the agent harvests what the user says and widens the field. Grilling, with its recommended answers and design tree, is convergent, and it belongs in cut and in Wayfinder, never in capture. The agent adds a card only when the user says so; a gap it notices in the backbone is put as a **question** ("what happens when a simulation fails?"), and the user's answer becomes the card.

## Refer by name

Boards and cards are issues and have titles. In everything the human reads, refer to them by title; ids and URLs ride inside the name as links, never stand in for it.

## The story map

Three levels, top to bottom:

- **Activity**: one thing the user does on the way to the outcome. Activities read left to right in time order as the **backbone**. Read the backbone aloud: it should tell one person's story ("an analyst signs in, sets an ignition, runs a simulation, checks it against live detections, exports a briefing"). If it reads as a feature list, the level has slipped too low. If it reads as two unrelated stories, it is two boards.
- **Task**: one thing done inside an activity. "Draw a polygon area of interest" under "monitor detections". Stacked under its activity, most essential at the top.
- **Detail**: a refinement of a task. "Glass-box styling for the selected block." Rides along when its task is built.

A **release** is a horizontal line across the map. Above the line is in; below is later. The line **crosses every activity**: release 1 takes the thinnest task from each column so the whole journey works end to end, ugly and complete. That thinness is what makes it a walking skeleton. Where the product cannot be used until much more exists, the line is still drawn, but it answers "what must we see working to trust the architecture?" (the **riskiest assumption**) rather than "what can users have?". Cut says which criterion it is using.

## The board

One board per product, on the issue tracker. **Where the board, its cards, coordinates and views physically live is tracker-specific.** Consult the tracker doc's "Horizon operations" section for how _this_ repo expresses them; if no tracker doc has been provided, tell the user to run `/setup-matt-pocock-skills`, or default to the local-markdown tracker.

### The board body

The whole product at low resolution, loaded once per session. Cards are **not** listed here; they are found by query.

```markdown
## Frame

**Who:** <the people or systems this serves, and what they do today without it>
**Why:** <the pain or opportunity, and why now>
**Outcome:** <what is different for them once it exists; how anyone would know>

<one paragraph: one full pass through the product as a story, told from the Who's seat>

## Backbone

<activity> → <activity> → <activity> → …

## Releases

<!-- one line per release, newest last -->

- **R1** — <one-line gist: what it proves or delivers>. Map: [<map title>](link). <not cut | cut | charting | specifying | building | shipped YYYY-MM-DD>
- **R2** — not cut

## Status

<the line a fresh session reads first: which release is where, how many cards are unplaced, any cut in progress and how far it got>
```

### Cards

Each card is an issue on the tracker, attached to the board. Its title is the idea **in the user's words**, tidied at most; the "as a user I want" form belongs to `/to-spec`, downstream. Its body holds whatever context the user gave, and for a detail, a `Detail of: <task title>` line. Blank is fine.

A card carries three **coordinates**, each a single value: **Activity** (which column), **Release** (which row: `R1`, `R2`, … or `Later`), **Level** (`task` or `detail`). A card with no Activity is **unplaced**; capture leaves cards unplaced freely and cut places them. A closed card is **built**.

### Views

The tracker doc says how to render the map (a board grouped by Activity with Release as rows, or a label filter). Whatever the tracker offers, a human can move a card between releases in the tracker's own UI, and the next session reads that as the cut having moved. The tracker is the state; conversation holds nothing.

## Invocation

The first argument names the board (title, number or URL). Without it, list the boards the tracker holds and ask which, or start a new one. The second argument picks the phase. **One phase per session**, and capture may be many sessions: every card is written the moment it is spoken, so a capture session is cheap to abandon and resume.

### New board

User invokes with a product idea and no board.

1. Run the [fit check](#fit-check). Send phase-shaped work to `/wayfinder` and stop.
2. **Frame** the idea before touching features. Ask the big-picture questions, divergent and one at a time, with no recommended answer: who is this for, what do they do today without it, what hurts, why now, what is different once it exists, how would anyone know it worked, who else is affected. Let the user ramble; the frame is theirs. Done when Who, Why and Outcome can each be written in a line the user agrees with.
3. Draft the story paragraph and a first **Backbone** from the frame and whatever the user has said. Read the backbone back to them as a story. Iterate until it reads as one person's journey. Done when the user confirms the backbone.
4. Create the board with Frame and Backbone filled, Releases holding `R1 — not cut`, Status reading "new; no cards". Create the coordinate fields with the backbone's activities in order.
5. Continue straight into capture; the board is now the argument.

### Capture

User invokes with a board and `capture`, optionally with material to ingest: a filled `/to-questionnaire`, a meeting transcript, a competitor's feature list, or nothing but their own head.

1. Load the board body. Report the Status line in one sentence.
2. Ingest any material first: one card per distinct idea, written as it is read. Then harvest from the user. Each idea becomes a card **immediately**, before the next question. Set Activity when it is obvious; otherwise leave the card unplaced. Set Level only when obvious.
3. Widen the field. When the user pauses, ask across the angles they have not touched: other actors, day two, failure, operations, migration, compliance, offboarding. One question at a time, never a recommendation. A gap in the backbone is raised as a question.
4. Done when the user says they are dry **and** every idea spoken this session exists as a card. Update Status with the unplaced count.

A **quick append** is capture without a session: `/horizon <board> "<card text>"` creates one card, unplaced, and stops.

### Cut

User invokes with a board and `cut`. Cut is the convergent phase: call the Skill tool with "grilling" when the line is contested.

1. Load the board body and the **low-res view** of every open card: title and coordinates, one line each, never bodies. If the wall is large, cut one activity per session and record in Status which activities are placed.
2. Place every unplaced card: propose an Activity and Level for each, in a batch, and set them on the user's confirmation. A card that fits no activity is either a new activity (redraw the backbone, in order) or a signal the board should split.
3. Sort each column: within an activity, tasks most-essential first. Show the columns as a table.
4. Propose the line. Say which criterion applies (user value, or riskiest assumption) and name the assumption the release proves. The line touches every activity; a column with nothing above the line is a column the skeleton has skipped, so pick its thinnest task. Grill until the user agrees the line.
5. Set Release on every card: the next release number above the line, and the next-but-one or `Later` below. Nothing is deleted or closed; below the line is later, never never.
6. Done when every open card carries an Activity, a Level and a Release, and the Releases table has a gist for the new release. Update Status.

### Emit

User invokes with a board and `emit`, after a cut.

1. Load the board body and the low-res view of the cards in the next uncharted release.
2. Write the **destination block**, and post it as a comment on the board (or the tracker's equivalent) so it survives the session:

   ```markdown
   ## Destination

   A spec for <release> of <product>: <one or two lines naming the thin path through every activity and what it proves>.

   ## Notes

   <domain; the board, by name and link; skills every session should consult; standing preferences>

   ## Out of scope

   <!-- everything below the line, by activity, each pointing at the board so "out of scope" reads as "later" -->

   - <activity>: <card titles>, see [<board title>](link)

   ## Not yet specified

   <!-- decisions the cut surfaced and left open: how, not what -->
   ```

3. Choose the exit. When the block's **Not yet specified** holds decisions you cannot yet phrase as sharp questions, the way is foggy: tell the user to open a fresh session and run `/wayfinder` with the block, and mark the release `charting` in the Releases table. When every open decision is already a sharp question, one interview settles them: send the user to a fresh `/grill-with-docs` session with the block, from which `/to-spec` and `/to-tickets` follow as on the main flow, and mark the release `specifying`. Either way the release reaches `/to-spec` before any ticket is cut.
4. Done when the block is posted and the Releases table names the exit. When the map or spec exists, link it from the Releases table.

### Status

User invokes with a board and `status`, or with a board alone. Load the body, count open cards by Release and unplaced, and report in a few lines. If the user says a release has shipped: close the cards the release delivered, mark the release `shipped` with the date, and suggest a short capture for what building it taught them. The loop is capture → cut → emit → build → status → capture.

## Splitting a board

When the backbone stops reading as one story, split: one board per journey, and a small board for whatever they share (a shell, auth, a map component). A card that belongs in two boards is shared infrastructure and marks where the third board goes. Splitting is a scoping act, recorded in each board's Frame, never a step on a release.
