
local JunkHandling = _G.JunkHandling

local moduleOptions = {
  name = function(info) return LazyTown:ApplyStateColor("Junk Handling", JunkHandling.db.enabled) end,
  handler = JunkHandling,
  disabled = LazyTown.IsDisabled,
  type = 'group',
  childGroups = 'tab',
  args = {
    enabled = {
      name = "Enabled",
      order = 10,
      type = 'toggle',
      set = "SetModuleState",
      get = function(info) return JunkHandling.db.enabled end,
    },

    generalGroup = {
      name = "General",
      order = 40,
      type = 'group',
      args = {
        sellMethod = {
          name = "Method of selling",
          order = 20,
          width = 'double',
          type = 'select',
          values = {
            auto = "Auto-sell",
            button = "Vendor button",
          },
          set = function(info, val) JunkHandling.db.sellMethod = val JunkHandling:UpdateSellMethod()end,
          get = function(info) return JunkHandling.db.sellMethod end,
        },
        printSoldItems = {
          name = "Print items sold",
          order = 40,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.printSold = val end,
          get = function(info) return JunkHandling.db.printSold end,
        },
        printRecap = {
          name = "Print gold recap",
          order = 50,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.printRecap = val end,
          get = function(info) return JunkHandling.db.printRecap end,
        },

        exceptionGroup = {
          name = "Item Exceptions",
          type = 'group',
          inline = true,
          args = {
            exceptionInput = {
              name = "Input",
              desc = "Case sensitive. Supports dragging and dropping of items on it.",
              order = 10,
              type = 'input',
              set = function(info, val) JunkHandling.currentInput = val:match("^%s*(.-)%s*$") end,
              get = function(info) return JunkHandling.currentInput end,
            },
            exceptionKeep = {
              name = "Keep (or mark as junk)",
              desc = "Label as keep vs. label as junk",
              order = 15,
              type = 'toggle',
              set = function(info, val) JunkHandling.db.labelAsKeep = val end,
              get = function(info) return JunkHandling.db.labelAsKeep end,
            },
            exceptionAdd = {
              name = "Add",
              desc = "Add item to exception list",
              order = 20,
              type = 'execute',
              func = "AddToExceptionList",
            },
            exceptionRemove = {
              name = "Remove",
              desc = "Remove item from exception list",
              order = 30,
              type = 'execute',
              func = "RemoveFromExceptionLists",
            },
            exceptionPrint = {
              name = "Print exception lists",
              desc = "Print the exception lists to chat",
              order = 40,
              type = 'execute',
              func = "PrintExceptionLists",
            },
            exceptionClearKeep = {
              name = "Del keep",
              desc = "Clears the keep exception list",
              order = 50,
              width = 'half',
              confirm = true,
              type = 'execute',
              func = "ClearKeepList",
            },
            exceptionClearJunk = {
              name = "Del junk",
              desc = "Clears the junk exception list",
              order = 60,
              width = 'half',
              confirm = true,
              type = 'execute',
              func = "ClearJunkList",
            },
          },
        },
        logGroup = {
          name = "Log",
          type = 'group',
          inline = true,
          args = {
            logPrint = {
              name = "Print log",
              order = 10,
              desc = "Note: Items that were soulbound will not display that in the tooltips.",
              type = 'execute',
              func = "PrintLog",
            },
            logValuePrint = {
              name = "Print value log",
              order = 30,
              type = 'execute',
              func = "PrintValueLog",
            },
            logNrPrintLines = {
              name = "# print lines",
              order = 20,
              type = 'range',
              step = 1,
              min = 1,
              max = 50,
              set = function(info, val) JunkHandling.db.logLines = val end,
              get = function(info) return JunkHandling.db.logLines end,
            },
            logFromIndex = {
              name = "Print from index",
              order = 40,
              type = 'range',
              step = 1,
              min = 1,
              max = 100,
              set = function(info, val) JunkHandling.db.logIndex = val end,
              get = function(info) return JunkHandling.db.logIndex end,
            },
          },
        },
      },
    },

    qualityGroup = {
      name = "Quality filter",
      order = 50,
      type = 'group',
      args = {
        -- inserted near end of file
      },
    },
    deleteGroup = {
      name = "Delete",
      order = 60,
      type = 'group',
      args = {
        enable = {
          name = "Enable deleting of items",
          order = 10,
--          width = 'double',
          type = 'toggle',
          set = function(info, val) JunkHandling.db.del.enabled = val JunkHandling:UpdateDeleteMethod() end,
          get = function(info) return JunkHandling.db.del.enabled end,
        },
        printDeletedItems = {
          name = "Print deleted items",
          order = 15,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.del.print = val end,
          get = function(info) return JunkHandling.db.del.print end,
        },
        howHeader = {
          name = "HOW",
          order = 120,
          type = 'header',
        },
        howDescription = {
          name = function(info)
                   if JunkHandling.db.del.howToDelete == 'button' then
                     return "Creates a button in your backpack for easy junk destruction."
                   elseif JunkHandling.db.del.howToDelete == 'autoBefore' then
                     return "Automatically deletes junk when you need those slots for other items."
                   elseif JunkHandling.db.del.howToDelete == 'autoAfter' then
                     return "Automatically deletes X junk items when you receive the '" .. ERR_INV_FULL .. "' error message."
                   end
                 end,
          order = 125,
          type = 'description',
        },
        howToDelete = {
          name = "How to delete",
          order = 130,
          type = 'select',
          values = {
            button = "Button in backpack",
            autoBefore = "Auto (BEFORE bags full)",
            autoAfter = "Auto (AFTER bags full)",
          },
          set = function(info, val) JunkHandling.db.del.howToDelete = val JunkHandling:UpdateDeleteMethod() end,
          get = function(info) return JunkHandling.db.del.howToDelete end,
        },
        usingWhichBags = {
          name = "Using which bag layout",
          desc = "If you are using wow's original bags or something created in an addon",
          order = 160,
          hidden = function(info) return JunkHandling.db.del.howToDelete ~= 'button' end,
          type = 'select',
          values = {
            original = "Original WoW bags",
            bagnon = "Bagnon",
          },
          set = function(info, val) JunkHandling.db.del.bags = val JunkHandling:UpdateDeleteMethod() end,
          get = function(info) return JunkHandling.db.del.bags end,
        },
        nrItems = {
          name = "# items to delete",
          order = 150,
          hidden = function(info) return JunkHandling.db.del.howToDelete == 'autoBefore'  end,
          type = 'range',
          step = 1,
          min = 1,
          max = 10,
          set = function(info, val) JunkHandling.db.del.nrItems = val JunkHandling:UpdateDeleteButtonText() end,
          get = function(info) return JunkHandling.db.del.nrItems end,
        },
        clearForQuest = {
          name = "Clear for quest",
          desc = "Clear just enough to complete your quest",
          order = 150,
          hidden = function(info) return JunkHandling.db.del.howToDelete ~= 'autoBefore' end,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.del.clearForQuest = val JunkHandling:UpdateDeleteMethod() end,
          get = function(info) return JunkHandling.db.del.clearForQuest end,
        },
        clearForLoot = {
          name = "Clear for loot*",
          desc = "Clear just enough junk to pick up all the non-junk in the current loot. " ..
                  "*Only works for manual looting. See auto loot below for auto looting.",
          order = 160,
          hidden = function(info) return JunkHandling.db.del.howToDelete ~= 'autoBefore' end,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.del.clearForLoot = val JunkHandling:UpdateDeleteMethod() end,
          get = function(info) return JunkHandling.db.del.clearForLoot end,
        },
        autoloot = {
          name = "Auto Loot*",
          desc = "*For this to work you HAVE TO disable 'Auto Loot' in the regular options. The addon will auto loot for you.",
          order = 170,
          hidden = function(info) return JunkHandling.db.del.howToDelete ~= 'autoBefore' end,
          disabled = function(info) return not JunkHandling.db.del.clearForLoot end,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.del.autoloot = val JunkHandling:UpdateDeleteMethod() end,
          get = function(info) return JunkHandling.db.del.autoloot end,
        },
        autolootModifier = {
          name = "Auto Loot key*",
          desc = "*For this to work you HAVE TO set the 'Auto Loot Key' to 'None' in the regular options.",
          order = 180,
          hidden = function(info) return JunkHandling.db.del.howToDelete ~= 'autoBefore' end,
          disabled = function(info) return not JunkHandling.db.del.clearForLoot end,
          type = 'select',
          values = {
            none = "None",
            shift = "Shift",
            ctrl = "Control",
            alt = "Alt",
          },
          set = function(info, val) JunkHandling.db.del.modifierKey = val end,
          get = function(info) return JunkHandling.db.del.modifierKey end,
        },
        alwaysOneOpen = {
          name = "Always one slot open",
          desc = "Always keep one container slot open (so you can receive items from master looter among other things)",
          order = 140,
          hidden = function(info) return JunkHandling.db.del.howToDelete ~= 'autoBefore' end,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.del.oneOpen = val JunkHandling:UpdateDeleteMethod() end,
          get = function(info) return JunkHandling.db.del.oneOpen end,
        },
        whatHeader = {
          name = "WHAT",
          order = 20,
          type = 'header',
        },
        whatToDelete = {
          name = "What to delete",
          order = 30,
          type = 'select',
          values = {
            useFilter = "Use quality filter",
            onlyGray = "Only gray items",
          },
          set = function(info, val) JunkHandling.db.del.whatToDelete = val end,
          get = function(info) return JunkHandling.db.del.whatToDelete end,
        },
        delOrder = {
          name = "Deleting order",
          order = 40,
          hidden = function(info) return JunkHandling.db.del.whatToDelete ~= 'useFilter' end,
          type = 'select',
          values = {
            cheapestFirst = "Cheapest first",
            lowQualityFirst = "Lowest quality first",
          },
          set = function(info, val) JunkHandling.db.del.order = val end,
          get = function(info) return JunkHandling.db.del.order end,
        },
        neverSpecialItems = {
          name = "Never delete items that cannot be sold to a merchant",
          desc = "This is for special items like the Hearthstone, various quest items and so on",
          order = 50,
          width = 'full',
          type = 'toggle',
          set = function(info, val) JunkHandling.db.del.notSpecial = val end,
          get = function(info) return JunkHandling.db.del.notSpecial end,
        },
        neverOverXWorth = {
          name = function(info) return "Never over " .. JunkHandling.db.del.worth / 10000 .. " gold" end,
          desc = "Never delete items worth more than X gold",
          order = 60,
          type = 'range',
          step = 1,
          min = 1,
          max = 50,
          set = function(info, val) JunkHandling.db.del.worth = val * 10000 end,
          get = function(info) return JunkHandling.db.del.worth / 10000 end,
        },
      },
    },
    disenchantGroup = {
      name = "Disenchant",
      order = 70,
      type = 'group',
      args = {
        dontSellOrDelete = {
          name = "Never sell or delete items that can be disenchanted",
          order = 5,
          width = 'double',
          type = 'toggle',
          set = function(info, val) JunkHandling.db.DE.neverSellOrDelete = val end,
          get = function(info) return JunkHandling.db.DE.neverSellOrDelete end,
        },
        DEWigetHeader = {
          name = "Disenchant Wiget settings",
          order = 10,
          type = 'header',
        },
        enableDisenchantWiget = {
          name = "Enable Wiget",
          desc = "Enables a small tool that shows up when you have (junk) items that you can disenchant. (Requires Enchanting) " ..
                  "Can be moved by dragging with right mouse button.",
          order = 15,
          disabled = function(info) return JunkHandling:GetEnchantingLevel() == nil or not JunkHandling.db.enabled end,
          type = 'toggle',
          set = function(info, val) JunkHandling.db.DE.enabled = val JunkHandling:UpdateDisenchanting(true) end,
          get = function(info) return JunkHandling.db.DE.enabled end,
        },
        disenchantWigetScale = {
          name = "Scale",
          order = 25,
          disabled = function(info) return not JunkHandling.db.DE.enabled end,
          type = 'range',
          step = 0.01,
          min = 0.4,
          max = 1.6,
          set = function(info, val) JunkHandling.db.DE.scale = val DisenchantWiget:SetScale(val) end,
          get = function(info) return JunkHandling.db.DE.scale end,
        },
        frameStrata = {
          name = "Frame strata",
          order = 20,
          disabled = function(info) return not JunkHandling.db.DE.enabled end,
          type = 'select',
          values = {
            BACKGROUND = 'BACKGROUND',
            LOW = 'LOW',
            MEDIUM = 'MEDIUM',
            HIGH = 'HIGH',
            DIALOG = 'DIALOG',
            FULLSCREEN = 'FULLSCREEN',
            FULLSCREEN_DIALOG = 'FULLSCREEN_DIALOG',
            TOOLTIP = 'TOOLTIP',
          },
          set = function(info, val) JunkHandling.db.DE.frameStrata = val DisenchantWiget:SetFrameStrata(val) end,
          get = function(info) return JunkHandling.db.DE.frameStrata end,
        },
        alpha = {
          name = "Alpha",
          order = 27,
          disabled = function(info) return not JunkHandling.db.DE.enabled end,
          type = 'range',
          step = 0.01,
          min = 0.25,
          max = 1,
          set = function(info, val) JunkHandling.db.DE.alpha = val
                                    if not DisenchantWiget.fadeTimer and DisenchantWiget:GetAlpha() ~= 0 then
                                      DisenchantWiget:SetAlpha(val) end end,
          get = function(info) return JunkHandling.db.DE.alpha end,
        },
        whatToDisenchant = {
          name = "What to disenchant with wiget",
          order = 30,
          type = 'multiselect',
          values = {
            useFilter = "Use Quality Filter",
            uncommon = ITEM_QUALITY_COLORS[2].hex .. "Uncommon|r",
            rare = ITEM_QUALITY_COLORS[3].hex .. "Rare|r",
            epic = ITEM_QUALITY_COLORS[4].hex .. "Epic|r",
          },
          set = function(info, key, val)  local whatToDE = JunkHandling.db.DE.whatToDE   whatToDE[key] = val
                                          if whatToDE.useFilter and key == 'useFilter' then
                                          whatToDE.uncommon = false  whatToDE.rare = false whatToDE.epic = false
                                          elseif whatToDE.uncommon or whatToDE.rare or whatToDE.epic then whatToDE.useFilter = false end
                                          JunkHandling:UpdateDisenchanting(true) end,
          get = function(info, key) return JunkHandling.db.DE.whatToDE[key] end,
        },
        minLevel = {
          name = "Min Item Level",
          order = 40,
          type = 'range',
          step = 1,
          min = 1,
          max = 164,
          set = function(info, val) JunkHandling.db.DE.minLevel = val JunkHandling:UpdateDisenchanting(true) end,
          get = function(info) return JunkHandling.db.DE.minLevel end,
        },
        maxLevel = {
          name = "Max Item Level",
          order = 50,
          type = 'range',
          step = 1,
          min = 1,
          max = 164,
          set = function(info, val) JunkHandling.db.DE.maxLevel = val JunkHandling:UpdateDisenchanting(true) end,
          get = function(info) return JunkHandling.db.DE.maxLevel end,
        },
        itemsPlayerCanDE = {
          name = "Only show items you can disenchant",
          desc = "Based on your enchanting rank, can you disenchant item X?",
          order = 35,
          width = 'double',
          type = 'toggle',
          set = function(info, val) JunkHandling.db.DE.playerCanDE = val JunkHandling:UpdateDisenchanting(true) end,
          get = function(info) return JunkHandling.db.DE.playerCanDE end,
        },
      },
    },
  },
}

