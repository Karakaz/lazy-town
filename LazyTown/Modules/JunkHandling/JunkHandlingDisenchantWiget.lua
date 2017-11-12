
function JunkHandling:CreateDisenchantWiget()
  local wigetName = "DisenchantWiget"
  local self = CreateFrame('Frame', wigetName, UIParent)

  JunkHandling:CreateDisenchantWigetMethods()
  self.db = JunkHandling.db.DE

  LazyTown.RestoreAllPoints(self)
  self:SetWidth(64)
  self:SetHeight(64)
  self:SetScale(self.db.scale)
  self:SetAlpha(0)
  self:SetHitRectInsets(5, 5, 5, 5)
  self:EnableMouse(true)
  self:SetMovable(true)
  self:RegisterForDrag("RightButton")
  self:SetScript("OnDragStart", function(self) self:StartMoving() end)
  self:SetScript("OnDragStop", function(self)  self:StopMovingOrSizing() LazyTown.SaveAllPoints(self) end)
  self:SetScript('OnLeave', function(self) GameTooltip:Hide() end)

  self.borderTexture = self:CreateTexture(wigetName .. "BorderTexture", 'BORDER')
  self.borderTexture:SetTexture("Interface\\AddOns\\LazyTown\\Textures\\DEWigetBorder")
  self.borderTexture:SetAllPoints()

  self.itemTexture = self:CreateTexture(wigetName .. "ItemTexture", 'BORDER')
  self.itemTexture:SetPoint('CENTER', 1, 1)
  self.itemTexture:SetWidth(46)
  self.itemTexture:SetHeight(46)

  local deButton = CreateFrame('Button', wigetName .. "DEButton", self, "SecureActionButtonTemplate")
  deButton:SetPoint('BOTTOMLEFT')
  deButton:SetWidth(28)
  deButton:SetHeight(28)
  deButton:SetHitRectInsets(2, 2, 2, 2)
  deButton:SetHighlightTexture("Interface\\AddOns\\LazyTown\\Textures\\UI-GroupLoot-DE-Highlight", 'ADD')
  deButton:SetNormalTexture("Interface\\AddOns\\LazyTown\\Textures\\UI-GroupLoot-DE-Up")
  deButton:SetPushedTexture("Interface\\AddOns\\LazyTown\\Textures\\UI-GroupLoot-DE-Down")
  deButton:SetAttribute('type', 'spell')
  deButton:SetAttribute('spell', 'Disenchant')

  local needButton = CreateFrame('Button', wigetName .. "NeedButton", self)
  needButton:SetPoint('BOTTOMRIGHT', -2, 1)
  needButton:SetWidth(22)
  needButton:SetHeight(22)
  needButton:SetHitRectInsets(1, 0, 1, 2)
  needButton:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", 'ADD')
  needButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
  needButton:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Down")
  needButton:SetScript('OnClick', function() JunkHandling:AddToExceptionList(nil, DisenchantWiget.curItem.name, true) end)

  local nextButton = CreateFrame('Button', wigetName .. "NextButton", self)
  nextButton:SetPoint('TOPLEFT', 3, -3)
  nextButton:SetWidth(20)
  nextButton:SetHeight(20)
  nextButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", 'ADD')
  nextButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
  nextButton:SetScript('OnClick', function() GameTooltip:Hide() DisenchantWiget:RollNextItem() JunkHandling:UpdateDisenchanting()
                                             DisenchantWiget.NextButton:GetScript('OnEnter')(DisenchantWiget.NextButton) end)
  nextButton:SetScript('OnLeave', function(self) GameTooltip:Hide() end)

  self.nextBorderTexture = nextButton:CreateTexture(wigetName .. "NextBorderTexture")--, 'BORDER')
  self.nextBorderTexture:SetTexture("Interface\\AddOns\\LazyTown\\Textures\\DEWigetBorder2")
  self.nextBorderTexture:SetPoint('TOPLEFT', -6, 6)
  self.nextBorderTexture:SetWidth(34)
  self.nextBorderTexture:SetHeight(34)

  self.nextItemTexture = nextButton:CreateTexture(wigetName .. "NextItemTexture")--, 'BORDER')
  self.nextItemTexture:SetAllPoints()

  local numberButton = CreateFrame('Button', wigetName .. "NumberButton", self)
  numberButton:SetPoint('TOPRIGHT', 4, 3)
  numberButton:SetWidth(33)
  numberButton:SetHeight(33)
  numberButton:SetHitRectInsets(2, 2, 2, 2)
  numberButton:SetNormalTexture("Interface\\AddOns\\LazyTown\\Textures\\DEWigetNumberFrame")
  numberButton:SetScript('OnClick', function() DisenchantWiget:RollNextRarity() JunkHandling:UpdateDisenchanting() end)
  numberButton:SetScript('OnLeave', function(self) GameTooltip:Hide() end)
  numberButton:SetScript('OnEnter', function(self) local DEW = DisenchantWiget
                    DEW:CalcNumberQualityItems()
                    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
                    if DEW.nrEpics > 0 then GameTooltip:AddLine(ITEM_QUALITY_COLORS[4].hex .. DEW.nrEpics .. "|r") end
                    if DEW.nrRares > 0 then GameTooltip:AddLine(ITEM_QUALITY_COLORS[3].hex .. DEW.nrRares .. "|r") end
                    if DEW.nrUncommons > 0 then GameTooltip:AddLine(ITEM_QUALITY_COLORS[2].hex .. DEW.nrUncommons .. "|r") end
                    GameTooltip:Show() end)

  self.numberText = numberButton:CreateFontString(wigetName .. "NumberText", 'OVERLAY', "GameFontNormal")
  self.numberText:SetPoint('CENTER')
  self.numberText:SetTextColor(1, 1, 0.8, 1)

  self.DEButton = deButton
  self.NeedButton = needButton
  self.NextButton = nextButton
  self.NumberButton = numberButton

  self.curIndex = 1
