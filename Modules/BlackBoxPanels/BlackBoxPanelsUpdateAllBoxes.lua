
function BlackBoxPanels:UpdateAllBoxes()
  if self:IsEnabled() then
    for _, dbBox in ipairs(self.db.boxes) do
      self:UpdateBox(dbBox)
    end
  else
    self:HideAllBoxes(true)
  end
end

function BlackBoxPanels:UpdateBox(dbBox)
  if not dbBox.box then
    self:CreateBox(dbBox)
  end
  if dbBox.show then
    self:UpdateDimensions(dbBox)
    self:SetBoxBackdrop(dbBox)
    self:SetBoxColors(dbBox)
    dbBox.box:EnableMouse(not self.db.locked)
    dbBox.box.name:SetText(self.db.locked or not dbBox.showName and "" or dbBox.name)
    dbBox.box:SetFrameStrata(self.StrataConversion[dbBox.strata])
    dbBox.box:SetFrameLevel(dbBox.level)
    dbBox.box:Show()
  else
    dbBox.box:Hide()
  end
end

function BlackBoxPanels:CreateBox(dbBox)
  local box = self:CreateBoxFrame(dbBox)
  
  if dbBox.inheritFrom == 'default' then
    self:FillInDefaults(dbBox)
  elseif dbBox.inheritFrom == 'selected' then
    self:DB1CopyDB2(dbBox, self.selected, true)
    dbBox.x = 0
    dbBox.y = 0
    dbBox.show = true
  end
  dbBox.inheritFrom = nil
  
  self.selected = dbBox
end

function BlackBoxPanels:CreateBoxFrame(dbBox)
  local box = CreateFrame('Frame', self.boxNameBase .. dbBox.id, UIParent)
  box:ClearAllPoints()
  box:SetMovable(true)
  box:EnableMouse(true)
  box:SetScript('OnMouseDown', self.Box_OnMouseDown)
  box:SetScript('OnMouseUp', self.Box_OnMouseUp)
  box:SetScript('OnHide', self.Box_OnHide)
  box:SetScript('OnEnter', self.Box_OnEnter)
  box:SetScript('OnLeave', self.Box_OnLeave)
  
  box.name = box:CreateFontString(box:GetName() .. "Name", 'OVERLAY', "GameFontNormalSmall")
  box.name:SetPoint('TOP', 0, -7)
  
  box.dbBox = dbBox
  dbBox.box = box
end

function BlackBoxPanels:FillInDefaults(dbBox)
  dbBox.x = 0
  dbBox.y = 0
  dbBox.width = 200
  dbBox.height = 150
  dbBox.background = 'BBP_Diagonal2'
  dbBox.border = 'BBP_Thin1'
  dbBox.backgroundColor = {0.75, 0.75, 0.75, 1}
  dbBox.borderColor = {0.75, 0.75, 0.75, 1}
  dbBox.factor = 10
  dbBox.show = true
  dbBox.showName = true
  dbBox.strata = 1
  dbBox.level = 1
end

function BlackBoxPanels:UpdateDimensions(dbBox)
  dbBox.box:SetPoint('CENTER', dbBox.x, dbBox.y)
  dbBox.box:SetWidth(dbBox.width)
  dbBox.box:SetHeight(dbBox.height)
end

function BlackBoxPanels:SetBoxBackdrop(dbBox)
  dbBox.box:SetBackdrop({ bgFile = LazyTown:Media('background', dbBox.background),
                          edgeFile = LazyTown:Media('border', dbBox.border),
                          tile = true, tileSize = 256, edgeSize = 16,
                          insets = {left = 4, right = 4, top = 4, bottom = 4}})
end

function BlackBoxPanels:SetBoxColors(dbBox)
  dbBox.box:SetBackdropColor(unpack(dbBox.backgroundColor))
  dbBox.box:SetBackdropBorderColor(unpack(dbBox.borderColor))
end
