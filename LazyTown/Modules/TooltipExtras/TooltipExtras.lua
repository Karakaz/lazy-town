
function TooltipExtras:OnTooltipSetUnit(tooltip)
  local name, unit = tooltip:GetUnit()
  if not unit then return end
  
  if self.db.health.enabled then
    self:GetAndSetHealthText(unit)
  end

  if self.db.unitBorderStyle ~= 'none' then
    self:SetTooltipColor(unit, self.db.unitBorderStyle, tooltip.SetBackdropBorderColor, 0.75)
    self.borderColored = true
  elseif self.db.unitBackgroundStyle ~= 'none' then
    self:SetTooltipColor(unit, self.db.unitBackgroundStyle, tooltip.SetBackdropColor, 0.3)
    self.backgroundColored = true
  end
end

function TooltipExtras:GetAndSetHealthText(unit)
  if unit then
--    self:Print("GetAndSetHealthText(" .. tostring(unit) .. ")")
    local health = UnitHealth(unit)
    local max = UnitHealthMax(unit)
    if self.db.health.format == 'normal' then        self.healthText:SetText(health .. " / " .. max)
    elseif self.db.health.format == 'remaining' then self.healthText:SetText(health)
    elseif self.db.health.format == 'missing' then   self.healthText:SetText(max == health and '' or max - health)
    end
  end
end

function TooltipExtras:SetTooltipColor(unit, style, colorFunction, strength)
  local hostile = UnitIsEnemy('player', unit)
  local friend = UnitIsFriend('player', unit)
  local isPlayer = UnitIsPlayer(unit)
  local _, class, r, g, b

  if isPlayer then
    _, class = UnitClass(unit)
    r, g, b = RAID_CLASS_COLORS[class].r * strength, RAID_CLASS_COLORS[class].g * strength, RAID_CLASS_COLORS[class].b * strength
  end

  if style == 'classHos' then
    if isPlayer then    colorFunction(GameTooltip, r, g, b)
    elseif hostile then colorFunction(GameTooltip, 0.66 * strength, 0.13 * strength, 0.13 * strength, 1)
    elseif friend then  colorFunction(GameTooltip, 0.13 * strength, 0.66 * strength, 0.13 * strength, 1)
    else                colorFunction(GameTooltip, 0.66 * strength, 0.66 * strength, 0.13 * strength, 1)
    end
  elseif style == 'class' then
    if isPlayer then colorFunction(GameTooltip, r, g, b)
    end
  elseif style == 'hos' then
    if hostile then    colorFunction(GameTooltip, 0.66 * strength, 0.13 * strength, 0.13 * strength, 1)
    elseif friend then colorFunction(GameTooltip, 0.13 * strength, 0.66 * strength, 0.13 * strength, 1)
    else               colorFunction(GameTooltip, 0.66 * strength, 0.66 * strength, 0.13 * strength, 1)
    end
  elseif style == 'hosClass' then
    if hostile then      colorFunction(GameTooltip, 0.66 * strength, 0.13 * strength, 0.13 * strength, 1)
    elseif isPlayer then colorFunction(GameTooltip, r, g, b)
    elseif friend then   colorFunction(GameTooltip, 0.13 * strength, 0.66 * strength, 0.13 * strength, 1)
    else                 colorFunction(GameTooltip, 0.66 * strength, 0.66 * strength, 0.13 * strength, 1)
    end
  end
end

function TooltipExtras:OnTooltipSetDefaultAnchor(tooltip, parent, ...)
  if self.db.anchor == 'default' then
    self.hooks[tooltip]['OnTooltipSetDefaultAnchor'](tooltip, parent, ...)
  elseif self.db.anchor == 'custom' then
    tooltip:SetOwner(self.anchor, 'ANCHOR_TOPRIGHT')
    tooltip.default = 1
  elseif self.db.anchor == 'onMouse' then
    self:AnchorOnCurMousePos(tooltip)
    tooltip.default = 1
  elseif self.db.anchor == 'atMouse' then
    tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
    local mouseX, mouseY = GetCursorPosition()
    GameTooltip:SetPoint('BOTTOMLEFT', UIParent, mouseX + 40, mouseY + 20)
    tooltip.default = 1
  end
end

function TooltipExtras:AnchorOnCurMousePos(tooltip)
    tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
    self.timer:Show()
    if UnitExists('mouseover') then
      self.timer.unit = UnitGUID('mouseover')
    end
end

function TooltipExtras:OnHide(tooltip)
  if self.db.anchor == 'onMouse' then
    self.timer:Hide()
    self.timer.unit = nil
  end
end

function TooltipExtras:OnShow(tooltip)
  local itemLink = self.sellValue.link or select(2, tooltip:GetItem())

  if itemLink then
    self:AddItemInfo(tooltip, itemLink)
    if self.db.borderAsItem then  self:AddBorderAsItem(tooltip, itemLink)  self.borderColored = true  end
    if self.db.backgroundAsItem then  self:AddBackgroundAsItem(tooltip, itemLink)  self.backgroundColored = true  end
  end

  if not self.borderColored then
    tooltip:SetBackdropBorderColor(unpack(self.db.borderColor))
  end
  if not self.backgroundColored then
    tooltip:SetBackdropColor(unpack(self.db.backgroundColor))
  end
  self.borderColored = false
  self.backgroundColored = false
end

function TooltipExtras:AddBorderAsItem(tooltip, itemLink)
  local color = JunkHandling:ColorFromItemLink(itemLink)
  tooltip:SetBackdropBorderColor(color.r * 0.75, color.g * 0.75, color.b * 0.75)
end

function TooltipExtras:AddBackgroundAsItem(tooltip, itemLink)
  local color = JunkHandling:ColorFromItemLink(itemLink)
  tooltip:SetBackdropColor(color.r * 0.2, color.g * 0.2, color.b * 0.2)
end
