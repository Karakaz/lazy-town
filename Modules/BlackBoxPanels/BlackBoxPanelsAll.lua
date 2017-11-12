
function BlackBoxPanels:SetAllBackgrounds(info, val)
  for index, dbBox in ipairs(self.db.boxes) do
    dbBox.background = val
  end
  self:UpdateAllBoxes()
end

function BlackBoxPanels:SetAllBorders(info, val)
  for index, dbBox in ipairs(self.db.boxes) do
    dbBox.border = val
  end
  self:UpdateAllBoxes()
end

function BlackBoxPanels:SetAllBackgroundColors(info, r, g, b, a)
  self:SetAllColors('backgroundColor', r, g, b, a)
end

function BlackBoxPanels:SetAllBorderColors(info, r, g, b, a)
  self:SetAllColors('borderColor', r, g, b, a)
end

function BlackBoxPanels:SetAllColors(colorProperty, r, g, b, a)
  local color
  for index, dbBox in ipairs(self.db.boxes) do
    color = dbBox[colorProperty]
    color[1] = r    color[2] = g    color[3] = b    color[4] = a
  end
  self:UpdateAllBoxes()
end

function BlackBoxPanels:ShowAllBoxes()
  for index, dbBox in ipairs(self.db.boxes) do
    if dbBox.box then
      dbBox.box:Show()
      dbBox.show = true
    end
  end
end

function BlackBoxPanels:HideAllBoxes(onlyHide)
  for index, dbBox in ipairs(self.db.boxes) do
    if dbBox.box then
      dbBox.box:Hide()
      if not onlyHide then
        dbBox.show = false
      end
    end
  end
end
