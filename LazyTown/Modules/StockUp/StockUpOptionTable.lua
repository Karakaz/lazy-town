
local StockUp = _G.StockUp

local reagents = {
  THREADS = {'Coarse Thread', 'Fine Thread', 'Silken Thread', 'Heavy Silken Thread', 'Rune Thread'},
  VIALS = {'Empty Vial', 'Leaded Vial', 'Crystal Vial', 'Imbued Vial'},
  DRINKS = {['Refreshing Spring Water'] = {1, 4}, ['Ice Cold Milk'] = {5, 14}, ['Melon Juice'] = {15, 24}, ['Sweet Nectar'] = {25, 34},
           ['Moonberry Juice'] = {35, 44}, ['Morning Glory Dew'] = {45, 54}, ["Footman's Waterskin"] = {55, 59},
           ["Grunt's Waterskin"] = {55, 59}, ['Filtered Draenic Water'] = {60, 64}, ['Purified Draenic Water'] = 65,
           ["Star's Lament"] = {55, 64}, ["Star's Tears"] = 65},
  DRUID = {['Maple Seed'] = {20, 29}, ['Stranglethorn Seed'] = {30, 39}, ['Ashwood Seed'] = {40, 49}, ['Hornbeam Seed'] = {50, 59},
           ['Ironwood Seed'] = {60, 68}, ['Flintweed Seed'] = 69, ['Wild Berries'] = {50, 59}, ['Wild Thornroot'] = {60, 69},
           ['Wild Quillvine'] = 70},
  MAGE = {['Rune of Teleportation'] = 20, ['Rune of Portals'] = 40, ['Arcane Powder'] = 56},
  PALADIN = {['Symbol of Divinity'] = 30, ['Symbol of Kings'] = 52},
  PRIEST = {['Holy Candle'] = {48, 59}, ['Sacred Candle'] = 60},
  ROGUE = {['Flash Powder'] = 22, ['Dust of Decay'] = {20, 37}, ['Essence of Pain'] = {20, 47}, Deathweed = 30,
           ['Dust of Deterioration'] = {36, 67}, ['Essence of Agony'] = 38, ["Maiden's Anguish"] = 62},
  SHAMAN = {Ankh = 30},
  WARLOCK = {['Infernal Stone'] = 50, ['Demonic Figurine'] = 60},
  ARROWS = {['Rough Arrow'] = {1, 9}, ['Sharp Arrow'] = {10, 24}, ['Razor Arrow'] = {25, 39}, ['Jagged Arrow'] = {40, 54},
            ['Wicked Arrow'] = {55, 64}, ['Blackflight Arrow'] = 65},
  BULLETS = {['Light Shot'] = {1, 9}, ['Heavy Shot'] = {10, 24}, ['Solid Shot'] = {25, 39}, ['Accurate Slugs'] = {40, 54},
             ['Impact Shot'] = {55, 64}, ['Ironbite Shell'] = 65}
}

