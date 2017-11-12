
function TooltipExtras:OnInitialize()
  self:GeneralSetup('tooltip')
  self.sellValue = {show = false, count = 1}
  self.partA = {}
  self.partB = {}
end

function TooltipExtras:OnEnable()
  self:Update('all')
  self:AnchorSetupIfNeeded()
end

function TooltipExtras:AnchorSetupIfNeeded()
  if self.db.anchor == 'custom' and not self.anchor then
    self:CreateCustomAnchor()
  elseif self.db.anchor == 'onMouse' and not self.timer then
    self:CreateTimer()
  end
end

function TooltipExtras:CreateTimer()
  local f = CreateFrame('Frame', "TooltipExtrasTimerFrame", UIParent)
  f:Hide()
  f:SetScript('OnUpdate', self.TimerOnUpdate)
  self.timer = f
end

function TooltipExtras.TimerOnUpdate(frame, elapsed)
  if frame.unit and frame.unit ~= UnitGUID('mouseover') then
    frame:Hide()
    GameTooltip:Hide()
  else
    local mouseX, mouseY = GetCursorPosition()
    GameTooltip:SetPoint('BOTTOMLEFT', UIParent, mouseX + 40, mouseY + 20)
  end
end

function TooltipExtras:OnDisable()
  self:UndoAll()
  self:UnhookAll()
end

function TooltipExtras:UndoAll()
  self:UpdateScale(1)
  self:UpdateBackdrop('Blizzard Tooltip')
  self:UpdateFont('Friz Quadrata TT')
  self:UpdateHealthBar('Blizzard')
  self:UpdateHealthText(true)
end

function TooltipExtras:Update(what)
  if self:IsEnabled() then
    if what == 'all' then
      self:HookTooltips()
      self:UpdateScale()
      self:UpdateBackdrop()
      self:UpdateFont()
      self:UpdateHealthBar()
      self:UpdateHealthText()
    elseif what == 'hooks' then
      self:HookTooltips()
    elseif what == 'scale' then
      self:UpdateScale()
    elseif what == 'backdrop' then
      self:UpdateBackdrop()
    elseif what == 'font' then
      self:UpdateFont()
    elseif what == 'healthBar' then
      self:UpdateHealthBar()
    elseif what == 'healthText' then
      self:UpdateHealthText()
    end
  end
end

function TooltipExtras:HookTooltips()
  self:UnhookAll()

  local GT, IRT, WMT = GameTooltip, ItemRefTooltip, WorldMapTooltip
  self:HookScript(GT, 'OnTooltipSetUnit')
  self:RawHookScript(GT, 'OnTooltipSetDefaultAnchor')
--  self:HookScript(GT, 'OnTooltipSetItem')
  self:HookScript(GT, 'OnHide')

  self:HookScript(GT, 'OnShow')
  self:HookScript(IRT, 'OnShow')
  self:HookScript(WMT, 'OnShow')

  if self.db.sellValue.enabled then
    self:HookSellValueMethods(GT)
    self:Hook(IRT, 'SetHyperlink', true)
  end
end

function TooltipExtras:HookSellValueMethods(GT)
  self:Hook(GT, 'SetAction', true)
  self:Hook(GT, 'SetAuctionItem', true)
  self:Hook(GT, 'SetAuctionSellItem', true)
  self:Hook(GT, 'SetBagItem', true)
  self:Hook(GT, 'SetCraftItem', true)
  self:Hook(GT, 'SetGuildBankItem', true)
--  self:Hook(GT, 'SetHyperlink', true)
  self:Hook(GT, 'SetInboxItem', true)
  self:Hook(GT, 'SetInventoryItem', true)
  self:Hook(GT, 'SetLootItem', true)
  self:Hook(GT, 'SetLootRollItem', true)
  self:Hook(GT, 'SetMerchantCostItem', true)
  self:Hook(GT, 'SetMerchantItem', true)
  self:Hook(GT, 'SetQuestItem', true)
  self:Hook(GT, 'SetQuestLogItem', true)
  self:Hook(GT, 'SetSendMailItem', true)
  self:Hook(GT, 'SetSocketedItem', "RegisterItem", true)
  self:Hook(GT, 'SetExistingSocketGem', "RegisterItem", true)
  self:Hook(GT, 'SetSocketGem', "RegisterItem", true)
  self:Hook(GT, 'SetTradePlayerItem', true)
  self:Hook(GT, 'SetTradeSkillItem', true)
  self:Hook(GT, 'SetTradeTargetItem', true)
