# The page

One self-contained HTML file. No build step, no framework. The only network
dependency is Mermaid, and the page stays readable when it fails to load.

## Closed by default

Every card is a `<details>`. The page loads as a stack of headings and nothing
else, so the first thing the reader gets is the shape of the whole thing on one
screen. Each card opens to a short **gist**, and the gist holds a second
`<details>` for the **detail**.

Three depths, each one entered on purpose:

```
▸ The wrapper catches the timeout          ← always visible
    A failed call waits, then goes again.  ← opens on click
    ▸ What the backoff actually does       ← opens on click
```

Native `<details>` does the work. No JavaScript is needed to read the page —
the scripts only add position memory and the expand-all control.

**The bar**: closed, the page fits in one screenful. If it does not, there are
too many cards.

## Typography is load-bearing

This page exists because reading is the bottleneck. The numbers below are part of
the deliverable, not decoration — keep them.

- Body text `19px`, line-height `1.7`.
- Line length capped at `62ch`. Long lines are the single worst thing for re-reading.
- Left-aligned, ragged right. Never justified.
- Paragraphs of one to three sentences, with real space between them.
- Light and dark both defined, following the system. The user's desktop is dark.

## Shell

Fill in the title, the lede, and the cards. Set `data-mode` on `<body>` to
`layered`, `stepwise`, or `visual` — `stepwise` is the only one that pages.

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{Topic}</title>
<style>
  :root {
    --bg: #fbfaf8; --surface: #ffffff; --border: #e2ded7;
    --fg: #1c1a17; --muted: #6b6660; --accent: #b4531f; --accent-soft: #fdf0e7;
    --shadow: 0 1px 2px rgba(0,0,0,.05), 0 8px 24px rgba(0,0,0,.04);
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: #14120f; --surface: #1c1a17; --border: #322e28;
      --fg: #ece8e1; --muted: #9a938a; --accent: #e08a52; --accent-soft: #2a2019;
      --shadow: none;
    }
  }
  * { box-sizing: border-box; }
  html { color-scheme: light dark; }
  body {
    margin: 0; padding: 0 20px 25vh;
    background: var(--bg); color: var(--fg);
    font: 19px/1.7 ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
    -webkit-font-smoothing: antialiased;
  }
  .wrap { max-width: 62ch; margin: 0 auto; }
  header { padding: 10vh 0 0; }
  h1 { font-size: 1.9rem; line-height: 1.25; margin: 0 0 .6rem; letter-spacing: -.02em; }
  .lede { font-size: 1.15rem; margin: 0 0 1rem; }
  .todo {
    background: var(--accent-soft); border-left: 3px solid var(--accent);
    padding: .9rem 1.1rem; border-radius: 0 8px 8px 0; margin: 1.5rem 0;
  }
  .todo h2 { font-size: .78rem; text-transform: uppercase; letter-spacing: .09em;
             color: var(--accent); margin: 0 0 .5rem; }
  .todo ul { margin: 0; padding-left: 1.1rem; }
  .todo li { margin-bottom: .3rem; }
  .todo li:last-child { margin-bottom: 0; }

  /* The toolbar sits between the lede and the stack. */
  .bar { display: flex; justify-content: space-between; align-items: baseline;
         margin: 2rem 0 .6rem; }
  .bar .hint { color: var(--muted); font-size: .82rem; text-transform: uppercase;
               letter-spacing: .09em; }
  .bar button { font: inherit; font-size: .85rem; background: none; cursor: pointer;
                border: 1px solid var(--border); border-radius: 999px;
                padding: .2rem .8rem; color: var(--muted); }
  .bar button:hover { color: var(--accent); border-color: var(--accent); }

  /* A card: closed it is one heading; open it is the gist. */
  .card {
    background: var(--surface); border: 1px solid var(--border); border-radius: 12px;
    margin: .55rem 0; box-shadow: var(--shadow);
  }
  .card > summary {
    list-style: none; cursor: pointer; padding: 1rem 1.3rem;
    display: flex; gap: .75rem; align-items: baseline;
  }
  .card > summary::-webkit-details-marker { display: none; }
  .card > summary::before {
    content: "›"; color: var(--accent); font-size: 1.3rem; line-height: 1;
    transition: transform .15s ease; flex: none; transform: translateY(.1em);
  }
  .card[open] > summary::before { transform: translateY(.1em) rotate(90deg); }
  .card > summary h2 { font-size: 1.15rem; line-height: 1.35; margin: 0; font-weight: 600; }
  .card[open] > summary { padding-bottom: .4rem; }
  .card .body { padding: 0 1.3rem 1.4rem 2.65rem; }
  .card .body > p { margin: 0 0 .9rem; }
  .card .body > p:last-child { margin-bottom: 0; }
  .num { display: block; font-size: .72rem; letter-spacing: .1em; text-transform: uppercase;
         color: var(--muted); margin-bottom: .5rem; }
  .note { color: var(--muted); font-size: .95rem; }

  /* The second level, inside a card. */
  .more { margin-top: 1rem; border-top: 1px solid var(--border); padding-top: .9rem; }
  .more > summary { cursor: pointer; color: var(--accent); font-size: .95rem; }
  .more[open] > summary { margin-bottom: .8rem; }
  .more p:last-child, .more ul:last-child, .more ol:last-child { margin-bottom: 0; }
  .more ul, .more ol { padding-left: 1.1rem; }
  .more li { margin-bottom: .45rem; }

  code { font: .88em/1.5 ui-monospace, "SF Mono", Menlo, monospace;
         background: var(--accent-soft); padding: .1em .35em; border-radius: 4px; }
  pre { background: var(--accent-soft); padding: 1rem; border-radius: 8px;
        overflow-x: auto; font-size: .85rem; line-height: 1.55; }
  pre code { background: none; padding: 0; }
  figure { margin: 1.2rem 0; }
  figure svg, .mermaid svg { max-width: 100%; height: auto; display: block; margin: 0 auto; }
  figcaption { color: var(--muted); font-size: .95rem; margin-top: .7rem; text-align: center; }
  .toc { margin: 0; padding-left: 1.2rem; }
  .toc li { margin-bottom: .35rem; }

  .pager {
    position: fixed; left: 50%; transform: translateX(-50%); bottom: 24px;
    display: flex; gap: .5rem; align-items: center;
    background: var(--surface); border: 1px solid var(--border);
    border-radius: 999px; padding: .45rem .6rem; box-shadow: var(--shadow);
  }
  .pager button {
    font: inherit; font-size: .95rem; border: 0; border-radius: 999px;
    padding: .45rem 1rem; cursor: pointer; background: var(--accent); color: #fff;
  }
  .pager button:disabled { opacity: .45; cursor: default; }
  .pager .ghost { background: transparent; color: var(--muted); }
  .pager .count { color: var(--muted); font-size: .85rem; padding: 0 .6rem;
                  font-variant-numeric: tabular-nums; }
  .stuck { color: var(--muted); font-size: .9rem; text-align: center; margin-top: 1.6rem; }
  @media (max-width: 500px) {
    body { font-size: 18px; }
    header { padding-top: 7vh; }
    .card .body { padding-left: 1.3rem; }
  }
