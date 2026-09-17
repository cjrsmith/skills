---
name: unpack
description: Rebuild a dense answer for a reader coming to it cold — a self-paced HTML page of layered cards, one-at-a-time steps, or diagrams — then open it in the browser.
disable-model-invocation: true
argument-hint: "[layered | stepwise | visual], and/or what did not land — omit to let the material decide"
allowed-tools: Bash Read Write Glob Grep
---

# Unpack

The user has hit a wall of text — usually your own last answer — and needs it in a form they can take at their own speed. **Rebuild** it as one self-contained HTML page and open it.

Rebuild, never reformat. The sentences you already wrote are the ones that did not land; putting them in a nicer font changes nothing.

They did not land because they **took something for granted** — a term, a step, a reason the reader was assumed to already hold. So the rebuild starts from the reader rather than from the material. Say the ideas again from scratch, for someone arriving **cold**, one idea to a **card**.

Every invocation ends with a page open in the user's browser.

## The principle: closed by default

The page holds back. It loads as a list of headings — the shape of the whole
thing on one screen — and the reader opens what they want, when they want it.
Each heading opens to a two-sentence **gist**; each gist holds a second toggle
for the **detail**.

This is the point of the skill, in every mode. The user reads at their own pace,
and pace means choosing what arrives next. A page that shows everything at once
has handed back the wall of text with better spacing.

Three depths, and the reader enters each on purpose:

```
▸ The wrapper catches the timeout          always visible
    A failed call waits, then goes again.  opens on click
    ▸ What the backoff actually does       opens on click
```

The modes differ in what a card holds, never in this. `stepwise` limits harder
still, to one card at a time. `visual` opens onto a picture instead of a
paragraph.

## Step 1: Find the material, and what it takes for granted

Default to the most recent substantial output in this conversation. An argument that names a file, a topic, or a section overrides that.

If the material refers to code, files, or commands you have not actually read, read them now. A confidently wrong page is worse than the dense text it replaced.

Then write two lists, for yourself:

1. **Every distinct idea** the material contains. The page covers all of them.
2. **Everything the material takes for granted** — each term, acronym, prior decision, and piece of background it uses without introducing. When the user named what did not land, that goes at the top of the list, and you check the rest against it.

Both lists are bars you check against in Step 3. The second list is what makes this a rebuild: it is the difference between the same text in a bigger font and a page that starts where the reader is.

## Step 2: Pick the mode

An argument naming a mode wins. Otherwise choose from the material and say which you chose, and how to switch, when you hand back.

| Material | Mode | Spec |
|---|---|---|
| A decision, a summary, a status, a recommendation | `layered` | [LAYERED.md](./LAYERED.md) |
| A procedure, or ideas that build on each other | `stepwise` | [STEPWISE.md](./STEPWISE.md) |
| A system, a flow, a structure, things related to things | `visual` | [VISUAL.md](./VISUAL.md) |

Read the spec for the mode you picked. The other two do not apply.

Diagrams are welcome in any mode. `visual` is the mode where they carry the explanation rather than support it.

## Step 3: Write the page

Build the HTML from the shell, styling, and scripts in [PAGE.md](./PAGE.md). Save it to the working directory root as `unpack-{topic}.html`, kebab-case.

**The writing bar**, in every mode.

What goes on a card:

- One idea per card. Two ideas means two cards.
- The heading carries the card alone. Closed, it is all the reader sees.
- The gist is one or two sentences. A fourth sentence belongs behind the toggle.
- Concrete beats abstract. Name the real file, the real number, the real command.
- Say what it means for the user, not only what it is.

Every card lands **cold**. This is the reframe, and it lives in the order and the wording rather than in a preface:

- **No card waits on a card below it.** Every term on a card is ordinary English, or it was defined earlier on the page. In `layered` and `visual` the reader chooses the order, so a card carries its own half-sentence definition rather than leaning on the card above it.
- A card that needs two things the reader does not have yet is really two cards. Split it.
- Each item on your Step 1 assumptions list is replaced with a plain word, defined in half a sentence where it first appears, or given a card of its own. It never simply shows up.

The sentences are ASD-STE100 Simplified Technical English:

- One instruction, one sentence. Under twenty words.
- Active voice, present tense. "The wrapper catches the timeout", not "timeouts are caught".
- One word, one meaning, for the whole page. Choose `retry` or `attempt`, then keep it.
- The simplest verb that is true. "Use", not "utilise". "Start", not "initiate".
- Articles stay in. "Run the test", not "Run test".

**Check before opening**, three things:

1. Closed, the whole page fits on one screen. If it does not, there are too many cards.
2. Every idea from your Step 1 list appears on exactly one card.
3. **Read the page cold**, top to bottom, as someone who knows only ordinary English. Nothing from your assumptions list arrives unexplained, and no card depends on a card below it.

## Step 4: Open it

```bash
xdg-open unpack-{topic}.html 2>/dev/null || open unpack-{topic}.html
```

Keep the file out of the user's repo without touching tracked files:

```bash
if gitdir=$(git rev-parse --git-dir 2>/dev/null); then
  grep -qxF 'unpack-*.html' "$gitdir/info/exclude" 2>/dev/null \
    || echo 'unpack-*.html' >> "$gitdir/info/exclude"
fi
```

Then hand back in two or three lines: the path, the mode you chose and the other modes available, and the one thing you decided the original text had assumed. Name that guess — if it is wrong, it is the fastest thing for them to correct. They can also come back **stuck** on any card.

## Step 5: The stuck loop

The user reads at their own pace with no agent in the loop. They return only when a card does not land, naming it by number or heading.

When they do:

1. Rewrite that one card. Leave every other card untouched — they have already been read, and rewriting them costs the user that ground again.
2. Check the card against the reader before you check the prose: does it still take something for granted? That is the usual cause, and the fix is a sentence of setup rather than a rewrite.
3. Otherwise reach for a different angle, not more words: a concrete example, a diagram, an analogy, a smaller decomposition into two cards.
4. Save the file and tell them to reload. The page reopens exactly as they left it — which cards were open lives in the URL hash.

A question that turns out to be about the subject rather than the wording is a normal question. Answer it in the terminal, then fold the answer into the card.
