
function LazyTown:OnInitialize()
  self:SetupDB()
  self:SetupOptions()

  self.Media = LibStub('LibSharedMedia-3.0').Fetch --works since 'self' isn't used in LSM's Fetch method

  self:RegisterChatCommand("lazytown", "OpenOptions")
  self:RegisterChatCommand("lt", "OpenOptions")
  
  self:SetupLibDataBroker()
  
  self:StartupMessage()
  self:SetEnabledState(self.db.profile.enabled)
end

function LazyTown:SetupDB()
  self.db = LibStub("AceDB-3.0"):New("LazyTownDB", self.defaults)
  self.db.RegisterCallback(self, "OnProfileChanged", ReloadUI)
  self.db.RegisterCallback(self, "OnProfileCopied", ReloadUI)
  self.db.RegisterCallback(self, "OnProfileReset", ReloadUI)
  self.defaults = nil
end

function LazyTown:SetupOptions()
  local profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  profile.order = 20
  profile.args.reset.desc = "Resets the current profile to the default. UI-reload is required."
  profile.args.reset.confirm = true

  self.options.args.profile = profile

  LibStub("AceConfig-3.0"):RegisterOptionsTable("LazyTown", self.options)

  self.options = nil
end

function LazyTown:SetupLibDataBroker()
  LibStub('LibDataBroker-1.1'):NewDataObject("LazyTown", {
    type = 'launcher',
    icon = "Interface\\AddOns\\LazyTown\\Textures\\LazyTownIconRound2",
    OnClick = function(clickedframe, button)  LazyTown:OpenOptions()  end,
  })
end

function LazyTown:StartupMessage()
  if self.db.profile.startupMessage then
    self:Print(self:GetChat(), "Welcome to LazyTown! To open configuration, type /lazytown")
  end
end

function LazyTown:OnEnable()
  self.db.profile.enabled = true
  self:UpdateMinimapButton()
  self:UpdateTechnical()
end

function LazyTown:OnDisable()
  self.db.profile.enabled = false
  self:UpdateMinimapButton(true)
  self:SetCVars(self.db.global.cvarDefaults)
  self:SetConsoleVars(self.db.global.consoleDefaults)
end

function LazyTown:IsDisabled()
  return not LazyTown:IsEnabled()
end

function LazyTown:OpenOptions(...)
  LibStub("AceConfigDialog-3.0"):Open("LazyTown")
  if select('#', ...) >= 1 then
    LibStub("AceConfigDialog-3.0"):SelectGroup("LazyTown", ...)
  end
end

function LazyTown:GetChat()
  local chat = getglobal(LazyTown.db.profile.chat)
  if chat then
    return chat
  else
    LazyTown.db.profile.chat = 'DEFAULT_CHAT_FRAME'
    return DEFAULT_CHAT_FRAME
  end
end

function LazyTown:ApplyStateColor(text, state)
  if self:IsEnabled() then
    if state then
      return '|cFF6FC536' .. text .. '|r'
    else
      return '|cFFDD4444' .. text .. '|r'
    end
  else
    return '|cFF666666' .. text .. '|r'
  end
end
