<p align="center">
  <img src="assets/logo.svg" alt="MLXnarrator" width="520">
</p>

<p align="center">
  <b>Give your silent screen recording a voice. Offline, on your Mac, for free.</b>
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-orange"></a>
  <a href="https://github.com/durgeshgowdac/MLXnarrator/releases"><img alt="Latest release" src="https://img.shields.io/github/v/release/durgeshgowdac/MLXnarrator?include_prereleases&color=blue"></a>
  <a href="https://github.com/durgeshgowdac/MLXnarrator/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/durgeshgowdac/MLXnarrator?style=flat&color=yellow"></a>
  <a href="https://github.com/durgeshgowdac/MLXnarrator/issues"><img alt="Open issues" src="https://img.shields.io/github/issues/durgeshgowdac/MLXnarrator"></a>
  <a href="https://github.com/durgeshgowdac/MLXnarrator/commits/main"><img alt="Last commit" src="https://img.shields.io/github/last-commit/durgeshgowdac/MLXnarrator"></a>
  <a href="CONTRIBUTING.md"><img alt="PRs welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen"></a>
</p>

<p align="center">
  <img alt="Platform: Apple Silicon" src="https://img.shields.io/badge/platform-Apple%20Silicon-black?logo=apple">
  <img alt="Python 3.10 to 3.12" src="https://img.shields.io/badge/python-3.10%20%E2%80%93%203.12-blue?logo=python&logoColor=white">
  <img alt="Runs 100% offline" src="https://img.shields.io/badge/runs-100%25%20offline-success">
  <a href="https://github.com/ml-explore/mlx"><img alt="Built with MLX" src="https://img.shields.io/badge/built%20with-MLX-lightgrey?logo=apple"></a>
  <a href="https://huggingface.co/hexgrad/Kokoro-82M"><img alt="Voice: Kokoro-82M" src="https://img.shields.io/badge/voice-Kokoro--82M-ff69b4"></a>
  <a href="https://github.com/ggml-org/whisper.cpp"><img alt="Subtitles: whisper.cpp" src="https://img.shields.io/badge/subtitles-whisper.cpp-informational"></a>
  <a href="https://ffmpeg.org"><img alt="Render: FFmpeg" src="https://img.shields.io/badge/render-FFmpeg-007808?logo=ffmpeg&logoColor=white"></a>
</p>

---

Every demo video has the same problem: it's twelve seconds of you clicking things and eleven seconds of you wishing you had said something clever.

**MLXnarrator** fixes that. Write what you want to say in a plain text file. It speaks the script with a local text-to-speech model, fits the narration to your video, listens to itself with Whisper to produce subtitles, and renders a finished MP4 with ffmpeg.

No cloud. No API keys. No per-minute fees. No "your free trial has ended" email.

```
 scripts/narration.txt        input/demo.mp4
         │                         │
         ▼                         │
  Kokoro TTS (MLX)                 │
  src/narrate.py                     │
         │                         │
         ▼                         │
  atempo fit to video length       │
  (warns above 1.30x)              │
         │                         │
         ├──────────┐              │
         ▼          ▼              │
  whisper.cpp    audio/            │
  → narration.srt  narration-fit.wav
         │          │              │
         ▼          ▼              ▼
   proofread    ffmpeg render ──► output/demo-final.mp4
```

## Why you might like it

