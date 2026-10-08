#!/bin/bash
# Render WITHOUT subtitles: demo video + narration, nothing burned in.
#
#   ./bin/render-no-subs.sh              # fast: video stream is copied, not re-encoded
#   ./bin/render-no-subs.sh --reencode   # re-encode video (H.264, CRF 18) instead of copying
#
# Does NOT run TTS or whisper, and does not need an SRT file or libass.
# Needs audio/narration-fit.wav from a previous ./bin/generate.sh (or ./bin/run-all.sh) run.
# Output goes to output/demo-final-nosubs.mp4 so your subtitled render is never overwritten.
set -e

BASE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BASE"
mkdir -p output

DEMO="input/demo.mp4"
AUDIO="audio/narration-fit.wav"
OUT="output/demo-final-nosubs.mp4"

REENCODE=0
case "${1:-}" in
  "")           ;;
  --reencode)   REENCODE=1 ;;
  -h|--help)    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *)            echo "Unknown option: $1 (try --help)"; exit 1 ;;
esac

# Subtitles are not used here, so plain ffmpeg is enough.
# Still prefer ffmpeg-full if installed, for consistency with the other scripts.
if [ -x /opt/homebrew/opt/ffmpeg-full/bin/ffmpeg ]; then
  FFMPEG=/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg
  FFPROBE=/opt/homebrew/opt/ffmpeg-full/bin/ffprobe
else
  FFMPEG=ffmpeg
  FFPROBE=ffprobe
fi

for f in "$DEMO" "$AUDIO"; do
  [ -f "$f" ] || { echo "Missing: $f"; exit 1; }
done

if [ "$REENCODE" -eq 1 ]; then
  VCODEC=(-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p)
  echo "Rendering without subtitles (re-encoding video)..."
else
  VCODEC=(-c:v copy)
  echo "Rendering without subtitles (video stream copied, no re-encode)..."
fi

HAS_AUDIO=$("$FFPROBE" -v error -select_streams a -show_entries stream=index -of csv=p=0 "$DEMO" | head -n1)

if [ -n "$HAS_AUDIO" ]; then
  # Keep the original audio quietly underneath the narration
  "$FFMPEG" -y -loglevel error \
    -i "$DEMO" -i "$AUDIO" \
    -filter_complex "[0:a]volume=0.15[orig];[1:a]volume=1.0[nar];[orig][nar]amix=inputs=2:duration=longest:normalize=0[a]" \
    -map 0:v:0 -map "[a]" \
    "${VCODEC[@]}" \
    -c:a aac -b:a 192k -shortest "$OUT"
else
  echo "(demo.mp4 has no audio track - using narration only)"
  "$FFMPEG" -y -loglevel error \
    -i "$DEMO" -i "$AUDIO" \
    -map 0:v:0 -map 1:a \
    "${VCODEC[@]}" \
    -c:a aac -b:a 192k -shortest "$OUT"
fi

echo "Done: $BASE/$OUT"
