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
}
''')
lua.execute((pathlib.Path(__file__).parent / 'SXPQuestProbe' / 'SXPQuestProbe.lua').read_text())
lua.execute('''
SlashCmdList.SXPQUESTPROBE("")
C_QuestLog.GetNumQuestLogEntries = function() return 0, 1 end
SlashCmdList.SXPQUESTPROBE("")
''')
assert '1 quest IDs disappeared' in lua.globals().messages[4]
print('Quest probe reports a missing quest ID')

