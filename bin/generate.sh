#!/bin/bash
set -e

BASE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BASE"
mkdir -p audio subtitles output

DEMO="input/demo.mp4"
# Prefer ffmpeg-full (has libass, keg-only) if installed, else whatever is on PATH
if [ -x /opt/homebrew/opt/ffmpeg-full/bin/ffmpeg ]; then
  FFMPEG=/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg
  FFPROBE=/opt/homebrew/opt/ffmpeg-full/bin/ffprobe
else
  FFMPEG=ffmpeg
  FFPROBE=ffprobe
fi

# whisper.cpp from Homebrew (brew install whisper.cpp)
if command -v whisper-cli >/dev/null 2>&1; then
  WHISPER="$(command -v whisper-cli)"
else
  echo "ERROR: whisper-cli not found. Run: brew install whisper.cpp"
  exit 1
fi

# Model: override with WHISPER_MODEL=/path/to/ggml-xxx.bin
MODEL="${WHISPER_MODEL:-models/ggml-base.en.bin}"
if [ ! -f "$MODEL" ]; then
  echo "ERROR: Whisper model not found: $MODEL"
  echo "Download it with:"
  echo "  curl -L -o models/ggml-base.en.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
  exit 1
fi

# Narration is allowed to run at most this much faster than natural speed
MAX_SPEEDUP=1.30
# Leave a little breathing room at the end of the video
TAIL_PAD=0.5

echo "================================"
echo " Narration + Subtitles (no render)"
echo "================================"

source "$BASE/.venv/bin/activate"

# ---------- [1/2] TTS ----------
echo
echo "[1/2] Generating narration..."
python src/narrate.py

# ---------- fit narration to video length ----------
VID_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$DEMO")
NAR_DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 audio/narration.wav)
TARGET=$(awk -v v="$VID_DUR" -v p="$TAIL_PAD" 'BEGIN{printf "%.3f", v-p}')
FACTOR=$(awk -v n="$NAR_DUR" -v t="$TARGET" 'BEGIN{f=n/t; if(f<1)f=1; printf "%.4f", f}')

echo "Video: ${VID_DUR}s | Narration: ${NAR_DUR}s | Speed-up needed: ${FACTOR}x"

if awk -v f="$FACTOR" -v m="$MAX_SPEEDUP" 'BEGIN{exit !(f>m)}'; then
  echo "WARNING: needs ${FACTOR}x (> ${MAX_SPEEDUP}x). Narration will sound rushed; consider trimming scripts/narration.txt."
fi

# atempo keeps pitch; subtitles are generated from THIS file so timing matches the final mix
"$FFMPEG" -y -loglevel error -i audio/narration.wav \
  -filter:a "atempo=${FACTOR}" -ar 48000 -c:a pcm_s16le audio/narration-fit.wav

# ---------- [2/2] Subtitles ----------
echo
echo "[2/2] Generating subtitles..."

"$FFMPEG" -y -loglevel error -i audio/narration-fit.wav \
  -ar 16000 -ac 1 -c:a pcm_s16le audio/narration-whisper.wav

# Never silently overwrite a proofread SRT: keep a timestamped backup
if [ -f subtitles/narration.srt ]; then
  BAK="subtitles/narration.$(date +%Y%m%d-%H%M%S).srt.bak"
  cp subtitles/narration.srt "$BAK"
  echo "Existing SRT backed up to $BAK"
fi

"$WHISPER" \
  -m "$MODEL" \
  -f audio/narration-whisper.wav \
  -osrt \
  -ml 60 -sow \
  -of subtitles/narration \
  -np

echo
echo "================================"
echo "Done! Next steps:"
echo "  1. Proofread: subtitles/narration.srt"
echo "  2. Render:    ./bin/render.sh"
echo "================================"