# Changelog

[简体中文](CHANGELOG.md) · [English README](docs/readme/README.en.md)

## 1.7.3

- Reuse acquisition groups and reduce repeated layout and text measurements to make open detail panels cheaper to draw.
- With auto-pause turned off, JEI dims the game scene behind the native HUD while the overlay is open. The left column uses the same backing in either mode.
- Item details and settings use a deeper purple sampled from the cooking panel frame.

## 1.7.2

- The backing covers the full left column and uses the same color and opacity with auto-pause on or off. The game's health, mana, and stamina indicators draw above it.
- Reuse the current page of item icons to reduce per-frame rendering work while the inventory is open.

## 1.7.1

- Item details and settings now open centered above the inventory with a dark frame, full gold corners, and light text in the game's native font. Press Esc to close either panel.
- The item list keeps a dark backing when auto-pause is off and uses slightly smaller icons for clearer spacing.

## 1.7.0

- Redesigned item details and settings with native wooden frames and item slots. Transmutation recipes use the game's cube artwork. The sidebar has larger icons and keeps its backing when auto-pause is off.
- Settings now show auto-pause, key bindings, and developer mode. Crafting quantities follow ingredient names, and transmutation results show their names on hover.
- The catalog deduplicates native IDs, marks recipe blueprints with a scroll, and hides explicitly labeled work-in-progress items from the regular list. Duplicate sources for the same chest type are merged.
- Borderless window preparation for input methods now happens during startup, avoiding a window mode change on the first inventory opening.
- Finished the frame edges and removed heavy outlines from labels on light panels. Long English titles and ingredient names wrap onto additional lines.

## 1.6.0

- Added individual recipe blueprints. You can look up how to obtain a blueprint and which recipe it unlocks. Cheat mode creates the blueprint using the game's recipe ID. Dictionary 10 and Dictionary 20 now appear in the regular item list.
- Added Chinese and English item tags and exact item ID search in developer mode. Reforge scrolls now show their specific affixes.
- The `Ctrl+O` visibility toggle now remembers its state. With both developer and cheat modes enabled, you can obtain hidden items that the game can generate.
- Fixed a movement issue when the cursor was over JEI and an auto-pause issue after opening the game's Codex.
