# Layered

Three depths on one page, all of them shut. The reader scans the headings, opens
what they need, and stops at whatever depth answers the question.

Set `data-mode="layered"`. There is no pager; the cards open in place.

## Layer 1 — the lede, the actions, the headings

Three things are visible on load, and nothing else.

The `.lede` is one sentence. If the reader closes the tab after it, they should
still know what the material was about.

Under it, a `.todo` block listing what the user actually has to do — decisions to
make, commands to run, things to check. Each item is one line, starting with a verb.

```html
<div class="todo">
  <h2>What you need to do</h2>
  <ul>
    <li>Pick a retry ceiling — 3 is the usual answer.</li>
    <li>Run <code>npm test</code> before deploying.</li>
  </ul>
</div>
```

When the material asks nothing of the user, say so in one line and keep the
block. Its absence reads as an oversight; "Nothing to do — this is background"
closes the question.

Then the stack of closed cards. **The headings are the contents page.** Read
top to bottom as a list, they should tell the reader what the material covers
before they open anything.

## Layer 2 — the gist

One card per concept, three to seven of them. The heading is **five words or
fewer**; opening it gives one or two plain sentences.

The five-word cap is the work. It forces you to decide what the concept actually
is before you write about it. "Retries are capped at three" is a heading.
"Understanding the retry configuration system" is an unfinished thought.

Write the headings to be read consecutively. Each one should make sense cold,
without the one above it, because the reader is scanning rather than reading.

Order by consequence, not by foundation. The reader who opens two cards and
stops should have opened the two that mattered.

## Layer 3 — the detail

Each card carries its own `.more` toggle holding the technical version of *that*
concept. Co-located, never pooled into an appendix — a reader who opens one card
should get that card's detail and nothing else.

This is where precision lives: the real names, the exact flags, the edge case,
the reason it works this way. Jargon is allowed here and defined as it appears.

Name the toggle for what is inside it — "Why three and not five", not "More
detail". The reader should be able to decide whether to open it without opening it.
