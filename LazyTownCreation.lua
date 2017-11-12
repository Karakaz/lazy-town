
------------------------------------------------------------------------------------------
---------------------------------   PROTOTYPE SETUP  -------------------------------------
------------------------------------------------------------------------------------------

local prototype = {}

function prototype:SetModuleState(infoOrState, valOrNil)
  local state = type(valOrNil) == 'nil' and infoOrState or valOrNil
  if state then
    self.db.enabled = true
    self:Enable()
  else
    self.db.enabled = false
    self:Disable()
  end
end

function prototype:GeneralSetup(tag, dbSubtable)
  self.tag = tag
  self.db = (dbSubtable or LazyTown.db.profile)[tag]

  if self.RawHook then
    self:InstallLazyHooks() --I prefer this functionality over ace's standard implementation
  end

  self:SetEnabledState(self.db.enabled)
end

function prototype:InstallLazyHooks()
  self.AceHook             = self.Hook
  self.AceHookScript       = self.HookScript
  self.AceRawHook          = self.RawHook
  self.AceRawHookScript    = self.RawHookScript
  self.AceSecureHook       = self.SecureHook
  self.AceSecureHookScript = self.SecureHookScript
  self.AceUnhook           = self.Unhook

  local func =  function(self, expression, method, ...)
                  if expression then
                    self["Ace" .. method](self, ...)
                  elseif LazyTown.db.profile.debug then
                    local s = (method == "Unhook" and "non-existing" or "already active")
                    local debugString = debugstack(3, 1, 0)
                    local locationInfo = debugString:match("\\([^\\]-\.lua.-)\n") or debugString
                    self:Print(LazyTown:GetChat(), format("Attempting to %s() %s hook. %s", method, s, locationInfo))
                  end
                end

  self.Hook             = function(self, ...) func(self, not self:IsHooked(...), "Hook",             ...) end
  self.HookScript       = function(self, ...) func(self, not self:IsHooked(...), "HookScript",       ...) end
  self.RawHook          = function(self, ...) func(self, not self:IsHooked(...), "RawHook",          ...) end
  self.RawHookScript    = function(self, ...) func(self, not self:IsHooked(...), "RawHookScript",    ...) end
  self.SecureHook       = function(self, ...) func(self, not self:IsHooked(...), "SecureHook",       ...) end
  self.SecureHookScript = function(self, ...) func(self, not self:IsHooked(...), "SecureHookScript", ...) end
  self.Unhook           = function(self, ...) func(self, self:IsHooked(...),     "Unhook",           ...) end
end

------------------------------------------------------------------------------------------
-----------------------------------   GLOBAL DEFS  ---------------------------------------
------------------------------------------------------------------------------------------

LazyTown = LibStub('AceAddon-3.0'):NewAddon("LazyTown", 'AceConsole-3.0')

LazyTown:SetDefaultModulePrototype(prototype)
LazyTown:SetDefaultModuleLibraries('AceConsole-3.0')