</style>
</head>
<body data-mode="layered">
<div class="wrap">
  <header>
    <h1>{Topic}</h1>
    <p class="lede">{One sentence. What this is about, in the plainest words available.}</p>
  </header>

  <div class="bar">
    <span class="hint">{n} things &middot; open what you want</span>
    <button class="expand">Open all</button>
  </div>

  <main id="cards">
    <!-- cards go here -->
  </main>

  <p class="stuck">Stuck on a card? Say so in the terminal — name it by heading.</p>
</div>

<nav class="pager" hidden>
  <button class="ghost prev">&larr;</button>
  <span class="count"></span>
  <button class="next">Got it &rarr;</button>
</nav>

<script type="module">
  const cards = [...document.querySelectorAll('.card')];
  const stepwise = document.body.dataset.mode === 'stepwise';
  const setHash = h => { try { history.replaceState(null, '', h || location.pathname); }
                         catch (e) {} };

  // Mermaid sizes a diagram from its container, and a closed <details> is
  // zero-wide. Open everything to measure, then put it back.
  const all = [...document.querySelectorAll('details')];
  const was = all.map(d => d.open);
  all.forEach(d => { d.open = true; });
  try {
    const { default: mermaid } = await import(
      'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs');
    mermaid.initialize({
      startOnLoad: false,
      look: 'handDrawn',
      handDrawnSeed: 3,
      theme: matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default',
      fontFamily: 'ui-sans-serif, system-ui, sans-serif',
      flowchart: { curve: 'basis', padding: 16 },
    });
    await mermaid.run({ querySelector: '.mermaid' });
  } catch (e) {
    // Offline or CDN blocked: the diagram source stays visible as text.
  } finally {
    all.forEach((d, i) => { d.open = was[i]; });
  }

  if (stepwise) initPager(); else initStack();

  // Layered and visual: everything closed, the hash remembers what was opened.
  function initStack() {
    const expand = document.querySelector('.expand');
    const wanted = new Set(location.hash.slice(1).split(',').filter(Boolean).map(Number));
    cards.forEach((c, i) => { if (wanted.has(i + 1)) c.open = true; });

    const remember = () => {
      const open = cards.map((c, i) => (c.open ? i + 1 : 0)).filter(Boolean);
      setHash(open.length ? '#' + open.join(',') : '');
      expand.textContent = open.length === cards.length ? 'Close all' : 'Open all';
    };
    cards.forEach(c => c.addEventListener('toggle', remember));
    expand.onclick = () => {
      const shut = cards.some(c => !c.open);
      cards.forEach(c => { c.open = shut; });
    };
    remember();

    const first = cards.find(c => c.open);
    if (first) first.scrollIntoView({ block: 'start' });
  }

  // Stepwise: one card on screen, already open, its detail still closed.
  function initPager() {
    if (cards.length < 2) return;
    document.querySelector('.bar').hidden = true;
    const pager = document.querySelector('.pager');
    const count = pager.querySelector('.count');
    const next = pager.querySelector('.next');
    const prev = pager.querySelector('.prev');
    const at = () => Math.min(cards.length,
                    Math.max(1, parseInt(location.hash.slice(1), 10) || 1));

    function show(n) {
      n = Math.min(cards.length, Math.max(1, n));
      cards.forEach((c, i) => { c.hidden = i !== n - 1; c.open = i === n - 1; });
      count.textContent = n + ' of ' + cards.length;
      prev.hidden = n === 1;
      next.textContent = n === cards.length ? 'Done' : 'Got it →';
      next.disabled = n === cards.length;
      setHash('#' + n);
      scrollTo(0, 0);
    }

    pager.hidden = false;
    show(at());
    next.onclick = () => show(at() + 1);
    prev.onclick = () => show(at() - 1);
    addEventListener('hashchange', () => show(at()));
    addEventListener('keydown', e => {
      if (e.key === 'ArrowRight' || e.key === ' ') show(at() + 1);
      if (e.key === 'ArrowLeft') show(at() - 1);
    });
  }