local moduleOptions = {
  name = function(info) return LazyTown:ApplyStateColor("Stock Up", StockUp.db.enabled) end,
  handler = StockUp,
  disabled = LazyTown.IsDisabled,
  type = 'group',
  childGroups = 'tab',
  args = {
    enabled = {
      name = "Enabled",
      order = 10,
      type = 'toggle',
      set = "SetModuleState",
      get = function(info) return StockUp.db.enabled end,
    },

    generalGroup = {
      name = "General",
      order = 20,
      type = 'group',
      args = {
        description = {
          name = "Stock Up can automatically buy reagents and other items for you. Select or specify the items you want to buy and they " ..
                 "will be bought as long as the vendor still has them in stock. The addon will buy new stacks untill you have the desired " ..
                 "amount of stacks. It will not fill stacks unless the merchant offers to sell one quantity of the item at a time.",
          order = 5,
          type = 'description',
        },
        autoSell = {
          name = "Sell outdated reagents",
          desc = "Automatically sell reagents you no longer need because of your higher level",
          order = 20,
          type = 'toggle',
          set = function(info, val) StockUp.db.autoSell = val end,
          get = function(info) return StockUp.db.autoSell end,
        },
        fullPercent = {
          name = "Stack full definition %",
          desc = "Consider stacks of X% as full",
          order = 30,
          type = 'range',
          step = 5,
          min = 25,
          max = 100,
          set = function(info, val) StockUp.db.fullPercent = val / 100 end,
          get = function(info) return StockUp.db.fullPercent * 100 end,
        },
        customGroup = {
          name = "Stock custom items",
          order = 50,
          type = 'group',
          inline = true,
          args = {
            customInput = {
              name = "Input",
              desc = "Case sensitive. Supports dragging and dropping of items on it.",
              order = 10,
              type = 'input',
              set = function(info, val) StockUp.currentInput = val:match("^%s*(.-)%s*$") end,
              get = function(info) return StockUp.currentInput end,
            },
            customStacks = {
              name = "# stacks",
              order = 15,
              type = 'range',
              step = 1,
              min = 1,
              max = 20,
              set = function(info, val) StockUp.db.customStacks = val end,
              get = function(info) return StockUp.db.customStacks end,
            },
            customAdd = {
              name = "Add",
              desc = "Add item to custom items list",
              order = 20,
              type = 'execute',
              func = "AddToCustomList",
            },
            customRemove = {
              name = "Remove",
              desc = "Remove item from custom items list",
              order = 30,
              type = 'execute',
              func = "RemoveFromCustomList",
            },
            customPrint = {
              name = "Print custom items list",
              desc = "Print the custom items list to chat",
              order = 40,
              type = 'execute',
              func = "PrintCustomList",
            },
            customClear = {
              name = "Clear list",
              desc = "Clears the entire custom items list",
              order = 50,
              confirm = true,
              type = 'execute',
              func = "ClearCustomList",
            },
          },
        },
      },
    },
    reagentGroup = {
      name = function(info) return StockUp.localizedClass end,
      order = 30,
      type = 'group',
      args = {
        stockReagents = {
          name = "|cffffd100Stock Reagents|r",
          desc = "Automatically buy relevant reagents from vendors based on your level",
          order = 5,
          width = 'double',
          type = 'toggle',
          set = function(info, val) StockUp.db.reagentsEnabled = val end,
          get = function(info) return StockUp.db.reagentsEnabled end,
        },
        stockAmmo = {
          name = "|cffffd100Ammo Type|r",
          order = 10,
          hidden = function(info) return StockUp.class ~= 'HUNTER' end,
          width = 'double',
          type = 'select',
          values = {
            arrows = "Arrows",
            bullets = "Bullets",
          },
          set = function(info, val) StockUp.db.hunterAmmo = val end,
          get = function(info) return StockUp.db.hunterAmmo end,
        },
        --reagents inserted after table definition
      },
    },
    drinkGroup = {
      name = "Drinks",
      order = 40,
      type = 'group',
      args = {
        stockDrinks = {
          name = "|cffffd100Stock Drinks|r",
          desc = "Automatically buy water from vendors",
          order = 10,
          width = 'double',
          type = 'toggle',
          set = function(info, val) StockUp.db.drinksEnabled = val end,
          get = function(info) return StockUp.db.drinksEnabled end,
        },
        --drinks inserted after table definition
      },
    },
    vialGroup = {
      name = "Vials",
      order = 50,
      type = 'group',
      args = {
        stockVials = {
          name = "|cffffd100Stock Vials|r",
          desc = "Automatically buy vials from vendors",
          order = 10,
          width = 'double',
          type = 'toggle',
          set = function(info, val) StockUp.db.vialsEnabled = val end,
          get = function(info) return StockUp.db.vialsEnabled end,
        },
        --vials inserted after table definition
      },
    },
    threadGroup = {
      name = "Threads",
      order = 60,
      type = 'group',
      args = {
        stockThreads = {
          name = "|cffffd100Stock Threads|r",
          desc = "Automatically buy threads from vendors",
          order = 10,
          width = 'double',
          type = 'toggle',
          set = function(info, val) StockUp.db.threadsEnabled = val end,
          get = function(info) return StockUp.db.threadsEnabled end,
        },
        --threads inserted after table definition
      },
    },
  },
}

local defaultStockUp = LazyTown.defaults.profile.stockUp
local count

