
function LTMisc:UpdateMacroText()
  self:UpdateActionButtonTextAlpha("Name", self.db.hideMacroText and self:IsEnabled())
end

function LTMisc:UpdateHotKeyText()
  self:UpdateActionButtonTextAlpha("HotKey", self.db.hideHotKeyText and self:IsEnabled())
end

function LTMisc:UpdateActionButtonTextAlpha(textName, enabled)
  local actionButtons = {"ActionButton", "MultiBarLeftButton", "MultiBarRightButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton"}
  for i = 1, #actionButtons do
    for j = 1, 12 do
      _G[actionButtons[i] .. j .. textName]:SetAlpha(enabled and 0 or 1)
    end
  end
end

function LTMisc:UpdateGryphonAlpha()
  MainMenuBarLeftEndCap:SetAlpha(self:IsEnabled() and self.db.gryphonAlpha or 1)
  MainMenuBarRightEndCap:SetAlpha(self:IsEnabled()and self.db.gryphonAlpha or 1)
end

function LTMisc:UpdatePortraits()
  if self.db.classIconPortraits and self:IsEnabled() then
    self:RawHook("SetPortraitTexture", true)
  else
    self:Unhook("SetPortraitTexture")
    self:UndoTexCoords()
  end
  self:UpdateShownPortraits()
end

function LTMisc:UndoTexCoords()
  PlayerPortrait:SetTexCoord(0, 1, 0, 1)
  TargetPortrait:SetTexCoord(0, 1, 0, 1)
  TargetofTargetPortrait:SetTexCoord(0, 1, 0, 1)
  for i = 1, 4 do
    _G["PartyMemberFrame" .. i .. "Portrait"]:SetTexCoord(0, 1, 0, 1)
  end
end

function LTMisc:UpdateShownPortraits()
  SetPortraitTexture(PlayerPortrait, 'player')
  if UnitExists('target') then
    SetPortraitTexture(TargetPortrait, 'target')
  end
  if UnitExists('targettarget') then
    SetPortraitTexture(TargetofTargetPortrait, 'targettarget')
  end
  for i = 1, GetNumPartyMembers() do
    SetPortraitTexture(_G["PartyMemberFrame" .. i .. "Portrait"], "party" .. i)
  end
end

function LTMisc:SetPortraitTexture(portrait, unit, ...)
  self.hooks.SetPortraitTexture(portrait, unit, ...)
  if portrait then
    if UnitIsPlayer(unit) then
      local _, class = UnitClass(unit)
      local t = CLASS_BUTTONS[class]
      if t then
        portrait:SetTexture("Interface\\AddOns\\LazyTown\\Textures\\UI-Classes-Circles")
        if unit == "targettarget" then
          portrait:SetTexCoord(t[1] + 0.023, t[2] - 0.007, t[3] + 0.012, t[4] - 0.012)
        else
          portrait:SetTexCoord(unpack(t))
        end
      end
    else
      portrait:SetTexCoord(0, 1, 0, 1)
    end
  end
end
