
------- LOG ----------------------------------------------------------

function JunkHandling:GetLog()
  return self.db.log
end

function JunkHandling:LogSale(soldItemString, itemRarity)
  self:RegisterLogLine(soldItemString)
  self:RegisterLogValue(itemRarity, self.itemValue)
end

function JunkHandling:LogDeletion(deletedItemString, itemValue)
  self:RegisterLogLine(deletedItemString)
  self:RegisterDeletedItemValue(itemValue)
end

function JunkHandling:RegisterLogLine(line)
  local log = self:GetLog()
  table.insert(log, date("%d/%m %H:%M") .. "  " .. line)
  if #log > 100 then
    table.remove(log, 1)
  end
end

function JunkHandling:RegisterLogValue(itemRarity, itemValue)
  local valueTable, countTable = self.db.value, self.db.count
  valueTable[itemRarity] = valueTable[itemRarity] + itemValue
  countTable[itemRarity] = countTable[itemRarity] + 1
  valueTable['all'] = valueTable['all'] + itemValue
  countTable['all'] = countTable['all'] + 1
end

function JunkHandling:RegisterDeletedItemValue(itemValue)
  local dbJunk = self.db
  dbJunk.value.deleted = dbJunk.value.deleted + itemValue
  dbJunk.count.deleted = dbJunk.count.deleted + 1
end

function JunkHandling:PrintLog(info)
  local log, chat = self:GetLog(), LazyTown:GetChat()
  chat:AddMessage("JunkHandler, Log:")

  local max = self.db.logLines
  local start, finish = 1, #log
  if #log > max - self.db.logIndex + 1 then
    start = #log - max - self.db.logIndex + 2
    finish = #log - self.db.logIndex + 1
  end

  for i = start, finish do
    chat:AddMessage(log[i])
  end
end

function JunkHandling:PrintValueLog(info)
  local chat = LazyTown:GetChat()
  local dbJunk = self.db
  chat:AddMessage("JunkHandler, Total Earnings from " .. dbJunk.count.all .. " sold items:")
  chat:AddMessage(format("%5d%s Epic|r:     %s", dbJunk.count.epic, ITEM_QUALITY_COLORS[4].hex, ValueToMoneyString(dbJunk.value.epic)))
  chat:AddMessage(format("%5d%s Rare|r:     %s", dbJunk.count.rare, ITEM_QUALITY_COLORS[3].hex, ValueToMoneyString(dbJunk.value.rare)))
  chat:AddMessage(format("%5d%s Uncommon|r: %s", dbJunk.count.uncommon,ITEM_QUALITY_COLORS[2].hex,ValueToMoneyString(dbJunk.value.uncommon)))
  chat:AddMessage(format("%5d%s Common|r:   %s", dbJunk.count.common, ITEM_QUALITY_COLORS[1].hex, ValueToMoneyString(dbJunk.value.common)))
  chat:AddMessage(format("%5d%s Poor|r:     %s", dbJunk.count.poor, ITEM_QUALITY_COLORS[0].hex, ValueToMoneyString(dbJunk.value.poor)))
  chat:AddMessage("----------------------------------------")
  chat:AddMessage("       |cffffff00Total|r: " .. ValueToMoneyString(dbJunk.value.all))
  if dbJunk.del.enabled then
    chat:AddMessage("# deleted items: "..dbJunk.count.deleted.." worth a total of "..ValueToMoneyString(dbJunk.value.deleted))
  end
end

------- EXCEPTIONS ----------------------------------------------------

function JunkHandling:DecypherAndDeleteInput()
  local input = self.currentInput
  if input and input:len() > 0 then

    if input:match("|h|r$") then
      input = (GetItemInfo(input))
    end
  end
  self.currentInput = nil
  return input
end

function JunkHandling:AddToExceptionList(info, s, keep)
  if s == nil then
    s = self:DecypherAndDeleteInput()
  end
  if s and s:len() > 0 then
    if keep or keep == nil and self.db.labelAsKeep then
      self.db.keepList[s] = true
      self.db.junkList[s] = nil
      self:Print(LazyTown:GetChat(), "Added keep exception: " .. s)
    else
      self.db.junkList[s] = true
      self.db.keepList[s] = nil
      self:Print(LazyTown:GetChat(), "Added junk exception: " .. s)
    end
  end
  self:UpdateDisenchanting(true)
end

function JunkHandling:RemoveFromExceptionLists(info, s)
  if s == nil then
    s = self:DecypherAndDeleteInput()
  end
--  self:Print(type(s))
  if s and s:len() > 0 then
    self.db.keepList[s] = nil
    self.db.junkList[s] = nil
    self:Print(LazyTown:GetChat(), "Removed exception: " .. s)
  end
  self:UpdateDisenchanting(true)
end

function JunkHandling:ClearKeepList()
  local keepList = self.db.keepList
  if keepList then
    for k, v in pairs(keepList) do
      keepList[k] = nil
    end
  end
  self:UpdateDisenchanting(true)
end

function JunkHandling:ClearJunkList()
  local junkList = self.db.junkList
  if junkList then
    for k, v in pairs(junkList) do
      junkList[k] = nil
    end
  end
  self:UpdateDisenchanting(true)
end

function JunkHandling:IsException(itemName)
  return self.db.junkList[itemName] or self.db.keepList[itemName]
end

function JunkHandling:PrintExceptionLists()
  local chat = LazyTown:GetChat()
  local color = "|cffff5555"
  chat:AddMessage(color .. "JunkHandler, Exception Lists:|r")

  local sortedKeep = self:KeysToSortedList(self.db.keepList)
  local sortedJunk = self:KeysToSortedList(self.db.junkList)

  self:PrintList(chat, color, "[Keep] ", sortedKeep)
  self:PrintList(chat, color, "[Junk] ", sortedJunk)
end

function JunkHandling:KeysToSortedList(inputTable)
  local outputTable = {}
  for k, v in pairs(inputTable) do
    table.insert(outputTable, k)
  end
  table.sort(outputTable)
  return outputTable
end

function JunkHandling:PrintList(chat, color, label, sortedTable)
  if #sortedTable == 0 then
    chat:AddMessage(color .. label .. "~~ empty ~~|r")
  else
    for i = 1, #sortedTable do
      chat:AddMessage(color .. label .. sortedTable[i] .. "|r")
    end
  end
end
