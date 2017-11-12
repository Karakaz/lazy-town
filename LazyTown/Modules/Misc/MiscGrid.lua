
function LTMisc:UpdateGrid()
  if self:IsEnabled() and self.db.grid then
    self:SetupGrid()
  else
    self:TeardownGrid()
  end
end

function LTMisc:SetupGrid()
  self:HideOldLines()
  self.texNr = self.grid and 3 or 1
  
  self:UpdateResolutionVariables()
  
  if not self.grid then
    self:CreateGrid()
  end
  self:UpdateFourths()
  self:DrawGrid()
  
  if not self.cvarBucket then
    self.cvarBucket = self:RegisterBucketEvent('CVAR_UPDATE', 0.1, "UpdateGrid")
  end
end

function LTMisc:TeardownGrid()
  if self.grid then
    self.grid:Hide()
  end
  if self.cvarBucket then
    self:UnregisterBucket(self.cvarBucket)
    self.cvarBucket = nil
  end
end

function LTMisc:HideOldLines()
  if self.texNr then
    for i = 3, self.texNr - 1 do
      _G["LTMisc_Grid" .. i]:Hide()
    end
  end
end

function LTMisc:UpdateResolutionVariables()
  local UIParentScale = GetCVar('useUiScale') and UIParent:GetEffectiveScale() or 1
  self.gameX = LTViewport.resX * LTViewport.scale / UIParentScale
  self.gameY = LTViewport.resY * LTViewport.scale / UIParentScale
  self.boxWidth = self.db.boxWidth * LTViewport.scale / UIParentScale
  self.boxHeight = self.db.boxHeight * LTViewport.scale / UIParentScale
end

function LTMisc:CreateGrid()
  self.gridName = "LTMisc_Grid"
  self.grid = CreateFrame('Frame', self.gridName, UIParent)
  self.grid:SetAllPoints()
  self:DrawBlueVertical(0)
  self:DrawBlueHorizontal(0)
end

function LTMisc:DrawBlueVertical(xOff)
  local t = self:GetVerticalLine()
  t:SetPoint('CENTER', xOff, 0)
  t:SetTexture(0, 0, 1, 0.4)
end

function LTMisc:DrawBlueHorizontal(yOff)
  local t = self:GetHorizontalLine()
  t:SetPoint('CENTER', 0, yOff)
  t:SetTexture(0, 0, 1, 0.4)
end

function LTMisc:UpdateFourths()
  local func = self.db.gridFourths and "Show" or "Hide"
  if func == "Show" then
    self:DrawFourths()
  end
  local t
  for i = 3, 6 do
    t = _G[self.gridName .. i]
    if t then
      t[func](t)
    end
  end
end

function LTMisc:DrawFourths()
  self:DrawBlueVertical(self.gameX / 4)
  self:DrawBlueVertical(-self.gameX / 4)
  self:DrawBlueHorizontal(self.gameY / 4)
  self:DrawBlueHorizontal(-self.gameY / 4)
end

function LTMisc:DrawGrid()
  self:DrawVerticalLines()
  self:DrawHorizontalLines()
  self.grid:Show()
end

function LTMisc:DrawVerticalLines()
  local t
  for i = self.boxWidth, self.gameX / 2, self.boxWidth do
    t = self:GetVerticalLine()
    t:SetPoint('CENTER', i, 0)
    
    t = self:GetVerticalLine()
    t:SetPoint('CENTER', -i, 0)
  end
end

function LTMisc:DrawHorizontalLines()
  local t
  for i = self.boxHeight, self.gameY / 2, self.boxHeight do
    t = self:GetHorizontalLine()
    t:SetPoint('CENTER', 0, i)
    
    t = self:GetHorizontalLine()
    t:SetPoint('CENTER', 0, -i)
  end
end

function LTMisc:GetVerticalLine()
  local t = self:GetFreeTexture()
  t:SetWidth(2)
  t:SetHeight(self.gameY)
  return t
end

function LTMisc:GetHorizontalLine()
  local t = self:GetFreeTexture()
  t:SetWidth(self.gameX)
  t:SetHeight(2)
  return t
end

function LTMisc:GetFreeTexture()
  local t = _G[self.gridName .. self.texNr]
  if t then
    t:Show()
  else
    t = self.grid:CreateTexture(self.gridName .. self.texNr, 'BACKGROUND')
  end
  if self.db.gridWhite then
    t:SetTexture(1, 1, 1, 0.5)
  else
    t:SetTexture(0, 0, 0, 0.5)
  end
  self.texNr = self.texNr + 1
  return t
end
