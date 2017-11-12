
function BlackBoxPanels:CreateBoxDimensionHelper()
  self.boxDimensionHelper = CreateFrame('Frame', "BlackBoxPanelsDimensionHelper", UIParent)
  self.boxDimensionHelper:Hide()
  self.boxDimensionHelper:SetScript('OnUpdate', self.DimensionHelper_UpdateBoxDimensions)
end

function BlackBoxPanels.DimensionHelper_UpdateBoxDimensions(helper)
  local self = BlackBoxPanels
  local box = helper.box
  local dbBox = box.dbBox
  local x, y = GetCursorPosition()
  local s = box:GetEffectiveScale()
  x, y = x / s, y / s
  if self.isResizing then
    self:ResizeBox(dbBox, box, x, y)
  elseif self.isMoving then
    self:MoveBox(dbBox, box, x, y)
  end
end

function BlackBoxPanels:ResizeBox(dbBox, box, x, y)
  if self.onLeftEdge or self.onRightEdge then
    if self.onLeftEdge then
      dbBox.width = dbBox.width + self.prevX - x
    else
      dbBox.width = dbBox.width + x - self.prevX
    end
    if dbBox.width < 20 then
      dbBox.width = 20
      x = self.prevX
    end
    box:SetWidth(dbBox.width)
    dbBox.x = dbBox.x + (x - self.prevX) / 2
    self.prevX = x
  end
  if self.onBottomEdge or self.onTopEdge then
    if self.onBottomEdge then
      dbBox.height = dbBox.height + self.prevY - y
    else
      dbBox.height = dbBox.height + y - self.prevY
    end
    if dbBox.height < 20 then
      dbBox.height = 20
      y = self.prevY
    end
    box:SetHeight(dbBox.height)
    dbBox.y = dbBox.y + (y - self.prevY) / 2
    self.prevY = y
  end
  box:SetPoint('CENTER', dbBox.x, dbBox.y)
end

function BlackBoxPanels:MoveBox(dbBox, box, x, y)
  dbBox.x = dbBox.x + x - self.prevX
  dbBox.y = dbBox.y + y - self.prevY
  box:SetPoint('CENTER', dbBox.x, dbBox.y)
  self.prevX = x
  self.prevY = y
end
