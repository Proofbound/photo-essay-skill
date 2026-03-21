# Installing Photo Essay on Windows

This adds a skill to Claude Code that turns a folder of photos into a polished, magazine-style HTML document you can email or share — no design skills needed.

## Quick Install

1. Make sure you have **Python 3** installed (free from the [Microsoft Store](https://apps.microsoft.com/search?query=python+3))
2. Download [`install-windows.bat`](https://raw.githubusercontent.com/Proofbound/photo-essay-skill/main/install-windows.bat) (right-click, "Save link as...")
3. Double-click it and follow the prompts
4. Done!

## How to Use It

Open Claude Code and say things like:

- "Make a photo essay from C:\Users\YourName\Pictures\vacation"
- "Turn my trip photos into something nice"
- "Create a photo story from this folder"

Claude will ask about the trip (where, when, any context) and produce a single `.html` file you can open in any browser or email as an attachment.

## Requirements

- Windows 10 or 11
- [Claude Code](https://claude.com/claude-code) (already installed)
- Python 3 (free from the Microsoft Store — search "Python 3.12")
- Internet connection for the initial install

## Manual Install

If the batch file doesn't work, you can install by hand:

### Step 1: Install Python

- Open the **Microsoft Store**
- Search for **Python 3.12**
- Click **Get** (free)
- Open Command Prompt and verify: `python --version`

### Step 2: Download the Skill

- Go to https://github.com/Proofbound/photo-essay-skill
- Click the green **Code** button, then **Download ZIP**
- Extract the ZIP file
- Move the extracted folder to: `C:\Users\YourName\.claude\skills\photo-essay\`

To find your username, open Command Prompt and type: `echo %USERPROFILE%`

### Step 3: Install Python Packages

Open Command Prompt and run:

```
python -m pip install Pillow pillow-heif
```

### Step 4: Verify

```
python -c "from PIL import Image; print('OK')"
```

You should see `OK`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `python is not recognized` | Python isn't on your PATH. Reinstall from Microsoft Store, or try `py` instead of `python`. |
| `pip is not recognized` | Use `python -m pip` instead of `pip`. |
| Permission errors | Right-click the .bat file and select **Run as administrator**. |
| Skill not working in Claude | Make sure the files are in `%USERPROFILE%\.claude\skills\photo-essay\` and that the subfolder `skills\photo-essay\SKILL.md` exists inside it. |
| HEIC/iPhone photos skipped | The `pillow-heif` package may not have installed. Run `python -m pip install pillow-heif` again. JPEG and PNG photos will still work. |
