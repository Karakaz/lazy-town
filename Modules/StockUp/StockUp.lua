
function StockUp:MERCHANT_SHOW(event)
  self:ScanBagsForItems()
  self:ScanMerchantForItems()

  self.money = GetMoney()
  self.bagSpace = MainMenuBarBackpackButton.freeSlots or JunkHandling:CalcNrFreeSlots()

  local noError, errorText = pcall(self.BeginBuying, self)
  if not noError then
    self:Print(LazyTown:GetChat(), errorText:match(": (!.+!)") or errorText or error()) --passing uncaught errors on
  end
end

function StockUp:ScanBagsForItems()
--  self:Print("ScanBagsForItems()")
  local tbl = {}
  local name, link, count, stackSize, _
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      link = GetContainerItemLink(bag, slot)
      if link then
        _, count = GetContainerItemInfo(bag, slot)
        name, _, _, _, _, _, _, stackSize = GetItemInfo(link)
        -- exception for sacred candle
        if name == "Sacred Candle" then  stackSize = 20  end
        tinsert(tbl, {index = #tbl + 1, name = name, link = link, count = count, stackSize = stackSize, bag = bag, slot = slot})
      end
    end
  end
  self.bagItems = tbl
end

function StockUp:ScanMerchantForItems()
--  self:Print("ScanMerchantForItems()")
  local tbl = {}
  local name, price, quantity, numAvailable, extendedCost, _
  for i = 1, GetMerchantNumItems() do
    name, _, price, quantity, numAvailable, _, extendedCost = GetMerchantItemInfo(i)
    if numAvailable == -1 then
      numAvailable = 1000000 --simpler code this way
    end
    tinsert(tbl, {index = i, name = name, price = price, quantity = quantity, numAvailable = numAvailable,
                  extendedCost = extendedCost, link = GetMerchantItemLink(i)})
  end
  self.merchantItems = tbl
end

function StockUp:BeginBuying()
--  self:Print("BeginBuying()")
  if self.db.reagentsEnabled then     self:BuyReagents() end
  if self.db.drinksEnabled then       self:BuyType(self.db.drinks) end
  if self.db.vialsEnabled then        self:BuyType(self.db.vials) end
  if self.db.threadsEnabled then      self:BuyType(self.db.threads) end
  
  if not LibStub('KaraLib-1.0'):IsTableEmpty(self.db.custom) then
    self:BuyType(self.db.custom)
  end
end

function StockUp:BuyReagents()
  if self.class == 'HUNTER' then
    if     self.db.hunterAmmo == 'arrows'  then self:BuyType(self.db.reagents.ARROWS)
    elseif self.db.hunterAmmo == 'bullets' then self:BuyType(self.db.reagents.BULLETS) end
  else
    self:BuyType(self.db.reagents[self.class])
  end
end

function StockUp:BuyType(typeTable)
--  self:Print("BuyType(..)")
  local merchantItem, playerLevel
  for name, data in pairs(typeTable) do
--    self:Print(name)
    if data.enabled then
      playerLevel = UnitLevel('player')
      if type(data.range) == 'number' and playerLevel >= data.range or
         type(data.range) == 'table' and playerLevel >= data.range[1] and playerLevel <= data.range[2] then
        merchantItem = self:GetMerchantItem(name)
        if merchantItem then
          self.nrStacksNeeded = self:NeedMoreOfItem(name, data.stacks)
--          self:Print("nrStacksNeeded=" .. self.nrStacksNeeded)
          if self.nrStacksNeeded > 0 then
            self:SetUpAndBeginBuying(merchantItem)
          end
        end
      else
        if self.db.autoSell then
          self:SellAllOfItem(name)
        end
      end
    end
  end
end

function StockUp:GetMerchantItem(name)
  for i, item in ipairs(self.merchantItems) do
    if item.name == name then
      return item
    end
  end
end

function StockUp:NeedMoreOfItem(itemName, stacksNeeded)
--  self:Print("NeedMoreOfItem(" .. itemName .. ", " .. stacksNeeded .. ")")
  local nrOfFullStacks, bagItem, index = 0
  repeat
    bagItem = self:BagNextStack(itemName, index)

    if bagItem and bagItem.count >= bagItem.stackSize * self.db.fullPercent  then
--      self:Print("count=" .. bagItem.count .. ", stackSize=" .. bagItem.stackSize .. ", fullPercent=" .. self.db.fullPercent)
      bagItem.consideredFull = true
      if nrOfFullStacks + 1 == stacksNeeded then
        return 0
      else
        nrOfFullStacks = nrOfFullStacks + 1
      end
    end

    index = bagItem and bagItem.index + 1
  until bagItem == nil
  return stacksNeeded - nrOfFullStacks
end

function StockUp:BagNextStack(itemName, index)
  index = index or 1
  for i = index, #self.bagItems do
    if itemName == self.bagItems[i].name then
      return self.bagItems[i]
    end
  end
end

function StockUp:SetUpAndBeginBuying(merchantItem)
--  self:Print("SetUpAndBeginBuying(..)")
  local needMore = self:FillHalfFullStacks(merchantItem)
  if needMore then
    self:BuyNewStacks(merchantItem)
  end
end

function StockUp:FillHalfFullStacks(merchantItem)
--  self:Print("FillHalfFullStacks(..)")
  local bagItem, index, needMore
  repeat
    bagItem = self:BagNextStack(merchantItem.name, index)

    needMore = self:FillBagItem(bagItem, merchantItem)
    if not needMore then  return false  end

    index = bagItem and bagItem.index + 1
  until bagItem == nil
  return true
end

function StockUp:FillBagItem(bagItem, merchantItem)
--  self:Print("FillBagItem(..)")
  local neededToFill
  if bagItem and merchantItem.numAvailable >= 1 then

    neededToFill = bagItem.stackSize - bagItem.count
    if merchantItem.quantity <= neededToFill then

      self.buyQuantity = floor(neededToFill / merchantItem.quantity)

      self:BuyItem(merchantItem)

      if self:CountsAsFullAndFinished(bagItem, merchantItem) then
        return false
      end
    end
  end
  return true
end

function StockUp:CountsAsFullAndFinished(bagItem, merchantItem)
--  self:Print("CountAsFullAndFinished(..)")
  if not bagItem.consideredFull and bagItem.count + merchantItem.quantity * self.buyQuantity >= bagItem.stackSize * self.db.fullPercent then
    if self.nrStacksNeeded - 1 <= 0 then
      return true
    else
      self.nrStacksNeeded = self.nrStacksNeeded - 1
    end
  end
end

function StockUp:BuyNewStacks(merchantItem)
--  self:Print("BuyNewStacks(..)")
  local _, stackSize
  _, _, _, _, _, _, _, stackSize = GetItemInfo(merchantItem.link)
  if merchantItem.name == "Sacred Candle" then  stackSize = 20  end
  self.buyQuantity = floor(stackSize / merchantItem.quantity)
  repeat
    self:BuyItem(merchantItem)
    self.nrStacksNeeded = self.nrStacksNeeded - 1
    self.bagSpace = self.bagSpace - 1
  until self.nrStacksNeeded <= 0
end

function StockUp:BuyItem(merchantItem, fillingStack)
--  self:Print("BuyItem(..)")
  if merchantItem.numAvailable < self.buyQuantity then
    self.buyQuantity = merchantItem.numAvailable
  end
  if self:HasEnoughResourcesToBuyItem(merchantItem) then
    BuyMerchantItem(merchantItem.index, self.buyQuantity)
  --  LazyTown:GetChat():AddMessage("StockUp: Bought " .. self.buyQuantity * merchantItem.quantity .. "x " .. merchantItem.link)
    self.money = self.money - merchantItem.price * self.buyQuantity
    merchantItem.numAvailable = merchantItem.numAvailable - self.buyQuantity
  end
end

function StockUp:HasEnoughResourcesToBuyItem(merchantItem, fillingStack)
  if self.money < self.buyQuantity * merchantItem.price then
    error("! Not enough money to buy reagents !")
  end
  if not fillingStack and self.bagSpace <= 0 then
    error("! Not enough bag space to buy reagents !")
  end
  if merchantItem.extendedCost then
    local honor, arenaPoints, itemCount = GetMerchantItemCostInfo(merchantItem.index)
    if not self:HasEnoughHonor(honor) then
      error("! Not enough honor to buy reagents !")
    end
    if not self:HasEnoughArenaPoints(arenaPoints) then
      error("! Not enough arena points to buy reagents !")
    end
    self:HasEnoughItems(merchantItem.index, itemCount) --raises it's own error
  end
  return true
end

function StockUp:HasEnoughHonor(baseHonor)
  if baseHonor and baseHonor > 0 then
    return GetHonorCurrency() >= baseHonor * self.buyQuantity
  end
  return true
end

function StockUp:HasEnoughArenaPoints(baseArenaPoints)
  if baseArenaPoints and baseArenaPoints > 0 then
    return GetArenaCurrency() >= baseArenaPoints * self.buyQuantity
  end
  return true
end

function StockUp:HasEnoughItems(merchantItemIndex, nrItemsNeeded)
  if nrItemsNeeded and nrItemsNeeded > 0 then
    JunkHandling:RecordBagItemCounts()
    local itemCount, itemLink, _
    for i = 1, nrItemsNeeded do
      _, itemCount, itemLink = GetMerchantItemCostItem(merchantItemIndex, i)
      if itemCount and itemCount > 0 and itemLink then
        if not JunkHandling:HasAtLeastXOfItem(itemLink, itemCount * self.buyQuantity) then
          error("! Need more " .. itemLink .. " to purchase reagents !")
        end
      end
    end
  end
  return true
end

function StockUp:SellAllOfItem(itemName)
--  self:Print("SellAllOfItem(" .. itemName .. ")")
  local soldItem
  for index, bagItem in ipairs(self.bagItems) do
    if itemName == bagItem.name then
      UseContainerItem(bagItem.bag, bagItem.slot)
      soldItem = bagItem
    end
  end
  if soldItem then
    LazyTown:GetChat():AddMessage("StockUp: Sold all " .. soldItem.link)
  end
end
