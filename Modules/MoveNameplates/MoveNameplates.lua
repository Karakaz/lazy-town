
function MoveNameplates:FrameOnUpdate(elapsed)
  if WorldFrame:GetNumChildren() ~= self.numChildren then
    MoveNameplates:ScanNameplates(WorldFrame:GetChildren())

    self.numChildren = WorldFrame:GetNumChildren()
  end
end

function MoveNameplates:ScanNameplates(...)
  local plate
  for i = 1, select("#", ...) do
    plate = select(i, ...)
    if not self.nameplates[plate] and self:IsNameplateFrame(plate) then
      self.nameplates[plate] = true

      self:SetUpNameplate(plate)
    end
  end
end

function MoveNameplates:IsNameplateFrame(frame)
  if frame:GetName() then
    return false
  end

  local overlayRegion = frame:GetRegions()
  if overlayRegion and
      overlayRegion:GetObjectType() == "Texture" and
      overlayRegion:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then
    return true
  end
end

function MoveNameplates:SetUpNameplate(plate)

  plate.healthBar, plate.castBar = plate:GetChildren()
  plate.overlay, plate.castBarOverlay, plate.spellIcon, plate.highlight,
  plate.nameText, plate.levelText, plate.bossIcon, plate.raidIcon = plate:GetRegions()

  self:SetWidthsAndHeights(plate)

  if self:IsNameplatesClickable() then
    self:CreateHelperFrames(plate)
  else
    plate:EnableMouse(true)
  end

  self:RegisterPoints(plate:GetChildren())
  self:RegisterPoints(plate:GetRegions())

  self:HookNameplate(plate)
  self:UpdateNameplate(plate.healthBar)
end

function MoveNameplates:SetWidthsAndHeights(plate)
  plate.origWidth = plate:GetWidth()
  plate.origHeight = plate:GetHeight()

  plate.width = plate.origWidth + abs(self.db.xOff)
  plate.height = plate.origHeight + abs(self.db.yOff)
end

function MoveNameplates:CreateHelperFrames(plate)
  self:CreateCoverFrame(plate)  --Frame to cover a part of the nameplate so it's not clickable
  self:CreateHelperFrame(plate) --Frame equal in size to the original nameplate for elements to anchor to

  if self.debugging then
    self:DrawBox(plate.cover, 1, 0, 0, 0.3)
    self:DrawBox(plate.frame, 0, 0, 1, 0.3)
  end
end

function MoveNameplates:CreateCoverFrame(plate)
  plate.cover = CreateFrame('Button', tostring(plate) .. "Cover", plate)

  if self.db.yOff > 0 then
    plate.cover:SetPoint('TOPLEFT', plate, 'BOTTOMLEFT', 0, plate.height - plate.origHeight)
    plate.cover:SetPoint('BOTTOMRIGHT', plate, 'BOTTOMRIGHT')
  else
    plate.cover:SetPoint('TOPLEFT', plate, 'TOPLEFT')
    plate.cover:SetPoint('BOTTOMRIGHT', plate, 'TOPRIGHT', 0, -plate.height + plate.origHeight)
  end

  plate.cover:SetScript('OnEnter', function(self, motion) -- Hiding nameplate highlighting
                                     plate.highlight:SetTexture('Interface\\BUTTONS\\UI-PassiveHighlight')
                                     plate.nameText:SetTextColor(1, 1, 1, 1)
                                   end)

  plate.cover:SetScript('OnLeave', function(self, motion) -- Showing nameplate highlighting again
                                     plate.highlight:SetTexture('Interface\\Tooltips\\Nameplate-Glow')
                                     plate.nameText:SetTextColor(1, 1, 0, 1)
                                   end)
end

function MoveNameplates:CreateHelperFrame(plate)
  plate.frame = CreateFrame('Frame', tostring(plate) .. "Frame", plate)
  plate.frame:SetPoint('TOPLEFT', plate, 'TOPLEFT')
  plate.frame:SetPoint('BOTTOMRIGHT', plate, 'TOPRIGHT', 0, -plate.origHeight)
end

function MoveNameplates:DrawBox(frame, r, g, b, a) -- Displays a colored box showing the area of the frame
  frame.background = frame:CreateTexture("BackgroundTexture", "BACKGROUND")
  frame.background:SetTexture(r, g, b, a)
  frame.background:SetAllPoints(frame)
end

function MoveNameplates:RegisterPoints(...)
  local element, numPoints
  for i = 1, select("#", ...) do
    element = select(i, ...)
    if element then
      element.points = {}
      numPoints = element:GetNumPoints()
      for i = 1, numPoints do
        element.points[i] = {}
        element.points[i].point, element.points[i].relativeTo, element.points[i].relativePoint, element.points[i].xOffset, element.points[i].yOffset = element:GetPoint(i)
      end
    end
  end
end

function MoveNameplates:HookNameplate(plate)
  self:HookScript(plate.healthBar, 'OnShow', "UpdateNameplate")
  self:HookScript(plate.healthBar, 'OnSizeChanged', "UpdateNameplate")
--  plate.healthBar:SetScript('OnShow', UpdateNameplate)
--  plate.healthBar:SetScript('OnSizeChanged', UpdateNameplate)
end

function MoveNameplates:UpdateNameplate(healthBar)
  local plate = healthBar:GetParent()

  self:ResizeNameplate(plate)
  self:MoveElements(plate)
end

function MoveNameplates:ResizeNameplate(plate)
  if self:IsNameplatesClickable() and self.db.yOff <= 0 then
    plate:SetHeight(plate.height)
  end
end

function MoveNameplates:MoveElements(plate)
  self:MoveElement(plate.healthBar)      --StatusBar
  self:MoveElement(plate.overlay)        --Texture
  self:MoveElement(plate.castBarOverlay) --Texture (castbar and spellIcon are anchored to this)
  self:MoveElement(plate.highlight)      --Texture
  self:MoveElement(plate.nameText)       --FontString
  self:MoveElement(plate.levelText)      --FontString
  self:MoveElement(plate.bossIcon)       --Texture
  self:MoveElement(plate.raidIcon)       --Texture
end

function MoveNameplates:MoveElement(element)
  if element then
    local p = {}
    local relativeFrame = (element:GetParent().frame or element.points[1].relativeTo)
    numPoints = element:GetNumPoints()
    for i = 1, numPoints do
      p[i] = {}
      p[i].point, p[i].relativeTo, p[i].relativePoint, p[i].xOffset, p[i].yOffset = element:GetPoint(i)
    end

    if p[1].xOffset == element.points[1].xOffset and p[1].yOffset == element.points[1].yOffset then

      element:ClearAllPoints()

      for i = 1, numPoints do
        element:SetPoint(p[i].point, relativeFrame, p[i].relativePoint, p[i].xOffset + self.db.xOff, p[i].yOffset + self.db.yOff)
      end
    end
  end
end