end

function JunkHandling:CreateDisenchantWigetMethods()

  function DisenchantWiget:EvaluateDEItems()
    self:EvaluateDEItem(self.curItem)
    self:EvaluateDEItem(self.nextItem)
  end

  function DisenchantWiget:EvaluateDEItem(itemTable)
    if itemTable and (itemTable.keep ~= JunkHandling.db.keepList[itemTable.name] or
                      itemTable.junk ~= JunkHandling.db.junkList[itemTable.name]) then
      if not JunkHandling:ShouldDisenchantItem(itemTable.link, itemTable.bag, itemTable.slot) then
        JunkHandling:ClearDEItem(itemTable.bag, itemTable.slot)
      end
    end
  end

  function DisenchantWiget:Update()
    if self.hasNewIndex then
      self.hasNewIndex = false
    else
      self:EvaluateDEItems()
    end

    local DEItems = JunkHandling.DEItems
    local len = #DEItems

    self.numberText:SetText(len)

    local index = (self.curIndex <= len and self.curIndex or 1)

    if len >= 1 then
      self:UpdateItem(DEItems[index].bag, DEItems[index].slot, DEItems[index].itemLink)
      if self:GetAlpha() ~= self.db.alpha then
        self:Fade('in')
      end
    else
      if self:GetAlpha() ~= 0 then
        self:Fade('out')
      end
    end

    if len >= 2 then
      index = (index == len and 1 or index + 1)
      self:UpdateNextItem(DEItems[index].bag, DEItems[index].slot, DEItems[index].itemLink)
    elseif len == 1 then
      self.NextButton:Hide()
    end
  end

  function DisenchantWiget:UpdateItem(bag, slot, itemLink)
    self.curItem = self:CreateItemTable(bag, slot, itemLink)

    self.itemTexture:SetTexture(self.curItem.texture)
    self:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_TOP')
                                             GameTooltip:SetBagItem(bag, slot)
                                             GameTooltip:Show() end)
    self.DEButton:SetAttribute('target-bag', bag)
    self.DEButton:SetAttribute('target-slot', slot)
  end

  function DisenchantWiget:UpdateNextItem(bag, slot, itemLink)
    self.nextItem = self:CreateItemTable(bag, slot, itemLink)

    self.nextItemTexture:SetTexture(self.nextItem.texture)
    self.NextButton:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_TOP')
                                                        GameTooltip:SetBagItem(bag, slot)
                                                        GameTooltip:Show() end)
  end

  function DisenchantWiget:CreateItemTable(bag, slot, itemLink)
    local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)
    return {name = itemName, link = itemLink, texture = itemTexture,
              bag = bag, slot = slot, keep = JunkHandling.db.keepList[itemName], junk = JunkHandling.db.junkList[itemName]}
  end

  function DisenchantWiget:RollNextItem()
    self.curIndex = (self.curIndex >= #JunkHandling.DEItems and 1 or self.curIndex + 1)
  end

  function DisenchantWiget:RollNextRarity()
    local DEItems = JunkHandling.DEItems
    for i = self.curIndex + 1, #DEItems do
      if self:IsNewRarityIndex(DEItems[self.curIndex].rarity, DEItems[i].rarity) then
        self:SetIndexAndUpdateDisenchanting(i)
        return
      end
    end
    for i = 1, self.curIndex - 1 do
      if self:IsNewRarityIndex(DEItems[self.curIndex].rarity, DEItems[i].rarity) then
        self:SetIndexAndUpdateDisenchanting(i)
        return
      end
    end
  end

  function DisenchantWiget:SetIndexAndUpdateDisenchanting(index)
    self.curIndex = index
    self.hasNewIndex = true
  end

  function DisenchantWiget:IsNewRarityIndex(curRarity, newRarity)
    if curRarity == 'uncommon' and (newRarity == 'rare' or self.nrRares == 0 and newRarity == 'epic') or
       curRarity == 'rare' and (newRarity == 'epic' or self.nrEpics == 0 and newRarity == 'uncommon') or
       curRarity == 'epic' and (newRarity == 'uncommon' or self.nrUncommons == 0 and newRarity == 'rare') then
      return true
    end
  end

  function DisenchantWiget:Fade(inOrOut)
    self.fade = inOrOut

    if inOrOut == 'in' then self:Show() end

    if not self.fadeTimer then
      self.fadeTimer = JunkHandling:ScheduleRepeatingTimer(self.FadeMethod,  0.1, self)
    end
  end

  function DisenchantWiget:FadeMethod()
    local alpha = self:GetAlpha()
    if self.fade == 'in' then
      if alpha > self.db.alpha - 0.01 then
        self:SetAlpha(self.db.alpha)
        self.fade = nil
        JunkHandling:CancelTimer(self.fadeTimer)
        self.fadeTimer = nil
      else
        self:SetAlpha(alpha + 0.03)
      end
    elseif self.fade == 'out' then
      if alpha < 0.01 then
        self:SetAlpha(0)
        self:Hide()
        self.fade = nil
        JunkHandling:CancelTimer(self.fadeTimer)
        self.fadeTimer = nil
      else
        self:SetAlpha(alpha - 0.03)
      end
    end
--    JunkHandling:Print("FadeMethod, alpha=" .. alpha)
  end

  function DisenchantWiget:CalcNumberQualityItems()
    local DEItems = JunkHandling.DEItems
    self.nrEpics = 0
    self.nrRares = 0
    self.nrUncommons = 0
    for i = 1, #DEItems do
      local rarity = DEItems[i].rarity
      if rarity == 'epic' then
        self.nrEpics = self.nrEpics + 1
      elseif rarity == 'rare' then
        self.nrRares = self.nrRares + 1
      elseif rarity == 'uncommon' then
        self.nrUncommons = self.nrUncommons + 1
      end
    end
  end

end
