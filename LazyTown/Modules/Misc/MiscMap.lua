
function LTMisc:UpdateZoneLevels()
  if self.db.zoneLevels and self:IsEnabled() then
    self:RawHook(WorldMapFrameAreaLabel, "SetText", "WorldMapFrameAreaLabel_SetText", true)
    self.zoneRanges =  {["Eversong Woods"] = {low = 1, high = 10},
                        ["Tirisfal Glades"] = {low = 1, high = 10},
                        ["Mulgore"] = {low = 1, high = 10},
                        ["Durotar"] = {low = 1, high = 10},
                        ["Elwynn Forest"] = {low = 1, high = 10},
                        ["Azuremyst Isle"] = {low = 1, high = 10},
                        ["Teldrassil"] = {low = 1, high = 10},
                        ["Dun Morogh"] = {low = 1, high = 10},
                        ["Loch Modan"] = {low = 10, high = 20},
                        ["Westfall"] = {low = 10, high = 20},
                        ["Bloodmyst Isle"] = {low = 10, high = 20},
                        ["Darkshore"] = {low = 10, high = 20},
                        ["Ghostlands"] = {low = 10, high = 20},
                        ["Silverpine Forest"] = {low = 10, high = 20},
                        ["The Barrens"] = {low = 10, high = 25},
                        ["Redridge Mountains"] = {low = 15, high = 25},
                        ["Stonetalon Mountains"] = {low = 15, high = 27},
                        ["Ashenvale"] = {low = 18, high = 30},
                        ["Duskwood"] = {low = 18, high = 30},
                        ["Wetlands"] = {low = 20, high = 30},
                        ["Hillsbrad Foothills"] = {low = 20, high = 30},
                        ["Thousand Needles"] = {low = 25, high = 35},
                        ["Arathi Highlands"] = {low = 30, high = 40},
                        ["Desolace"] = {low = 30, high = 40},
                        ["Alterac Mountains"] = {low = 30, high = 40},
                        ["Stranglethorn Vale"] = {low = 30, high = 45},
                        ["Dustwallow Marsh"] = {low = 35, high = 45},
                        ["Badlands"] = {low = 35, high = 45},
                        ["Swamp of Sorrows"] = {low = 35, high = 45},
                        ["The Hinterlands"] = {low = 40, high = 50},
                        ["Feralas"] = {low = 40, high = 50},
                        ["Tanaris"] = {low = 40, high = 50},
                        ["Searing Gorge"] = {low = 45, high = 50},
                        ["Blasted Lands"] = {low = 45, high = 55},
                        ["Azshara"] = {low = 45, high = 55},
                        ["Felwood"] = {low = 48, high = 55},
                        ["Un'Goro Crater"] = {low = 48, high = 55},
                        ["Burning Steppes"] = {low = 50, high = 58},
                        ["Western Plaguelands"] = {low = 51, high = 58},
                        ["Eastern Plaguelands"] = {low = 53, high = 60},
                        ["Winterspring"] = {low = 53, high = 60},
                        ["Silithus"] = {low = 55, high = 60},
                        ["Deadwind Pass"] = {low = 55, high = 70},
                        ["Hellfire Peninsula"] = {low = 58, high = 63},
                        ["Zangarmarsh"] = {low = 60, high = 64},
                        ["Terokkar Forest"] = {low = 62, high = 65},
                        ["Nagrand"] = {low = 64, high = 67},
                        ["Blade's Edge Mountains"] = {low = 65, high = 68},
                        ["Netherstorm"] = {low = 67, high = 70},
                        ["Shadowmoon Valley"] = {low = 67, high = 70},
                        ["Moonglade"] = {low = 68, high = 70},
                        ["Isle of Quel'Danas"] = {low = 70, high = 70}}
  else
    self:Unhook(WorldMapFrameAreaLabel, "SetText")
    self.zoneRanges = nil
  end
end

function LTMisc:WorldMapFrameAreaLabel_SetText(fontString, text, ...)
  self.hooks[WorldMapFrameAreaLabel].SetText(fontString, text, ...)
  local zoneRange = self.zoneRanges[text]
  if zoneRange then
    local r, g, b = self:GetZoneColor(zoneRange.low, zoneRange.high)
    fontString:SetText(format("|cff%.2x%.2x%.2x%s [%d-%d]|r", r*255, g*255, b*255, text, zoneRange.low, zoneRange.high))
  end
end

function LTMisc:GetZoneColor(low, high)
  local diff = (low + high) / 2 - UnitLevel('player')
  if diff > -10 then
    return DurabilityPercent:GetDurabilityColor(0.55 - diff * 0.035)
  else
    return 0.65, 0.65, 0.65
  end
end

function LTMisc:UpdateCoordinates()
  if self:IsEnabled() and self.db.coordinates then
    self:SetupCoords()
  else
    self:TeardownCoords()
  end
end

function LTMisc:SetupCoords()
  if self.coords then
    self.coords:Show()
  else
    self:CreateMapCoords()
    self:UpdateCoordsFormat()
  end
  self:HookScript(WorldMapFrame, 'OnShow', "WorldMapFrame_OnShow")
  self:HookScript(WorldMapFrame, 'OnHide', "WorldMapFrame_OnHide")
end

function LTMisc:CreateMapCoords()
  self.coords = WorldMapFrame:CreateFontString("LazyTown_Map_Coords", 'ARTWORK', "GameFontNormal")
  self.coords:SetPoint('BOTTOM', 0, 10)
end

function LTMisc:UpdateCoordsFormat()
  local p = self.db.precision
  self.coordsFormat = format("Cursor coords: %%.%df, %%.%df          Player coords: %%.%df, %%.%df", p, p, p, p)
end

function LTMisc:TeardownCoords()
  if self.coords then
    self.coords:Hide()
  end
  self:Unhook(WorldMapFrame, 'OnShow')
  self:Unhook(WorldMapFrame, 'OnHide')
  self:WorldMapFrame_OnHide()
end

function LTMisc:WorldMapFrame_OnShow()
  if not self.coordsTimer then
    self.coordsTimer = LibStub('AceTimer-3.0'):ScheduleRepeatingTimer(self.UpdateCoordsText, 0.05, self)
  end
end

function LTMisc:WorldMapFrame_OnHide()
  if self.coordsTimer then
    LibStub('AceTimer-3.0'):CancelTimer(self.coordsTimer)
    self.coordsTimer = nil
  end
end

function LTMisc:UpdateCoordsText()
  local pX, pY = GetPlayerMapPosition('player')
  local cX, cY = self:CalcCursorMapPosition()

  self.coords:SetText(format(self.coordsFormat, cX, cY, pX * 100, pY * 100))
end

function LTMisc:CalcCursorMapPosition()
  local scale = WorldMapFrame:GetScale()
  local x, y = GetCursorPosition()
  x, y = x / scale, y / scale

  local width = WorldMapButton:GetWidth()
  local height = WorldMapButton:GetHeight()
  local centerX, centerY = WorldMapFrame:GetCenter()
  
  return ((x - (centerX - width / 2)) / width + 0.0022) * 100, ((height / 2 + centerY - y) / height - 0.0262) * 100
end

function LTMisc:UpdateMapAlpha()
  WorldMapFrame:SetAlpha(self:IsEnabled() and self.db.mapAlpha or 1)
  BlackoutWorld:SetAlpha(self:IsEnabled() and self.db.backgroundAlpha or 1)
end
