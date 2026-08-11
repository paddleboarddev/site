---
title: "The worst bugs in a fork don't break the build"
description: "What I've learned maintaining a 271-crate Rust fork: the failures that matter merge cleanly, compile, pass CI, and ship."
date: 2026-08-11
---

I maintain PaddleBoard, a fork of [Zed](https://zed.dev). Zed is a genuinely
excellent editor — fast, native, and unusually well engineered — and everything below
is downstream of that work. None of what follows is a criticism of it. It's what I've
learned about the failure modes that show up when you take a 271-crate Rust codebase
and merge from it every week while diverging from it deliberately.

The short version: **the bugs that cost me the most never broke the build.** Every one
of them merged cleanly, compiled, passed CI, and shipped. A fork's dangerous failures
aren't red — they're green.

Here's the taxonomy I've accumulated, and what I built to catch each class.

### 1. Files that vanish, with no diff to review

PaddleBoard renamed four upstream crate directories — `crates/zed` became
`crates/paddleboard`, and similarly for `zed_actions`, `zed_credentials_provider`,
and `zed_env_vars`.

Now upstream adds a new file inside `crates/zed/`. Git looks for something on my side
to conflict against. There isn't one — I renamed the directory. So the merge completes
cleanly and the file is simply **not there**. Nothing fails to compile, because my
renamed crate never referenced a file it never had.

There is no diff to review. The failure is an *absence*, and code review is very bad
at absences.

On 2026-07-20, four `reliability/hang_detection` files disappeared exactly this way.
No conflict, no error, no red.

### 2. Files that come back from the dead

The same git behavior, running the other direction.

PaddleBoard deleted five upstream directories outright — `call`, `collab`,
`collab_ui`, `livekit_api`, `livekit_client` — because the fork has no collaboration
features.

When upstream *modifies* a file I deleted, git raises a modify/delete conflict and a
human sees it. Good. But when upstream *adds a new file* in one of those directories,
nothing opposes the add. It merges cleanly and **resurrects** in a directory I killed.
It never compiles, because the crate isn't a workspace member — so nothing ever goes
red. By July 2026 I had accumulated **30** of these.

### The part I find genuinely interesting

These two failure modes are mirror images, and together they **partition the space**.

For any upstream directory the fork doesn't have, there are exactly two reasons: I
renamed it, or I deleted it. Renamed directories leak files *out* (dropped). Deleted
directories leak files *in* (zombies). So two guards, one per case, cover every
upstream directory I lack:

- `check-dropped-upstream-files` compares the **merge base** — the newest upstream
  commit actually merged — against `HEAD`, so files upstream added but I haven't
  merged yet are correctly ignored.
- `check-zombie-upstream-files` is just `git ls-files` over the deleted directories.
  No upstream fetch, so it's cheap enough to run on **every** PR.

The maintenance rule falls out of the partition: rename another directory, add it to
`RENAME_MAP`; delete one, add it to `DELETED_DIRS`. **A directory on neither list is
unwatched** — which is precisely the blind spot the guards exist to close, so the
lists are load-bearing and the scripts say so.

I only understood the second guard was necessary *because* I'd built the first one and
noticed it couldn't see in that direction.

### 3. Renames that turn code into prose

The fork renamed task variables from `ZED_*` to `PADDLEBOARD_*`.

Two `git_graph` tests then started failing with an assertion that made no sense —
expected `"Git Show abcdef1"`, got `"Print File $ZED_FILE"`. The wrong task had run.

The cause: `$ZED_GIT_SHA_SHORT` in a test fixture was **not an unresolved variable**.
After the rename, the parser only recognises names behind the `PADDLEBOARD_` prefix —
so `$ZED_*` wasn't a variable at all. It was **plain text**. A string that happens to
start with a dollar sign.

That's much quieter than a missing variable, and it broke the tests twice over. The
label never got substituted; *and* a fixture that existed specifically to prove
unresolvable tasks get filtered out of a menu stopped being filtered, because nothing
about it was unresolvable any more. It stayed in the menu and got picked.

**Lesson: when you rename a namespace, values in the old namespace don't error. They
demote to data.**

### 4. Two safe changes that combine into a broken one

My main window couldn't be dragged by its title area. Not "regressed" — it had
*never* worked.

Two changes did it, neither wrong alone:

- Upstream added `app_owns_titlebar_drag: true`, telling AppKit not to handle window
  dragging because the app draws its own title bar and moves the window itself.
  Correct — for upstream.
- Months earlier, a UI pass in my fork **removed the per-workspace title bar entirely.**

So the flag switched off AppKit's dragging on the promise that something else would
handle it, and in my fork nothing did. The only `start_window_move` call lives inside
the title bar that never renders.

Each change is defensible in isolation and reviewable in isolation. The bug lives in
the *interaction*, which no diff shows and no test covered. This is the failure mode I
have the least good answer for — my current one is a `// PaddleBoard:` comment at every
intentional divergence (**493** of them across 188 files) so the next merge conflict
has the reasoning attached.

### 5. No gate at all

The most embarrassing category, and probably the most common in small projects.

For a long stretch, **no workflow in the repo built Rust.** The checks covered
embedded-asset paths, upstream drift, and a few project-specific invariants — none of
which invoke the compiler. A dependency bump that broke the build would have passed CI
green. The real gate was me remembering to run `cargo check` locally.

Then a second one: nothing *ran the tests* either. Twenty broken tests sat on `main`
until an unrelated session tripped over them.

And a third, which I like best as an illustration: a status-bar button crashed the app
on every click, and had since the day it shipped. Not a regression — **broken from day
one**, which means nobody had ever clicked it. The fix was easy; the interesting part
is that a unit test now clicks every status-bar button, because the actual gap wasn't
in the code, it was that nothing exercised it.

The gates I ended up with are deliberately narrower than the obvious version:

- **The compile gate runs `cargo check`, not the full lint suite.** Clippy across 271
  crates with `--all-targets --all-features` is a release build's worth of work, and
  the failure actually escaping was "does it compile."
- **The test gate covers only the fork's own crates**, selected by a `paddleboard`
  name prefix derived from `cargo metadata` rather than a hand-maintained list.
  Upstream's ~240 crates churn every week; a red gate caused by upstream test drift is
  one I can't fix, and a permanently red gate is worth less than no gate.

That second decision has a cost I walked into: a fork-authored crate that *didn't*
carry the prefix sat outside the gate, and its broken tests survived. The naming
convention was quietly doing double duty as the test boundary. I renamed the crate
rather than add an exception list, because exception lists rot.

### 6. Release plumbing that lies

`gh release edit --prerelease=false` does **not** move GitHub's "Latest" badge.
`make_latest` is a separate field that GitHub computes only when a non-prerelease
release is *created* — and mine are all created as prereleases and promoted after.

The badge sat on an old version across **three** releases before anyone noticed. Every
release "succeeded."

Worse, in the same area: my updater parses release tags with a semver parser and
`filter_map`s away anything that doesn't parse. A four-component tag like `v0.2.4.1`
would publish successfully, look completely correct on the releases page, and be
**silently skipped by every installed copy**. A release that reaches nobody.

### The meta-lesson: measure before you optimise

I'll close with a fresh one, because it's the same disease in a different organ.

CI got expensive. I "knew" why: macOS runners bill at a 10× multiplier, and everyone
knows macOS is what costs money in GitHub Actions.

I measured. Over four days: **2,220 billed minutes**. macOS was **1.4%** of it. Two
Linux jobs were ~88% — not because they were slow, but because they ran on *both*
`pull_request` and `push: main`, and on docs-only branches. **Where spend lands is a
question of frequency, not per-minute rate.** The fix was trigger scope and
cancel-in-progress, not runner choice.

Two traps in getting that number, both of which produced confident wrong answers first:

- GitHub's `/actions/runs/{id}/timing` endpoint returns `total_ms: 0` on this repo.
  It's not an error — it's a zero. You have to compute from each job's
  `started_at`/`completed_at` and apply the multiplier by hand.
- `gh run list` silently returns exactly `--limit` rows. My first pass capped at 80,
  got back 80, and undercounted the bill by **3×**. If the row count equals your
  limit, it's a lower bound, not a total.

Both are the same shape as everything above: **the tool returned a plausible answer
instead of an error.**

### What I'd tell someone starting a long-lived fork

1. **Enumerate how upstream can change in ways your fork can't see.** Renamed
   directories and deleted directories were my two; yours will differ. Try to
   partition the space rather than collect anecdotes — a partition tells you when
   you're done.
2. **Tag every intentional divergence in-line**, with the reason. Merge conflicts are
   where you pay for undocumented decisions, and they arrive months later.
3. **Prefer new files to edited ones.** Upstream can't conflict on a file it doesn't
   have. Most of my fork's features live in crates upstream has never heard of.
4. **Scope gates to what you can actually fix.** A red check nobody can act on gets
   ignored, and then so does every other red check.
5. **Assume your tools will hand you a plausible wrong number.** Cross-check anything
   you're about to make a decision on.

---

PaddleBoard goes into public beta on **26 August**. It's a fork of Zed with the AI
infrastructure built in — local models, a semantic index, a sandbox — and telemetry
hard-disabled. If you want to watch the guards above do their job, they're all in
`script/` in the repo.
