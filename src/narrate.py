from pathlib import Path
import re
import sys
import warnings

# Suppress the specific FutureWarning from PyTorch JIT
warnings.filterwarnings(
    "ignore",
    category=FutureWarning,
    module="torch.jit._script",
)

from kokoro_mlx import KokoroTTS


BASE = Path(__file__).resolve().parent.parent
SCRIPT = BASE / "scripts" / "narration.txt"
OUTPUT = BASE / "audio" / "narration.wav"

VOICE = "am_michael"
SPEED = 1.0
SAMPLE_RATE = 48000


TIMESTAMP = r"\[?\s*\d{1,2}:\d{2}(?::\d{2})?\s*[-\u2013\u2014]+\s*\d{1,2}:\d{2}(?::\d{2})?\s*\]?"


def clean_script(raw: str) -> str:
    """Strip everything that shouldn't be spoken: section/timestamp headings and markdown."""
    kept = []
    for line in raw.splitlines():
        stripped = line.strip()

        # Markdown headings (# Title) and horizontal rules (---)
        if stripped.startswith("#") or re.fullmatch(r"[-*_]{3,}", stripped):
            continue

        # Section marker lines like: **[00:00 - 00:25] - Introduction**
        if re.search(TIMESTAMP, stripped):
            continue

        # Markdown emphasis / code ticks / links
        line = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", line)
        line = re.sub(r"[*_`]+", "", line)
        kept.append(line.rstrip())

    text = "\n".join(kept)
    return re.sub(r"\n{3,}", "\n\n", text).strip()


def main():
    if not SCRIPT.exists():
        print(f"Missing script: {SCRIPT}")
        sys.exit(1)

    text = clean_script(SCRIPT.read_text(encoding="utf-8"))

    if not text:
        print("Script is empty.")
        sys.exit(1)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    print("Loading Kokoro...")

    tts = KokoroTTS.from_pretrained()

    print("Generating narration...")

    tts.save(
        text,
        str(OUTPUT),
        voice=VOICE,
        speed=SPEED,
        sample_rate=SAMPLE_RATE,
    )

    print(f"Saved: {OUTPUT}")


if __name__ == "__main__":
    main()