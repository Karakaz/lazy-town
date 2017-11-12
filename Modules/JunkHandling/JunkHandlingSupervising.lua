
function JunkHandling:OnInitialize()
  self:GeneralSetup('junk')
  self:CreateScanningTooltip()
end

function JunkHandling:CreateScanningTooltip()
  self.tooltip = CreateFrame("GameTooltip", "JunkHandling_Tooltip", nil, "GameTooltipTemplate")
  self.tooltip:SetScript("OnTooltipAddMoney", function(self, copper)  JunkHandling.itemValue = copper or 0  end)
end

function JunkHandling:OnEnable()
  self:UpdateSellMethod()
  self:UpdateDeleteMethod()
  self:UpdateDisenchanting(true)
end

function JunkHandling:OnDisable()
  self:UndoSellSetup()
  self:UndoDeleteSetup()
  self:UpdateDisenchanting()
end

function JunkHandling:UndoSellSetup()
  self:UnregisterEvent('MERCHANT_SHOW')
  if self.sellButton then self.sellButton:Hide() end
end

function JunkHandling:UndoDeleteSetup()
  if not self.db.DE.enabled then
    self:UnregisterEvent('BAG_UPDATE')
  end
  self:UnregisterEvent('UI_ERROR_MESSAGE')
  self:UnregisterEvent('QUEST_COMPLETE')
  self:UnregisterEvent('LOOT_OPENED')
  self:Unhook('LootFrame_OnEvent')
  if self.deleteButton then 
    self.deleteButton:Hide()
    self:Unhook(ContainerFrame1, 'OnShow')
  end
  if self.deletedBucket then
    self:UnregisterBucket(self.deletedBucket)
    self.deletedBucket = nil
  end
end

function JunkHandling:UpdateSellMethod()
  if not self:IsEnabled() then return end
  self:UndoSellSetup()

  if self.db.sellMethod == 'auto' then
    self:RegisterEvent('MERCHANT_SHOW', "SellJunk")
  elseif self.db.sellMethod == 'button' then
    if self.sellButton then
      self.sellButton:Show()
    else
      self:CreateMerchantButton()
    end
  end
end

function JunkHandling:CreateMerchantButton()
  self.sellButton = CreateFrame('Button', "JunkHandler_SellButton", MerchantFrame, 'OptionsButtonTemplate')
  self.sellButton:SetText("Sell Junk")
  self.sellButton:SetScale(1.05)
  self.sellButton:SetPoint('TOPRIGHT', MerchantFrame, 'TOPRIGHT', -40, -40)
  self.sellButton:SetScript('OnClick', function(self, button, down) JunkHandling:SellJunk() end)
end

function JunkHandling:UpdateDeleteMethod()
  local dbJunk = self.db
  self:UndoDeleteSetup()
  if self:IsEnabled() and dbJunk.del.enabled then
    
    if not self.deletedBucket then
      self.deletedBucket = self:RegisterBucketMessage('JUNK_ITEM_DELETED', 0.01)
    end
  
    if dbJunk.del.howToDelete == 'autoAfter' then
      self:UpdateToAutoAfter(dbJunk)
    elseif dbJunk.del.howToDelete == 'autoBefore' then
      self:UpdateToAutoBefore(dbJunk)
    elseif dbJunk.del.howToDelete == 'button' then
      self:UpdateToButton(dbJunk)
    end
  end
end

function JunkHandling:UpdateToAutoAfter(dbJunk)
  self:RegisterEvent('UI_ERROR_MESSAGE')
end

function JunkHandling:UpdateToAutoBefore(dbJunk)
  self.freeSlots = self:CalcNrFreeSlots()
  self:RegisterEvent('BAG_UPDATE')
  if dbJunk.del.clearForQuest then
    self:RegisterEvent('QUEST_COMPLETE')
  end
  if dbJunk.del.clearForLoot then
    self:RegisterEvent('LOOT_OPENED')
    self:RawHook('LootFrame_OnEvent', true)
  end
  if dbJunk.del.oneOpen then
    if self.freeSlots == 0 then
      self:DeleteXJunkItems(1)
    end
  end
end

function JunkHandling:UpdateToButton(dbJunk)
  if not self.deleteButton then
    self:CreateBasicDeleteButton()
  end

  if dbJunk.del.bags == 'original' then
    self:SetUpForOriginal()
  elseif dbJunk.del.bags == 'bagnon' then
    self:SetUpForBagnon()
  end
  self:UpdateDeleteButtonText()
end

function JunkHandling:CreateBasicDeleteButton()
  self.deleteButton = CreateFrame('Button', "JunkHandler_DeleteButton", UIParent, 'OptionsButtonTemplate')
  self.deleteButton:SetScale(0.85)
  self.deleteButton:SetScript('OnClick', function(self, button, down) JunkHandling:DeleteXJunkItems(JunkHandling.db.del.nrItems) end)
  self.deleteButton:SetScript('OnLeave', function(self) GameTooltip:Hide() end)
  self.deleteButton:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
                                                        GameTooltip:SetText("Deletes X junk items from all your bags.")
                                                        GameTooltip:Show() end)
end

function JunkHandling:SetUpForOriginal()
  self.deleteButton:SetParent(ContainerFrame1)
  self.deleteButton:SetPoint('TOPRIGHT', -8, -33)
  self.deleteButton:SetFrameLevel(ContainerFrame1:GetFrameLevel() + 1)
  self:SecureHookScript(ContainerFrame1, 'OnShow', "ContainerFrame1_OnShow")
  if not ContainerFrame1:IsShown() then
    self.deleteButton:Hide()
  end
end

function JunkHandling:ContainerFrame1_OnShow(frame)
  if ContainerFrame1Name:GetText() == "Backpack" then
    self.deleteButton:Show()
  else
    self.deleteButton:Hide()
  end
end

function JunkHandling:SetUpForBagnon()
  if not BagnonFrame0 then
    if Bagnon then
      Bagnon:CreateInventory()
    else
      self:Print(LazyTown:GetChat(), self:GenerateWrongAddonString("Bagnon"))
      return
    end
  end
  self.deleteButton:SetParent(BagnonFrame0)
  self.deleteButton:SetPoint('BOTTOM', 5, 6)
  self.deleteButton:SetWidth(50)
end

function JunkHandling:GenerateWrongAddonString(addonName)
  return "Could not find " .. addonName .. ". Please make sure it is installed properly " ..
          "or change the 'Using which bag layout' setting to the correct bag addon."
end

function JunkHandling:UpdateDeleteButtonText()
  if self.deleteButton then
    if self.db.del.bags == 'original' then
      self.deleteButton:SetText("Clear " .. self.db.del.nrItems .. " items")
    else
      self.deleteButton:SetText("Clear " .. self.db.del.nrItems)
    end
  end
end

function JunkHandling:QualityFilterUpdated()
  if self.db.DE.enabled and self.db.DE.whatToDE.useFilter then
    self:UpdateDisenchanting(true)
  end
end
