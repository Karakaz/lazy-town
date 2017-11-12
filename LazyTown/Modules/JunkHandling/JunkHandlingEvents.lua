
--- Used by deletion, autoBefore
function JunkHandling:QUEST_COMPLETE(event)
  local rewardsFromQuest = GetNumQuestRewards() + (GetNumQuestChoices() >= 1 and 1 or 0)

  if rewardsFromQuest > self.freeSlots then
    self:DeleteXJunkItems(rewardsFromQuest - self.freeSlots)
  end
end

--- Used by deletion, autoBefore
function JunkHandling:LOOT_OPENED(event, autoloot)
  self:RecordBagItemCounts()
  local nrNonJunkItems = 0
  local shouldPickupLoot = {}
  for i = 1, GetNumLootItems() do
    if LootSlotIsItem(i) then
      local link = GetLootSlotLink(i)
      if self:HasRoomInStackableItem(link, select(3, GetLootSlotInfo(i))) then
        table.insert(shouldPickupLoot, true)
      elseif self:ShouldDeleteItem(link, i) then
        table.insert(shouldPickupLoot, false)
      else
        table.insert(shouldPickupLoot, true)
        nrNonJunkItems = nrNonJunkItems + 1
      end
    else
      table.insert(shouldPickupLoot, true)
    end
  end
  if nrNonJunkItems > self.freeSlots then
    self:DeleteXJunkItems(nrNonJunkItems - self.freeSlots)
  else
  end
  self.nrSlotsForJunk = self.freeSlots - nrNonJunkItems
  self.shouldPickupLoot = shouldPickupLoot
end

--- Used by deletion, autoAfter
function JunkHandling:UI_ERROR_MESSAGE(event, message)
  if message == ERR_INV_FULL then
    self:DeleteXJunkItems(self.db.del.nrItems)
  end
end

--- Used by deletion, autoBefore, and disenchanting
function JunkHandling:BAG_UPDATE(event, bagID)
--  self:Print("BAG_UPDATE(..)")
  if self.db.del.howToDelete == 'autoBefore' then
    self.freeSlots = self:CalcNrFreeSlots()
    if self.db.del.oneOpen then
      if self.freeSlots == 0 then
        self:DeleteXJunkItems(1)
      end
    end
  end
  if self.db.DE.enabled then
    self:SendMessage("BAG_UPDATE_COLLECTION", bagID)
  end
end

--- Used by disenchanting
function JunkHandling:BAG_UPDATE_COLLECTION(bags)
--  self:Print("BAG_UPDATE_COLLECTION(..)")
  for i = 0, 4 do
    if type(bags[i]) == 'number' then
      self:ScanBagForDEItems(i)
    end
  end
  self:UpdateDisenchanting()
end

--- Used by disenchanting and autoBefore
function JunkHandling:PLAYER_REGEN_ENABLED(event)
  self:UnregisterEvent('PLAYER_REGEN_ENABLED')
  self:UpdateDisenchanting(true)

  if self.db.del.howToDelete == 'autoBefore' then
    self:RegisterEvent('BAG_UPDATE')
  end
end

--- Used by disenchanting
function JunkHandling:UNIT_SPELLCAST_SUCCEEDED(event, unit, spellName, spellRank)
  if unit == 'player' and spellName == 'Disenchant' then
    self:RegisterLogLine("Disenchanted item: " .. self.DECurItem.link)
    self:UpdateDisenchanting(true)
  end
end
