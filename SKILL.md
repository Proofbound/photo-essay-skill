---
name: photo-essay
description: |
  **Photo Essay Builder**: Creates Smithsonian-quality, mobile-optimized HTML photo essays from a directory of photos. Compresses images, extracts GPS/EXIF metadata, researches locations, and writes magazine-style prose with historical and cultural depth — all in a single self-contained HTML file ready to email.
  - MANDATORY TRIGGERS: photo essay, trip photos, travel writeup, photo story, emailable photo document, "make something nice from these photos", trip report with photos, photo journal, vacation photos, outing photos, travel email
  - Also trigger when: user points to a directory of photos and wants a narrative document, user wants to create a shareable trip summary, user uploads travel/outing photos and wants a writeup, user asks for a "Smithsonian-style" or magazine-style photo piece
---

# Photo Essay Builder

Create a self-contained, mobile-optimized HTML photo essay from a directory of photos. The output is a single `.html` file with base64-embedded compressed images — no external dependencies, ready to email as an attachment or paste into a message.

## When You Receive This Skill

You're being asked to turn a set of photos into a polished, readable narrative. Think of the output as a Smithsonian magazine article crossed with a personal travel email: rich cultural and historical context, but written in a warm first-person-plural voice ("we") that makes the reader feel like they were there.

## Workflow

### 1. Gather Context (ask the user)

Before processing, clarify these if not already obvious from the conversation:

- **Photo location**: Where did they go? (City, neighborhood, specific sites)
- **Date**: When was the visit?
- **Voice**: "We" (default), or name specific people?
- **Tone**: Smithsonian-style with historical depth (default), or lighter/casual?
- **Any special context**: Events, conditions, personal significance (e.g., a security situation, a festival, a closed attraction)

If the user has already been chatting and the context is clear, skip the questions and get to work.

### 2. Process Photos

Run `scripts/process_photos.py` on the photo directory. This script:

- Reads all `.jpeg`, `.jpg`, `.heic`, `.png` files
- Extracts EXIF data: GPS coordinates, timestamps, orientation
- Auto-orients images (fixes rotation from EXIF)
- Resizes to 640px wide, JPEG quality 72 (good balance of clarity and file size)
- Outputs a JSON manifest with base64 data, dimensions, GPS, and timestamps

```bash
python3 <skill-path>/scripts/process_photos.py <photo-directory> <output-manifest.json>
```

Install dependencies if needed: `pip install Pillow pillow-heif --break-system-packages -q`

### 3. Research Locations

Using the GPS coordinates from the manifest:

- **Cluster photos by location** — photos within ~50m of each other are at the same spot
- **Web search** for each cluster's coordinates or nearby landmarks
- **Build a knowledge base** of: historical background, architectural details, artist attributions, cultural significance, notable details a visitor wouldn't know

The research quality is what separates this from a photo dump. Aim for details that would make someone who *was there* say "oh, I didn't know that!" Examples:
- The sculptor's name, training, and artistic lineage
- The building's construction date and original purpose
- The etymology of place names
- Connections to broader cultural traditions

### 4. Write the Narrative

For each photo (or photo cluster), write a description that:

- **Opens with what's visible** — ground the reader in the image
- **Layers in context** — history, art, culture, etymology
- **Connects to the visit** — "we walked past..." / "we stopped at..."
- **Uses precise vocabulary** — name specific art styles, architectural terms, materials
- **Includes foreign terms** with translations — italicize foreign words, provide English meaning on first use

Photo ordering should follow a narrative arc, not just file-name order. Think about:
- Chronological flow (use timestamps if available)
- Spatial flow (walking tour sequence via GPS)
- Dramatic arc (opening wide shot → details → personal moments → closing)

### 5. Write the Intro

The intro paragraph(s) should:
- Set the scene: where, when, why
- Provide geographical and historical context for the destination
- Mention any special circumstances (closures, weather, security events, festivals)
- End with a transition into the photos: "Here's what we found."

Use a drop-cap for the first letter (the HTML template supports this).

### 6. Build the HTML

The HTML structure is:

```
Header (title, subtitle, dateline)
Intro paragraphs
[For each photo:]
  Photo (full-width, rounded corners, shadow)
  Title (red accent color)
  Description paragraph(s)
  Divider (• • •)
[Optional interlude blocks for non-photo sections like El Parián]
Footer (location, date, tagline)
```

Key design decisions already baked into the template:
- **Max width 640px** — optimized for phone screens
- **Georgia/serif font** — magazine feel
- **Red (#c0392b) accent color** — titles and drop-cap
- **Base64 embedded images** — single file, no broken links
- **Interlude blocks** — for text-only sections (styled with left border accent)

Construct the HTML inline following this pattern.

### 7. Deliver

- Save the HTML to the photo directory (alongside the source photos)
- Also save to the user's workspace/Notes folder if available
- Present both links to the user
- Mention the file size and photo count
- Offer to adjust: reorder, expand/trim descriptions, swap photos, change tone

## Tips for Great Results

**On research depth**: The sweet spot is 3-5 sentences of cultural/historical context per photo. Enough to reward careful reading, not so much that it overwhelms. A good test: would this paragraph work in a museum placard?

**On photo selection**: If there are more than ~15 photos, suggest curating down. The user can always add more, but a tight edit reads better on a phone. Group similar shots and pick the best one.

**On voice**: Default to warm, knowledgeable, personal. Not academic — no footnotes or hedging. Not travel-blog breathless — no "you won't BELIEVE." Think: a well-traveled friend who happens to know a lot about art history, writing you an email the day after a trip.

**On HTML emails**: Some email clients strip `<style>` blocks. The inline-style approach in the template is more robust. If the user asks about email compatibility, note that the HTML works best as an attachment opened in a browser, or in email clients that support embedded HTML (Gmail, Apple Mail). Outlook may strip some formatting.

**On interlude blocks**: Use these for locations you visited but didn't photograph, or for contextual sections that bridge the narrative (like describing a plaza or a security situation). They break up the photo grid and add narrative variety.

## Dependencies

- Python 3 with Pillow (`pip install Pillow --break-system-packages`)
- `pillow-heif` for HEIC support (`pip install pillow-heif --break-system-packages`)
- Web search access for location research
