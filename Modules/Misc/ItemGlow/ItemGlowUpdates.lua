
local _G = _G
local JunkHandling = _G.JunkHandling

-----------------------------------   SET GLOW   -----------------------------------------

function LTItemGlow:SetGlowFromItemLink(frame, itemLink, anchorRegion)
  itemLink = self:FilterOnlyGear(itemLink)
  self:SetGlowFromRarity(frame, itemLink and JunkHandling:RarityFromItemLink(itemLink), anchorRegion)
end

function LTItemGlow:FilterOnlyGear(itemLink)
  if self.db.gearOnly and itemLink then
    local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(itemLink)
    if JunkHandling:ItemIsGear(itemLink, equipLoc) then
      return itemLink
    end
  else
    return itemLink
  end
end

function LTItemGlow:SetGlowFromRarity(frame, rarity, anchorRegion)
  local color = rarity and rarity ~= 'common' and JunkHandling:ColorFromRarity(rarity)
  self:SetGlowOnFrame(frame, color, anchorRegion)
end

function LTItemGlow:SetGlowOnFrame(frame, color, anchorRegion)
  if not frame.glow then
    self:CreateGlow(frame, anchorRegion)
  end

  if color then
    frame.glow:SetVertexColor(color.r, color.g, color.b)
    frame.glow:Show()
  else
    frame.glow:Hide()
  end
end

function LTItemGlow:CreateGlow(frame, anchorRegion)
  local t = frame:CreateTexture(frame:GetName() .. "Glow", 'OVERLAY')
  t:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
  t:SetPoint('CENTER', anchorRegion or frame)
  t:SetWidth(70)
  t:SetHeight(70)
  t:SetAlpha(0.6)
  t:SetBlendMode('ADD')
  frame.glow = t
  tinsert(self.glowFrames, frame)
end

-----------------------------------     BANK     -----------------------------------------

function LTItemGlow:UpdateBank()
  local regButton
  for i = 1, NUM_BANKGENERIC_SLOTS do
    regButton = self:RegisterGlowGroup(_G["BankFrameItem" .. i], "Bank")
    self:SetGlowFromItemLink(regButton, GetContainerItemLink(-1, i))
  end
end

-----------------------------------  CHARACTER   -----------------------------------------

function LTItemGlow:UpdateCharacter()
  local regButton
  for index, name in ipairs(self.EquipmentSlots) do
    regButton = self:RegisterGlowGroup(_G["Character" .. name .. "Slot"], "Character")
    self:SetGlowFromItemLink(regButton, GetInventoryItemLink('player', index))
  end
end

-----------------------------------  CONTAINERS  -----------------------------------------

function LTItemGlow:UpdateContainers()
--  self:Print("UpdateContainers()")
  if ContainerFrame1.bagsShown >= 1 then
    for _, containerName in ipairs(ContainerFrame1.bags) do
      self:UpdateContainer(containerName)
    end
  end
  self.firstSetContainers = false
end

function LTItemGlow:UpdateContainer(containerName)
  local container = _G[containerName]
  if container and container:IsShown() then
    for i = 1, container.size do
      self:SetSlotGlow(container, containerName, i)
    end
  end
end

function LTItemGlow:SetSlotGlow(container, containerName, buttonIndex)
  local regButton = self:RegisterGlowGroup(_G[containerName .. "Item" .. buttonIndex], "Containers")
  self:SetGlowFromItemLink(regButton, GetContainerItemLink(container:GetID(), container.size - buttonIndex + 1))
end

-----------------------------------    CRAFT    ------------------------------------------

function LTItemGlow:UpdateCraft(id)
  self:SetGlowFromItemLink(self:RegisterGlowGroup(CraftIcon, "Craft"), GetCraftItemLink(id))

  local regButton
  for i = 1, GetCraftNumReagents(id) do
    regButton = self:RegisterGlowGroup(_G["CraftReagent" .. i], "Craft")
    self:SetGlowFromItemLink(regButton, GetCraftReagentItemLink(id, i), _G["CraftReagent" .. i .. "IconTexture"])
  end
end

---------------------------------  EQUIPPED BAGS  ----------------------------------------

function LTItemGlow:UpdateEquippedBags()
  local regButton
  for i = 0, 3 do
    regButton = self:RegisterGlowGroup(_G["CharacterBag" .. i .. "Slot"], "EquippedBags")
    self:SetGlowFromItemLink(regButton, GetInventoryItemLink('player', 20 + i))
  end
end

---------------------------------   GUILD BANK   -----------------------------------------

function LTItemGlow:UpdateGuildBank()
  local tab, nrSlots = GetCurrentGuildBankTab(), NUM_SLOTS_PER_GUILDBANK_GROUP
  local column, index, regButton
  for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
    column = ceil((i - 0.5) / nrSlots)
    index = i % nrSlots
    if index == 0 then index = nrSlots end
    regButton = self:RegisterGlowGroup(_G["GuildBankColumn" .. column .. "Button" .. index], "GuildBank")
    self:SetGlowFromItemLink(regButton, GetGuildBankItemLink(tab, i))
  end
