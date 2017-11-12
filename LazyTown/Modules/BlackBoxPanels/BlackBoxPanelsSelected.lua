
function BlackBoxPanels:GetSelectedProperty(property)
  return self.selected and self.selected[property]
end

function BlackBoxPanels:SetSelectedProperty(property, value)
  if self.selected and self.selected[property] ~= value then
    self.selected[property] = value
    self:UpdateSelectedBox()
  end
end

function BlackBoxPanels:UpdateSelectedBox()
  if self:IsEnabled() then
    self:UpdateBox(self.selected)
  else
    self.selected.box:Hide()
  end
end

function BlackBoxPanels:MoveSelectedLeft()
  self.selected.x = self.selected.x - self.selected.factor
  self:UpdateSelectedBox()
end

function BlackBoxPanels:MoveSelectedRight()
  self.selected.x = self.selected.x + self.selected.factor
  self:UpdateSelectedBox()
end

function BlackBoxPanels:MoveSelectedUp()
  self.selected.y = self.selected.y + self.selected.factor
  self:UpdateSelectedBox()
end

function BlackBoxPanels:MoveSelectedDown()
  self.selected.y = self.selected.y - self.selected.factor
  self:UpdateSelectedBox()
end

function BlackBoxPanels:IncreaseSelectedWidth()
  self.selected.width = self.selected.width + self.selected.factor
  self:UpdateSelectedBox()
end

function BlackBoxPanels:DecreaseSelectedWidth()
  self.selected.width = self.selected.width - self.selected.factor
  if self.selected.width < 20 then
    self.selected.width = 20
  end
  self:UpdateSelectedBox()
end

function BlackBoxPanels:IncreaseSelectedHeight()
  self.selected.height = self.selected.height + self.selected.factor
  self:UpdateSelectedBox()
end

function BlackBoxPanels:DecreaseSelectedHeight()
  self.selected.height = self.selected.height - self.selected.factor
  if self.selected.height < 20 then
    self.selected.height = 20
  end
  self:UpdateSelectedBox()
end
