
function LTAutomation:OnInitialize()
  self:GeneralSetup('auto')
end

function LTAutomation:OnEnable()
  self:UpdateAll()
end

function LTAutomation:OnDisable()
  self:UpdateAll()
end

function LTAutomation:UpdateAll()
  self:UpdateRepair()
  self:UpdateQuest()
  self:UpdateObjTooltip()
  self:UpdateRelease()
  self:UpdateParty()
  self:UpdateBlocks()
  self:UpdateConfirm()
  self:UpdateMail()
  self:UpdateSummon()
  self:UpdateRess()
end

function LTAutomation:UpdateRepair()
  if self:IsEnabled() and self.db.repair then self:RegisterEvent('MERCHANT_SHOW')
  else self:UnregisterEvent('MERCHANT_SHOW') end
end

function LTAutomation:UpdateQuest()
  if self:IsEnabled() and self.db.qAccept then self:RegisterEvent('QUEST_DETAIL')
  else self:UnregisterEvent('QUEST_DETAIL') end

  if self:IsEnabled() and self.db.qTurnIn then self:RegisterEvent('QUEST_PROGRESS')
                                               self:RegisterEvent('QUEST_COMPLETE')
  else self:UnregisterEvent('QUEST_PROGRESS')
       self:UnregisterEvent('QUEST_COMPLETE') end

  if self:IsEnabled() and self.db.qConfirm then self:RegisterEvent('QUEST_ACCEPT_CONFIRM')
  else self:UnregisterEvent('QUEST_ACCEPT_CONFIRM') end
end

function LTAutomation:UpdateObjTooltip()
  if self:IsEnabled() and self.db.objTooltip.enabled then
    if self.objTooltip then
      local tooltip= self.objTooltip

      tooltip:SetScale(tooltip.db.scale)

      if tooltip.timePassed < self.db.objTooltip.timeBeforeFade or tooltip:GetAlpha() > tooltip.db.alpha then
        tooltip:SetAlpha(tooltip.db.alpha)
      end
    else
      self:CreateObjectiveTooltip()
    end
  else
    if self.objTooltip then
      self.objTooltip:ResetTooltip()
      self.objTooltip:Hide()
    end
  end
end

function LTAutomation:CreateObjectiveTooltip()
  local tooltip = CreateFrame("GameTooltip", "LTAutomation_ObjTooltip", nil, "GameTooltipTemplate")
  tooltip.db = self.db.objTooltip
  LazyTown.RestoreAllPoints(tooltip)
  tooltip:EnableMouse(true)
  tooltip:SetMovable(true)
  tooltip:RegisterForDrag("RightButton")
  tooltip:SetScript('OnDragStart', function(self) self:StartMoving() end)
  tooltip:SetScript('OnDragStop', function(self)  self:StopMovingOrSizing() LazyTown.SaveAllPoints(self) end)
  tooltip:SetScript('OnEnter', function(self) self:ResetTooltip() end)
  tooltip:SetScript('OnLeave', function(self) self.timer = LTAutomation:ScheduleRepeatingTimer("ObjTooltipFade", 0.1, 0.1) end)
  tooltip:SetScript('OnMouseUp', function(self, button) self:ResetTooltip() self:Hide() end)
  function tooltip:ResetTooltip()
    if self.timer then
      LTAutomation:CancelTimer(self.timer)
      self.timer = nil
    end
    self:SetAlpha(self.db.alpha)
    self.timePassed = 0
  end
  tooltip:ResetTooltip()
  self.objTooltip = tooltip
end

function LTAutomation:ObjTooltipFade(delta)
  local tooltip = self.objTooltip
  if tooltip.timer then
    tooltip.timePassed = tooltip.timePassed + delta
    if tooltip.timePassed >= tooltip.db.timeBeforeFade then
      local alpha = tooltip:GetAlpha()
      if alpha <= 0.01 then
        tooltip:ResetTooltip()
        tooltip:Hide()
      else
        tooltip:SetAlpha(alpha - delta / tooltip.db.fadeTime * tooltip.db.alpha)
      end
    end
  end
end

function LTAutomation:UpdateRelease()
  if self:IsEnabled() and self.db.releaseBG then self:RegisterEvent('PLAYER_DEAD')
  else self:UnregisterEvent('PLAYER_DEAD') end
end

function LTAutomation:UpdateParty()
  if self:IsEnabled() and self.db.whoParty or self:AtLeastOneAutoAccept() then self:RegisterEvent('PARTY_INVITE_REQUEST')
  else self:UnregisterEvent('PARTY_INVITE_REQUEST') end
