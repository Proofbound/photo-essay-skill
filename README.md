# Photo Essay Skill for Claude Code

A [Claude Code](https://claude.com/claude-code) skill that turns a directory of photos into a polished, self-contained HTML photo essay — ready to email or share.

Think Smithsonian magazine meets personal travel email: rich historical and cultural context, warm first-person voice, all in a single `.html` file with embedded images.

## What it does

- Reads photos from a directory (JPEG, PNG, HEIC, WebP)
- Extracts GPS coordinates and timestamps from EXIF data
- Compresses and resizes images for mobile
- Researches locations via web search
- Writes magazine-style prose with historical and cultural depth
- Outputs a single self-contained HTML file (base64-embedded images, no dependencies)

## Install

### As a plugin (recommended)

```bash
# In Claude Code:
/plugin marketplace add Proofbound/photo-essay-skill
/plugin install photo-essay@proofbound-photo-essay-skill
```

### Manual install

```bash
git clone https://github.com/Proofbound/photo-essay-skill.git ~/.claude/skills/photo-essay
```

Then install the Python dependencies:

```bash
pip install Pillow pillow-heif --break-system-packages
```

## Usage

In Claude Code, just say:

- "Make a photo essay from ~/Photos/tokyo-trip"
- "Turn these trip photos into something nice"
- "Create a photo story from this folder"

Claude will ask for any needed context (location, date, tone) and handle the rest.

## Output

The result is a single `.html` file that:

- Works on any device (mobile-optimized, 640px max width)
- Can be emailed as an attachment
- Has no external dependencies (all images embedded)
- Uses Georgia serif font with magazine-style layout

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI
- Python 3 with [Pillow](https://pillow.readthedocs.io/)
- `pillow-heif` for HEIC/iPhone photo support

## License

MIT
