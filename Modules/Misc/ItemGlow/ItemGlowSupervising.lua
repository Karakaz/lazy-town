
------------------------------  SUPERVISING ITEM GLOW  -----------------------------------

function LTItemGlow:OnInitialize()
  self:GeneralSetup('itemGlow', LTMisc.db)
  self.glowFrames = {}
end

function LTItemGlow:OnEnable()
  self:UpdateItemGlow()
end

function LTItemGlow:OnDisable()
  self:UpdateItemGlow()
  self:UnregisterEvent('ADDON_LOADED')
  self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
end

function LTItemGlow:UpdateItemGlow()
  if self:IsEnabled() and LTMisc:IsEnabled() then
    self.EquipmentSlots = {[0] = "Ammo", "Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands",
                           "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand", "Ranged", "Tabard"}
    self:Supervise(true)
  else
    self:Supervise(false)
    self.EquipmentSlots = nil
  end
end

function LTItemGlow:Supervise(moduleEnabled)
  local dbG = self.db.where
  local GlowGroups = {Bank = dbG.bank, Character = dbG.char, Containers = dbG.containers, Craft = dbG.craft, EquippedBags = dbG.eqBags, GuildBank = dbG.guildBank,
                      Inspect = dbG.inspect, Mail = dbG.mail, Merchant = dbG.merch, Trade = dbG.trade, Tradeskill = dbG.tradeSkill}
  for group, enabled in pairs(GlowGroups) do
    if enabled and moduleEnabled then
      self[group .. "Setup"](self)
    else
      self[group .. "Teardown"](self)
      self:HideGlowOnFrames(group)
    end
  end
end

function LTItemGlow:HideGlowOnFrames(group)
  for _, frame in ipairs(self.glowFrames) do
    if frame.glowGroup == group then
      frame.glow:Hide()
    end
  end
end

-----------------------------------    COMMON    -----------------------------------------

function LTItemGlow:RegisterGlowGroup(frame, group)
  frame.glowGroup = group
  return frame
end

function LTItemGlow:ADDON_LOADED(event, addon)
  if self:IsEnabled() then
    if addon == "Blizzard_CraftUI" and self.db.where.craft then
        self:SecureHook("CraftFrame_SetSelection")
    end
    if addon == "Blizzard_InspectUI" and self.db.where.inspect then
        self:SecureHook("InspectFrame_OnShow")
        self:SecureHook("InspectFrame_OnHide", "InspectCheckAndUnregisterU_I_C")
    end
    if addon == "Blizzard_TradeSkillUI" and self.db.where.tradeSkill then
        self:SecureHook("TradeSkillFrame_SetSelection")
    end
  end
  if IsAddOnLoaded("Blizzard_CraftUI") and IsAddOnLoaded("Blizzard_InspectUI") and IsAddOnLoaded("Blizzard_TradeSkillUI") then
    self:UnregisterEvent('ADDON_LOADED')
  end
end

function LTItemGlow:UNIT_INVENTORY_CHANGED(event, unit)
  if unit == 'player' and CharacterFrame:IsShown() and self.db.where.char then
    self:UpdateCharacter()
  end
  if unit == 'target' and InspectFrame:IsShown() and self.db.where.inspect then
    self:UpdateInspect()
  end
end

------------------------------------    BANK    ------------------------------------------

function LTItemGlow:BankSetup()
  self:SecureHook("BankFrame_OnShow", "UpdateBank")
  self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", "UpdateBank")
end

function LTItemGlow:BankTeardown()
  self:Unhook("BankFrame_OnShow")
  self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
end

-----------------------------------  CHARACTER   -----------------------------------------

function LTItemGlow:CharacterSetup()
  self:SecureHook("CharacterFrame_OnShow")
  self:SecureHook("CharacterFrame_OnHide", "CharacterCheckAndUnregisterU_I_C")
end

function LTItemGlow:CharacterTeardown()
  self:Unhook("CharacterFrame_OnShow")
  self:Unhook("CharacterFrame_OnHide")
  self:InspectCheckAndUnregisterU_I_C()
end

function LTItemGlow:CharacterFrame_OnShow()
  self:RegisterEvent('UNIT_INVENTORY_CHANGED')
  self:UpdateCharacter()
end

function LTItemGlow:CharacterCheckAndUnregisterU_I_C()
  if not InspectFrame or InspectFrame and not InspectFrame:IsShown() or not self.db.where.inspect then
    self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
  end
end

-----------------------------------  CONTAINERS  -----------------------------------------

function LTItemGlow:ContainersSetup()
  self:SecureHook("OpenAllBags", "UpdateContainers")
  self:SecureHook("ContainerFrame_OnShow")
  self:RegisterEvent('BAG_UPDATE')
  self.containerBucket = self:RegisterBucketMessage('CONTAINER_GLOW_UPDATE', 0.1, "UpdateContainers")
end

function LTItemGlow:ContainersTeardown()
  self:Unhook("OpenAllBags")
  self:Unhook("ContainerFrame_OnShow")
  self:UnregisterEvent('BAG_UPDATE')
  self:UnregisterBucket(self.containerBucket)
end

function LTItemGlow:ContainerFrame_OnShow()
  self:SendMessage('CONTAINER_GLOW_UPDATE')
end

function LTItemGlow:BAG_UPDATE()
  if self.firstSetContainers then
    self:SendMessage('CONTAINER_GLOW_UPDATE')
  else
    self:UpdateContainers()
    self.firstSetContainers = true
  end
end

-----------------------------------    CRAFT    ------------------------------------------

