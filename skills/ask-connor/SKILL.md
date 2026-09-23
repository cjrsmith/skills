---
name: ask-connor
description: Ask which skill or flow fits your situation. A router over the skills in this repo.
disable-model-invocation: true
---

# Ask Connor

You don't remember every skill, so ask.

A **flow** is a path through the skills. Most paths run along one **main flow**, and two **on-ramps** merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath.

## The main flow: idea → ship

The route most work travels. You have an idea and want it built.

1. **`/grill-with-docs`** sharpens the idea by interview. Start here whenever you are **working in a working directory**: it's stateful, retaining what it learns in `CONTEXT.md` and ADRs. (No working directory? Use `/grill-me` instead, covered under Standalone. Both run the same `/grilling` primitive; `grill-with-docs` is the one that leaves a paper trail, which makes it the better of the two whenever a repo is there to leave it in.)
2. **Branch: can you settle every question in conversation?** If a question needs a runnable answer (state, business logic, a UI you have to see), detour through a prototype, bridged by **`/handoff`** in both directions (a prototype lives in its own directory, which is exactly what `/handoff` is for; see Phase boundaries):
   - **`/handoff`** out, then open a fresh session against that file,
   - **`/prototype`** to answer the question with throwaway code,
   - **`/handoff`** back what you learned, and reference it from the original idea thread.
3. **Branch: is this a multi-session build?**
   - **Yes** → **`/to-spec`** (turn the thread into a spec), then **`/to-tickets`** to split it into tracer-bullet tickets, each declaring its **blocking edges**. On a local tracker that's one file per ticket under `.scratch/<feature>/issues/`, worked blockers-first by hand; on a real tracker the edges become native blocking links, so any ticket whose blockers are done can be grabbed: kick off **`/implement`** per ticket, **`/clear`ing context between each one**. Each ticket is self-contained, so the last one's context is disposable.
   - **No** → **`/implement`** right here, in the same context window.

   Either way, **`/implement`** builds each issue by driving **`/tdd`** internally (one red-green slice at a time), then closes out by running **`/review-code`**, a two-axis review (Standards + Spec) of the diff, before committing. Reach for **`/tdd`** on its own when you just want to build a concrete behaviour test-first without a full spec, and **`/review-code`** on its own whenever you want to review a branch or PR against a fixed point.

### Two other ways to build

Same place in the flow, different hands on the keyboard:

- **`/implement-spec`** takes the spec and its tickets as one **task graph** and works the whole **frontier** at once, dispatching implementer subagents in the background for maximum concurrency, onto a single branch and one PR. Subagents talk in **context pointers** (the spec, the tickets, previous commits), never in duplicated prose. Reach for it when the tickets are already sharp and you want the spec built in one go rather than a ticket at a time; reach for per-ticket `/implement` when you want to read each slice as it lands.
- **`/navigator`** inverts the roles: **you** are the Driver and type every line, in another tab, and the agent is the Navigator, holding the aim and giving directions. Its code reaches you only when you go and read it. Reach for it when the point is that you end up knowing the code, not that it gets written fastest.

### Context hygiene