-------------------------  CLASS REAGENTS & AMMO  ----------------------------------------------------
local c = {
  {Class = "Druid",   CLASS = "DRUID"},
  {Class = "Mage",    CLASS = "MAGE"},
  {Class = "Paladin", CLASS = "PALADIN"},
  {Class = "Priest",  CLASS = "PRIEST"},
  {Class = "Rogue",   CLASS = "ROGUE"},
  {Class = "Shaman",  CLASS = "SHAMAN"},
  {Class = "Warlock", CLASS = "WARLOCK"},
  {Class = "Arrows",  CLASS = "ARROWS", class = 'arrows'},
  {Class = "Bullets", CLASS = "BULLETS", class = 'bullets'},
}
for i = 1, #c do
  count = 1
  defaultStockUp.reagents[c[i].CLASS] = {}
  for reagent, range in pairs(reagents[c[i].CLASS]) do
    moduleOptions.args.reagentGroup.args["reagent" .. c[i].Class .. count] = {
      name = reagent,
      desc = "Buy " .. reagent .. " from level" .. (type(range) == 'number' and " " .. range or "s " .. range[1] .. " to " .. range[2]),
      order = 10000 - (count + 100 * (type(range) == 'number' and range or (range[1] + range[2]) / 2)),
      hidden = function(info) return not (StockUp.class == c[i].CLASS or StockUp.class == 'HUNTER' and StockUp.db.hunterAmmo == c[i].class) end,
      type = 'toggle',
      set = function(info, val) StockUp.db.reagents[c[i].CLASS][reagent].enabled = val end,
      get = function(info) return StockUp.db.reagents[c[i].CLASS][reagent].enabled end,
    }
    moduleOptions.args.reagentGroup.args["reagent" .. c[i].Class .. count .. "Stacks"] = {
      name = "# stacks",
      order = 10000 - (-1 + count + 100 * (type(range) == 'number' and range or (range[1] + range[2]) / 2)),
      hidden = function(info) return not (StockUp.class == c[i].CLASS or StockUp.class == 'HUNTER' and StockUp.db.hunterAmmo == c[i].class) end,
      type = 'range',
      step = 1,
      min = 1,
      max = 5,
      set = function(info, val) StockUp.db.reagents[c[i].CLASS][reagent].stacks = val end,
      get = function(info) return StockUp.db.reagents[c[i].CLASS][reagent].stacks end,
    }
    defaultStockUp.reagents[c[i].CLASS][reagent] = {enabled = true, range = range, stacks = i > 7 and 4 or 1}
    count = count + 1
  end
end

-------------------------  DRINKS  ---------------------------------------------------------
count = 1
for drink, range in pairs(reagents.DRINKS) do
  moduleOptions.args.drinkGroup.args["drink" .. count] = {
    name = drink,
    desc = "Buy " .. drink .. " from level" .. (type(range) == 'number' and " " .. range or "s " .. range[1] .. " to " .. range[2]),
    order = 10000 - (count + 100 * (type(range) == 'number' and range or (range[1] + range[2]) / 2)),
    type = 'toggle',
    set = function(info, val) StockUp.db.drinks[drink].enabled = val end,
    get = function(info) return StockUp.db.drinks[drink].enabled end,
  }
  moduleOptions.args.drinkGroup.args["drink" .. count .. "Stacks"] = {
    name = "# stacks",
    order = 10000 - (-1 + count + 100 * (type(range) == 'number' and range or (range[1] + range[2]) / 2)),
    type = 'range',
    step = 1,
    min = 1,
    max = 8,
    set = function(info, val) StockUp.db.drinks[drink].stacks = val end,
    get = function(info) return StockUp.db.drinks[drink].stacks end,
  }
  defaultStockUp.drinks[drink] = {enabled = true, range = range, stacks = 2}
  count = count + 1
end

-------------------------  VIALS & THREADS  ---------------------------------------------------------
local t = {
  {type = "vial", types = "vials", TYPES = "VIALS"},
  {type = "thread", types = "threads", TYPES = "THREADS"},
}
for i = 1, #t do
  for index, itemName in ipairs(reagents[t[i].TYPES]) do
    moduleOptions.args[t[i].type .. "Group"].args[t[i].type .. index] = {
      name = itemName,
      order = 1000 - (10 + index * 10),
      type = 'toggle',
      set = function(info, val) StockUp.db[t[i].types][itemName].enabled = val end,
      get = function(info) return StockUp.db[t[i].types][itemName].enabled end,
    }
    moduleOptions.args[t[i].type .. "Group"].args[t[i].type .. index .. "Stacks"] = {
      name = "# stacks",
      order = 1000 - (5 + index * 10),
      type = 'range',
      step = 1,
      min = 1,
      max = 5,
      set = function(info, val) StockUp.db[t[i].types][itemName].stacks = val end,
      get = function(info) return StockUp.db[t[i].types][itemName].stacks end,
    }
    defaultStockUp[t[i].types][itemName] = {enabled = false, range = 1, stacks = 1}
  end
end

LazyTown:AddModuleOptions("stockUpGroup", moduleOptions)
