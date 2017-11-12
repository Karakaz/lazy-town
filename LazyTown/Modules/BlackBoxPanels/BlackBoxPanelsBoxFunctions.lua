
function BlackBoxPanels.Box_OnMouseDown(box, button)
  if button == 'RightButton' then
    LazyTown:OpenOptions("boxPanelsGroup")
  elseif button == 'LeftButton' then
    BlackBoxPanels:Box_BeginResizingOrMoving(box)
  end
end

function BlackBoxPanels.Box_OnMouseUp(box, button)
  if button == 'LeftButton' then
    BlackBoxPanels:Box_EndResizingOrMoving()
  end
end

function BlackBoxPanels.Box_OnHide(box)
  BlackBoxPanels:Box_EndResizingOrMoving()
end

function BlackBoxPanels:Box_BeginResizingOrMoving(box)
  if not self.isResizing and (self.onLeftEdge or self.onRightEdge or self.onTopEdge or self.onBottomEdge) then
    self.isResizing = true
  elseif not self.isMoving then
    self.isMoving = true
  end

  self.prevX, self.prevY = GetCursorPosition()
  local s = box:GetEffectiveScale()
  self.prevX, self.prevY = self.prevX / s, self.prevY / s
  
  self.boxDimensionHelper.box = box
  self.boxDimensionHelper:Show()
end

function BlackBoxPanels:Box_EndResizingOrMoving()
  if self.isMoving then
    self.isMoving = false
  elseif self.isResizing then
    self.isResizing = false
  end
  self.boxDimensionHelper:Hide()
end

function BlackBoxPanels.Box_OnEnter(box)
  local self = BlackBoxPanels
  if self.hoverTimer then
    self:CancelTimer(self.hoverTimer)
  end
  self.hoverTimer = self:ScheduleRepeatingTimer("Box_HoverUpdate", 0.01, box)
end

function BlackBoxPanels:Box_HoverUpdate(box)
  if not self.hoverTimer then  return  end
  
  self:Box_SetCursor()
 
  if self.isResizing or self.isMoving then  return  end
  
  local x, y = GetCursorPosition()
  local s = box:GetEffectiveScale()
  x, y = x / s, y / s
  self.onLeftEdge = (x >= box:GetLeft() and x <= box:GetLeft() + 8)
  self.onRightEdge = (x <= box:GetRight() and x >= box:GetRight() - 8)
  self.onTopEdge = (y <= box:GetTop() and y >= box:GetTop() - 8)
  self.onBottomEdge = (y >= box:GetBottom() and y <= box:GetBottom() + 8)
end

function BlackBoxPanels:Box_SetCursor()
  local basePath = "Interface\\AddOns\\LazyTown\\Textures\\BlackBoxPanels\\Cursor_"
  if self.onLeftEdge then
    if self.onTopEdge then
      SetCursor(basePath .. "TopLeft")
    elseif self.onBottomEdge then
      SetCursor(basePath .. "BottomLeft")
    else
      SetCursor(basePath .. "Vertical")
    end
  elseif self.onRightEdge then
    if self.onTopEdge then
      SetCursor(basePath .. "TopRight")
    elseif self.onBottomEdge then
      SetCursor(basePath .. "BottomRight")
    else
      SetCursor(basePath .. "Vertical")
    end
  elseif self.onTopEdge or self.onBottomEdge then
      SetCursor(basePath .. "Horizontal")
  else
    SetCursor(basePath .. "Move")
  end
end

function BlackBoxPanels.Box_OnLeave(box)
  local self = BlackBoxPanels
  SetCursor(nil)
  if self.hoverTimer then
    self:CancelTimer(self.hoverTimer)
    self.hoverTimer = nil
  end
end