end

-----------------------------------   INSPECT   ------------------------------------------

function LTItemGlow:UpdateInspect()
  if InspectFrame:IsShown() then
    local unit, regButton = InspectFrame.unit
    for index, name in ipairs(self.EquipmentSlots) do
      regButton = self:RegisterGlowGroup(_G["Inspect" .. name .. "Slot"], "Inspect")
      self:SetGlowFromItemLink(regButton, GetInventoryItemLink(unit, index))
    end
  else
    self:UnregisterEvent('PLAYER_TARGET_CHANGED')
  end
end

-----------------------------------     MAIL     -----------------------------------------

function LTItemGlow:UpdateInbox()
  local nrInboxItems = GetInboxNumItems()
  local page, maxPageItems = InboxFrame.pageNum, INBOXITEMS_TO_DISPLAY
  local itemLink, regButton, inboxItemIndex
  for i = 1, maxPageItems do
    regButton = self:RegisterGlowGroup(_G["MailItem" .. i .. "Button"], "Mail")
    inboxItemIndex = i + ((page - 1) * maxPageItems)
    if inboxItemIndex <= nrInboxItems then
      self:SetGlowFromRarity(regButton, JunkHandling.QC[self:GetHighestAttachmentRarity(inboxItemIndex)])
    else
      self:SetGlowOnFrame(regButton)
    end
  end
end

function LTItemGlow:GetHighestAttachmentRarity(inboxItemIndex)
  local highestQuality, itemLink = 0
  for j = 1, ATTACHMENTS_MAX_RECEIVE do
    itemLink = self:FilterOnlyGear(GetInboxItemLink(inboxItemIndex , j))
    if itemLink then
      highestQuality = max(highestQuality, JunkHandling.QC[JunkHandling:RarityFromItemLink(itemLink)])
    end
  end
  return highestQuality
end

function LTItemGlow:UpdateOpenMail()
  if InboxFrame.openMailID then
    local regButton
    for i = 1, ATTACHMENTS_MAX_RECEIVE do
      regButton = self:RegisterGlowGroup(_G["OpenMailAttachmentButton" .. i], "Mail")
      self:SetGlowFromItemLink(regButton, GetInboxItemLink(InboxFrame.openMailID, i))
    end
  end
end

function LTItemGlow:UpdateSendMail()
  if SendMailFrame:IsShown() then
    local regButton
    for i = 1, ATTACHMENTS_MAX_SEND do
      regButton = self:RegisterGlowGroup(_G["SendMailAttachment" .. i], "Mail")
      self:SetGlowFromItemLink(regButton, GetSendMailItemLink(i))
    end
  end
end

-----------------------------------   MERCHANT   -----------------------------------------

function LTItemGlow:UpdateMerchantGoods()
  self:UpdateMerchant(GetMerchantItemLink)
  self:SetGlowFromItemLink(self:RegisterGlowGroup(MerchantBuyBackItemItemButton, "Merchant"), GetBuybackItemLink(GetNumBuybackItems()))
end

function LTItemGlow:UpdateMerchant(itemLinkFunction)
  local regButton
  for i = 1, MERCHANT_ITEMS_PER_PAGE do
    regButton = self:RegisterGlowGroup(_G["MerchantItem" .. i .. "ItemButton"], "Merchant")
    self:SetGlowFromItemLink(regButton, itemLinkFunction((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i))
  end
end

-----------------------------------    TRADE    ------------------------------------------

function LTItemGlow:UpdateTrade()
  for i = 1, 7 do
    self:UpdateTradePlayerItem(nil, i)
    self:UpdateTradeTargetItem(nil, i)
  end
end

function LTItemGlow:UpdateTradePlayerItem(event, itemIndex)
  self:SetGlowFromItemLink(self:RegisterGlowGroup(_G["TradePlayerItem" .. itemIndex .. "ItemButton"], "Trade"), GetTradePlayerItemLink(itemIndex))
end

function LTItemGlow:UpdateTradeTargetItem(event, itemIndex)
  self:SetGlowFromItemLink(self:RegisterGlowGroup(_G["TradeRecipientItem" .. itemIndex .. "ItemButton"], "Trade"), GetTradeTargetItemLink(itemIndex))
end

-----------------------------------  TRADESKILL  -----------------------------------------

function LTItemGlow:UpdateTradeSkill(id)
  self:SetGlowFromItemLink(self:RegisterGlowGroup(TradeSkillSkillIcon, "Tradeskill"), GetTradeSkillItemLink(id))

  local regButton
  for i = 1, GetTradeSkillNumReagents(id) do
    regButton = self:RegisterGlowGroup(_G["TradeSkillReagent" .. i], "Tradeskill")
    self:SetGlowFromItemLink(regButton, GetTradeSkillReagentItemLink(id, i), _G["TradeSkillReagent" .. i .. "IconTexture"])
  end
end
