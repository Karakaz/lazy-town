
function DurabilityPercent:InstallDurability()
  for slot, _ in pairs(self.slots) do
    self[slot] = {}
    self:InstallDurabilityInSlot(slot)
  end
end

function DurabilityPercent:InstallDurabilityInSlot(slot)
  local button = _G["Character" .. slot .. "Slot"]
  local durability = button:CreateFontString("Character" .. slot .. "Durability", 'OVERLAY')
  durability:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 0.5, 0.25)
  durability:SetFont(LazyTown:Media('font', self.db.font), self.db.fontSize, 'OUTLINE')
  self[slot] = durability
end

function DurabilityPercent:UpdateCharacter()
  local curD, maxD, durability
  for slot, index in pairs(self.slots) do
    curD, maxD = GetInventoryItemDurability(index)
    curD, maxD = tonumber(curD) or 0, tonumber(maxD) or 0

    durability = self[slot]
    if maxD > 0 then
      durability:SetTextColor(self:GetDurabilityColor(curD / maxD))
      durability:SetText(self:ConstructDurabilityText(curD, maxD))
    else
      durability:SetText("")
    end
  end
end

function DurabilityPercent:GetDurabilityColor(percent)
  if percent > 1 then percent = 1 end
  if percent < 0 then percent = 0 end
  return percent > 0.5 and 2 - percent * 2 or 1,  percent < 0.5 and percent * 2 or 1,  0
end

function DurabilityPercent:ConstructDurabilityText(curD, maxD)
  local percent, text = 100 * curD / maxD

  if self.db.threshold >= percent then
    if self.db.inverted then
      text = self.db.percent and 100 - floor(percent + 0.5) .. "%" or maxD - curD .. "/" .. maxD
    else
      text = self.db.percent and floor(percent + 0.5) .. "%" or curD .. "/" .. maxD
    end
  else
    text = ""
  end

  return text
end
