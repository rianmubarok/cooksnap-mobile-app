"""Generate adaptive foreground from icon.png without changing logo scale."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "icons" / "icon.png"
OUT = ROOT / "assets" / "icons" / "icon_foreground.png"
BG = (162, 230, 103)  # #A2E667


def color_distance(c1: tuple[int, ...], c2: tuple[int, ...]) -> float:
    return sum((a - b) ** 2 for a, b in zip(c1[:3], c2[:3])) ** 0.5


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    pixels = src.load()
    width, height = src.size

    # Keep logo size/position exactly as icon.png; only remove lime background.
    fg = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    fg_pixels = fg.load()
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a < 16:
                continue
            if color_distance((r, g, b), BG) < 42:
                continue
            fg_pixels[x, y] = (r, g, b, a)

    fg.save(OUT)
    print(f"Generated {OUT.name} (same scale as icon.png)")


if __name__ == "__main__":
    main()