</script>
</body>
</html>
```

## Cards

```html
<details class="card">
  <summary><h2>{Five words at most}</h2></summary>
  <div class="body">
    <p>{The gist. One or two plain sentences, and nothing more.}</p>
    <details class="more">
      <summary>{What is inside, named}</summary>
      <p>{Where precision lives. Jargon allowed here, defined as it appears.}</p>
    </details>
  </div>
</details>
```

- **The heading is the whole card when closed.** It has to say what the card is
  about on its own, because for most of the page's life it is all the reader sees.
- **The gist is one or two sentences.** If it runs to four, the extra belongs
  behind the inner toggle.
- **Name the inner summary.** "Why not one file" tells the reader what opening it
  buys. "More detail" makes them open it to find out, which is the cost this page
  exists to avoid.
- **A card with nothing more to say drops the inner `<details>`.** An empty
  disclosure trains the reader to stop opening them.

## Diagrams

Mermaid source goes in a `<pre class="mermaid">`, wrapped in a `<figure>` with a
caption saying what to notice:

```html
<figure>
  <pre class="mermaid">
flowchart LR
  A["Request arrives"] --> B["Retry wrapper"]
  B -->|"times out"| C["Wait, then retry"]
  C --> B
  B -->|"succeeds"| D["Response"]
  </pre>
  <figcaption>The loop is the whole idea: a timeout sends it back, not forward.</figcaption>
</figure>
```

Gotchas worth knowing:

- **Measure with everything open.** Mermaid sizes an SVG from its container, and
  a closed `<details>` is zero-wide — a diagram rendered inside one comes out
  collapsed. The script opens every `<details>` on the page, runs Mermaid, then
  restores them in a `finally`. Keep that order, and keep the `finally`: without
  it a CDN failure would leave the whole page hanging open.
- **`toggle` fires asynchronously.** Setting `.open` in code does not update the
  hash on the next line; the event lands a tick later. Anything reading the state
  straight after a programmatic open is reading the state from before it.
- Quote every node label: `A["Retry wrapper"]`. Unquoted labels break on
  brackets, slashes, and punctuation.
- `look: 'handDrawn'` gives the sketched line. Older Mermaid ignores the key and
  renders clean, which is a fine fallback.
- Label the edges with verbs (`-->|"times out"|`). An unlabelled arrow makes the
  reader guess the relationship.

For a picture Mermaid cannot draw — a layout, a shape, a physical arrangement —
write inline `<svg>` by hand. Keep it crude. A rough box-and-arrow sketch that is
right beats a polished one that hedges.
