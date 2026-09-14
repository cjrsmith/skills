# Stepwise

The hardest limit of the three: one card on screen, and the reader moves when
they are ready. This is the mode for anything where card four is meaningless
until card three has landed.

Set `data-mode="stepwise"`. The pager appears and the toolbar hides on its own.
The card on screen opens automatically; its `.more` toggle stays shut, so the
detail is still something the reader asks for.

## Card 1 is the map

Before any content, one card listing the headings of everything that follows —
just the headings, in order, as a numbered list.

```html
<details class="card">
  <summary><h2>What we are going to cover</h2></summary>
  <div class="body">
    <p>Six steps. Each one builds on the one before it.</p>
    <ol class="toc">
      <li>Request arrives</li>
      <li>The wrapper catches the timeout</li>
    </ol>
  </div>
</details>
```

Knowing the shape of the journey is what makes it safe to go slowly. Without it,
every card raises the question of how many are left.

## Ordering is the whole design

Order the cards so that **each one uses only ideas the reader has already met**.
Every term on card four was either defined on cards one to three or is ordinary
English. This is checkable: walk the cards in order and confirm that nothing in
each is still unexplained.

When a card needs two things the reader does not have yet, it is really two
cards. Split it.

Four to nine content cards. Fewer than four rarely needs pacing; more than nine
and the sequence itself becomes the thing that is hard to hold.

## A card

```html
<details class="card">
  <summary><h2>The wrapper catches the timeout</h2></summary>
  <div class="body">
    <span class="num">Step 3 of 6</span>
    <p>{Two to four sentences. One idea.}</p>
    <p class="note">Check: could you say what happens on the second failure?</p>
    <details class="more">
      <summary>The exact backoff timings</summary>
      <p>{Detail, for the reader who wants it now rather than later.}</p>
    </details>
  </div>
</details>
```

- The `.num` is not decoration. Knowing there are three left is what makes it
  safe to slow down on this one.
- Two to four sentences in the body. A card that needs more is two cards.
- Close with one `.note` — a question the reader can answer in their head. Not a
  quiz: a way to tell "I read that" from "I have that", which is the judgement
  this whole mode asks them to make.
- A small diagram or three lines of code earn their place. A long code block does
  not; the reader is deciding whether they understood a sentence.

## The last card

The final card recaps: every heading in order, each with its one-line version.
Card 1 was the map before the journey; this is the map after it, and it is the
part worth re-reading tomorrow.
