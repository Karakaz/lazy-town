
function JunkHandling:SellJunk()
  local sessionValue, itemLink = 0
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      itemLink = GetContainerItemLink(bag, slot)
      if itemLink and self:ShouldSellContainerItem(itemLink, bag, slot) then
        self:SellItem(bag, slot, itemLink)
        sessionValue = sessionValue + self.itemValue
      end
    end
  end
  if sessionValue > 0 then
    self:SessionLogAndPrint(sessionValue)
  end
end

function JunkHandling:ShouldSellContainerItem(itemLink, bag, slot)
  local itemName, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
  if self:IsException(itemName) then
    return self:RemoveBasedOnExceptions(itemName)
  end
  if self:NeverSellOrDelDisenchantableItems(itemName, itemLink, itemEquipLoc) then
    return self:ShouldRemoveItem(itemLink, bag, slot)
  end
end

function JunkHandling:SellItem(bag, slot, itemLink)
  UseContainerItem(bag, slot)
  local soldItemString = format("Sold item: %s  %s", itemLink, ValueToMoneyString(self.itemValue))
  self:LogSale(soldItemString, self:RarityFromItemLink(itemLink))
  if self.db.printSold then
    LazyTown:GetChat():AddMessage(soldItemString)
  end
end

function JunkHandling:SessionLogAndPrint(sessionValue)
  local soldJunkString = "Sold junk for " .. ValueToMoneyString(sessionValue)
  if self.db.printRecap then
    self:Print(LazyTown:GetChat(), soldJunkString)
  end
  self:RegisterLogLine(soldJunkString)
end
