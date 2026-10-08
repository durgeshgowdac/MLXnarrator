# Narration Prompts

Don't fancy writing the narration from scratch? Let an LLM do the first draft, then make it sound like you. These two prompts work in any chat assistant.

This page belongs to [MLXnarrator](../README.md). Finished narration goes into `scripts/narration.txt`.

The pipeline likes narration in a specific shape: a **section marker line** with a time range, followed by plain spoken paragraphs. Marker lines are stripped before speech, so they only organise the script and keep the pacing honest.

```
**[00:00 - 00:20] - Introduction**

Spoken text goes here, as plain sentences.

**[00:20 - 00:45] - Main feature**

More spoken text.
```

Work in two steps: a skeleton first (so you can check the structure against your recording), then the final narration.

## Prompt 1: skeleton

Fill in the `[brackets]` and paste into any LLM:

```text
You are helping me narrate a screen-recording demo video.

Project: [name and one-line description]
Audience: [e.g. recruiters, developers, a hackathon jury]
Video length: [e.g. 2 minutes 30 seconds]
What the screen shows, in order:
[rough list, e.g. 1. login page  2. dashboard  3. upload a file  4. results view]

Create a SKELETON for the narration: split the video into sections that follow
the order of the screen, and give each section:
- a marker line in exactly this format: **[MM:SS - MM:SS] - Section title**
- 2 to 4 short notes on what must be said (not full sentences)
- a target word count for that section

Rules:
- Time ranges must be continuous, start at 00:00 and end at the video length.
- Total target words = video seconds x 2.3 (about 140 words per minute).
  Never exceed this: the narration is sped up if it runs long, and over 1.3x sounds rushed.
- Open with a short hook and close with a one-line takeaway.
- Output only the skeleton. No introduction, no commentary.
```

> The skeleton contains note bullets. **Do not paste it into `scripts/narration.txt`**, or the voice will read the bullets aloud with great confidence. Use it for planning only.

## Prompt 2: final narration

Paste this together with the skeleton you approved:

```text
Using the skeleton below, write the final narration for text-to-speech.

Output format, strictly:
- Keep every marker line exactly as in the skeleton: **[MM:SS - MM:SS] - Section title**
- Under each marker, write 1 to 3 short paragraphs of spoken text.
- Plain text only. No bullet points, no headings, no bold or italics, no emojis,
  no stage directions like (pause) or [click], no URLs.

Writing rules for text-to-speech:
- Write for the ear: short sentences, contractions, first person ("I", "we").
- Spell out anything awkward to pronounce: write "A P I" only if the voice
  mispronounces "API"; write numbers as words ("twenty twenty-six", "three hundred").
- Say what is happening on screen as it happens ("Now I upload a file...").
- Hit each section's target word count, within 10 percent.
- Output only the narration. No introduction, no commentary.

SKELETON:
[paste skeleton here]
```

Paste the result into `scripts/narration.txt`, run `./bin/generate.sh`, and listen to `audio/narration-fit.wav`. If it feels rushed, ask the LLM to cut every section by 10 percent and regenerate.

## Tips

- Check the skeleton against your recording *before* asking for the final text. Fixing structure is cheap; fixing a finished script is not.
- Read the narration aloud once. If you stumble, the voice will too.
- If the voice mangles a word, respell it phonetically in the script (for example, write "sequel" for "SQL" if that's how you want it said).
- Not sure how long your video is? `ffprobe -v error -show_entries format=duration -of csv=p=0 input/demo.mp4` prints it in seconds.
