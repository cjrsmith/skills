# Visual

The picture carries the explanation; the prose captions it. This is the mode for
anything whose difficulty is *shape* — what connects to what, what happens in
what order, what contains what.

Set `data-mode="visual"`. Cards start closed, as everywhere else, so opening one
is how the reader asks for a picture rather than being handed six at once.

## One idea, one picture

A card opens onto its diagram, a one-sentence caption, and at most a short
paragraph. The `.more` toggle underneath holds the words — the exceptions, the
mechanism, the names of things.

If a card has three paragraphs above the fold and a diagram, the diagram is not
doing the work. Either the picture is wrong, or the idea belongs in another mode.

**Seven nodes is the ceiling.** Past that a diagram stops being a picture and
becomes a second wall of text. Split it: draw the system at low resolution on one
card, then zoom into each part on its own. Two clear diagrams beat one complete one.

## Choosing the diagram

| The material is about | Draw |
|---|---|
| Something moving through stages | `flowchart LR` |
| Who calls whom, in what order | `sequenceDiagram` |
| What contains or relates to what | `flowchart TD` with subgraphs |
| Modes a thing can be in | `stateDiagram-v2` |
| Tables and their keys | `erDiagram` |

When nothing fits, hand-write an `<svg>`. A crude sketch of the real shape beats
a tidy flowchart of the wrong one.

## Making the picture readable

- **Label nodes in plain English.** "Waits for the retry" — not `retryHandler()`.
  Identifiers belong in the caption, if anywhere.
- **Label every edge with a verb.** `-->|"sends the token"|`. An unlabelled arrow
  hands the reader a relationship to guess at.
- **Say what to notice** in the `<figcaption>`. Not a title for the diagram — a
  sentence pointing at the thing it was drawn to show. "Notice that nothing is
  written to the database until the last step."
- **Keep direction consistent.** Time and flow go left to right, or top to
  bottom, never both on one page.
- **Colour carries meaning or is absent.** Use `classDef` to mark one class of
  thing — the slow steps, the parts the user owns — and say in the caption what
  the colour means. Decorative colour is noise the reader tries to decode.

## The headings still do the scanning

Closed, this page is a list of headings like any other. Write them to describe
what the picture shows, not that a picture exists. "The retry loops back on
itself" is a heading; "Diagram of the retry flow" wastes the one line the reader
always sees.
