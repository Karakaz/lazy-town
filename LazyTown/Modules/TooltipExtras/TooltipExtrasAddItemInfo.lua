
function TooltipExtras:AddItemInfo(tooltip, itemLink)
  local itemLevel, stackSize, _

    _, _, _, itemLevel, _, _, _, stackSize = GetItemInfo(itemLink)

    if self.db.itemLevel and itemLevel then
      self:RegisterLinePart("iLevel " .. itemLevel, unpack(self.db.itemLevelColor))
    end

    if self.db.itemID then
      self:RegisterLinePart("ItemID " .. itemLink:match("Hitem:(%d+):"), unpack(self.db.itemIDColor))
      self:AddPartsToTooltip(tooltip, true)
    end

    if self.db.stackSize and stackSize ~= 1 then
      self:RegisterLinePart("StackSize " .. stackSize, unpack(self.db.stackSizeColor))
    end
    self:AddPartsToTooltip(tooltip)

    if self.sellValue.show then
      local sell1, sell2 = self:MakeSellValues(tooltip, itemLink)
      if sell1 then
        self:RegisterLinePart(sell1, 1, 1, 1)
        if sell2 then
          self:RegisterLinePart(sell2, 1, 1, 1)
        end
      end
    end
    self:AddPartsToTooltip(tooltip)
end

function TooltipExtras:RegisterLinePart(newPart, r, g, b)
  local storePart = (self.partA.part and self.partB or self.partA)
  storePart.part = newPart
  storePart.r = r
  storePart.g = g
  storePart.b = b
end

function TooltipExtras:AddPartsToTooltip(tooltip, onlyDouble)
  if self.partA.part then
    local a = self.partA
    if self.partB.part then
      local b = self.partB
      tooltip:AddDoubleLine(a.part, b.part, a.r, a.g, a.b, b.r, b.g, b.b)
      b.part = nil
      onlyDouble = false
    else
      if not onlyDouble then
        tooltip:AddLine(a.part, a.r, a.g, a.b)
      end
    end
    if not onlyDouble then
      a.part = nil
    end
  end
end

function TooltipExtras:MakeSellValues(tooltip, itemLink)
  local part1, part2 = self:GenerateSellValueLine(tooltip, itemLink)
  self:ResetSellValueVariables()
  return part1, part2
end

function TooltipExtras:ResetSellValueVariables()
  self.sellValue.show = false
  self.sellValue.count = 1
  self.sellValue.link = nil
  self.sellValue.action = nil
  self.sellValue.id = nil
end

function TooltipExtras:GenerateSellValueLine(tooltip, itemLink)
  if self.sellValue.action then
    self:RegisterActionItemInfo(tooltip, self.sellValue.id)
  end

  local itemCount = self.sellValue.count or 1
  itemLink = self.sellValue.link or itemLink

  local value = GetSellValue(itemLink)
  if value and value > 0 and itemCount then
    return self:FormattedSellValue(value, itemCount)
  end
end

function TooltipExtras:RegisterActionItemInfo(tooltip, id)
  local _, link = tooltip:GetItem()
--  self:Print("SetAction(" .. id .. ")" .. " : item=" .. tostring(link))
  if link then
    local count = 1
    if IsConsumableAction(id) or IsStackableAction(id) then
      local actionCount = GetActionCount(id)
      if actionCount and actionCount == GetItemCount(link) then
        count = actionCount
      end
    end
    self.sellValue.link = link
    self.sellValue.count = count
  end
end

function TooltipExtras:FormattedSellValue(value, itemCount)
  local format = self.db.sellValue.format

  if format == 'both' or IsAltKeyDown() then
    if itemCount > 1 then
      return " " .. ValueToMoneyString(value * itemCount, self.db.sellValue.style),
             "|cffbbbbbb(" .. itemCount .. " x " .. ValueToMoneyString(value, self.db.sellValue.style) .. ")|r "
    else
      return " " .. ValueToMoneyString(value * itemCount, self.db.sellValue.style)
    end
  elseif format == 'collected' then
    return " " .. ValueToMoneyString(value * itemCount, self.db.sellValue.style)

  elseif format == 'mix' then
    return (itemCount > 1 and " " .. itemCount .. " x " or " ") .. ValueToMoneyString(value, self.db.sellValue.style)

  elseif format == 'individual' then
    return " " .. ValueToMoneyString(value, self.db.sellValue.style)
  end
end
