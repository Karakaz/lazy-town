
function LTMisc:UpdateCloseButton()
  if not simpleMinimap then
    if self.db.hideCloseButton and self:IsEnabled() then
      MinimapToggleButton:Hide()
      MinimapBorderTop:SetTexture("Interface\\AddOns\\LazyTown\\Textures\\UI-MINIMAP-BORDER")
      MinimapBorder:SetTexture("Interface\\AddOns\\LazyTown\\Textures\\UI-MINIMAP-BORDER")
      MinimapZoneTextButton:SetPoint('CENTER', 7, 82.5)
    else
      MinimapToggleButton:Show()
      MinimapBorderTop:SetTexture("Interface\\Minimap\\UI-Minimap-Border")
      MinimapBorder:SetTexture("Interface\\Minimap\\UI-Minimap-Border")
      MinimapZoneTextButton:SetPoint('CENTER', -3, 83)
    end
  end
end

function LTMisc:UpdateWorldMapButton()
  if self.db.hideMapButton and self:IsEnabled() then
    MiniMapWorldMapButton:Hide()
  else
    MiniMapWorldMapButton:Show()
  end
end

function LTMisc:UpdateNorthMark()
  if self.db.hideNorth and self:IsEnabled() then
    MinimapNorthTag:SetAlpha(0)
  else
    MinimapNorthTag:SetAlpha(1)
  end
end

function LTMisc:UpdateTimeButton()
  if self.db.hideTimeButton and self:IsEnabled() then
    GameTimeFrame:Hide()
  else
    GameTimeFrame:Show()
  end
end

function LTMisc:UpdateZoomButtons()
  if self.db.hideZoom and self:IsEnabled() then
    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
  else
    MinimapZoomIn:Show()
    MinimapZoomOut:Show()
  end
end

function LTMisc:UpdateScrollZoom()
  if self.db.scrollZoom and self:IsEnabled() then
    Minimap:EnableMouseWheel(true)
    self:HookScript(Minimap, 'OnMouseWheel', function(self, delta) _G["Minimap_Zoom" .. (delta > 0 and "In" or "Out")]() end)
  else
    Minimap:EnableMouseWheel(false)
    self:Unhook(Minimap, 'OnMouseWheel')
  end
end
