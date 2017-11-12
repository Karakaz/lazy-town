
--------------- Auto BEFORE -----------------------------------------------------------------

function JunkHandling:RecordBagItemCounts() --also used by other modules
  local bagMap = {}
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      local link = GetContainerItemLink(bag, slot)
      if link then
        local max = select(8, GetItemInfo(link))
        if max > 1 then
          local count = select(2, GetContainerItemInfo(bag, slot))
          if bagMap[link] then
            bagMap[link].count = bagMap[link].count + count
            bagMap[link].max = bagMap[link].max + max
          else
            bagMap[link] = {count = count, max = max}
          end
        end
      end
    end
  end
  self.bagMap = bagMap
end

function JunkHandling:HasRoomInStackableItem(link, amount) --also used by other modules
  return self.bagMap[link] and self.bagMap[link].max - self.bagMap[link].count >= amount
end

function JunkHandling:HasAtLeastXOfItem(link, amount) --used by StockUp
  return self.bagMap[link] and self.bagMap[link].count >= amount
end

function JunkHandling:LootFrame_OnEvent(event, ...)
  if event == 'LOOT_OPENED' then
    LootFrame.page = 1
    ShowUIPanel(LootFrame)
    if not LootFrame:IsShown() then
      CloseLoot(arg1 ~= 0) -- The parameter tells code that we were unable to open the UI
    end
    if self:ShouldAutoLoot() then
      self:ScheduleTimer("LootAll", 0.02)
    end
  else
    self.hooks.LootFrame_OnEvent(event, ...)
  end
end

function JunkHandling:ShouldAutoLoot()
  local autoloot = self.db.del.autoloot
  if self.db.del.modifierKey == 'ctrl' and IsControlKeyDown() or
     self.db.del.modifierKey == 'alt' and IsAltKeyDown() or
     self.db.del.modifierKey == 'shift' and IsShiftKeyDown() then
    autoloot = not autoloot
  end
  return autoloot
end

function JunkHandling:LootAll()
  for i = 1, GetNumLootItems() do
    local link = GetLootSlotLink(i)
    if LootSlotIsCoin(i) or self.shouldPickupLoot[i] or not LootSlotIsItem(i) then
      LootSlot(i)
    elseif self.nrSlotsForJunk > 0 then
      LootSlot(i)
      self.nrSlotsForJunk = self.nrSlotsForJunk - 1
    end
  end
end

function JunkHandling:CalcNrFreeSlots()
  local totalFree, freeSlots, bagFamily = 0
  for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
    freeSlots, bagFamily = GetContainerNumFreeSlots(i)
    if bagFamily == 0 then
      totalFree = totalFree + freeSlots
    end
  end
  return totalFree
end

--------------- DeleteXJunkItems ----------------------------------------------------------

function JunkHandling:DeleteXJunkItems(nrToDelete)
--  self:Print("DeleteXJunkItems(" .. nrToDelete .. ")")
  local itemLink
  local junk = {}
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      itemLink = GetContainerItemLink(bag, slot)

      if itemLink and self:ShouldDeleteItem(itemLink, bag, slot) then
        table.insert(junk, {value = GetSellValue(itemLink) * select(2, GetContainerItemInfo(bag, slot)),
                            rarity = JunkHandling.QC[self:RarityFromItemLink(itemLink)],
                            bag = bag,   slot = slot,   link = itemLink})
      end
    end
  end
  table.sort(junk, self.JunkSortFunction)
  self:DeleteXFirstItems(nrToDelete, junk)
end

function JunkHandling:ShouldDeleteItem(itemLink, bagOrLootIndex, slotOrNil)
  local itemName, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
  if self:IsException(itemName) then
    return self:RemoveBasedOnExceptions(itemName)
  end
  if self.db.del.whatToDelete == 'onlyGray' then
    if self:RarityFromItemLink(itemLink) == 'poor' then
      return true
    end
  elseif self.db.del.whatToDelete == 'useFilter' then
    if self:NeverSellOrDelDisenchantableItems(itemName, itemLink, itemEquipLoc) then
      return self:ShouldRemoveItem(itemLink, bagOrLootIndex, slotOrNil)
    end
  end
end

function JunkHandling.JunkSortFunction(junkA, junkB)
  if junkA.rarity == junkB.rarity or JunkHandling.db.del.order == 'cheapestFirst' then
    return junkA.value < junkB.value
  else
    return junkA.rarity < junkB.rarity
  end
end

function JunkHandling:DeleteXFirstItems(nrToDelete, junkTable)
  local nrItemsDeleted = 0

  ClearCursor()
  for i = 1, #junkTable do
    if nrItemsDeleted < nrToDelete then
      if not (self.db.del.notSpecial and junkTable[i].value == 0) or junkTable[i].value < self.db.del.worth then
        self:DeleteItem(junkTable[i])
        nrItemsDeleted = nrItemsDeleted + 1
      end
    else
      break
    end
  end
  if nrItemsDeleted == 0 then
    LazyTown:GetChat():AddMessage("Could not find any junk items to delete.")
  elseif nrItemsDeleted < nrToDelete then
    LazyTown:GetChat():AddMessage("Could only find and delete " .. nrItemsDeleted .. " junk items.")
  end
end

function JunkHandling:DeleteItem(junkElement)
  PickupContainerItem(junkElement.bag, junkElement.slot)
  DeleteCursorItem()
  self:SendMessage("JUNK_ITEM_DELETED", junkElement)
end

function JunkHandling:JUNK_ITEM_DELETED(junkElements)
  local uniques = {}
  for junkElement, _ in pairs(junkElements) do
    uniques[junkElement.bag .. junkElement.link .. junkElement.slot] = junkElement
  end
  self:RegisterDeletedItemStrings(uniques)
end

function JunkHandling:RegisterDeletedItemStrings(uniques)
  local shouldPrint, deletedItemString = self.db.del.print
  for _, junkElement in pairs(uniques) do
    deletedItemString = "Deleted item: " .. junkElement.link --.. " (" .. junkElement.bag .. ", " .. junkElement.slot .. ")"
    self:LogDeletion(deletedItemString, junkElement.value)
    if shouldPrint then
      LazyTown:GetChat():AddMessage(deletedItemString)
    end
  end
end
