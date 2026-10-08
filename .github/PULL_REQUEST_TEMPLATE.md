## What does this change?

<!-- A sentence or two. Link the issue if there is one: "Fixes #123" -->

## Why?

<!-- The problem this solves, or the idea behind it. -->

## How I tested it

<!-- Tick what applies, and mention your macOS version and chip (e.g. macOS 15, M2). -->

- [ ] `python tests/test_voice.py`
- [ ] `./bin/generate.sh`
- [ ] `./bin/render.sh` / `./bin/render-no-subs.sh`
- [ ] Double-clicked the matching `.command` launcher
- [ ] Docs only, nothing to run

## Checklist

- [ ] New scripts in `bin/` have a matching `.command` launcher, if they're meant for double-clicking
- [ ] New scripts are executable (`git add --chmod=+x`)
- [ ] No videos, audio, models, tokens or personal narration included
- [ ] README or docs updated if behaviour changed