Keep steps 1–3 in **one unbroken context window** (don't compact or clear until after `/to-tickets`) so the grilling, spec, and tickets all build on the same thinking. Each `/implement` then starts fresh, working from the ticket.

The limit on this is the **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**: the window (~150k tokens on state-of-the-art models) within which the model still reasons sharply. If a session approaches it before `/to-tickets`, don't push on degraded; `/compact` at the nearest phase boundary and carry on (see Phase boundaries).

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- **Bugs and requests piling up** → **`/triage`**. It moves issues through triage roles and produces agent-ready issues, which **`/implement`** later picks up.

  Triage is only for issues **you didn't create**: bug reports, incoming feature requests, anything that arrives raw. Tickets that `/to-tickets` produced are already agent-ready, so **don't triage them**.

- **Something's broken** → **`/diagnosing-bugs`**. For the hard ones: the bug that resists a first glance, the intermittent flake, the regression that crept in between two known-good states. It refuses to theorise until it has a **tight feedback loop** (one command that already goes red on *this* bug), then fixes with a regression test. Its post-mortem hands off to **`/improve-codebase-architecture`** when the real finding is that there's no good seam to lock the bug down.

  **A program on this machine died instead** → **`/diagnose-crash`**, the core-dump end of broken: a segfault, an abort, a window that just vanished. It works from `coredumpctl`, the symbolized backtrace and the command line the process was actually started with to an honest account of what happened, and carries the route for reporting a confirmed Omarchy bug upstream. Model-invoked, so a crash reaches it without you typing anything. Where `/diagnosing-bugs` needs a bug you can still provoke, this one starts from the corpse.

- **A whole product's worth of ideas, more than one map should hold** → **`/horizon`**. It frames the idea (who, why, outcome), lays the **backbone** of a **story map** on the issue tracker, harvests every idea as a **card** without judging it, then **cuts** the next release as a **walking skeleton**: the thinnest task from every activity, end to end. Nothing below the line is deleted, it is *later*, and the board outlives every release, so slice two starts from the board, not from re-explaining the product. It **emits** a destination block for the release and hands off: to **`/wayfinder`** when the *how* is still foggy, or onto the main flow at **`/grill-with-docs`** when every open decision is already a sharp question. Both routes reach `/to-spec` before a ticket is cut. Reach for it when the thing in your head is a product, not a feature; a feature you can already name goes to `/wayfinder` or `/grill-with-docs` directly.

- **A huge, foggy effort: a greenfield project or a huge feature build, too big for one session** → **`/wayfinder`**, the most cognitively demanding flow here. When the way from here to the destination isn't visible yet, it charts a **shared map** of **decision tickets** on the issue tracker and resolves them one at a time, producing **decisions, not deliverables**, until the fog is pushed back and the way is clear. Where **`/grill-with-docs`** sharpens an idea you can hold in one session, wayfinder is for the idea you can't, and it's slower and denser, so save it for exactly that, never a well-scoped feature.

  When the map clears, **it hands off, it doesn't build**: merge onto the main flow at **`/to-spec`**, which collapses the map's linked decisions into a buildable plan, then `/to-tickets` and `/implement` as usual. Looping the map straight into `/implement` skips that collapse and throws the linked detail away, so go straight to `/implement` only when the effort turned out genuinely small.

## Codebase health

Not feature work, just upkeep.

- **`/improve-codebase-architecture`** runs whenever you have a spare moment to keep the codebase good for agents to operate in. It surfaces **deepening opportunities**; picking one _generates an idea_ you can take into the main flow at `/grill-with-docs`. It's the survey that finds the candidates; **`/codebase-design`** (below) is the bench you design the chosen one on.
- **`/setup-ts-deep-modules`** makes that shape **enforceable** in a TypeScript repo, once: dependency-cruiser rules that hide every package's implementation in subfolders and leave the entry-point files as the only way in, then a proof that the rules bite. Where `/improve-codebase-architecture` finds the work by reading, this stops the shape eroding by failing the build.
- **`/retro`** looks at the **session** rather than the code, and improves the **environment** the next agent runs in: a missing navigation pointer, an automated check that would have caught the mistake, a coding-standards rule for the reviewer agent, a steering instruction bloating `AGENTS.md`. Run it after a session that went badly, so the lesson lands in the repo instead of in your memory.

## Vocabulary underneath

Two model-invoked references that run *beneath* the other skills, each the single source of truth for its vocabulary. Reach for them directly when the **words**, not the process, are the problem; or let the skills above pull them in.

- **`/domain-modeling`**: sharpen the project's *domain* language: challenge a fuzzy term, resolve an overloaded word ("account" doing three jobs), record a hard-to-reverse decision as an ADR. It's the active discipline `/grill-with-docs` drives to keep `CONTEXT.md` a clean glossary.
- **`/codebase-design`** is the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's *shape*: a lot of behaviour behind a small interface at a clean seam. `/tdd` and `/improve-codebase-architecture` both speak it.

## Phase boundaries

A **phase** is a chunk of work inside a session: the grilling, the implementation, the QA. At the **boundary** between two of them you have five options, and picking between them is the fuzziest decision in this whole map:

- **Continue**: stay put. Costs nothing, loses nothing.
- **`/clear`**: empty the window, when nothing here matters to what's next.
- **`/handoff`** writes a portable markdown file. Narrow: only for a **new harness**, a **new directory**, a **colleague**, or forking a side task **mid-phase**. What it buys is portability. **`/claude-handoff`** is the same summary **fired rather than filed**: it launches a named background agent seeded with it, in this directory, so the next phase starts immediately and you keep this window. Use it when the next phase is a whole task you'd only hand back to yourself anyway; use plain `/handoff` when the file has to travel to a different tool, machine, or person.
- **Subagent**: send a tightly-scoped task to its own window and get a report back.
- **`/compact`** compresses this context and seeds a fresh session with it. The **default**, at the bottom of the tree rather than the first reach.

Read [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) for the ordered tree: the five questions, the reasoning behind each branch, and why the primary-source cost makes **Continue** the one to rule out first. Make the decision **at** a boundary; mid-phase, continue or split the rest into subagents.

## Writing prose

Not documents for agents: an article for humans. Two phases, run in order over one file of raw material.

- **`/writing-fragments`** is **explore**: a grilling session that mines fragments out of you, from your very first sentence onwards, and appends them to a single markdown file. No outline, no phases, nothing thrown away. Widening the space is the whole job.
- Then one of the two **exploit** halves. Both read that pile end to end, treat it as read-only, and write a separate article file:
  - **`/writing-shape`** commits to a **structure** and mines the pile to fill it, paragraph by paragraph.
  - **`/writing-beats`** commits to a **path** instead: a choose-your-own-adventure journey of **beats**, where every concept a beat leans on must already have been **grounded** by an earlier one. Reach for it when the order of ideas is the hard part, and for `/writing-shape` when you already know the shape and just need it filled.
- **`/writing-for-agents`** is the reference for the *other* kind of writing: documents agents consume, which is skills, `AGENTS.md`, and any doc a pointer aims at. Read it before writing or editing one of those, including anything in this repo.

## Explaining

Making something land, for you or for someone else.

- **`/wait-what`** is the corrective for a message that didn't land. Use it mid-conversation, inside any other skill, and the agent re-pitches what it just said with the context you were missing, in plain English, using the `CONTEXT.md` vocabulary. It works after the fact; `/grill-with-docs` is the upfront cure, because a shared language agreed early is what stops the jargon arriving at all.
- **`/unpack`** is the same corrective when re-pitching in the chat isn't enough. It **rebuilds** the answer from scratch for a reader arriving **cold** — layered cards, one-at-a-time steps, or diagrams — as a self-contained HTML page it opens in your browser, so you can take it at your own speed. Rebuild, never reformat: the sentences that already failed don't improve in a nicer font.
- **`/walkthrough`** aims that at a codebase instead of an answer: an HTML page with a clickable Mermaid diagram of a feature, flow, architecture, or database schema, readable in under two minutes. It's an onboarding **mental model**, not a code reference.
- **`/teach`**: learn a concept over multiple sessions, using the current directory as a stateful workspace.

## Standalone

Off the main flow entirely.

- **`/grill-me`**: the same relentless interview as `/grill-with-docs`, but **stateless**: it saves nothing locally and builds no `CONTEXT.md`. Reach for it when you are **not working in a working directory** (sharpening a plan, a design, a piece of writing, anything with no repo under it). If you are in a working directory, use `/grill-with-docs` instead: it runs the same interview and leaves a paper trail, so it is strictly the better one.
- **`/grilling`** is the interview primitive itself: rounds, the frontier, facts are the agent's job and decisions are yours. `/grill-me` and `/grill-with-docs` are the two named ways in, and `/triage`, `/wayfinder` and `/improve-codebase-architecture` all run it internally. Reach for it directly only when you want the interview with no wrapper around it.
- **`/loop-me`** is the interview pointed at your **life** rather than a codebase. A **loop** is anything recurring — a career, a week, a morning, one repeated chore — and seeing the loops is what reveals which are predictable enough to **delegate**. Its only output is **workflow** specs in `workflows/*.md`, one per loop. Reach for it when the thing to sharpen is something you'll do again, not something to build once.
- **`/resolving-merge-conflicts`** works an in-progress merge or rebase conflict hunk by hunk, resolving by **intent** traced to each side's primary source rather than by picking lines, then finishes the operation. It never runs `--abort`. Standalone and off every flow: reach for it when you are already mid-conflict.
- **`/prototype`** is a small, throwaway program that answers one design question: does this state model feel right, or what should this UI look like. Throwaway is a constraint on how the code is written, not a promise to destroy it: the answer folds into the real code, and the prototype itself is kept as a **primary source** on a `prototype/<name>` branch out of main, pointed at from the implementation issue. It's the detour in step 2 of the main flow, but reach for it any time a design question is hard to settle on paper.
- **`/research`**: delegate reading legwork to a **background agent**: it investigates a question against **primary sources**, then leaves a cited Markdown file in the repo. Keep working while it reads. The file it produces is something to take *into* the main flow at `/grill-with-docs`, since research feeds the thinking rather than replacing it.
- **`/to-questionnaire`** comes in when the thing blocking you isn't in your head or the codebase but in **someone else's**, and it writes them a questionnaire to fill in. It's the inverse of `/grill-me`: instead of interviewing you about the subject, it interviews you about the **send** (who it's going to, what you need back) and aims the questions at the gap. What comes back is material for `/grill-with-docs` or `/to-spec`.
- **`/wizard`** is for the steps only a **human** can take: provisioning infrastructure, setting up credentials or CI secrets, clicking through an unfamiliar third-party dashboard, running a one-off migration or cutover. It generates an interactive bash script that opens each URL, captures each value, and writes it into `.env` and GitHub secrets, so the procedure stops being something you re-explain to an agent every time. Model-invoked, so the agent reaches for it the moment it hits a wall only you can pass. If the agent could just do it itself, it should; this is for where a human is genuinely in the loop.