end

function LTAutomation:AtLeastOneAutoAccept()
  for _, enabled in pairs(self.db.autoAccept) do
    if enabled then  return true  end
  end
end

function LTAutomation:UpdateBlocks()
  if self:IsEnabled() and self.db.blockDuels then self:RegisterEvent('DUEL_REQUESTED')
  else self:UnregisterEvent('DUEL_REQUESTED') end

  if self:IsEnabled() and self.db.blockTrades then self:SecureHook("TradeFrame_Update")
  else self:Unhook("TradeFrame_Update") end

  if self:IsEnabled() and self.db.blockGInvites then self:RegisterEvent('GUILD_INVITE_REQUEST')
  else self:UnregisterEvent('GUILD_INVITE_REQUEST') end
  
  if self:IsEnabled() and self.db.blockGPetitions then self:RegisterEvent('PETITION_SHOW')
  else self:UnregisterEvent('PETITION_SHOW') end
end

function LTAutomation:UpdateConfirm()
  if self:IsEnabled() and self.db.confirmBOP then self:RegisterEvent('LOOT_BIND_CONFIRM')
  else self:UnregisterEvent('LOOT_BIND_CONFIRM') end

  if self:IsEnabled() and self.db.confirmRoll then self:RegisterEvent('CONFIRM_LOOT_ROLL')
  else self:UnregisterEvent('CONFIRM_LOOT_ROLL') end

  if self:IsEnabled() and self.db.confirmReplace then self:RegisterEvent('REPLACE_ENCHANT')
  else self:UnregisterEvent('REPLACE_ENCHANT') end
end

function LTAutomation:UpdateMail()
  if self:IsEnabled() and self:TakeAnyMailItems() then
    self:SetupMail()
  else
    self:TeardownMail()
  end
end

function LTAutomation:TakeAnyMailItems()
  local dbA = self.db
  return dbA.takeSaleGold or dbA.takeOutbidGold or dbA.takeBoughtItems or dbA.takeExpiredItems or dbA.takeCancelledItems
end

function LTAutomation:SetupMail()
  self:HookScript(MailFrame, 'OnShow', "MailFrame_OnShow")
  if not self.inboxBucket then
    self.inboxBucket = self:RegisterBucketEvent('MAIL_INBOX_UPDATE', 0.05, "ScanInbox")
  end
  self.AHFormats = {SaleGold = AUCTION_SOLD_MAIL_SUBJECT:gsub("%%s", ".*"),
                    OutbidGold = AUCTION_OUTBID_MAIL_SUBJECT:gsub("%%s", ".*"), 
                    BoughtItems = AUCTION_WON_MAIL_SUBJECT:gsub("%%s", ".*"),
                    ExpiredItems = AUCTION_EXPIRED_MAIL_SUBJECT:gsub("%%s", ".*"),
                    CancelledItems = AUCTION_REMOVED_MAIL_SUBJECT:gsub("%%s", ".*")}
end

function LTAutomation:MailFrame_OnShow()
  self.firstScan = true
  self.saleMoney = 0
  self.outbidMoney = 0
  self.boughtItems = 0
  self.expiredItems = 0
  self.cancelledItems = 0
  self.skippedItems = 0
  self.havePrintedSummary = false
end

function LTAutomation:TeardownMail()
  self:Unhook(MailFrame, 'OnShow')
  if self.inboxBucket then
    self:UnregisterBucket(self.inboxBucket)
    self.inboxBucket = nil
  end
  self.AHFormats = nil
end

function LTAutomation:UpdateSummon()
  if self:IsEnabled() and self.db.summonAccept then
    self:RegisterEvent('CONFIRM_SUMMON')
    self:Hook(StaticPopupDialogs['CONFIRM_SUMMON'].OnHide, "DialogSummon_OnHide")
  else
    self:UnregisterEvent('CONFIRM_SUMMON')
    self:Unhook(StaticPopupDialogs['CONFIRM_SUMMON'].OnHide)
  end
end

function LTAutomation:UpdateRess()
  if self:IsEnabled() and self.db.ressAccept then
    self:RegisterEvent('RESURRECT_REQUEST')
    self:Hook(StaticPopupDialogs['RESURRECT_NO_SICKNESS'].OnCancel, "DialogRess_OnCancel")
  else
    self:UnregisterEvent('RESURRECT_REQUEST')
    self:Unhook(StaticPopupDialogs['RESURRECT_NO_SICKNESS'].OnCancel)
  end
end
