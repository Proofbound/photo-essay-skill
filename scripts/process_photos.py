#!/usr/bin/env python3
"""
Process a directory of photos for the photo-essay skill.

Reads all images, extracts EXIF/GPS, auto-orients, resizes, compresses,
and outputs a JSON manifest with base64-encoded image data.

Usage:
    python process_photos.py <photo-directory> <output-manifest.json>

Dependencies:
    pip install Pillow pillow-heif --break-system-packages
"""

import base64
import io
import json
import os
import sys
from pathlib import Path

from PIL import Image, ImageOps
from PIL.ExifTags import TAGS, GPSTAGS

# Try to import HEIC support
try:
    import pillow_heif
    pillow_heif.register_heif_opener()
    HEIC_SUPPORT = True
except ImportError:
    HEIC_SUPPORT = False

MAX_WIDTH = 640
JPEG_QUALITY = 72
SUPPORTED_EXTENSIONS = {'.jpeg', '.jpg', '.png', '.heic', '.webp'}


def extract_gps(img):
    """Extract GPS coordinates from EXIF data. Returns (lat, lon) or None."""
    try:
        exif = img._getexif()
        if not exif:
            return None

        gps_info = {}
        for tag_id, value in exif.items():
            tag = TAGS.get(tag_id, tag_id)
            if tag == 'GPSInfo':
                for gps_tag_id, gps_value in value.items():
                    gps_tag = GPSTAGS.get(gps_tag_id, gps_tag_id)
                    gps_info[gps_tag] = gps_value

        if not gps_info or 'GPSLatitude' not in gps_info:
            return None

        def to_decimal(coords, ref):
            d, m, s = [float(x) for x in coords]
            decimal = d + m / 60 + s / 3600
            if ref in ('S', 'W'):
                decimal = -decimal
            return decimal

        lat = to_decimal(
            gps_info.get('GPSLatitude', (0, 0, 0)),
            gps_info.get('GPSLatitudeRef', 'N')
        )
        lon = to_decimal(
            gps_info.get('GPSLongitude', (0, 0, 0)),
            gps_info.get('GPSLongitudeRef', 'W')
        )
        return (round(lat, 6), round(lon, 6))
    except Exception:
        return None


def extract_timestamp(img):
    """Extract datetime from EXIF. Returns ISO string or None."""
    try:
        exif = img._getexif()
        if not exif:
            return None
        for tag_id, value in exif.items():
            tag = TAGS.get(tag_id, tag_id)
            if tag == 'DateTimeOriginal':
                # Convert "2026:02:24 14:30:00" to "2026-02-24T14:30:00"
                return value.replace(':', '-', 2).replace(' ', 'T', 1)
        return None
    except Exception:
        return None


def process_image(filepath):
    """Load, orient, resize, compress. Returns dict with base64, dims, metadata."""
    img = Image.open(filepath)

    # Extract metadata before any transforms
    gps = extract_gps(img)
    timestamp = extract_timestamp(img)

    # Auto-orient based on EXIF
    img = ImageOps.exif_transpose(img)

    # Resize
    w, h = img.size
    if w > MAX_WIDTH:
        ratio = MAX_WIDTH / w
        img = img.resize((MAX_WIDTH, int(h * ratio)), Image.LANCZOS)

    # Convert to RGB for JPEG output
    if img.mode in ('RGBA', 'P', 'LA', 'L'):
        if img.mode in ('RGBA', 'LA'):
            background = Image.new('RGB', img.size, (255, 255, 255))
            if img.mode == 'RGBA':
                background.paste(img, mask=img.split()[3])
            else:
                background.paste(img, mask=img.split()[1])
            img = background
        else:
            img = img.convert('RGB')

    # Compress to JPEG
    buf = io.BytesIO()
    img.save(buf, format='JPEG', quality=JPEG_QUALITY, optimize=True)
    b64 = base64.b64encode(buf.getvalue()).decode('utf-8')
    size_kb = len(buf.getvalue()) / 1024

    return {
        'filename': os.path.basename(filepath),
        'b64': b64,
        'width': img.size[0],
        'height': img.size[1],
        'size_kb': round(size_kb, 1),
        'gps': gps,
        'timestamp': timestamp,
        'maps_url': f"https://maps.google.com/?q={gps[0]},{gps[1]}" if gps else None,
    }


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <photo-directory> <output-manifest.json>")
        sys.exit(1)

    photo_dir = sys.argv[1]
    output_path = sys.argv[2]

    if not os.path.isdir(photo_dir):
        print(f"Error: {photo_dir} is not a directory")
        sys.exit(1)

    # Collect image files
    files = []
    for f in sorted(os.listdir(photo_dir)):
        ext = Path(f).suffix.lower()
        if ext in SUPPORTED_EXTENSIONS:
            if ext == '.heic' and not HEIC_SUPPORT:
                print(f"  Warning: skipping {f} (install pillow-heif for HEIC support)")
                continue
            files.append(os.path.join(photo_dir, f))

    if not files:
        print(f"No supported image files found in {photo_dir}")
        sys.exit(1)

    print(f"Processing {len(files)} images from {photo_dir}...")

    manifest = []
    total_size = 0

    for filepath in files:
        try:
            result = process_image(filepath)
            total_size += result['size_kb']
            print(f"  {result['filename']}: {result['width']}x{result['height']}, "
                  f"{result['size_kb']:.0f}KB"
                  f"{' GPS:'+result['maps_url'] if result['gps'] else ''}")
            manifest.append(result)
        except Exception as e:
            print(f"  Error processing {os.path.basename(filepath)}: {e}")

    # Write manifest
    with open(output_path, 'w') as f:
        json.dump(manifest, f, indent=2)

    print(f"\nManifest written: {output_path}")
    print(f"Photos: {len(manifest)}")
    print(f"Total embedded size: {total_size/1024:.1f}MB")

    # Print GPS cluster summary
    gps_photos = [p for p in manifest if p['gps']]
    if gps_photos:
        print(f"\nGPS data found in {len(gps_photos)}/{len(manifest)} photos")
        # Simple clustering: group by proximity (~50m ≈ 0.0005 degrees)
        clusters = []
        for p in gps_photos:
            placed = False
            for cluster in clusters:
                ref = cluster[0]['gps']
                if (abs(p['gps'][0] - ref[0]) < 0.0005 and
                    abs(p['gps'][1] - ref[1]) < 0.0005):
                    cluster.append(p)
                    placed = True
                    break
            if not placed:
                clusters.append([p])

        print(f"Location clusters: {len(clusters)}")
        for i, cluster in enumerate(clusters):
            center = cluster[0]['gps']
            print(f"  Cluster {i+1}: {len(cluster)} photos near "
                  f"{center[0]:.4f}, {center[1]:.4f} "
                  f"(https://maps.google.com/?q={center[0]},{center[1]})")


if __name__ == '__main__':
    main()
