
function JunkHandling:ColorFromItemLink(itemLink)
  return self:ColorFromRarity(self:RarityFromItemLink(itemLink))
end

function JunkHandling:ColorFromRarity(rarity)
  return ITEM_QUALITY_COLORS[self.QC[rarity]]
end

function JunkHandling:RarityFromItemLink(itemLink)
  return self.QC[itemLink:match("|cff(%x+)|H")]
end

JunkHandling.QC = { --Quality Conversion
  poor = 0,
  common = 1,
  uncommon = 2,
  rare = 3,
  epic = 4,
  legendary = 5, --legendary is not used by module JunkHandling
  [0] = 'poor',
  [1] = 'common',
  [2] = 'uncommon',
  [3] = 'rare',
  [4] = 'epic',
  [5] = 'legendary',
  ["9d9d9d"] = 'poor',
  ["ffffff"] = 'common',
  ["1eff00"] = 'uncommon',
  ["0070dd"] = 'rare',
  ["a335ee"] = 'epic',
  ["ff8000"] = 'legendary',
}

JunkHandling.Gear = { --Proficiency Class -> Gear
  ALL = {Cloth = 1, Miscellaneous = 1, ['Fishing Poles'] = 1},
  DRUID = {Leather = 1, Idols = 1, ['One-Handed Maces'] = 1, ['Two-Handed Maces'] = 1, Staves = 1, Daggers = 1, ['Fist Weapons'] = 1},
  HUNTER = {Leather = 1, Mail = 30, ['One-Handed Axes'] = 1, ['Two-Handed Axes'] = 1, ['One-Handed Swords'] = 1,
            ['Two-Handed Swords'] = 1, Polearms = 1, Staves = 1, Daggers = 1, ['Fist Weapons'] = 1, Bows = 1, Crossbows = 1,
            Guns = 1, Arrow = 1, Bullet = 1},
  MAGE = {['One-Handed Swords'] = 1, Staves = 1, Daggers = 1, Wands = 1},
  PALADIN = {Leather = 1, Mail = 1, Plate = 30, Shield = 1, Librams = 1, ['One-Handed Axes'] = 1, ['Two-Handed Axes'] = 1,
              ['One-Handed Maces'] = 1, ['Two-Handed Maces'] = 1, ['One-Handed Swords'] = 1, ['Two-Handed Swords'] = 1, Polearms = 1},
  PRIEST = {['One-Handed Maces'] = 1, Staves = 1, Daggers = 1, Wands = 1},
  ROGUE = {Leather = 1, ['One-Handed Axes'] = 1, ['One-Handed Swords'] = 1, ['One-Handed Maces'] = 1, Daggers = 1,
            ['Fist Weapons'] = 1, Bows = 1, Crossbows = 1, Guns = 1, Thrown = 1, Arrow = 1, Bullet = 1},
  SHAMAN = {Leather = 1, Mail = 30, Shield = 1, Totems = 1, ['One-Handed Axes'] = 1, ['Two-Handed Axes'] = 1,
            ['One-Handed Maces'] = 1, ['Two-Handed Maces'] = 1, Staves = 1, Daggers = 1, ['Fist Weapons'] = 1},
  WARLOCK = {['One-Handed Swords'] = 1, Staves = 1, Daggers = 1, Wands = 1},
  WARRIOR = {Leather = 1, Mail = 1, Plate = 30, Shield = 1, ['One-Handed Axes'] = 1, ['Two-Handed Axes'] = 1,
              ['One-Handed Maces'] = 1, ['Two-Handed Maces'] = 1, ['One-Handed Swords'] = 1, ['Two-Handed Swords'] = 1, Polearms = 1,
              Staves = 1, Daggers = 1, ['Fist Weapons'] = 1, Bows = 1, Crossbows = 1, Guns = 1, Thrown = 1, Arrow = 1, Bullet = 1},
  BEST = function(class, level)
          if class == 'DRUID' or class == 'ROGUE' then  return 'Leather' end
          if class == 'MAGE' or class == 'PRIEST' or class == 'WARLOCK' then  return 'Cloth' end
          if class == 'HUNTER' or class == 'SHAMAN' then
            if level < 35 then
              return 'Leather'
            elseif level >= 35 and level < 45 then
              return 'Leather', 'Mail'
            else
              return 'Mail'
            end
          end
          if class == 'PALADIN' or class == 'WARRIOR' then
            if level < 45 then  return 'Mail', 'Plate'
            else  return 'Plate'
            end
          end
          JunkHandling:Print("UNKNOWN CLASS: " .. class)
        end,
}
