#!/bin/bash
# Re-render using your EDITED subtitles/narration.srt.
# Does NOT run TTS or whisper, so your subtitle edits are never overwritten.
# Needs audio/narration-fit.wav from a previous run-all.sh run.
set -e

BASE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BASE"
mkdir -p output

DEMO="input/demo.mp4"
AUDIO="audio/narration-fit.wav"
SRT="subtitles/narration.srt"
OUT="output/demo-final.mp4"

# ---- Subtitle look (tweak freely) ----
FONT="Avenir Next Demi Bold"   # alternatives: "Helvetica Neue Bold", "Futura Medium", "Arial Rounded MT Bold", "Menlo Bold"
SIZE=14                        # relative to 288px-tall canvas: 12=medium, 14=large, 16=extra large
TEXT_COLOR="&H00FFFFFF"        # white
BOX_COLOR="&H66000000"         # black box, 60% opaque (AABBGGRR; 00=100% opaque, 4D=70%, 80=50%, FF=invisible)
OUTLINE=2                      # thickness of the border around the text (in box mode: box padding)
MARGIN_V=24                    # distance from bottom

# Prefer ffmpeg-full (has libass, keg-only) if installed, else whatever is on PATH
if [ -x /opt/homebrew/opt/ffmpeg-full/bin/ffmpeg ]; then
  FFMPEG=/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg
  FFPROBE=/opt/homebrew/opt/ffmpeg-full/bin/ffprobe
else
  FFMPEG=ffmpeg
  FFPROBE=ffprobe
fi

for f in "$DEMO" "$AUDIO" "$SRT"; do
  [ -f "$f" ] || { echo "Missing: $f"; exit 1; }
done

STYLE="FontName=${FONT},FontSize=${SIZE},PrimaryColour=${TEXT_COLOR},BackColour=${BOX_COLOR},OutlineColour=${BOX_COLOR},BorderStyle=3,Outline=${OUTLINE},Shadow=0,Alignment=2,MarginV=${MARGIN_V},WrapStyle=0"
SUBS="subtitles=filename=${SRT}:force_style='${STYLE}'"

if ! "$FFMPEG" -hide_banner -filters 2>/dev/null | grep -qE '^ .* subtitles '; then
  echo "ERROR: ffmpeg has no 'subtitles' filter. Run: brew install ffmpeg-full"
  exit 1
fi

HAS_AUDIO=$("$FFPROBE" -v error -select_streams a -show_entries stream=index -of csv=p=0 "$DEMO" | head -n1)

echo "Rendering with edited subtitles..."

if [ -n "$HAS_AUDIO" ]; then
  "$FFMPEG" -y -loglevel error \
    -i "$DEMO" -i "$AUDIO" \
    -filter_complex "[0:v]${SUBS}[v];[0:a]volume=0.15[orig];[1:a]volume=1.0[nar];[orig][nar]amix=inputs=2:duration=longest:normalize=0[a]" \
    -map "[v]" -map "[a]" \
    -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
    -c:a aac -b:a 192k -shortest "$OUT"
else
  "$FFMPEG" -y -loglevel error \
    -i "$DEMO" -i "$AUDIO" \
    -filter_complex "[0:v]${SUBS}[v]" \
    -map "[v]" -map 1:a \
    -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p \
    -c:a aac -b:a 192k -shortest "$OUT"
fi

echo "Done: $BASE/$OUT"