
function DurabilityPercent:OnInitialize()
  self:GeneralSetup('durability', LTMisc.db)
end

function DurabilityPercent:OnEnable()
  self.slots = {Head = 1, Shoulder = 3, Chest = 5, Waist = 6, Legs = 7, Feet = 8, Wrist = 9, Hands = 10, MainHand = 16, SecondaryHand = 17, Ranged = 18}
  self:Supervise()
  self:RequestUpdate()
end

function DurabilityPercent:OnDisable()
  self.slots = nil
  self:Supervise()
end

function DurabilityPercent:Supervise()
  if self:IsEnabled() and LTMisc:IsEnabled() then
    if not self.hasSetUpCharacter then
      self:InstallDurability()
      self.hasSetUpCharacter = true
    end
    self:Hook("CharacterFrame_OnShow", true)
    self:Hook("CharacterFrame_OnHide", true)
  else
    self:Unhook("CharacterFrame_OnShow")
    self:Unhook("CharacterFrame_OnHide")
    self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
  end
end

function DurabilityPercent:CharacterFrame_OnShow()
  self:RegisterEvent('UNIT_INVENTORY_CHANGED')
  self:UpdateCharacter()
end

function DurabilityPercent:CharacterFrame_OnHide()
  self:UnregisterEvent('UNIT_INVENTORY_CHANGED')
end

function DurabilityPercent:UNIT_INVENTORY_CHANGED(event, unit)
  if unit == 'player' then
    self:UpdateCharacter()
  end
end

function DurabilityPercent:RequestUpdate()
  if self.hasSetUpCharacter and CharacterFrame:IsShown() then
    self:UpdateCharacter()
  end
end

function DurabilityPercent:UpdateFont()
  local font, fontSize, outline = LazyTown:Media('font', self.db.font), self.db.fontSize, 'OUTLINE'
  for slot, _ in pairs(self.slots) do
    self[slot]:SetFont(font, fontSize, outline)
  end
end
