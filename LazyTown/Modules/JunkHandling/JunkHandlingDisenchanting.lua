
function JunkHandling:UpdateDisenchanting(allBagsOrSingleBag)
--  self:Print("UpdateDisenchanting()")
  if self.db.DE.enabled and self:IsEnabled() then
    if InCombatLockdown() then
      self:UnregisterDEEvents()
      self:RegisterEvent('PLAYER_REGEN_ENABLED')
    else
      self:DEEnabled(allBagsOrSingleBag)
    end
  else
    self:DEDisabled()
  end
end

function JunkHandling:DEEnabled(allBagsOrSingleBag)
  if DisenchantWiget then
    DisenchantWiget:Show()
    DisenchantWiget.NextButton:Show()
  else
    self:CreateDisenchantWiget()
    allBagsOrSingleBag = true
  end

  self:DoScansIfNeeded(allBagsOrSingleBag)

  DisenchantWiget:Update()
  self:RegisterDEEvents()
end

function JunkHandling:DoScansIfNeeded(allBagsOrSingleBag)
  if type(allBagsOrSingleBag) == 'boolean' and allBagsOrSingleBag then
    self:ScanAllBagsForDEItems()
  elseif type(allBagsOrSingleBag) == 'number' then
    self:ScanBagForDEItems(allBagsOrSingleBag)
  end
end

function JunkHandling:ScanAllBagsForDEItems()
  self.DEItems = {}
  for i = 0, 4 do
    self:ScanBagForDEItems(i)
  end
end

function JunkHandling:ScanBagForDEItems(bag)
  for slot = 1, GetContainerNumSlots(bag) do
    local itemLink = GetContainerItemLink(bag, slot)
    if itemLink and self:ShouldDisenchantItem(itemLink, bag, slot) then
      self:AddDEItem(bag, slot, itemLink)
    else
      self:ClearDEItem(bag, slot)
    end
  end
end

function JunkHandling:ShouldDisenchantItem(itemLink, bag, slot)
  local itemName, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
  local itemRarity = self:RarityFromItemLink(itemLink)

  if self:IsException(itemName) then
    return self:RemoveBasedOnExceptions(itemName)
  end
  if self.db.DE.exceptions[itemName] == true then  return false  end

  if self:ItemIsGear(itemLink, itemEquipLoc) and self:ShouldDEBasedOnLevel(itemRarity, itemLevel) then
    if self.db.DE.whatToDE.useFilter then
      return self:ShouldRemoveItem(itemLink, bag, slot)
    else
      return self.db.DE.whatToDE[itemRarity]
    end
  end
end

function JunkHandling:ShouldDEBasedOnLevel(rarity, iLevel)
  if (iLevel >= self.db.DE.minLevel and iLevel <= self.db.DE.maxLevel or iLevel <= 0) then
    if self.db.DE.playerCanDE then
      return self:HasHighEnoughRankToDE(rarity, iLevel, self:GetEnchantingLevel())
    else
      return true
    end
  end
end

function JunkHandling:GetEnchantingLevel()
  for i = 1, GetNumSkillLines() do
    local skillName, isHeader, _, skillRank = GetSkillLineInfo(i)
    if not isHeader and skillName == "Enchanting" then
      return skillRank
    end
  end
end

function JunkHandling:HasHighEnoughRankToDE(rarity, iLevel, rank)
  if not rank then return end
  if iLevel <= 60 then
    return rank >= 5 * LibStub('KaraLib-1.0'):NextMultiple(iLevel, 5) - 100
  else
    if rarity == 'uncommon' or rarity == 'rare' then
      if iLevel < 100 then
        return rank >= 225
      else
        return rank >= 275
      end
    elseif rarity == 'epic' then
      if iLevel < 90 then
        return rank >= 225
      else
        return rank >= 300
      end
    else
--      self:Print("HasHighEnoughRankToDE(..) Error: Wrong rarity '" .. rarity .. "'")
    end
  end
end

function JunkHandling:AddDEItem(bag, slot, itemLink)
  self:ClearDEItem(bag, slot)
  tinsert(self.DEItems, {bag = bag, slot = slot, itemLink = itemLink, rarity = JunkHandling:RarityFromItemLink(itemLink)})
end

function JunkHandling:ClearDEItem(bag, slot)
  local index = self:GetDEIndexItem(bag, slot)
  if index then
    tremove(self.DEItems, index)
  end
end

function JunkHandling:GetDEIndexItem(bag, slot)
  for i, v in ipairs(self.DEItems) do
    if v.bag == bag and v.slot == slot then
      return i, v
    end
  end
end

function JunkHandling:RegisterDEEvents()
  self:RegisterEvent('BAG_UPDATE')
  self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
  if not self.bag_update_bucket then
    self.bag_update_bucket = self:RegisterBucketMessage("BAG_UPDATE_COLLECTION", 0.25)
  end
end

function JunkHandling:DEDisabled()
  if DisenchantWiget then
    DisenchantWiget:Hide()
  end
  self:UnregisterDEEvents()
end

function JunkHandling:UnregisterDEEvents()
  if self.db.del.howToDelete ~= 'autoAfter' then
    self:UnregisterEvent('BAG_UPDATE')
  end
  self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
  self:UnregisterBucket(self.bag_update_bucket)
  self.bag_update_bucket = nil
end
