
function LTMisc:UpdateQuestLevels()
  if self.db.questLevels and self:IsEnabled() then
    self.QuestTags = {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "!", Heroic = "H", Repeatable = "?"}
    self:RawHook("QuestLog_Update", true)
    self:RawHook("QuestWatch_Update", true)
    self:RawHook("GossipFrameUpdate", true)
    self:RawHook("QuestFrameGreetingPanel_OnShow", true)
  else
    self.QuestTags = nil
    self:Unhook("QuestLog_Update")
    self:Unhook("QuestWatch_Update")
    self:Unhook("GossipFrameUpdate")
    self:Unhook("QuestFrameGreetingPanel_OnShow")
  end
end

function LTMisc:QuestLog_Update(...)
  self.hooks.QuestLog_Update(...)

  local scrollOffset = FauxScrollFrame_GetOffset(QuestLogListScrollFrame)

  for i = 1, (GetNumQuestLogEntries()) do
    local newTitle = self:CheckIfQuestAndAddTags(i + scrollOffset)
    if newTitle then
      local titleFontString = _G["QuestLogTitle" .. i]
      if titleFontString then
        titleFontString:SetText(newTitle)
      end
    end
  end
end

function LTMisc:CheckIfQuestAndAddTags(qIndex)
  local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(qIndex)
  if not isHeader and questTitle then
    return self:ApplyTagsToTitle(level, questTag, suggestedGroup, isDaily, questTitle), questTitle
  end
end

function LTMisc:ApplyTagsToTitle(level, questTag, suggestedGroup, isDaily, questTitle)
  if not suggestedGroup or suggestedGroup == 0 then  suggestedGroup = nil  end
  if self.db.onlyLevel then
    return format("[%s] %s", level, questTitle)
  else
    return format("[%s%s%s%s] %s", level, questTag and self.QuestTags[questTag] or "", isDaily and self.QuestTags.Daily or "", suggestedGroup or "", questTitle)
  end
end

function LTMisc:QuestWatch_Update(...)
  self.hooks.QuestWatch_Update(...)

  for i = 1, GetNumQuestWatches() do
    local qIndex = GetQuestIndexForWatch(i)
    if qIndex then
      local numObjectives = GetNumQuestLeaderBoards(qIndex)

      if numObjectives > 0 then
        self:FindTitleAndAddTags(self:CheckIfQuestAndAddTags(qIndex))
      end
    end
  end
end

function LTMisc:FindTitleAndAddTags(newTitle, curTitle)
  for i = 1, MAX_QUESTWATCH_LINES do
    if _G["QuestWatchLine" .. i]:GetText() == curTitle then
      _G["QuestWatchLine" .. i]:SetText(newTitle)
      return
    end
  end
end

function LTMisc:GossipFrameUpdate(...)
  self.hooks.GossipFrameUpdate(...)
--  LTMisc:Print("GossipFrameUpdate")
  local buttonIndex = 1
  buttonIndex = self:AddTagsToGossipTitles(false, buttonIndex, GetGossipAvailableQuests())
  self:AddTagsToGossipTitles(true, buttonIndex, GetGossipActiveQuests())
end

function LTMisc:AddTagsToGossipTitles(isActive, buttonIndex, ...)
  local num = select('#', ...)
  if num == 0 then return buttonIndex end

  for i = 1, num, 3 do
    local title, level, isTrivial = select(i, ...)
    if level ~= -1 then
      _G["GossipTitleButton"..buttonIndex]:SetFormattedText("[%d] " .. (isActive and isTrivial and TRIVIAL_QUEST_DISPLAY or NORMAL_QUEST_DISPLAY), level, title)
    end
    buttonIndex = buttonIndex + 1
  end
  return buttonIndex + 1
end

function LTMisc:QuestFrameGreetingPanel_OnShow(...)
  self.hooks.QuestFrameGreetingPanel_OnShow(...)

  local numActive = GetNumActiveQuests()
  local numAvailable = GetNumAvailableQuests()

--  self:Print("numActive=" .. numActive)
--  self:Print("numAvailable=" .. numAvailable)

  for i = 1, numActive do
    local questButton = _G["QuestTitleButton" .. i]
    questButton:SetFormattedText("[%d] %s", GetActiveLevel(i), questButton:GetText())
  end
  for i = 1, numAvailable do
    local questButton = _G["QuestTitleButton" .. i + numActive]
    questButton:SetFormattedText("[%d] %s", GetAvailableLevel(i), questButton:GetText())
  end
end