LTAutomation     = LazyTown:NewModule("LTAutomation", 'AceBucket-3.0', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0')
BlackBoxPanels   = LazyTown:NewModule("BlackBoxPanels", 'AceTimer-3.0')
ErrorSuppression = LazyTown:NewModule("ErrorSuppression", 'AceHook-3.0')
JunkHandling     = LazyTown:NewModule("JunkHandling", 'AceBucket-3.0', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0')
LTMisc           = LazyTown:NewModule("LTMisc", 'AceBucket-3.0', 'AceEvent-3.0', 'AceHook-3.0')
MoveNameplates   = LazyTown:NewModule("MoveNameplates", 'AceHook-3.0')
StockUp          = LazyTown:NewModule("StockUp", 'AceEvent-3.0')
TooltipExtras    = LazyTown:NewModule("TooltipExtras", 'AceHook-3.0', 'AceTimer-3.0')
LTViewport       = LazyTown:NewModule("LTViewport", 'AceBucket-3.0')

LTMisc:SetDefaultModulePrototype(prototype)
LTMisc:SetDefaultModuleLibraries('AceConsole-3.0')

DurabilityPercent = LTMisc:NewModule("DurabilityPercent", 'AceEvent-3.0', 'AceHook-3.0')
LTItemGlow        = LTMisc:NewModule("LTItemGlow", 'AceBucket-3.0', 'AceEvent-3.0', 'AceHook-3.0')

------------------------------------------------------------------------------------------
-------------------------------   LOCAL & OBJECT DEFS  -----------------------------------
------------------------------------------------------------------------------------------

LazyTown.defaults = {
  global = {
    cvarDefaults = {},
    consoleDefaults = {
      detailDoodadAlpha = "1",
      characterAmbient = "1",
    },
  },
  profile = {
--  LazyTown settings  ------------------------------------------------------------------
    enabled = true,
    chat = 'DEFAULT_CHAT_FRAME',
    minimapButton = {enabled = false, position = 90},
    startupMessage = true,
    ultraDetails = false,
    cvars = {},
    console = {
      detailDoodadAlpha = "1",
      characterAmbient = "1",
    },

--  Module settings  ---------------------------------------------------------------------
    auto = {
      enabled = false,
      repair = true,
      repairGuild = false,
      repairPrint = false,
      releaseBG = false,
      releaseTime = 2,
      confirmBOP = true,
      confirmRoll = false,
      confirmReplace = true,
      sameEnchant = true,
      qAccept = false,
      objTooltip = {enabled = false, points = {}, scale = 0.9, alpha = 0.9, timeBeforeFade = 10, fadeTime = 6},
      qTurnIn = false,
      qConfirm = false,
      whoParty = true,
      autoAccept = {Friends = false, Guild = false},
      blockDuels = false,
      blockTrades = false,
      blockGInvites = false,
      blockGPetitions = false,
      duelsFilter = 'friendsGuild',
      tradesFilter = 'friendsGuild',
      gInvitesFilter = 'friends',
      gPetitionsFilter = 'friends',
      takeSaleGold = false,
      takeOutbidGold = false,
      takeBoughtItems = false,
      takeExpiredItems = false,
      takeCancelledItems = false,
      printSummary = false,
      ressAccept = false,
      ressTime = 45,
      ressCombat = false,
      ressPersist = false,
      summonAccept = false,
      summonTime = 90,
      summonCombat = true,
      summonCombatTime = 10,
      summonOverride = true,
    },
    boxPanels = {
      enabled = false,
      locked = false,
      boxes = {
      --all boxes are stored with these variables:
      --{
      --  id
      --  name
      --  box
      --  x
      --  y
      --  width
      --  height
      --  background
      --  border
      --  backgroundColor
      --  borderColor
      --  factor
      --  show
      --  showName
      --  strata
      --  level
      --}
      },
    },
    error = {
      enabled = false,
      what = 'mostFrequent',
      when = 'always',
      sound = true,
      filterCustom = {},
      filterExact = {
        [ERR_ABILITY_COOLDOWN] = true,        --"Ability is not ready yet."
        [ERR_AUTOFOLLOW_TOO_FAR] = true,      --"Target is too far away."
        [ERR_BADATTACKFACING] = true,         --"You are facing the wrong way!"
        [ERR_CLIENT_LOCKED_OUT] = false,      --"You can't do that right now."
        [ERR_GENERIC_NO_TARGET] = false,      --"You have no target."
        [ERR_GENERIC_STUNNED] = true,         --"You are stunned"
        [ERR_INVALID_ATTACK_TARGET] = false,  --"You cannot attack that target."
        [ERR_ITEM_COOLDOWN] = true,           --"Item is not ready yet."
        [ERR_NOEMOTEWHILERUNNING] = true,     --"You can't do that while moving!"
        [ERR_NOT_IN_COMBAT] = false,          --"You can't do that while in combat"
        [ERR_NOT_WHILE_DISARMED] = false,     --"You can't do that while disarmed"
        [ERR_NOT_WHILE_MOUNTED] = false,      --"You can't do that while mounted."
        [ERR_NO_ATTACK_TARGET] = false,       --"There is nothing to attack."
        [ERR_OUT_OF_ENERGY] = true,           --"Not enough energy"
        [ERR_OUT_OF_FOCUS] = true,            --"Not enough focus"
        [ERR_OUT_OF_MANA] = true,             --"Not enough mana"
        [ERR_OUT_OF_RAGE] = true,             --"Not enough rage"
        [ERR_OUT_OF_RANGE] = true,            --"Out of range."
        [ERR_SPELL_COOLDOWN] = true,          --"Spell is not ready yet."
        [ERR_USE_BAD_ANGLE] = false,          --"You aren't facing the right angle!"
        [ERR_USE_CANT_IMMUNE] = false,        --"You can't do that while you are immune."
        [INTERRUPTED] = true,                 --"Interrupted"
        [SPELL_FAILED_BAD_IMPLICIT_TARGETS] = false,--"No target"
        [SPELL_FAILED_BAD_TARGETS] = false,   --"Invalid target"
        [SPELL_FAILED_CASTER_AURASTATE] = true,--"You can't do that yet"
        [SPELL_FAILED_NOT_INFRONT] = true,    --"You must be in front of your target."
        [SPELL_FAILED_NOT_IN_CONTROL] = true, --"You are not in control of your actions"
        [SPELL_FAILED_NOT_MOUNTED] = false,   --"You are mounted."
        [SPELL_FAILED_NOT_ON_TAXI] = false,   --"You are in flight"
        [SPELL_FAILED_NO_COMBO_POINTS] = true,--"That ability requires combo points"
        [SPELL_FAILED_NO_ENDURANCE] = false,  --"Not enough endurance"
        [SPELL_FAILED_MOVING] = true,         --"Can't do that while moving"
        [SPELL_FAILED_SPELL_IN_PROGRESS] = true,--"Another action is in progress"
        [SPELL_FAILED_TARGETS_DEAD] = false,  --"Your target is dead"
      },
      filterStartsWidth = {
        ["Can't attack while"] = true,
        ["You are too far away"] = true,
      },
    },
    junk = {
      enabled = false,
      sellMethod = 'auto',
      labelAsKeep = true,
      junkList = {},
      keepList = {},
      log = {},
      logLines = 10,
      logIndex = 1,
      printSold = false,
      printRecap = true,
      count = {
        all = 0,
        poor = 0,
        common = 0,
        uncommon = 0,
        rare = 0,
        epic = 0,
        deleted = 0,
      },
      value = {
        all = 0,
        poor = 0,
        common = 0,
        uncommon = 0,
        rare = 0,
        epic = 0,
        deleted = 0,
      },
      del = {
        enabled = false,
        print = true,
        whatToDelete = 'onlyGray',
        howToDelete = 'button',
        bags = 'original',
        clearForQuest = true,
        clearForLoot = true,
        autoloot = false,
        modifierKey = 'none',
        oneOpen = true,
        notSpecial = true,
        nrItems = 3,
        order = 'cheapestFirst',
        worth = 100000,
      },
      DE = {
        neverSellOrDelete = false,
        enabled = false,
        points = {},
        frameStrata = 'MEDIUM',
        alpha = 1,
        scale = 1,
        minLevel = 1,
        maxLevel = 100,
        playerCanDE = true,
        exceptions = {["Lesser Magic Wand"] = true, ["Greater Magic Wand"] = true,
                      ["Lesser Mystic Wand"] = true, ["Greater Mystic Wand"] = true},
        whatToDE = {
          useFilter = true,
          uncommon = false,
          rare = false,
          epic = false,
        },
      },
      poor = {
        sell = true,
        soulbound = false,
        equip = false,
        bestArmor = false,
      },
      common = {
        sell = true,
        soulbound = true,
        equip = true,
        bestArmor = true,
      },
      uncommon = {
        sell = true,
        soulbound = true,
        equip = true,
        bestArmor = true,
      },
      rare = {
        sell = true,
        soulbound = true,
        equip = true,
        bestArmor = true,
      },
      epic = {
        sell = false,
        soulbound = false,
        equip = false,
        bestArmor = false,
      },
    },
    misc = {
      enabled = false,
      questLevels = false,
      onlyLevel = false,
      arenaPoints = false,
      hideMacroText = false,
      hideHotKeyText = false,
      gryphonAlpha = 1,
      classIconPortraits = false,
      zoneLevels = false,
      coordinates = false,
      precision = 1,
      mapAlpha = 1,
      backgroundAlpha = 1,
      hideCloseButton = false,
      hideMapButton = false,
      hideNorth = false,
      hideTimeButton = false,
      hideZoom = false,
      scrollZoom = false,
      bagType = 'original',
      checkboxDelete = false,
      checkboxDisenchant = false,
      checkboxProspect = false,
      grid = false,
      boxWidth = 80,
      boxHeight = 80,
      gridFourths = false,
      gridWhite = false,
      itemGlow = {
        enabled = false,
        gearOnly = false,
        where = {bank = true, char = true, containers = true, craft = true, eqBags = false, guildBank = true,
                       inspect = true, mail = true, merch = true, trade = true, tradeSkill = true},
      },
      durability = {
        enabled = false,
        percent = true,
        inverted = false,
        threshold = 100,
        font = "Arial Narrow",
        fontSize = 11.75,
      },
    },
    moveNP = {
      enabled = false,
      xOff = 0,
      yOff = 0,
      clickable = true,
    },
    stockUp = {
      enabled = false,
      autoSell = false,
      fullPercent = 0.75,
      customStacks = 1,
      custom = {},
      reagentsEnabled = false,
      reagents = { --[[filled in StockUpOptionTable.lua. same with drinks, vials & threads]] },
      hunterAmmo = 'arrows',
      drinksEnabled = false,
      drinks = {},
      vialsEnabled = false,
      vials = {},
      threadsEnabled = false,
      threads = {},
    },
    tooltip = {
      enabled = false,
      anchor = 'default',
      points = {},
      scale = 1,
      font = 'Friz Quadrata TT',
      border = 'Blizzard Tooltip',
      borderColor = {0.25, 0.25, 0.25, 1},
      backgroundColor = {0.15, 0.15, 0.20, 1},
      barTexture = 'Blizzard',
      health = {
        enabled = true,
        format = 'remaining',
        font = 'Friz Quadrata TT',
        textColor = {1, 1, 1},
      },
      unitBorderStyle = 'classHos',
      unitBackgroundStyle = 'none',
      sellValue = {
        enabled = true,
        format = 'collected',
        style = 'coin',
      },
      itemLevel = false,
      stackSize = false,
      itemID = false,
      itemLevelColor = {0.13, 1, 0.66},
      itemIDColor = {0.53, 0.63, 1},
      stackSizeColor = {1, 0.66, 0.2},
      borderAsItem = true,
      backgroundAsItem = false,
    },
    viewport = {
      enabled = false,
      top = 0,
      bottom = 0,
      left = 0,
      right = 0,
      fillStyle = 'solid',
      fillCenter = {0, 0, 0},
      fillEdge = {0, 0, 0},
    },
  },
}
