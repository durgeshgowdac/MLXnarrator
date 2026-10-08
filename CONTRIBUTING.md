# Contributing to MLXnarrator

Thanks for wanting to make MLXnarrator better. Whether you found a typo, a bug, or a smarter way to fit narration to video, you're in the right place.

By taking part you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to help

- **Report a bug.** Open an [issue](../../issues/new/choose) using the bug template.
- **Suggest an idea.** Open an issue using the feature template. A short "here's the problem I'm trying to solve" beats a long design.
- **Improve the docs.** If something confused you, it will confuse the next person too. Fixes to the README are always welcome.
- **Send a pull request.** Small and focused is ideal.

Not sure whether an idea fits? Open an issue first. It's much cheaper than a rejected pull request.

## What the project is (and isn't)

MLXnarrator is a small, offline pipeline for Apple Silicon Macs: text-to-speech, subtitles, and a render. It aims to stay readable and easy to run. Contributions that keep the shell scripts understandable and the setup short are the ones most likely to land.

Out of scope: cloud services, API keys, and anything that makes the project phone home.

## Setting up for development

You need an Apple Silicon Mac. Follow the [Setup section of the README](README.md#setup) end to end, then run:

```bash
python tests/test_voice.py     # you should hear a short sentence
python src/voices.py       # should print the list of voices
```

If both work, you're ready.

## Making a change

1. **Fork** the repository and create a branch from `main`:
   ```bash
   git checkout -b fix/short-description
   ```
   Branch prefixes we like: `feat/`, `fix/`, `docs/`, `chore/`.
2. **Make your change.** Keep it focused: one topic per pull request.
3. **Test it by hand** (see the checklist below).
4. **Commit** with a clear message, in the imperative mood:
   `Add --reencode flag to render-no-subs.sh`, not `added stuff`.
5. **Push** and open a pull request. Fill in the template; it's short.

## Testing checklist

There is no automated test suite yet, so please run what your change touches:

- [ ] `python tests/test_voice.py` plays audio
- [ ] `./bin/generate.sh` completes and writes `audio/narration-fit.wav` and `subtitles/narration.srt`
- [ ] `./bin/render.sh` and/or `./bin/render-no-subs.sh` produce a playable MP4
- [ ] Double-clicking the matching `.command` launcher works, if you touched one
- [ ] Your change doesn't overwrite a user's edited SRT without a backup

Tell us in the pull request what you tested and on which macOS version and chip.

## Style guide

**Shell scripts**
- Start with `#!/bin/bash` and `set -e`.
- Quote your variables: `"$FILE"`, not `$FILE`.
- Keep user-tweakable settings in clearly named variables at the top of the script.
- Prefer clear error messages that tell the user how to fix the problem (see the existing `ERROR:` lines).

**Python**
- Python 3.10 to 3.12 only (this is a `kokoro-mlx` requirement).
- Follow [PEP 8](https://peps.python.org/pep-0008/), and keep scripts small and dependency-light.
- New dependencies need a good reason. If you add one, update `requirements.txt` and explain why in the pull request.

**Docs**
- Plain, friendly, concise. A touch of humour is fine. Jargon without explanation is not.
- Use relative links between files.

## Shell scripts and double-click launchers

The real logic lives in `bin/*.sh`. Each script has a three-line launcher in the project root (`generate.command`, and so on) that simply runs its script, so macOS users can double-click it in Finder. Edit the script; the launcher rarely needs to change.

If you add a new script, add a matching launcher and make both executable before committing:

```bash
chmod +x bin/my-script.sh my-script.command
git add --chmod=+x bin/my-script.sh my-script.command
```

## What never belongs in a commit

- Videos, audio, or models (`*.mp4`, `*.wav`, `*.bin`, and friends). `.gitignore` already blocks these; please don't use `git add -f` around it.
- `scripts/narration.txt`, which is your personal script.
- Tokens or secrets of any kind, including Hugging Face tokens. If you accidentally commit one, revoke it immediately.

## Reporting security issues

Please don't open a public issue for a vulnerability. See [SECURITY.md](SECURITY.md).

## Licensing

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE), the same as the rest of the project.

Thank you for helping. Truly. The robots in this repository are very polite, but they can't write documentation.
