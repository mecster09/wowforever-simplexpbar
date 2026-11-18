# Simple XP Bar Forever

Keep an eye on your leveling progress with a compact, customizable experience bar for World of Warcraft: Forever. See your current XP, rested XP, and the estimated XP from completed quests together, with colored projections showing how they overlap.

## Features

- See current and maximum XP, percentage, rested XP, and completed-quest XP at a glance.
- Choose all completed quests or only tracked completed quests. An incomplete label warns when the quest log or a reward is unavailable.
- Change bar and projection colors, size, text size, and position. The bar is locked until you unlock it.
- Save settings across characters. XP continues updating in combat while configuration controls are disabled.

## Installation

1. Exit the game. In Battle.net, choose World of Warcraft: Forever and use the gear next to Play to locate its installation folder.
2. Copy the `SimpleXPBarForever` folder into `_forever_/Interface/AddOns/`, so `SimpleXPBarForever.toc` is directly inside that folder.
3. Start the game, enable **Simple XP Bar Forever** on the character selection AddOns screen, and log in.

```text
_forever_/Interface/AddOns/
└── SimpleXPBarForever/
    ├── SimpleXPBarForever.toc
    ├── Model.lua
    └── SimpleXPBarForever.lua
```

## Configuration

Type `/sxp` or `/simplexp` to open the options. You can show or hide the bar, lock or unlock dragging, select the quest scope, change dimensions and text size, choose colors, or reset the position or all settings. Hide the custom bar to restore the default status bar. Settings cannot be changed during combat.

The quest total is an estimate: rewards not yet available and collapsed quest log sections are marked incomplete. Open collapsed quest groups to include their quests. The bar shows the known total even when incomplete. The two projections start at the end of current XP and overlap; the overlapping area uses its own color. Projections stop visually at the end of the level, while text retains the full values.

## Maintenance and releases

The initial version is **0.1.0**. For a manual CurseForge release, update the version in the TOC and changelog, verify the interface version and behavior against the current Forever client, and ZIP the `SimpleXPBarForever` folder so the folder is at the ZIP root. Upload the ZIP as the appropriate Forever game version. Keep the folder name unchanged during upgrades; SavedVariables are retained by the game.

This early version requires in-game validation, especially quest reward availability, default-bar behavior, and combat safety. The game may show other status information in the same default status bar container.

For tests, install `lupa` in `.test-deps` with `python -m pip install --target .test-deps lupa`, then run `python -m unittest discover -s tests -v`.
