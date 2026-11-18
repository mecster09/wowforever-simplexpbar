# Simple XP Bar quest probe

This temporary diagnostic compares quest IDs returned by the Forever client before and after collapsing a quest-log section. It does not change quests, toggle headers, or save data.

1. Copy `SXPQuestProbe` into `_forever_/Interface/AddOns/`, fully restart the game, and enable **Simple XP Bar Quest Probe**.
2. Log in on a character with at least one active quest. Open the quest log and expand a section containing quests.
3. Type `/sxpcheck`. Collapse that section without accepting, abandoning, completing, or turning in any quests. Type `/sxpcheck` again.
4. Note the two count lines and whether quest IDs disappeared. `/sxpcheck reset` clears the snapshot so another section can be tested.
5. Repeat with a section containing a completed quest, if available. Disable or remove the diagnostic when finished.

The comparison tests the client and specific sections observed. A negative result does not prove every client version, quest type, or filter behaves the same way. The diagnostic does not inspect reward values or test combat taint.