local q = {
  {name = "poor",     Name = "Poor",     slang = "gray",   Slang = "Gray"},
  {name = "common",   Name = "Common",   slang = "white",  Slang = "White"},
  {name = "uncommon", Name = "Uncommon", slang = "green",  Slang = "Green"},
  {name = "rare",     Name = "Rare",     slang = "blue",   Slang = "Blue"},
  {name = "epic",     Name = "Epic",     slang = "purple", Slang = "Purple"},
}

for i = 1, 5 do
  moduleOptions.args.qualityGroup.args[q[i].name .. "Group"] = {
    name = ITEM_QUALITY_COLORS[i-1].hex .. q[i].Name .. "|r",
    order = i * 10,
    type = 'group',
    inline = true,
    args = {
      sell = {
        name = function(info) return JunkHandling.db.del.enabled and JunkHandling.db.del.whatToDelete == 'useFilter' and
                                      "Sell & Delete " .. q[i].Slang or "Sell " .. q[i].Slang end,
        desc = "Gets rid of ALL " .. q[i].slang .. " items unless an additional filter is used",
        order = 10,
        type = 'toggle',
        set = function(info, val) JunkHandling.db[q[i].name]["sell"] = val JunkHandling:QualityFilterUpdated() end,
        get = function(info) return JunkHandling.db[q[i].name]["sell"] end,
      },
      soulbound = {
        name = "Only soulbounded",
        desc = "Weapons and gear that is soulbounded",
        order = 20,
        disabled = function(info) return not JunkHandling.db[q[i].name]["sell"] end,
        type = 'toggle',
        set = function(info, val) JunkHandling.db[q[i].name]["soulbound"] = val JunkHandling:QualityFilterUpdated() end,
        get = function(info) return JunkHandling.db[q[i].name]["soulbound"] end,
      },
      equip = {
        name = "Only non-equipable",
        desc = "Weapons and gear that your character cannot equip, e.g. plate on priests",
        order = 40,
        disabled = function(info) return not JunkHandling.db[q[i].name]["sell"] end,
        type = 'toggle',
        set = function(info, val) JunkHandling.db[q[i].name]["equip"] = val JunkHandling:QualityFilterUpdated() end,
        get = function(info) return JunkHandling.db[q[i].name]["equip"] end,
      },
      bestArmor = {
        name = "All but best armor",
        desc = "Will sell armor not fit for your class, e.g. mail on warriors (from lvl 45+)",
        order = 30,
        disabled = function(info) return not JunkHandling.db[q[i].name]["sell"] or
                                         not JunkHandling.db[q[i].name]["equip"] end,
        type = 'toggle',
        set = function(info, val) JunkHandling.db[q[i].name]["bestArmor"] = val JunkHandling:QualityFilterUpdated() end,
        get = function(info) return JunkHandling.db[q[i].name]["bestArmor"] end,
      },
    },
  }
end

LazyTown:AddModuleOptions("junkHandlingGroup", moduleOptions)
