
function LTMisc:UpdateArenaPoints()
  if self.db.arenaPoints and self:IsEnabled() then
    self:ArenaPointsSetup()
  else
    self:ArenaPointsTeardown()
  end
end

function LTMisc:ArenaPointsSetup()
  local types = {normal = true}
  if IsAddOnLoaded("Blizzard_InspectUI") then
    types.inspect = true
    self:RawHook("InspectPVPTeam_Update", true)
  else
    self:RegisterEvent('ADDON_LOADED') --handler in MiscSupervising.lua
  end
  self:SetTeamAnchors(types)
  self:RawHook("PVPTeam_Update", true)
end

function LTMisc:ArenaPointsTeardown()
  self:Unhook("PVPTeam_Update")
  self:Unhook("InspectPVPTeam_Update")
end

function LTMisc:SetTeamAnchors(types)
  local ratingName
  for i = 1, 3 do
    ratingName = "PVPTeam" .. i .. "DataRating"
    if types.normal then  self:SetRegionAnchors(ratingName)  end
    if types.inspect then self:SetRegionAnchors("Inspect" .. ratingName) end
  end
end

function LTMisc:SetRegionAnchors(ratingRegionName)
  local ratingRegion = _G[ratingRegionName]
  ratingRegion:ClearAllPoints()
  ratingRegion:SetPoint('TOPRIGHT', -15, -15)
  ratingRegion:SetWidth(58)

  local labelRegion = _G[ratingRegionName .. "Label"]
  labelRegion:ClearAllPoints()
  labelRegion:SetPoint('RIGHT', ratingRegion, 'LEFT', -5)
end

function LTMisc:PVPTeam_Update(...)
  self.hooks.PVPTeam_Update(...)
  self:AddPointsToArenaRatings(GetArenaTeam, "PVPTeam%dData")
end

function LTMisc:InspectPVPTeam_Update(...)
  self.hooks.InspectPVPTeam_Update(...)
  self:AddPointsToArenaRatings(GetInspectArenaTeamData, "InspectPVPTeam%dData")
end

function LTMisc:AddPointsToArenaRatings(getArenaTeamFunction, parentName)
  local teamSizes, teamName, teamSize, ratingRegion, ratingText = {}

  for i = 1, 3 do
    teamName, teamSize = getArenaTeamFunction(i)
    if teamName then
      teamSizes[teamName] = tonumber(teamSize)
    end
  end

  for i = 1, 3 do
    teamName = _G[format(parentName .. "Name", i)]:GetText()
    if teamSizes[teamName] then
      ratingRegion = _G[format(parentName .. "Rating", i)]
      ratingText = ratingRegion:GetText()
      ratingRegion:SetText(format(ratingText .. " (%d)", self:GetArenaPoints(tonumber(ratingText), teamSizes[teamName])))
    end
  end
end

function LTMisc:GetArenaPoints(rating, teamSize)
  local points
  if rating > 1500 then
    points = 1511.26 / (1 + 1639.28 * exp(-0.00412 * rating))
  else
    points = 0.22 * rating + 14
  end
  return floor(0.5 + points * (teamSize == 2 and 0.76  or  teamSize == 3 and 0.88  or  teamSize == 5 and 1))
end
