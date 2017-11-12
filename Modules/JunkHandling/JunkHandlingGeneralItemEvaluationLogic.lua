
function JunkHandling:NeverSellOrDelDisenchantableItems(itemName, itemLink, itemEquipLoc)
  return not (self.db.DE.neverSellOrDelete and self:ItemIsGear(itemLink, itemEquipLoc)) and self.db.DE.exceptions[itemName] ~= true
end

function JunkHandling:RemoveBasedOnExceptions(itemName)
  if self.db.keepList[itemName] then  return false  end
  if self.db.junkList[itemName] then  return true   end
end

function JunkHandling:ShouldRemoveItem(link, bagOrLootIndex, slotOrNil)
  local name, _, _, level, minLevel, type, subType, stackCount, equipLoc, texture = GetItemInfo(link)
  local rarity = self:RarityFromItemLink(link)

  local sellS, soulboundS, equipS = self.db[rarity]['sell'], self.db[rarity]['soulbound'], self.db[rarity]['equip']

  if sellS then
    self:RetreiveTooltipAndValueInfo(link, bagOrLootIndex, slotOrNil)

    if not equipS and not soulboundS then
      return true
    end

    if self:ItemIsGear(link, equipLoc) and self:ShouldRemoveGearItem(rarity, subType, equipLoc) then
      return true
    end
  end
end

function JunkHandling:RetreiveTooltipAndValueInfo(link, bagOrLootIndex, slotOrNil)
  self.itemValue = false
  self:RetreiveTooltipInfo(bagOrLootIndex, slotOrNil)
  if not self.itemValue then
    if slotOrNil then
      self.itemValue = GetSellValue(link) * (select(2, GetContainerItemInfo(bagOrLootIndex, slotOrNil)) or 1)
    else
      self.itemValue = GetSellValue(link) * (select(3, GetLootSlotInfo(bagOrLootIndex)) or 1)
    end
  end
end

function JunkHandling:RetreiveTooltipInfo(bagOrLootIndex, slotOrNil)
  self.tooltip:SetOwner(UIParent, "ANCHOR_NONE")
  if slotOrNil then
    self.tooltip:SetBagItem(bagOrLootIndex, slotOrNil) --This also triggers OnTooltipAddMoney
  else
    self.tooltip:SetLootItem(bagOrLootIndex)
  end
  self.itemSoulbound = JunkHandling_TooltipTextLeft2:GetText()
  self.tooltip:Hide()
end

function JunkHandling:ItemIsGear(link, equipLoc)
  return IsEquippableItem(link) and not (equipLoc == 'INVTYPE_BAG' or equipLoc == 'INVTYPE_QUIVER' or
                                         equipLoc == 'INVTYPE_BODY' or equipLoc == 'INVTYPE_TABARD')
end

function JunkHandling:ShouldRemoveGearItem(rarity, subType, equipLoc)
  local shouldRemove = false

  if self.db[rarity]['equip'] then
    if self:ShouldRemoveBasedOnEquipment(rarity, subType, equipLoc) then
      shouldRemove = true
    else
      return false
    end
  end

  if self.db[rarity]['soulbound'] then
    return self:ShouldRemoveBasedOnSoulbound(rarity)
  end

  return shouldRemove
end

function JunkHandling:ShouldRemoveBasedOnEquipment(rarity, subType, equipLoc)
  if self:PlayerCanEquipGearItem(subType) then

    if self.db[rarity]['bestArmor'] then
      return self:ShouldRemoveBasedOnBestArmor(subType, equipLoc)
    end

    return false
  end
  return true
end

function JunkHandling:PlayerCanEquipGearItem(subType)
  local _, class = UnitClass('player')
  local level = UnitLevel('player')

  if (self.Gear['ALL'][subType] and level >= self.Gear['ALL'][subType]) or
      (self.Gear[class][subType] and level >= self.Gear[class][subType]) then
    return true
  end
end

function JunkHandling:ShouldRemoveBasedOnBestArmor(subType, equipLoc)
  if equipLoc ~= 'INVTYPE_CLOAK' and not self:IsBestArmor(subType) then
    return true
  end
end

function JunkHandling:IsBestArmor(subType)
  local _, class = UnitClass('player')
  if subType == 'Cloth' or subType == 'Leather' or subType == 'Mail' or subType == 'Plate' then
    local type1, type2 = self.Gear.BEST(class, UnitLevel('player'))
    return subType == type1 or subType == type2
  end
  return true
end

function JunkHandling:ShouldRemoveBasedOnSoulbound(rarity)
  return self.itemSoulbound == ITEM_SOULBOUND or self.itemSoulbound == ITEM_BIND_ON_PICKUP
end
