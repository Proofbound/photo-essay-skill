# Photo Essay Skill for Claude

A skill for [Claude Code](https://claude.com/claude-code) and [Claude Desktop](https://claude.ai/download) that turns a directory of photos into a polished, self-contained HTML photo essay — ready to email or share.

Think Smithsonian magazine meets personal travel email: rich historical and cultural context, warm first-person voice, all in a single `.html` file with embedded images.

## What it does

- Reads photos from a directory (JPEG, PNG, HEIC, WebP)
- Extracts GPS coordinates and timestamps from EXIF data
- Compresses and resizes images for mobile
- Researches locations via web search
- Writes magazine-style prose with historical and cultural depth
- Outputs a single self-contained HTML file (base64-embedded images, no dependencies)

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Proofbound/photo-essay-skill/main/install.sh | bash
```

### Windows

Download and double-click [`install-windows.bat`](https://raw.githubusercontent.com/Proofbound/photo-essay-skill/main/install-windows.bat), or see [WINDOWS-INSTALL.md](WINDOWS-INSTALL.md) for step-by-step instructions.

### Other methods

**As a Claude Code plugin:**
```bash
/plugin marketplace add Proofbound/photo-essay-skill
/plugin install photo-essay@proofbound-photo-essay-skill
```

**Manual:**
```bash
git clone https://github.com/Proofbound/photo-essay-skill.git ~/.claude/skills/photo-essay
pip install Pillow pillow-heif --break-system-packages
```

Claude Code and Claude Desktop share the same `~/.claude/skills/` directory, so installing once makes the skill available in both.

## Usage

In Claude Code or Claude Desktop, just say:

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

- [Claude Code](https://claude.com/claude-code) or [Claude Desktop](https://claude.ai/download)
- Python 3 with [Pillow](https://pillow.readthedocs.io/)
- `pillow-heif` for HEIC/iPhone photo support

## License

MIT
