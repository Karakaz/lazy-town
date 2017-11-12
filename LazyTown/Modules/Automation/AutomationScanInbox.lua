
function LTAutomation:ScanInbox()
--  self:Print('ScanInbox')
  
  if self.firstScan then
    self.nextIndex = GetInboxNumItems()
    self.firstScan = nil
  end
  
  local reachedTheEnd = self:ContinueScan()
  
  if reachedTheEnd and self.db.printSummary and not self.havePrintedSummary then
    self:PrintMailSummary()
    self.havePrintedSummary = true
  end
end

function LTAutomation:ContinueScan()
  local subject, money, ahType, _
  for i = self.nextIndex, 1, -1 do
    self.nextIndex = i - 1
    _, _, _, subject, money = GetInboxHeaderInfo(i)
    ahType = subject and self:GetAuctionMailType(subject)
    if ahType and self.db["take" .. ahType] then
      local couldNotTakeAttachment = self["Take" .. ahType](self, i, money)
      if couldNotTakeAttachment then
        self.skippedItems = self.skippedItems + 1
      end
      return
    end
  end
  return true
end

function LTAutomation:GetAuctionMailType(subject)
  for type, format in pairs(self.AHFormats) do
    if subject:find(format) then
      return type
    end
  end
end

function LTAutomation:TakeSaleGold(inboxIndex, money)
  if money > 0 then
--    self:Print("TakeSaleGold(" .. inboxIndex .. ")")
    TakeInboxMoney(inboxIndex)
    self.saleMoney = self.saleMoney + money
  end
end

function LTAutomation:TakeOutbidGold(inboxIndex, money)
  if money > 0 then
--    self:Print("TakeOutbidGold(" .. inboxIndex .. ")")
    TakeInboxMoney(inboxIndex)
    self.outbidMoney = self.outbidMoney + money
  end
end

function LTAutomation:TakeBoughtItems(inboxIndex)
--  self:Print("TakeBoughtItems(" .. inboxIndex .. ")")
  if self:TakeFirstItem(inboxIndex) then
    self.boughtItems = self.boughtItems + 1
  else
    return true
  end
end

function LTAutomation:TakeExpiredItems(inboxIndex)
--  self:Print("TakeExpiredItems(" .. inboxIndex .. ")")
  if self:TakeFirstItem(inboxIndex) then
    self.expiredItems = self.expiredItems + 1
  else
    return true
  end
end

function LTAutomation:TakeCancelledItems(inboxIndex)
--  self:Print("TakeCancelledItems(" .. inboxIndex .. ")")
  if self:TakeFirstItem(inboxIndex) then
    self.cancelledItems = self.cancelledItems + 1
  else
    return true
  end
end

function LTAutomation:TakeFirstItem(inboxIndex)
  local _, _, count = GetInboxItem(inboxIndex, 1)
  if self:HaveRoomForItem(GetInboxItemLink(inboxIndex, 1), count) then
    TakeInboxItem(inboxIndex, 1)
    return true
  end
end

function LTAutomation:HaveRoomForItem(itemLink, count)
  if itemLink then
    if (MainMenuBarBackpackButton.freeSlots or JunkHandling:CalcNrFreeSlots()) > 0 then
      return true
    else
      JunkHandling:RecordBagItemCounts()
      return JunkHandling:HasRoomInStackableItem(itemLink, count)
    end
  end
end

function LTAutomation:PrintMailSummary()
  local sale      = self.saleMoney > 0      and ValueToMoneyString(self.saleMoney) .. " from sales, " or ""
  local outbid    = self.outbidMoney > 0    and ValueToMoneyString(self.saleMoney) .. " in outbids, " or ""
  local bought    = self.boughtItems > 0    and self.boughtItems .. " won items, "                    or ""
  local expired   = self.expiredItems > 0   and self.expiredItems .. " expired items, "               or ""
  local cancelled = self.cancelledItems > 0 and self.cancelledItems .. " cancelled items"             or ""

  local skipped = self.skippedItems > 0 and self.skippedItems .. " items skipped (bags full)" or ""

  local printCollected = true

  if cancelled == "" then
    if expired == "" then
      if bought == "" then
        if outbid == "" then
          if sale == "" then
            if skipped == "" then
              return
            end
            printCollected = false
          else
            sale = sale:sub(1, #sale - 2)
          end
        else
          outbid = outbid:sub(1, #outbid - 2)
        end
      else
        bought = bought:sub(1, #bought - 2)
      end
    else
      expired = expired:sub(1, #expired - 2)
    end
  end
  
  if printCollected then
    LazyTown:GetChat():AddMessage(format("AH mail: %s%s%s%s%s collected.", sale, outbid, bought, expired, cancelled))
  end
  if skipped ~= "" then
    LazyTown:GetChat():AddMessage(format("AH mail: %s.", skipped))
  end
end
