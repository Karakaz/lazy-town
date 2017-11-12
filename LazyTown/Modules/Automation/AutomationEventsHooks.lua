
function LTAutomation:MERCHANT_SHOW(event)
  if self.db.repair and not IsShiftKeyDown() and CanMerchantRepair() then
    local repairPrint = self.db.repairPrint
    local repairCost, canRepair = GetRepairAllCost()
    if canRepair and repairCost > 0 then
      if self.db.repairGuild and self:CanPayWithGuildFunds(repairCost, repairPrint) then
        RepairAllItems(1)
        if repairPrint then
          self:Print(LazyTown:GetChat(), (GetGuildInfo('player')) .. " got your back and paid for your repairs, " .. ValueToMoneyString(repairCost))
        end
      else
        if GetMoney() >= repairCost then
          RepairAllItems()
          if repairPrint then self:Print(LazyTown:GetChat(), "Repaired all items, cost " .. ValueToMoneyString(repairCost)) end
        else
          if repairPrint then self:Print(LazyTown:GetChat(), "Not enough personal funds to pay repair cost, " .. ValueToMoneyString(repairCost)) end
        end
      end
    end
  end
end

function LTAutomation:CanPayWithGuildFunds(repairCost, repairPrint)
  if CanGuildBankRepair() then
    local amount = GetGuildBankWithdrawMoney()
    local guildBankMoney = GetGuildBankMoney()
    if amount == -1 then
      amount = guildBankMoney
    else
      amount = min(amount, guildBankMoney)
    end
    if amount >= repairCost then
      return true
    else
      if repairPrint then self:Print(LazyTown:GetChat(), "Not enough guild funds to pay repair cost or you've reached your daily limit") end
    end
  else
    if repairPrint then self:Print(LazyTown:GetChat(), "Your guild does not offer to pay for your repairs") end
  end
end

function LTAutomation:QUEST_DETAIL(event)
  if self.db.qAccept and not IsShiftKeyDown() then
    if self.db.objTooltip.enabled then
      self:StartObjTooltip(GetTitleText(), GetObjectiveText())
    end
    AcceptQuest()
  end
end

