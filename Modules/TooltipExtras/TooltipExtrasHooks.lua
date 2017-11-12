
function TooltipExtras:RegisterItemInfo(info1, info2)
  self.sellValue.show = true
  if info1 then
    self:RegisterInfo(info1)
    if info2 then
      self:RegisterInfo(info2)
    end
  end
end

function TooltipExtras:RegisterInfo(info)
  if type(info) == 'number' then
    self.sellValue.count = info
  else
    self.sellValue.link = info
  end
end

function TooltipExtras:RegisterItem()
  self.sellValue.show = true
end

function TooltipExtras:SetAction(tooltip, id) --Action is a special case (have to get iteminfo later)
  self.sellValue.action = true
  self.sellValue.id = id
end

function TooltipExtras:SetAuctionItem(tooltip, type, index)
  local _, _, count = GetAuctionItemInfo(type, index)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetAuctionSellItem(Tooltip)
  local _, _, count = GetAuctionSellItemInfo()
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetBagItem(tooltip, bag, slot)
  if not MerchantFrame:IsShown() then
    local _, itemCount = GetContainerItemInfo(bag, slot)
    self:RegisterItemInfo(itemCount)
  end
end

function TooltipExtras:SetCraftItem(tooltip, skill, slot)
  local count
  if slot then
    count = select(3, GetCraftReagentInfo(skill, slot))
  end
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetGuildBankItem(tooltip, tab, slot)
  local _, count = GetGuildBankItemInfo(tab, slot)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetHyperlink(tooltip, link, count)
  count = tonumber(count)
  if not count or count < 1 then
    local owner = tooltip:GetOwner()
    count = owner and tonumber(owner.count)
    if not count or count < 1 then count = 1 end
  end
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetInboxItem(tooltip, index, attachmentIndex)
  local _, _, count = GetInboxItem(index, attachmentIndex)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetInventoryItem(tooltip, unit, slot)
  if type(slot) ~= "number" or slot < 0 then return end

  local count = 1
  if slot < 20 or slot > 39 and slot < 68 then
    count = GetInventoryItemCount(unit, slot)
  end
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetLootItem(tooltip, slot)
  local _, _, count = GetLootSlotInfo(slot)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetLootRollItem(tooltip, rollID)
  local _, _, count = GetLootRollItemInfo(rollID)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetMerchantCostItem(tooltip, index, item)
  local _, count = GetMerchantItemCostItem(index, item)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetMerchantItem(tooltip, slot)
  local _, _, _, count = GetMerchantItemInfo(slot)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetQuestItem(tooltip, type, slot)
  local _, _, count = GetQuestItemInfo(type, slot)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetQuestLogItem(tooltip, type, index)
  local _, _, count = GetQuestLogRewardInfo(index)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetSendMailItem(tooltip, index)
  local _, _, count = GetSendMailItem(index)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetTradePlayerItem(tooltip, index)
  local _, _, count = GetTradePlayerItemInfo(index)
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetTradeSkillItem(tooltip, skill, slot)
  local count = 1
  if slot then
    count = select(3, GetTradeSkillReagentInfo(skill, slot))
  end
  self:RegisterItemInfo(count)
end

function TooltipExtras:SetTradeTargetItem(tooltip, index)
  local _, _, count = GetTradeTargetItemInfo(index)
  self:RegisterItemInfo(count)
end