end

function TooltipExtras:UpdateScale(scale)
  if not scale then scale = self.db.scale end
  GameTooltip:SetScale(scale)
  ItemRefTooltip:SetScale(scale)
  WorldMapTooltip:SetScale(scale)
end

function TooltipExtras:UpdateBackdrop(border)
  local borderPath = LazyTown:Media('border', border or self.db.border)
  self:SetBackdropOnTooltip(GameTooltip, borderPath)
  self:SetBackdropOnTooltip(ItemRefTooltip, borderPath)
  self:SetBackdropOnTooltip(WorldMapTooltip, borderPath)
end

function TooltipExtras:SetBackdropOnTooltip(tooltip, borderPath)
  tooltip:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                       edgeFile = borderPath,
                       tile = true, tileSize = 16, edgeSize = 16,
                       insets = {left = 4, right = 4, top = 4, bottom = 4}})
end

function TooltipExtras:UpdateFont(font)
  local newFont = LazyTown:Media('font', font or self.db.font)
  self:SetFontOnTooltip("GameTooltip", newFont)
  self:SetFontOnTooltip("ItemRefTooltip", newFont)
  self:SetFontOnTooltip("WorldMapTooltip", newFont)
end

function TooltipExtras:SetFontOnTooltip(tooltipName, font)
  for i = 1, 8 do
    _G[tooltipName .. "TextLeft" .. i]:SetFont(font, i == 1 and 14 or 12)
    _G[tooltipName .. "TextRight" .. i]:SetFont(font, i == 1 and 14 or 12)
  end
end

function TooltipExtras:UpdateHealthBar(barTexture)
  GameTooltipStatusBarTexture:SetTexture(LazyTown:Media('statusbar', barTexture or self.db.barTexture))
end

function TooltipExtras:UpdateHealthText(disabled)
  if not disabled and self.db.health.enabled then
    if self.healthText then
      self.healthText:Show()
    else
      self:CreateHealthText()
    end
    self.healthText:SetFont(LazyTown:Media('font', self.db.health.font), 11)
    self.healthText:SetTextColor(unpack(self.db.health.textColor))
  else
    if self.healthText then
      self.healthText:Hide()
    end
  end
end

function TooltipExtras:CreateHealthText()
  local f = CreateFrame('Frame', "GameTooltip_HealthTextFrame", GameTooltipStatusBar)
  self.healthText = GameTooltip:CreateFontString("GameTooltip_HealthText", 'ARTWORK', 'GameFontNormal')
  self.healthText:SetParent(f)
  self.healthText:SetPoint('CENTER', GameTooltipStatusBarTexture, 0, 0.5)
end

function TooltipExtras:ToggleCustomAnchor()
  if self.anchor then
    if self.anchor:IsShown() then
      self.anchor:Hide()
    else
      self.anchor:Show()
    end
  else
    self:CreateCustomAnchor()
    self.anchor:Show()
  end
end

function TooltipExtras:CreateCustomAnchor()
  local name = "TooltipExtras_CustomAnchor"
  local a = CreateFrame('Frame', name, UIParent)
  a.db = self.db
  LazyTown.RestoreAllPoints(a)
  a:SetWidth(125)
  a:SetHeight(25)
  a:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                 tile = true, tileSize = 8, edgeSize = 12, insets = {left = 2, right = 2, top = 2, bottom = 2}})
  a:SetBackdropColor(0.1, 0.1, 0.2, 1)
  a:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
  a:SetMovable(1)
  a:EnableMouse(1)
  a:SetToplevel(1)
  a:SetClampedToScreen(1)
  a:Hide()

  a:SetScript('OnMouseDown', function(self, button) self:StartMoving() end)
  a:SetScript('OnMouseUp', function(self, button) self:StopMovingOrSizing() LazyTown.SaveAllPoints(self) end)

  a.text = a:CreateFontString(name .. "Title", 'ARTWORK','GameFontHighlight')
  a.text:SetText("TooltipAnchor")
  a.text:SetPoint('LEFT', 10, 0)

  a.close = CreateFrame('Button', name .. "CloseButton", a, 'UIPanelCloseButton')
  a.close:SetPoint('RIGHT')
  a.close:SetWidth(28)
  a.close:SetHeight(28)
  a.close:SetHitRectInsets(5, 5, 5, 5)

  self.anchor = a
end