function LTAutomation:StartObjTooltip(questTitle, questObjective)
  local tooltip = self.objTooltip
  if tooltip:IsShown() then
    tooltip:ResetTooltip()
    tooltip:Hide()
  end
  tooltip:SetOwner(UIParent, 'ANCHOR_PRESERVE')
  tooltip:AddLine(questTitle, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
  tooltip:AddLine(questObjective, 1, 1, 1, true)
  tooltip:Show()
  tooltip:SetAlpha(tooltip.db.alpha)
  tooltip.timer = self:ScheduleRepeatingTimer("ObjTooltipFade", 0.1, 0.1)
end

function LTAutomation:QUEST_PROGRESS(event)
  if self.db.qTurnIn and not IsShiftKeyDown() and IsQuestCompletable() then
    CompleteQuest()
  end
end

function LTAutomation:QUEST_COMPLETE(event)
  local nrChoices = GetNumQuestChoices()
  if self.db.qTurnIn and not IsShiftKeyDown() and nrChoices <= 1 then
    GetQuestReward(nrChoices)
  end
end

function LTAutomation:QUEST_ACCEPT_CONFIRM(event)
  if self.db.qConfirm and not IsShiftKeyDown() then
    ConfirmAcceptQuest()
    StaticPopup_Hide('QUEST_ACCEPT_CONFIRM')
  end
end

function LTAutomation:PLAYER_DEAD(event)
  local inInstance, instanceType = IsInInstance()
  if self.db.releaseBG and inInstance and instanceType == 'pvp' and not HasSoulstone() then
    local releaseTime = self.db.releaseTime
    if releaseTime == 0 then
      RepopMe()
    else
      self:ScheduleTimer(function() if UnitIsDead('player') then RepopMe() end end, releaseTime)
    end
  end
end

function LTAutomation:PARTY_INVITE_REQUEST(event, inviter)
  local isFriend, isGuildMate = self:GetFriends()[inviter], self:GetGuildMates()[inviter]
  if self.db.whoParty and not isFriend and not isGuildMate then
    SendWho('n-"' .. inviter .. '"')
  end
  for tag, enabled in pairs(self.db.autoAccept) do
    if enabled then
      if tag == 'Friends' then
        if isFriend then    AcceptGroup() return  end
      elseif tag == 'Guild' then
        if isGuildMate then AcceptGroup() return  end
      elseif tag == inviter then
        AcceptGroup() return
      end
    end
  end
end

function LTAutomation:DUEL_REQUESTED(event, opponentName)
  if self.db.duelsFilter == 'friendsGuild' then
    if self:GetFriends()[opponentName] or self:GetGuildMates()[opponentName] then  return  end
  elseif self.db.duelsFilter == 'friends' then
    if self:GetFriends()[opponentName] then  return  end
  end
  CancelDuel()
  StaticPopup_Hide('DUEL_REQUESTED')
end

function LTAutomation:TradeFrame_Update()
  local otherPlayer = TradeFrameRecipientNameText:GetText()
  if self.db.tradesFilter == 'friendsGuild' then
    if self:GetFriends()[otherPlayer] or self:GetGuildMates()[otherPlayer] then  return  end
  elseif self.db.tradesFilter == 'friends' then
    if self:GetFriends()[otherPlayer] then  return  end
  end
  CancelTrade()
  HideUIPanel(TradeFrame)
end

function LTAutomation:GUILD_INVITE_REQUEST(event, inviter, guildname)
  if self.db.gInvitesFilter == 'friends' then
    if self:GetFriends()[inviter] then  return  end
  end
  DeclineGuild()
  StaticPopup_Hide('GUILD_INVITE')
end

function LTAutomation:PETITION_SHOW(event)
  local _, _, _, _, originator, isOriginator = GetPetitionInfo()
  if not isOriginator and self.db.gPetitionsFilter == 'friends' then
    if self:GetFriends()[originator] then  return  end
  end
  ClosePetition()
end

function LTAutomation:GetFriends()
  local friends = {}
  for i = 1, GetNumFriends() do
    friends[(GetFriendInfo(i))] = true
  end
  return friends
end

function LTAutomation:GetGuildMates()
  local guildMates = {}
  for i = 1, GetNumGuildMembers(true) do
    guildMates[(GetGuildRosterInfo(i))] = true
  end
  return guildMates
end

function LTAutomation:LOOT_BIND_CONFIRM(event, slot)
  ConfirmLootSlot(slot)
end

function LTAutomation:CONFIRM_LOOT_ROLL(event, id, rolltype)
  ConfirmLootRoll(id, rolltype)
end

function LTAutomation:REPLACE_ENCHANT(event, newEnchant, curEnchant)
  if GetCraftName() == 'Enchanting' then
    if not (self.db.sameEnchant and newEnchant ~= curEnchant) then
      ReplaceEnchant()
    end
  end
end

function LTAutomation:CONFIRM_SUMMON()
  if self.summonTimer then
    self:CancelTimer(self.summonTimer)
    self.summonTimer = nil
  end
  if self.summonOverrideTimer then
    self:CancelTimer(self.summonOverrideTimer)
    self.summonOverrideTimer = nil
  end
  
  if self.db.summonTime == 0 then
    self:AcceptSummon()
  else
    self.summonTimer = self:ScheduleTimer(self.db.summonTime, "AcceptSummon")
  end
  if self.db.summonOverride and (self.summonTimer or self:IsEventRegistered('PLAYER_REGEN_ENABLED')) then
    self.summonOverrideTimer = self:ScheduleTimer(GetSummonConfirmTimeLeft() - 1.5, "AcceptSummon", true)
  end
end

function LTAutomation:AcceptSummon(override)
  if UnitAffectingCombat('player') then
    if self.db.summonCombat and not override then
      self:RegisterEvent('PLAYER_REGEN_ENABLED')
    end
  else
    ConfirmSummon()
  end
  self.summonTimer = nil
end

function LTAutomation:PLAYER_REGEN_ENABLED()
  if not self.summonTimer then
    self.summonTimer = self:ScheduleTimer(self.db.summonCombatTime, "AcceptSummon")
  end
  self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function LTAutomation:DialogSummon_OnHide()
  if self.summonTimer then
    self:CancelTimer(self.summonTimer)
    self.summonTimer = nil
  end
  self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function LTAutomation:RESURRECT_REQUEST(source)
  
end

function LTAutomation:DialogRess_OnCancel()
  if self.ressTimer then
    self:CancelTimer(self.ressTimer)
    self.ressTimer = nil
  end
end
