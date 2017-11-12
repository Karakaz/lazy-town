
function LTMisc:OnInitialize()
  self:GeneralSetup('misc')
end

function LTMisc:OnEnable()
  self:UpdateAll()
end

function LTMisc:OnDisable()
  self:UpdateAll()
  self:UnregisterEvent('ADDON_LOADED')
end

function LTMisc:UpdateAll()
  self:UpdateQuestLevels()
  self:UpdateArenaPoints()
  self:UpdateMacroText()
  self:UpdateHotKeyText()
  self:UpdateGryphonAlpha()
  self:UpdatePortraits()
  self:UpdateZoneLevels()
  self:UpdateCoordinates()
  self:UpdateMapAlpha()
  self:UpdateCloseButton()
  self:UpdateWorldMapButton()
  self:UpdateNorthMark()
  self:UpdateTimeButton()
  self:UpdateZoomButtons()
  self:UpdateScrollZoom()
  self:UpdateBagType()
  self:UpdateGrid()
end

function LTMisc:ADDON_LOADED(event, addon)
  if self:IsEnabled() then
    if addon == "Blizzard_InspectUI" then
      if self.db.arenaPoints then
        self:RawHook("InspectPVPTeam_Update", true)
        self:SetTeamAnchors({inspect = true})
      end
    end
  end
end