function LTItemGlow:CraftSetup()
  if IsAddOnLoaded("Blizzard_CraftUI") then
    self:SecureHook("CraftFrame_SetSelection", "UpdateCraft")
  else
    self:RegisterEvent('ADDON_LOADED')
  end
end

function LTItemGlow:CraftTeardown()
  self:Unhook("CraftFrame_SetSelection")
end

---------------------------------  EQUIPPED BAGS  ----------------------------------------

function LTItemGlow:EquippedBagsSetup()
  self:Hook(CharacterBag0SlotIconTexture, "SetTexture", function() LTItemGlow:SendMessage('BAG_TEXTURE_BURST') end, true)
  self.bagTextureBucket = self:RegisterBucketMessage('BAG_TEXTURE_BURST', 0.01, "UpdateEquippedBags")
end

function LTItemGlow:EquippedBagsTeardown()
  self:Unhook(CharacterBag0SlotIconTexture, "SetTexture")
  self:UnregisterBucket(self.bagTextureBucket)
end

---------------------------------   GUILD BANK   -----------------------------------------

function LTItemGlow:GuildBankSetup()
  self:RegisterEvent('GUILDBANKFRAME_OPENED')
  self:RegisterEvent('GUILDBANKFRAME_CLOSED')
end

function LTItemGlow:GuildBankTeardown()
  self:UnregisterEvent('GUILDBANKFRAME_OPENED')
  self:UnregisterEvent('GUILDBANKFRAME_CLOSED')
end

function LTItemGlow:GUILDBANKFRAME_OPENED()
  if not self.guildBankTimer then
    self.guildBankTimer = LibStub('AceTimer-3.0'):ScheduleRepeatingTimer(self.UpdateGuildBank, 0.1, self)
  end
end

function LTItemGlow:GUILDBANKFRAME_CLOSED()
  if self.guildBankTimer then
    LibStub('AceTimer-3.0'):CancelTimer(self.guildBankTimer)
    self.guildBankTimer = nil
  end
end

-----------------------------------   INSPECT   ------------------------------------------

function LTItemGlow:InspectSetup()
  if IsAddOnLoaded("Blizzard_InspectUI") then
    self:SecureHook("InspectFrame_OnShow")
    self:SecureHook("InspectFrame_OnHide", "InspectCheckAndUnregisterU_I_C")
  else
    self:RegisterEvent('ADDON_LOADED')
  end
end

function LTItemGlow:InspectTeardown()
  self:Unhook("InspectFrame_OnShow")
  self:Unhook("InspectFrame_OnHide")
  self:UnregisterEvent('PLAYER_TARGET_CHANGED')
  self:InspectCheckAndUnregisterU_I_C()
end

function LTItemGlow:InspectFrame_OnShow()
  self:RegisterEvent('PLAYER_TARGET_CHANGED', "UpdateInspect")
  self:RegisterEvent('UNIT_INVENTORY_CHANGED')
  self:UpdateInspect()
end

function LTItemGlow:InspectCheckAndUnregisterU_I_C()
  if not CharacterFrame:IsShown() or not self.db.where.char then
    self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
  end
end

-----------------------------------     MAIL     -----------------------------------------

function LTItemGlow:MailSetup()
  self:SecureHook("InboxFrame_Update", "UpdateInbox")
  self:SecureHook("OpenMail_Update", "UpdateOpenMail")
  self.mailSendBucket = self:RegisterBucketEvent({'MAIL_SHOW', 'MAIL_SEND_INFO_UPDATE', 'MAIL_SEND_SUCCESS'}, 0.01, "UpdateSendMail")
end

function LTItemGlow:MailTeardown()
  self:Unhook("InboxFrame_Update")
  self:Unhook("OpenMail_Update")
  self:UnregisterBucket(self.mailSendBucket)
end

-----------------------------------   MERCHANT   -----------------------------------------

function LTItemGlow:MerchantSetup()
  self:SecureHook("MerchantFrame_UpdateMerchantInfo", "UpdateMerchantGoods")
  self:SecureHook("MerchantFrame_UpdateBuybackInfo")
end

function LTItemGlow:MerchantTeardown()
  self:Unhook("MerchantFrame_UpdateMerchantInfo")
  self:Unhook("MerchantFrame_UpdateBuybackInfo")
end

function LTItemGlow:MerchantFrame_UpdateBuybackInfo()
  self:UpdateMerchant(GetBuybackItemLink)
end

-----------------------------------    TRADE    ------------------------------------------

function LTItemGlow:TradeSetup()
  self:SecureHook("TradeFrame_OnShow", "UpdateTrade")
  self:RegisterEvent('TRADE_PLAYER_ITEM_CHANGED', "UpdateTradePlayerItem")
  self:RegisterEvent('TRADE_TARGET_ITEM_CHANGED', "UpdateTradeTargetItem")
end

function LTItemGlow:TradeTeardown()
  self:Unhook("TradeFrame_OnShow")
  self:UnregisterEvent('TRADE_PLAYER_ITEM_CHANGED')
  self:UnregisterEvent('TRADE_TARGET_ITEM_CHANGED')
end

-----------------------------------  TRADESKILL  -----------------------------------------

function LTItemGlow:TradeskillSetup()
  if IsAddOnLoaded("Blizzard_TradeSkillUI") then
    self:SecureHook("TradeSkillFrame_SetSelection", "UpdateTradeSkill")
  else
    self:RegisterEvent('ADDON_LOADED') --handler in MiscSupervising.lua
  end
end

function LTItemGlow:TradeskillTeardown()
  self:Unhook("TradeSkillFrame_SetSelection")
end
