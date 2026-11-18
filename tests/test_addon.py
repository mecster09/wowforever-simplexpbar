import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / '.test-deps'))
from lupa import LuaRuntime

ROOT = pathlib.Path(__file__).resolve().parents[1]


class AddonBehavior(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.ns = self.lua.table()
        self.lua.execute((ROOT / 'SimpleXPBarForever' / 'Model.lua').read_text(), 'SimpleXPBarForever', self.ns)

    def test_overlapping_projections_are_capped_but_totals_remain(self):
        result = self.ns.project(4200, 10000, 9000, 1500)
        self.assertAlmostEqual(result['current'], 0.42)
        self.assertAlmostEqual(result['restedEnd'], 1)
        self.assertAlmostEqual(result['questEnd'], 0.57)
        self.assertAlmostEqual(result['overlapEnd'], 0.57)

    def test_zero_maximum_does_not_divide_by_zero(self):
        result = self.ns.project(0, 0, 0, 100)
        self.assertEqual(result['questEnd'], 0)

    def test_game_entry_point_is_valid_lua(self):
        source = (ROOT / 'SimpleXPBarForever' / 'SimpleXPBarForever.lua').read_text()
        compile_lua = self.lua.eval('function(source) return load(source) end')
        self.assertTrue(callable(compile_lua(source)))

    def test_display_updates_for_completed_quests_and_level_cap(self):
        self.lua.execute((ROOT / 'tests' / 'client_stub.lua').read_text())
        self.lua.execute('quests = {{questID=1, complete=true, reward=1500}, {questID=2, complete=true}}')
        self.lua.execute((ROOT / 'SimpleXPBarForever' / 'SimpleXPBarForever.lua').read_text(), 'SimpleXPBarForever', self.ns)
        self.lua.globals().send('ADDON_LOADED', 'SimpleXPBarForever')
        bar = self.lua.globals().SimpleXPBarForeverFrame
        self.assertIn('Quests 1500 (incomplete)', bar['text']['value'])
        self.lua.execute('xp = 5000; send("PLAYER_XP_UPDATE")')
        self.assertIn('XP 5000 / 10000', bar['text']['value'])
        self.lua.execute('playerLevel = 60; send("PLAYER_LEVEL_UP")')
        self.assertFalse(bar['shown'])


if __name__ == '__main__':
    unittest.main()
