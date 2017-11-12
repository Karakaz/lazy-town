
function ErrorSuppression:OnInitialize()
  self:GeneralSetup('error')
end

function ErrorSuppression:OnEnable()
  self:RawHook("UIErrorsFrame_OnEvent", true)
  self:UpdateErrorSpeech(true)
end

function ErrorSuppression:OnDisable()
  self:Unhook("UIErrorsFrame_OnEvent")
end

function ErrorSuppression:UpdateErrorSpeech(override)
  if self:IsEnabled() or override then
    SetCVar('Sound_EnableErrorSpeech', self.db.sound and 1 or 0)
  end
end

function ErrorSuppression:UpdateErrors()
  local dbError = self.db
  local filterExact = dbError.filterExact
  local filterStartsWidth = dbError.filterStartsWidth

  if dbError.what == 'custom' then return end

  for error, enabled in pairs(filterExact) do
    filterExact[error] = true
  end
  for error, enabled in pairs(filterStartsWidth) do
    filterStartsWidth[error] = true
  end

  if dbError.what == 'mostFrequent' then
    filterExact[ERR_CLIENT_LOCKED_OUT] = false
    filterExact[ERR_GENERIC_NO_TARGET] = false
    filterExact[ERR_INVALID_ATTACK_TARGET] = false
    filterExact[ERR_NOT_IN_COMBAT] = false
    filterExact[ERR_NOT_WHILE_DISARMED] = false
    filterExact[ERR_NOT_WHILE_MOUNTED] = false
    filterExact[ERR_NO_ATTACK_TARGET] = false
    filterExact[ERR_USE_BAD_ANGLE] = false
    filterExact[ERR_USE_CANT_IMMUNE] = false
    filterExact[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = false
    filterExact[SPELL_FAILED_BAD_TARGETS] = false
    filterExact[SPELL_FAILED_NOT_MOUNTED] = false
    filterExact[SPELL_FAILED_NOT_ON_TAXI] = false
    filterExact[SPELL_FAILED_NO_ENDURANCE] = false
    filterExact[SPELL_FAILED_TARGETS_DEAD] = false
  end
end

function ErrorSuppression:PopInput()
  local s = self.currentInput
  self.currentInput = nil
  return s
end

function ErrorSuppression:AddToCustomList()
  local input = self:PopInput()
  if input and input:len() > 0 then
    self.db.filterCustom[input] = true
    self:Print(LazyTown:GetChat(), "Added custom error: " .. input)
  end
end

function ErrorSuppression:RemoveFromCustomList()
  local input = self:PopInput()
  if input and input:len() > 0 then
    self.db.filterCustom[input] = nil
    self:Print(LazyTown:GetChat(), "Removed custom error: " .. input)
  end
end

function ErrorSuppression:ClearCustomList()
  local customErrors = self.db.filterCustom
  if customErrors then
    for k, v in pairs(customErrors) do
      customErrors[k] = nil
    end
  end
end

function ErrorSuppression:PrintCustomList()
  local chat = LazyTown:GetChat()
  local color = "|cffff5555"
  chat:AddMessage(color .. "ErrorSuppression, Custom error/message List:|r")

  local t = {}

  for customError, v in pairs(self.db.filterCustom) do
    table.insert(t, customError)
  end

  if #t == 0 then
    chat:AddMessage(color .. "~~ empty ~~|r")
    return
  end

  table.sort(t)

  for i = 1, #t do
    chat:AddMessage(color .. t[i] .. "|r")
  end
end