- **Local text-to-speech.** [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) runs on Apple Silicon through MLX. Small model, surprisingly human voice.
- **Narration that fits.** The voice speeds up (never slows down) to match your video, and tells you politely if it starts sounding like an auctioneer.
- **Subtitles that match what you hear.** [whisper.cpp](https://github.com/ggml-org/whisper.cpp) transcribes the *final* audio, so timing is never a guess.
- **You stay in control.** Subtitles are a plain `.srt` you can proofread. Re-rendering never overwrites your edits, and any existing SRT is backed up before it can be regenerated.
- **Two render modes.** Burned-in subtitles, or none at all (fast, with no re-encode).
- **Pick your voice.** A whole cast to choose from, plus a helper script that lists every one. See [Choosing a voice](#choosing-a-voice).

## Requirements

| Requirement | Why |
|---|---|
| Apple Silicon Mac (M1 or later) | Kokoro runs through MLX, which needs Apple Silicon |
| [Homebrew](https://brew.sh) | Installs ffmpeg and whisper.cpp |
| Python **3.10 to 3.12** | Required by `kokoro-mlx` (3.13+ is not supported) |
| About 2 GB of free disk | Whisper model (~150 MB), Kokoro weights, Python packages |
| Internet, **once** | Downloads the Kokoro weights and the Whisper model on first setup |

## Setup

Five steps, one time only. Pour a coffee first; there are a few downloads along the way.

### 1. Install the system tools

```bash
brew install ffmpeg ffmpeg-full whisper.cpp python@3.12
```

| Formula | Used for |
|---|---|
| `whisper.cpp` | Provides the `whisper-cli` command that generates subtitles (previously named `whisper-cpp`). |
| `ffmpeg-full` | An ffmpeg build **with libass**, required to burn subtitles into video. It is *keg-only*, so it won't replace your normal ffmpeg. The scripts find it at `/opt/homebrew/opt/ffmpeg-full`. |
| `ffmpeg` | Regular ffmpeg on your `PATH`. Enough for `render-no-subs.sh`. |
| `python@3.12` | A Python version supported by `kokoro-mlx`. Skip it if you already have 3.10, 3.11 or 3.12. |

> Homebrew's plain `ffmpeg` has no libass, so it cannot burn subtitles. That is the whole reason `ffmpeg-full` is on the list.

Check that everything is in place:

```bash
whisper-cli --help | head -n 3
/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg -hide_banner -filters | grep subtitles
python3.12 --version
```

The second command should print a line containing `subtitles`.

### 2. Get the project

```bash
git clone https://github.com/durgeshgowdac/MLXnarrator.git
cd MLXnarrator
```

Create the working folders and your narration file, starting from the bundled example. They hold your own videos, audio and models, so they are **not** stored in git:

```bash
mkdir -p input audio subtitles output models scripts
cp scripts/narration.example.txt scripts/narration.txt
```

| Folder / file | Purpose |
|---|---|
| `input/` | Your screen recording, named `demo.mp4` |
| `audio/` | Generated narration (`narration.wav`, `narration-fit.wav`) |
| `subtitles/` | Generated and edited `narration.srt` |
| `output/` | Final rendered videos |
| `models/` | Whisper model file (step 4) |
| `scripts/narration.txt` | The text that gets spoken. It starts as a copy of the example; replace it with your own (see [Writing the narration script](#writing-the-narration-script)) |

Running `mkdir` again is harmless. It never touches existing files.

### 3. Make the scripts runnable (macOS)

Every step in this project can be run two ways: from the **terminal** (the `.sh` scripts in `bin/`) or from **Finder** by double-clicking the matching `.command` launcher. Both need the files to be executable. Git remembers executable permissions, so a `git clone` usually gives you runnable scripts. If you downloaded the project as a **ZIP** instead, the permissions may be lost, and macOS also quarantines the launchers. Fix both in one go:

```bash
chmod +x bin/*.sh *.command
xattr -d com.apple.quarantine generate.command render.command render-no-subs.command run-all.command
```

- `chmod +x` makes the scripts and launchers executable. Needed for both ways of running.
- `xattr -d com.apple.quarantine` removes the "downloaded from the internet" flag, which is what makes Finder refuse to open a `.command` file. Only the Finder route needs it. If it replies `No such xattr`, the file was never quarantined and you're already fine.

### 4. Create the Python environment

The scripts expect the virtual environment at `.venv/` inside the project.

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

`requirements.txt` pins [`kokoro-mlx`](https://pypi.org/project/kokoro-mlx/), `sounddevice` (for playback) and the spaCy English model used for text processing.

### 5. Download the Whisper model

`brew install whisper.cpp` installs the program but **not** the model files. Fetch the English base model (about 148 MB) into `models/`:

```bash
curl -L -o models/ggml-base.en.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin
```

Want better accuracy, or another language? Pick a model from the [whisper.cpp model list](https://huggingface.co/ggerganov/whisper.cpp/tree/main) and point the scripts at it:

```bash
WHISPER_MODEL=models/ggml-small.en.bin ./bin/generate.sh
```

That environment variable is a terminal feature. If you prefer double-clicking, change the default `MODEL=` line near the top of `bin/generate.sh` (and `bin/run-all.sh`) instead.

### Sound check

```bash
python tests/test_voice.py
```

You should hear a short sentence. The first run downloads the Kokoro weights from Hugging Face, so give it a moment. If Hugging Face rate-limits you, uncomment the `HF_TOKEN` lines at the top of `tests/test_voice.py` and add your own token (never commit it).

If you heard a voice, you're done with setup. If you heard silence, see [Troubleshooting](#troubleshooting).

## Usage

### 1. Add your video and your script

```bash
cp /path/to/your-recording.mp4 input/demo.mp4
open scripts/narration.txt      # replace the example with your own narration
```

Not sure what to write? Use the [LLM prompts](docs/NARRATION-PROMPTS.md), or start from [`scripts/narration.example.txt`](scripts/narration.example.txt).

The input video **must be named `input/demo.mp4`**. An audio track is optional; if there is one, it is kept quietly (15% volume) underneath the narration.

### 2. Generate narration and subtitles

| Finder | Terminal |
|---|---|
| Double-click `generate.command` | `./bin/generate.sh` |

Both run the same script. Pick whichever you prefer; the rest of this guide shows both.

This creates `audio/narration.wav`, a version fitted to your video length (`audio/narration-fit.wav`), and `subtitles/narration.srt`. It does **not** render the video yet.

Now open `subtitles/narration.srt` and fix any words Whisper misheard. (Whisper is good, not psychic. Expect the occasional "cube cuddle" where you said "kubectl".) If a previous SRT exists, it is copied to `subtitles/narration.<timestamp>.srt.bak` first.

### 3. Render

**With burned-in subtitles**, using your edited SRT, writing `output/demo-final.mp4`:

| Finder | Terminal |
|---|---|
| Double-click `render.command` | `./bin/render.sh` |

**Without subtitles**, writing `output/demo-final-nosubs.mp4`:

| | Finder | Terminal |
|---|---|---|
| Fast (copies the video stream, no re-encode) | Double-click `render-no-subs.command` | `./bin/render-no-subs.sh` |
| Re-encode (H.264) | Not available from the launcher | `./bin/render-no-subs.sh --reencode` |

The fast mode finishes in seconds with zero quality loss. Use the re-encode if, for example, your source isn't in a QuickTime-friendly format. Launchers can't take flags, so that option is terminal-only.

Both render scripts reuse `audio/narration-fit.wav`, so you can run them as often as you like, in any order, without re-running the voice or Whisper.

### Shortcut: everything, no proofreading

| Finder | Terminal |
|---|---|
| Double-click `run-all.command` | `./bin/run-all.sh` |

Runs the whole pipeline (voice, fit, subtitles, render) in one go with a default subtitle style. It **overwrites** `subtitles/narration.srt`, so once you start editing subtitles, switch to the generate and render steps above.

## Choosing a voice

The default voice is **`am_michael`**. To change it, open [`src/narrate.py`](src/narrate.py) and edit this line near the top:

```python
VOICE = "am_michael"   # ← swap in any voice ID
SPEED = 1.0            # 1.0 is natural; try 0.9 for a calmer read
```

Not sure which voices exist? Ask the repository. [`src/voices.py`](src/voices.py) lists every voice available for the model:

```bash
source .venv/bin/activate
python src/voices.py
```

```
Fetching available voices from the repository...

Total available voices found: <N>

- af_heart
- am_michael
- ...
```

The list is whatever the repository offers at that moment, so it may grow over time.

Copy any ID from the list into `VOICE`, and every script picks it up on the next run. No other changes needed.

**Reading the IDs.** Voice names follow a pattern: the first letter is the accent (`a` American, `b` British), the second is the voice (`f` female, `m` male), and the rest is the name. So `bm_george` is a British male voice called George. Voices for other languages may appear in the list too; this setup is English-first, so stick to `a` and `b` unless you've installed the multilingual extras of `kokoro-mlx`.

**Audition before you commit.** Hear a voice without touching any file:

```bash
python -c "from kokoro_mlx import KokoroTTS; KokoroTTS.from_pretrained().speak('Testing, one, two, three.', voice='bm_george')"
```

> `voices.py` needs internet, since it reads the model repository on Hugging Face. Once the weights are downloaded you can also list voices offline with `KokoroTTS.from_pretrained().list_voices()`.

## Writing the narration script

`scripts/narration.txt` is plain text. Anything that shouldn't be spoken is stripped automatically, so you can keep it tidy:

- Markdown headings (`# Title`) and rules (`---`)
- Timestamp section markers such as `**[00:00 - 00:25] - Introduction**`
- Bold and italic markers, backticks, and link URLs (link text is kept)

See [`scripts/narration.example.txt`](scripts/narration.example.txt) for a working template. It's the narration for MLXnarrator's own demo, written for a video of about **90 seconds** (roughly 200 words). Use it as a pattern:

- **Marker lines** (`**[00:12 - 00:32] - Write it down**`) split the script into sections that follow your screen, and keep your pacing honest.
- **Spoken text** goes underneath: short sentences, contractions, first person.
- **Names the voice might trip over** are better spelled out. The example writes "M L X narrator" instead of "MLXnarrator".

If you run the example against a much shorter video, you'll see the speed-up warning below. That's expected: 200 words need about 90 seconds to breathe.

**Tip:** if the narration is longer than the video, it gets sped up. If you see `WARNING: needs 1.4x`, shorten the script. Anything above 1.30x tends to sound rushed.

## Generate your narration with an LLM

Let an LLM draft the script. Two copy-and-paste prompts (a skeleton first, then the final narration) live in **[docs/NARRATION-PROMPTS.md](docs/NARRATION-PROMPTS.md)**. Paste the result into `scripts/narration.txt`, run the generate step (double-click `generate.command` or run `./bin/generate.sh`), and listen to `audio/narration-fit.wav`.

## Scripts at a glance

The real scripts live in `bin/`. Each has a double-click launcher in the project root with the same name and a `.command` extension. The launcher is a short wrapper that runs its script and then waits for Enter, so the window doesn't vanish before you can read the result.

| Script | What it does | Writes |
|---|---|---|
| `bin/generate.sh` (`generate.command`) | Voice, fit to video, subtitles. No render. | `audio/narration*.wav`, `subtitles/narration.srt` |
| `bin/render.sh` (`render.command`) | Final video **with** burned-in subtitles from your edited SRT. | `output/demo-final.mp4` |
| `bin/render-no-subs.sh` (`render-no-subs.command`) | Final video **without** subtitles. Add `--reencode` to re-encode. | `output/demo-final-nosubs.mp4` |
| `bin/run-all.sh` (`run-all.command`) | Everything in one shot (overwrites the SRT). | all of the above |
| `src/narrate.py` | Script to speech (called by the scripts above). | `audio/narration.wav` |
| `src/voices.py` | Lists every available voice. | nothing |
| `tests/test_voice.py` | Quick sound check. | nothing |

> `--reencode` is a terminal flag. Double-clicking `render-no-subs.command` always uses the fast copy mode.

## Configuration

| What | Where | Default |
|---|---|---|
| Voice | `VOICE` in `src/narrate.py` (browse with `src/voices.py`) | `am_michael` |
| Speaking speed | `SPEED` in `src/narrate.py` | `1.0` |
| Maximum speed-up before warning | `MAX_SPEEDUP` in `bin/generate.sh` / `bin/run-all.sh` | `1.30` |
| Silence left at the end of the video | `TAIL_PAD` in `bin/generate.sh` / `bin/run-all.sh` | `0.5` seconds |
| Subtitle font, size, colours, box, margin | variables at the top of `bin/render.sh` | Avenir Next Demi Bold, size 14, white on a 60% black box |
| Subtitle line length | `-ml 60` in `bin/generate.sh` | 60 characters |
| Whisper model | `WHISPER_MODEL` environment variable | `models/ggml-base.en.bin` |

Settings live in the scripts under `bin/`. The `.command` launchers just call them, so there is only one place to edit.

## Project layout

```
MLXnarrator/
├── bin/
│   ├── generate.sh               # voice + fit + subtitles
│   ├── render.sh                 # render with subtitles
│   ├── render-no-subs.sh         # render without subtitles
│   └── run-all.sh                # all-in-one
├── generate.command              # double-click launchers (thin wrappers around bin/)
├── render.command
├── render-no-subs.command
├── run-all.command
├── src/
│   ├── narrate.py                # Kokoro text-to-speech
│   └── voices.py                 # list available voices
├── tests/
│   └── test_voice.py             # sound check
├── scripts/
│   ├── narration.example.txt     # template (in git)
│   └── narration.txt             # your narration (copied from the example; any other .txt here is git-ignored too)
├── docs/
│   └── NARRATION-PROMPTS.md      # LLM prompts for drafting narration
├── assets/
│   └── logo.svg
├── requirements.txt
├── input/                        # demo.mp4                  (mkdir, git-ignored)
├── audio/                        # generated narration       (mkdir, git-ignored)
├── subtitles/                    # generated/edited SRT      (mkdir, git-ignored)
├── output/                       # final videos              (mkdir, git-ignored)
└── models/                       # Whisper model             (mkdir, git-ignored)
```

## Troubleshooting

**`ERROR: ... has no 'subtitles' filter`**
Your ffmpeg was built without libass. Run `brew install ffmpeg-full`. The scripts pick it up automatically from `/opt/homebrew/opt/ffmpeg-full`.

**`ERROR: whisper-cli not found`**
Run `brew install whisper.cpp`, then open a new terminal so your `PATH` refreshes.

**`ERROR: Whisper model not found`**
Run the `curl` command in [step 5](#5-download-the-whisper-model).

**`.venv/bin/activate: No such file or directory`**
You skipped [step 4](#4-create-the-python-environment). The scripts activate `.venv` themselves, so it must live in the project folder.

**`No matching distribution found for kokoro-mlx` / MLX errors**
Check `python --version` inside the venv. It must be 3.10, 3.11 or 3.12, and the Mac must be Apple Silicon.

**Double-clicking a `.command` file says it "cannot be opened" or "is from an unidentified developer"**
Run the `xattr` command from [step 3](#3-make-the-scripts-runnable-macos). If macOS still objects, right-click the file, choose **Open**, then confirm once.

**Double-clicking says "Permission denied"**
Run `chmod +x bin/*.sh *.command` from the project folder.

**A `.command` file can't find `whisper-cli` or `ffmpeg`, but the terminal can**
Double-click launchers start with whatever `PATH` your shell sets up at login. Make sure Homebrew is initialised in `~/.zprofile`: `eval "$(/opt/homebrew/bin/brew shellenv)"`.

**`VOICE` change has no effect, or "Voice file not found"**
The ID must match the list from `python src/voices.py` exactly, including the underscore (`am_michael`, not `am-michael`).

**Narration sounds rushed**
Look for the `WARNING: needs …x` line during `bin/generate.sh`. Shorten `scripts/narration.txt` or use a longer video.

**Subtitle font looks wrong**
The font name in `bin/render.sh` must be installed on your Mac. Change `FONT=` to any installed font, for example `Helvetica Neue Bold`.

**Subtitles drift after editing the SRT**
Edit only the *text* of each cue, not the timestamps, unless you know the timing you want.

## Contributing

Bug reports, ideas and pull requests are very welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md); it's short, and it contains no riddles.

## License

Released under the [MIT License](LICENSE).

## Credits

Built on the shoulders of some excellent open-source work:

- [whisper.cpp](https://github.com/ggml-org/whisper.cpp) (MIT) for subtitle generation
- [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) (Apache-2.0) and [kokoro-mlx](https://github.com/gabrimatic/kokoro-mlx) (MIT) for local speech
- [FFmpeg](https://ffmpeg.org) for all audio and video processing
- [MLX](https://github.com/ml-explore/mlx) from Apple