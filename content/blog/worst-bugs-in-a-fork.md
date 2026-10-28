---
title: "The Worst Bugs in a Fork Don't Break the Build"
description: "The failures that hurt a fork most merge cleanly, compile, pass CI and ship. Six of them from maintaining PaddleBoard, a fork of Zed, and what I built to catch each one."
date: 2026-10-28
image: "img/blog/worst-bugs-in-a-fork.png"
imageAlt: "Two branching git-style trees in orange, green, blue and violet on a dark background, with a single loose file falling into the gap between them."
---

So here's a fun one. For months, PaddleBoard's main window couldn't be dragged by
its title bar. Not "it broke last week". It had never worked. No error, no failing
test, nothing red anywhere in CI. You'd grab the top of the window, pull, and
nothing would happen.

If you haven't met PaddleBoard yet, it's an open-source AI IDE, and it's a fork of
[Zed](https://zed.dev). My name is [Jason](https://jasonsmith.io), but you can call
me Jay, and I maintain it. That window bug turned out to be the perfect example of
what I want to talk about: the bugs that hurt a fork the most don't break the build.
They merge cleanly, they compile, they pass CI, and they ship. Red is easy. Green is
the problem.

### Why Build PaddleBoard at All?

I wanted an agentic AI IDE that checked two boxes. One, it had to be open source.
Two, it had to be something I actually wanted to use. The ones out there have their
use cases, but none of them felt right to me. They were either an extension bolted
onto VS Code, VS Code with a new skin, or a canvas that didn't really let you write
code.

You may be curious as to why I chose the name "PaddleBoard". This was hands down one
of my favorite activities when I lived in Austin. Almost every weekend I would go to
Town Lake and hit up one of the boat launches. When I sat and tried to come up with a
name, it just popped into my head and felt right.

So why fork Zed instead of starting from scratch? Zed is lightweight (at least
compared to VS Code), it's built in Rust, and it's a great editor (seriously, go try
it). That made it an excellent starting point, way better than me building an IDE
from the ground up. I mean, in the world of open source, most projects are built on
the shoulders of giants, and everything in this post is downstream of the Zed team's
work. What I add on top are my own opinions: no telemetry, code the agent runs going
into a microVM by default, and a bundled llama.cpp so you can run a model without an
API key. It wouldn't be fair to ask Zed's maintainers to carry those, so they live in
a fork.

So why keep merging every week? Because Zed keeps getting better, and I want that.
Between v0.2.8 and v0.3.0, that's roughly 360 upstream commits I didn't have to
write. But it's not only about new features. I want PaddleBoard to stay lined up with
Zed's foundation, especially the unglamorous stuff like security. When Zed added
project trust, which keeps a folder you haven't marked as trusted in a restricted
mode, I got it in a weekly merge instead of building my own. Could PaddleBoard branch
off completely someday? Maybe. For now, there's no reason to. A fork that stops
merging is just a snapshot getting older, and the longer you wait, the more catching
up costs.

Here's the catch, though. I'm one person. When a merge goes in, green CI is the only
reviewer I have for the stuff a diff can't show you. So the failures that worry me
are the ones that stay green. Here are six of them, and what I built so they can't
happen the same way twice.

### 1. Files That Vanish

PaddleBoard renamed four of Zed's crate directories. `crates/zed` became
`crates/paddleboard`, and the same went for `zed_actions`, `zed_credentials_provider`
and `zed_env_vars`.

Now imagine upstream adds a new file inside `crates/zed/`. Git goes looking for
something on my side to conflict with, and there's nothing there, because I renamed
the directory. So the merge completes cleanly and the file just... isn't there.
Nothing fails to compile, because my crate never referenced a file it never had.

There's no diff to review, either. The bug is an absence, and code review is really
bad at absences. On 20 July, four hang-detection files disappeared exactly like this.
No conflict, no error, no red.

### 2. Files That Come Back From the Dead

Same git behaviour, other direction. PaddleBoard deleted five upstream directories
outright (`call`, `collab`, `collab_ui`, `livekit_api` and `livekit_client`) because
the fork doesn't do collaboration.

If upstream changes a file I deleted, git raises a conflict and I see it. Good. But if
upstream adds a brand new file in one of those directories, nothing stops it. It
merges cleanly and comes back to life in a directory I killed. It never compiles,
because that crate isn't part of the workspace anymore, so nothing ever goes red. By
July I had 30 of these zombies.

### The Part I Actually Find Interesting

Here's what I didn't expect: those two bugs are mirror images, and together they
cover every case.

Think about it. For any upstream directory my fork doesn't have, there are only two
possible reasons. I renamed it, or I deleted it. Renamed directories leak files out,
and deleted ones leak files in. So two checks, one for each, cover every upstream
directory I'm missing:

- `check-dropped-upstream-files` compares the newest upstream commit I've actually
  merged against my tree, so files upstream added after that are correctly ignored.
- `check-zombie-upstream-files` just lists what's tracked inside the deleted
  directories. It doesn't even need to fetch upstream, so it's cheap enough to run on
  every PR.

The whole configuration is two short lists:

```bash
# script/check-dropped-upstream-files: directories I renamed.
RENAME_MAP=(
    "crates/zed:crates/paddleboard"
    "crates/zed_actions:crates/paddleboard_actions"
    "crates/zed_credentials_provider:crates/paddleboard_credentials_provider"
    "crates/zed_env_vars:crates/paddleboard_env_vars"
)

# script/check-zombie-upstream-files: directories I deleted.
DELETED_DIRS=(
    "crates/call"
    "crates/collab"
    "crates/collab_ui"
    "crates/livekit_api"
    "crates/livekit_client"
)
```

Nine entries. That's it. The rest of each script is diffing and reporting. The clever
bit isn't the code, it's the claim that those two lists together account for every
upstream directory the fork doesn't have. Rename another directory and it goes on the
first list; delete one and it goes on the second. A directory on neither list isn't
being watched, and that's exactly the blind spot these checks exist to close.

(Full disclosure: I only realised I needed the second check because I'd built the
first one and noticed it couldn't see in that direction.)

### 3. Renames That Turn Code Into Plain Text

PaddleBoard renamed its task variables from `ZED_*` to `PADDLEBOARD_*`. Simple, right?

Then two `git_graph` tests started failing with an assertion that made no sense. They
expected `"Git Show abcdef1"` and got `"Print File $ZED_FILE"`. The wrong task had run.

Turns out `$ZED_GIT_SHA_SHORT` in a test fixture wasn't an unresolved variable
anymore. After the rename, the parser only recognises names that start with
`PADDLEBOARD_`, so `$ZED_` wasn't a variable at all. It was just text that happened to
start with a dollar sign.

That's way quieter than a missing variable, and it broke the tests twice over. The
label never got filled in, and a fixture that existed to prove unresolvable tasks get
filtered out of a menu stopped being filtered, because nothing about it was
unresolvable anymore. So it stayed in the menu and got picked.

So when you rename a namespace, the old names don't throw errors. They just quietly
become data.

### 4. Two Safe Changes, One Broken Window

Back to that window. Two changes caused it, and neither was wrong on its own:

- Upstream added `app_owns_titlebar_drag: true`, which tells macOS not to handle
  window dragging because the app draws its own title bar and moves the window itself.
  Totally correct for Zed.
- Months earlier, a UI cleanup in my fork removed the per-workspace title bar
  entirely.

So the flag turned off macOS's own dragging, on the promise that the app would handle
it. In my fork, nothing did. The only code that starts a window move lives inside a
title bar that never renders.

Each change makes sense by itself and passes review by itself. The bug only exists in
the combination, which no diff shows and no test covered. Honestly, this is the one I
have the weakest answer for. What I do now is leave a `// PaddleBoard:` comment
everywhere the fork deliberately diverges, so the next merge conflict comes with the
reasoning attached. As for the window itself, the fix was one line: PaddleBoard now
sets that flag back to false, so macOS handles the dragging again. (That's macOS.
Windows has its own drag bug,
[#87](https://github.com/paddleboarddev/paddleboard/issues/87), and that one is still
open.)

### 5. No Gate at All

This one's the most embarrassing, and I'd bet it's the most common in small projects.

For a while, nothing in CI actually built Rust. The checks covered embedded asset
paths, upstream drift and a few project rules, and none of them ran the compiler. A
dependency bump that broke the build would have passed green. The real gate was me
remembering to run `cargo check`. (Ya.)

Then I found out nothing ran the tests either. Twenty broken tests sat on `main` until
an unrelated piece of work tripped over them.

And my favourite: a status-bar button crashed the app every single time you clicked
it, and had since the day it shipped. Not a regression. Broken from day one, which
means nobody had ever clicked it. The fix was easy. The real gap was that nothing
exercised it, so now a test clicks every status-bar button.

Here's where the gates ended up:

- The compile gate lints the whole workspace on Linux. It started as plain
  `cargo check`, because running clippy over about 280 crates sounded like a release
  build's worth of work. Since mid-August it runs clippy with warnings denied, and
  because clippy does the same compile and adds the lints, it cost nothing extra. The
  macOS job still runs `cargo check` over a hand-picked list of crates.
- The test gate only covers the fork's own crates, picked out by their `paddleboard`
  name prefix. Upstream's roughly 250 crates change every week, and a gate that goes
  red over upstream test drift is one I can't fix. A permanently red gate is worse
  than no gate.

That second choice bit me, too. A crate I wrote didn't have the prefix, so it sat
outside the gate and its broken tests survived. I renamed the crate instead of adding
an exception list, because exception lists rot. And since 13 October a weekly run also
tests the upstream crates the fork has touched, after eleven upstream tests turned out
to have been failing unseen for exactly this reason.

### 6. Releases That Lie

`gh release edit --prerelease=false` doesn't move GitHub's Latest badge. That's a
separate setting, and GitHub only works it out when a release is created as a normal
release. Mine are all created as prereleases and promoted afterwards.

So the badge sat on an old version for three releases before anyone noticed. Every
one of those releases "succeeded".

It gets worse. My updater reads release tags with a semver parser and quietly drops
anything that doesn't parse. A four-part tag like `v0.2.4.1` would publish fine, look
perfect on the releases page, and be skipped by every installed copy. A release that
reaches nobody.

### Bonus Round: Measure Before You Optimise

One more, because it's the same disease in a different spot.

CI got expensive, and I knew exactly why. macOS runners bill at ten times the Linux
rate, and everyone knows macOS is what costs money on GitHub Actions. Right?

Well, I measured. Over four days there were 2,220 billed minutes, and macOS was 1.4%
of them. Two Linux jobs were about 88%, not because they were slow, but because they
ran on both pull requests and pushes to `main`, and on branches that only touched
docs. Where the money goes is about how often things run, not the per-minute rate.
The fix was running less often, not switching runners.

Getting that number had two traps of its own, and both gave me a confident wrong
answer first:

- GitHub's run timing endpoint returns `total_ms: 0` for this repo. Not an error, a
  zero. You have to work it out from each job's start and finish times and apply the
  multiplier yourself.
- `gh run list` quietly returns exactly as many rows as its `--limit`. My first pass
  capped at 80, got back 80, and undercounted the bill by three times. If the row count
  equals your limit, it's a lower bound, not a total.

Same shape as everything above: the tool handed me a plausible answer instead of an
error.

### If You're Starting a Fork

If you're about to maintain a long-lived fork, here's what I'd tell you. Work out the
ways upstream can change that your fork can't see, and try to cover the whole space
instead of collecting horror stories, because a complete list tells you when you're
done. Tag every deliberate divergence right in the code, with the reason, because you
pay for undocumented decisions at merge time, months later. Put your features in new
files and crates where you can, since upstream can't conflict with a file it doesn't
have (most of PaddleBoard's features live in crates Zed has never heard of). Only gate
on things you can actually fix. And assume your tools will sometimes hand you a
plausible wrong number, so double-check anything you're about to make a decision on.

### So, What's Next?

PaddleBoard's public beta, v0.3.0, is out. It's Zed with the AI infrastructure built
in: local models, a semantic index, a sandbox for anything the agent runs, and no
telemetry at all. If you want to watch the guards above do their thing, they all live
in `script/` in [the repo](https://github.com/paddleboarddev/paddleboard).

Grab the [beta](https://paddleboard.dev/beta), break it, and tell me what broke. Since
there's no telemetry, you telling me is honestly the only way I'll find out. And if
you maintain a fork of your own, I'd love to hear what's bitten you.

Jason "Jay" Smith - The Cloud Alchemist
