# Simple XP Bar quest probe

This temporary diagnostic compares completed tracked and untracked quests reported by the Forever client. It does not change quests, tracking, headers, or save data.

1. Copy `SXPQuestProbe` into `_forever_/Interface/AddOns/`, fully restart the game, and enable **Simple XP Bar Quest Probe**.
2. Log in on a character with at least one completed quest still in the quest log. Make sure its section is expanded so this test isolates tracking behavior.
3. Track that completed quest and type `/sxpcheck`. Note the completed tracked and untracked counts.
4. Untrack the same completed quest without handing it in and type `/sxpcheck` again. The tracked count should decrease by one, the untracked count should increase by one, and the `all` count should stay the same. Report both lines.
5. `/sxpcheck reset` clears the snapshot. Disable or remove the diagnostic when finished.

The displayed mode counts are diagnostic calculations, not the actual XP totals produced by the addon. Separately test collapsed sections and reward values; this probe only counts returned quest entries and does not establish combat taint safety.

