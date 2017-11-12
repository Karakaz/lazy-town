
function LazyTown:EnableAllModules()
  for name, module in self:IterateModules() do
    module:SetModuleState(true, module)
  end
end

function LazyTown:DisableAllModules()
  for name, module in self:IterateModules() do
    module:SetModuleState(false)
  end
end

function LazyTown:UpdateMinimapButton(disable)
  if not disable and self.db.profile.minimapButton.enabled then
    if self.minimapButton then
      self.minimapButton:Show()
    else
      self:CreateMinimapButton()
    end
  else
    if self.minimapButton then
      self.minimapButton:Hide()
    end
  end
end

function LazyTown:CreateMinimapButton()
  local minimapButtonName = "LazyTownMinimapButton"
  local f = CreateFrame('Button', minimapButtonName, Minimap)
  self.minimapButton = f
  self:UpdateMinimapButtonPosition()

  f:SetFrameLevel(MinimapBackdrop:GetFrameLevel() + 1)
  f:SetWidth(32)
  f:SetHeight(32)
  f:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", 'ADD')
  f:SetScript('OnClick', function(self, button) LazyTown:OpenOptions() end)

  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForClicks('AnyUp')
  f:RegisterForDrag('RightButton')

  f:SetScript('OnDragStart', function(self, button)  self:LockHighlight()  self.draggingFrame:Show()  end)
  f:SetScript('OnDragStop', function(self, button)  self:UnlockHighlight()  self.draggingFrame:Hide()  end)

  local df = CreateFrame('Frame', minimapButtonName .. "DraggingFrame")
  df:SetScript('OnUpdate', self.DraggingFrameOnUpdate)
  df:Hide()
  f.draggingFrame = df

  local t = f:CreateTexture(minimapButtonName .. "Icon", 'ARTWORK')
  t:SetTexture("Interface\\AddOns\\LazyTown\\Textures\\LazyTownIconRound")
  t:SetPoint('TOPLEFT', 5.5, -5.5)
  t:SetWidth(20)
  t:SetHeight(20)

  t = f:CreateTexture(minimapButtonName .. "Border", 'OVERLAY')
  t:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  t:SetPoint('TOPLEFT')
  t:SetWidth(52)
  t:SetHeight(52)
end

function LazyTown:UpdateMinimapButtonPosition()
  local pos = self.db.profile.minimapButton.position
  LazyTown.minimapButton:SetPoint('TOPLEFT', Minimap, 'TOPLEFT', 52 - (80 * cos(pos)), (80 * sin(pos)) - 52)
end

function LazyTown.DraggingFrameOnUpdate(draggingFrame, elapsed)
  local self = LazyTown
  local posX, posY = GetCursorPosition()
  local mapX, mapY = Minimap:GetLeft(), Minimap:GetBottom()

  posX = mapX - posX / UIParent:GetScale() + 70
  posY = posY / UIParent:GetScale() - mapY - 70

  self.db.profile.minimapButton.position = math.deg(math.atan2(posY, posX))
  self:UpdateMinimapButtonPosition()
end

function LazyTown:CreateMacro()
  if InCombatLockdown() then
    self:Print(self:GetChat(), "Cannot create macros while in combat. Try again later.")
    return
  end

  local name = "LazyTown"
  local body = "/lazytown"
  local iconTexture = "Interface\\Icons\\LazyTownIcon"
  local iconIndex = self:GetMacroIconIndex(iconTexture, "Interface\\Icons\\Spell_Nature_TimeStop")

  local nameM, iconTextureM, bodyM = GetMacroInfo(name)

  if nameM then
    if nameM ~= name or iconTextureM ~= iconTexture or bodyM ~= body then
      EditMacro(name, name, iconIndex, body, true, false)
    end
  else
    local nrGlobal, nrPerChar = GetNumMacros()
    if nrGlobal < 18 then
      CreateMacro(name, iconIndex, body, true, false)
    elseif nrPerChar < 18 then
      CreateMacro(name, iconIndex, body, true, true)
      self:Print(self:GetChat(), "Created character spesific macro (Not enough space in global macros).")
    else
      self:Print(self:GetChat(), "Not enough space to create more macros.")
    end
  end
  ClearCursor()
  PickupMacro(name)
end

function LazyTown:GetMacroIconIndex(iconTexture, defaultTexture)
  local icon, defaultIndex
  local GetMacroIconInfo = GetMacroIconInfo
  for i = 1, GetNumMacroIcons() do
    icon = GetMacroIconInfo(i)
    if icon == iconTexture then
      return i
    elseif icon == defaultTexture then
      defaultIndex = i
    end
  end
  return defaultIndex or 1
end
