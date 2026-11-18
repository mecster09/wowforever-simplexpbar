import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / '.test-deps'))
from lupa import LuaRuntime

lua = LuaRuntime()
lua.execute('''
messages = {}
function print(message) messages[#messages + 1] = message end
SlashCmdList = {}
C_QuestLog = {
    GetNumQuestLogEntries = function() return 1, 1 end,
    GetInfo = function() return {questID = 123, isHeader = false} end,
    IsComplete = function() return true end,
    GetQuestWatchType = function() return 0 end,
}
''')
lua.execute((pathlib.Path(__file__).parent / 'SXPQuestProbe' / 'SXPQuestProbe.lua').read_text())
lua.execute('''
SlashCmdList.SXPQUESTPROBE("")
C_QuestLog.GetQuestWatchType = function() return nil end
SlashCmdList.SXPQUESTPROBE("")
C_QuestLog.GetNumQuestLogEntries = function() return 0, 1 end
SlashCmdList.SXPQUESTPROBE("")
''')
assert '1 tracked, 0 untracked' in lua.globals().messages[2]
assert '0 tracked, 1 untracked' in lua.globals().messages[5]
assert 'all=1, tracked-only=0' in lua.globals().messages[5]
assert '1 quest IDs disappeared' in lua.globals().messages[10]
print('Quest probe reports a missing quest ID')

