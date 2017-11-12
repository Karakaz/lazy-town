
function BlackBoxPanels:OnInitialize()
  self:GeneralSetup('boxPanels')
  self.boxNameBase = "BlackBoxPanels_Box"
  self.boxIDCount = 0
  self:ResetPrevBoxPointersAndIDs()
  self:ImportTexturesIntoSharedMedia()
end

function BlackBoxPanels:ResetPrevBoxPointersAndIDs()
  for index, dbBox in ipairs(self.db.boxes) do
    dbBox.id = self:GenerateNewID()
    dbBox.box = false
    if dbBox.name:find("^Box%d+$") then
      dbBox.name = "Box" .. dbBox.id
    end
  end
end

function BlackBoxPanels:ImportTexturesIntoSharedMedia()
  local LSM = LibStub('LibSharedMedia-3.0')
  local baseName, basePath = "BBP_", "Interface\\AddOns\\LazyTown\\Textures\\BlackBoxPanels\\"
  local backgroundStr, borderStr = "background", "border"
  
  local backgrounds = {"Diagonal1", "Diagonal2", "Diagonal3", "Hexes1", "Hexes2", "Hexes3", "Holes1", "Holes2", "Metal1", "Metal2", "Metal3", 
                       "Pattern", "Square1", "Square2", "Square3", "Square4", "Square5", "Square6", "Square7"}
  for _, background in ipairs(backgrounds) do
    LSM:Register(backgroundStr, baseName .. background, basePath .. background)
  end
  
  local borders = {"Plain", "Thin1", "Thin2", "Smooth"}
  for _, border in ipairs(borders) do
    LSM:Register(borderStr, baseName .. border, basePath .. border)
  end
end

function BlackBoxPanels:OnEnable()
  if not self.StrataConversion then
    self.StrataConversion = {'BACKGROUND', 'LOW', 'MEDIUM', 'HIGH', 'DIALOG', 'FULLSCREEN', 'FULLSCREEN_DIALOG', 'TOOLTIP'}
  end
  if not self.boxDimensionHelper then
    self:CreateBoxDimensionHelper()
  end
  self:UpdateAllBoxes()
end

function BlackBoxPanels:OnDisable()
  self:UpdateAllBoxes()
  self.StrataConversion = nil
end

function BlackBoxPanels:GenerateNewID()
  self.boxIDCount = self.boxIDCount + 1
  return self.boxIDCount
end

function BlackBoxPanels:GetBoxIDs(minusSelected)
  local ids = {}
  for index, dbBox in ipairs(self.db.boxes) do
    if not minusSelected or dbBox.id ~= self.selected.id then
      ids[dbBox.id] = dbBox.name
    end
  end
  return ids
end

function BlackBoxPanels:GetBoxDB(boxID)
  for _, dbBox in ipairs(self.db.boxes) do
    if dbBox.id == boxID then
      return dbBox
    end
  end
end

function BlackBoxPanels:NewDBBox()
  local id = self:GenerateNewID()
  tinsert(self.db.boxes, {id = id,
                          name = "Box" .. id,
                          inheritFrom = self:HasNoBoxes() and 'default' or 'selected'})
  self:UpdateAllBoxes()
end

function BlackBoxPanels:HasNoBoxes()
  return LibStub('KaraLib-1.0'):IsTableEmpty(self.db.boxes)
end

function BlackBoxPanels:RemoveSelectedBox()
  local boxes = self.db.boxes
  for index, dbBox in ipairs(boxes) do
    if self.selected.id == dbBox.id then
      dbBox.box:Hide()
      if #boxes > 1 then
        self.selected = boxes[index == 1 and 2 or 1]
      else
        self.selected = false
      end
      tremove(boxes, index)
      break
    end
  end
end

function BlackBoxPanels:CopyFromOtherBox(info, val)
  local dbBox = self:GetBoxDB(val)
  self:DB1CopyDB2(self.selected, dbBox)
  self.selected.show = true
  self:UpdateSelectedBox()
end

function BlackBoxPanels:DB1CopyDB2(dbBox1, dbBox2, includeSize)
  if includeSize then
    dbBox1.width = dbBox2.width
    dbBox1.height = dbBox2.height
  end
  dbBox1.background = dbBox2.background
  dbBox1.border = dbBox2.border
  dbBox1.backgroundColor = dbBox2.backgroundColor
  dbBox1.borderColor = dbBox2.borderColor
  dbBox1.factor = dbBox2.factor
  dbBox1.showName = dbBox2.showName
  dbBox1.strata = dbBox2.strata
  dbBox1.level = dbBox2.level
end
