---
name: unpack
description: Rebuild a dense answer as a self-paced HTML page — a layered summary, one-concept-at-a-time cards, or diagrams — then open it in the browser.
disable-model-invocation: true
argument-hint: "[layered | stepwise | visual] — omit to let the material decide"
allowed-tools: Bash Read Write Glob Grep
---

# Unpack

The user has hit a wall of text — usually your own last answer — and needs it in a form they can take at their own speed. **Rebuild** it as one self-contained HTML page and open it.

Rebuild, never reformat. The sentences you already wrote are the ones that did not land; putting them in a nicer font changes nothing. Go back to the ideas underneath and say them again from scratch, in plain words, one to a **card**.

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

## Step 1: Find the source material

Default to the most recent substantial output in this conversation. An argument that names a file, a topic, or a section overrides that.

If the material refers to code, files, or commands you have not actually read, read them now. A confidently wrong page is worse than the dense text it replaced.

Then list, for yourself, every distinct idea the material contains. That list is what the page must cover — it is the bar you check against in Step 3.

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

**The writing bar**, in every mode:

- One idea per card. Two ideas means two cards.
- The heading carries the card alone. Closed, it is all the reader sees.
- The gist is one or two sentences. A fourth sentence belongs behind the toggle.
- Any term that is not ordinary English is either replaced with a plain word, or defined in half a sentence the first time it appears.
- Concrete beats abstract. Name the real file, the real number, the real command.
- Say what it means for the user, not only what it is.
- Short sentences. Under twenty words, most of the time.

**Check before opening**, three things:

1. Closed, the whole page fits on one screen. If it does not, there are too many cards.
2. Every idea from your Step 1 list appears on exactly one card.
3. Every term on the page is either plain English, or defined on the card where it first shows up.

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

Then hand back in two or three lines: the path, the mode you chose, the other modes available, and that they can come back **stuck** on any card.

## Step 5: The stuck loop

The user reads at their own pace with no agent in the loop. They return only when a card does not land, naming it by number or heading.

When they do:

1. Rewrite that one card. Leave every other card untouched — they have already been read, and rewriting them costs the user that ground again.
2. Reach for a different angle, not more words: a concrete example, a diagram, an analogy, a smaller decomposition into two cards.
3. Save the file and tell them to reload. The page reopens exactly as they left it — which cards were open lives in the URL hash.

A question that turns out to be about the subject rather than the wording is a normal question. Answer it in the terminal, then fold the answer into the card.