## Precondition

**`/setup-skills`**: run before your first engineering flow to configure the issue tracker, triage labels, and doc layout the other skills assume. Custom issue trackers also work.

## Fires on its own

Model-invoked, every one: the agent reaches these itself from the situation, so the list is here to tell you they exist, not to be typed.

- **`/setup-pre-commit`** installs Husky and lint-staged in this repo: Prettier on staged files, plus typecheck and tests at commit time. One-time, per repo.
- **`/git-guardrails-claude-code`** installs a PreToolUse hook that blocks the destructive git commands (`push`, `reset --hard`, `clean -f`, `branch -D`, `checkout .`) before they run.
- **`/omarchy`** is the reference for customizing this **Omarchy** machine: Hyprland window rules, keybindings, monitors, gaps, animations, the bar, terminal config, themes, idle and lock. Any edit under `~/.config/hypr/` or `~/.config/omarchy/` goes through it. When something crashes instead, that's `/diagnose-crash`.
- **`/herdr`** drives **Herdr**, the terminal multiplexer for coding agents: inspect and control panes, tabs, workspaces, and the agents running in them. Only in a Herdr-managed pane (`HERDR_ENV=1`), and only when you ask for Herdr by name.
- **`/find-skills`** searches the open agent-skills ecosystem and installs what it finds. The answer to "is there a skill for this?" when the answer isn't in this document.
- **`/migrate-to-shoehorn`** replaces `as` assertions in **test** files with `@total-typescript/shoehorn`, so partial test data stays type-safe. Test code only.
- **`/scaffold-exercises`** builds the AI Hero exercise tree — sections, problems, solutions, explainers — in the naming that passes `ai-hero-cli internal lint`.
