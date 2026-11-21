# Changelog

[简体中文](CHANGELOG.md) · [English README](docs/readme/README.en.md)

## 1.7.0

- Redesigned item details and settings with native wooden frames and item slots. Transmutation recipes use the game's cube artwork. The sidebar has larger icons and keeps its backing when auto-pause is off.
- Settings now show auto-pause, key bindings, and developer mode. Crafting quantities follow ingredient names, and transmutation results show their names on hover.
- The catalog deduplicates native IDs, marks recipe blueprints with a scroll, and hides explicitly labeled work-in-progress items from the regular list. Duplicate sources for the same chest type are merged.
- Borderless window preparation for input methods now happens during startup, avoiding a window mode change on the first inventory opening.

## 1.6.0

- Added individual recipe blueprints. You can look up how to obtain a blueprint and which recipe it unlocks. Cheat mode creates the blueprint using the game's recipe ID. Dictionary 10 and Dictionary 20 now appear in the regular item list.
- Added Chinese and English item tags and exact item ID search in developer mode. Reforge scrolls now show their specific affixes.
- The `Ctrl+O` visibility toggle now remembers its state. With both developer and cheat modes enabled, you can obtain hidden items that the game can generate.
- Fixed a movement issue when the cursor was over JEI and an auto-pause issue after opening the game's Codex.
