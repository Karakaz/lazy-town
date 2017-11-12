
function LazyTown:UpdateTechnical()
  if not self.technicalInitialized then
    if self:CVarDefaultsNotRegistered() then
      local cvars = self:FetchCVars()
      self:RegisterCVarDefaults(cvars)
    end
    self.technicalInitialized = true
  end
  self:UpdateOptionTableValues()
  self:UpdateUltraDetailsAndSet()
end

function LazyTown:CVarDefaultsNotRegistered()
  return LibStub('KaraLib-1.0'):IsTableEmpty(self.db.global.cvarDefaults)
end

function LazyTown:FetchCVars()
  local cvars = {farclip = true, horizonfarclip = true, targetNearestDistance = true, cameraDistanceMax = true, groundEffectDensity = true,
                 groundEffectDist = true, smallcull = true, skycloudlod = true, violenceLevel = true, screenshotFormat = true, screenshotQuality = true}

  for name, _ in pairs(cvars) do
    cvars[name] = GetCVar(name)
  end
  return cvars
end

function LazyTown:RegisterCVarDefaults(cvars)
  local dbDefaults = self.db.global.cvarDefaults
  local dbCVars = self.db.profile.cvars
  for name, value in pairs(cvars) do
    value = (name == 'screenshotFormat' and value or tonumber(value))
    dbDefaults[name] = value
    dbCVars[name] = value
  end
end

function LazyTown:UpdateOptionTableValues()
  local dbCVars, dbCVarDefaults = self.db.profile.cvars, self.db.global.cvarDefaults
  local cvars = {"farclip", "horizonfarclip", "targetNearestDistance", "cameraDistanceMax", "violenceLevel", "screenshotFormat", "screenshotQuality"}
  for _, name in ipairs(cvars) do
    if not dbCVars[name] then
      dbCVars[name] = dbCVarDefaults[name]
    end
  end
end

function LazyTown:UpdateUltraDetailsAndSet()
  if self.db.profile.ultraDetails then
    self:UpdateToUltra()
  else
    self:UpdateToNormal()
  end
  self:SetCVars()
  self:SetConsoleVars()
end

function LazyTown:UpdateToUltra()
  local dbCVars = self.db.profile.cvars
  local dbConsole = self.db.profile.console
  dbCVars.groundEffectDensity = 256
  dbCVars.groundEffectDist = 140
  dbCVars.smallcull = 0
  dbCVars.skycloudlod = 3
  dbConsole.detailDoodadAlpha = "100"
  dbConsole.characterAmbient = "-0.1"
end

function LazyTown:UpdateToNormal()
  local dbCVars, dbCVarDefaults = self.db.profile.cvars, self.db.global.cvarDefaults
  local dbConsole, dbConsoleDefaults = self.db.profile.console, self.db.global.consoleDefaults
  dbCVars.groundEffectDensity = dbCVarDefaults.groundEffectDensity
  dbCVars.groundEffectDist    = dbCVarDefaults.groundEffectDist
  dbCVars.smallcull           = dbCVarDefaults.smallcull
  dbCVars.skycloudlod         = dbCVarDefaults.skycloudlod
  dbConsole.detailDoodadAlpha = dbConsoleDefaults.detailDoodadAlpha
  dbConsole.characterAmbient  = dbConsoleDefaults.characterAmbient
end

function LazyTown:SetCVars(fromTable)
  for name, value in pairs(fromTable or self.db.profile.cvars) do
    SetCVar(name, value)
  end
end

function LazyTown:SetConsoleVars(fromTable)
  for name, value in pairs(fromTable or self.db.profile.console) do
    ConsoleExec(name .. " " ..  value)
  end
end

function LazyTown:ResetTechnicalToDefaults()
  self.db.profile.ultraDetails = false
  self:ResetCVarsToDefaults()
  self:ResetConsoleVarsToDefaults()
end

function LazyTown:ResetCVarsToDefaults()
  local dbCVars = self.db.profile.cvars
  for name, value in pairs(self.db.global.cvarDefaults) do
    dbCVars[name] = value
    SetCVar(name, value)
  end
end

function LazyTown:ResetConsoleVarsToDefaults()
  local dbConsole = self.db.profile.console
  for name, value in pairs(self.db.global.consoleDefaults) do
    dbConsole[name] = value
    ConsoleExec(name .. " " ..  value)
  end
end
