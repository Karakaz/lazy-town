
function LTMisc:UpdateBagType()
  if self.db.bagType == 'bagnon' then
    if not BagnonFrame0 then
      if Bagnon then
        Bagnon:CreateInventory()
      else
        self:Print(LazyTown:GetChat(), JunkHandling:GenerateWrongAddonString("Bagnon"))
        return
      end
    end
  end
  self:UpdateCheckbox('Delete')
  self:UpdateCheckbox('Disenchant')
  self:UpdateCheckbox('Prospect')
end

function LTMisc:UpdateCheckbox(type)
  if self:IsEnabled() and self.db["checkbox" .. type] then
    if not self.hasCreatedItemOverlays then
      self:CreateItemOverlays()
    end
    if not self.hasCreatedActionButtons and (type == 'Disenchant' or type == 'Prospect') then
      self:CreateItemActionButtons()
    end
    self:SetupCheckbox(type)
  else
    self:TeardownCheckbox(type)
    if self.db.bagType == 'original' and (not self.db.checkboxDelete and not self.db.checkboxDisenchant and not self.db.checkboxProspect) then
      self:Unhook(ContainerFrame1, 'OnShow')
    end
  end
  self:FixCheckboxPositions()
end

function LTMisc:SetupCheckbox(type)
  if not self["checkbox" .. type] then
    self:CreateBasicCheckbox(type)
  end

  if self.db.bagType == 'original' then
    self:FixCheckboxForOriginal(type)
  elseif self.db.bagType == 'bagnon' then
    self:FixCheckboxForBagnon(type)
  end
end

function LTMisc:TeardownCheckbox(type)
  if self["checkbox" .. type] then
    self["checkbox" .. type]:Hide()
  end
end

function LTMisc:FixCheckboxPositions()
  local point, xBase, yBase
  if self.db.bagType == 'original' then
    point, xBase, yBase = 'TOPRIGHT', -70, -33
  elseif self.db.bagType == 'bagnon' then
    point, xBase, yBase = 'BOTTOM', -15, 3
  end
  local xOff = 0
  if self.db.checkboxDelete and self.checkboxDelete then
    self.checkboxDelete:SetPoint(point, xBase, yBase)
    _G[self.checkboxDelete:GetName() .. "Text"]:SetText("Del mode")
    xOff = -76
  end
  if self.db.checkboxDisenchant and self.checkboxDisenchant then
    self.checkboxDisenchant:SetPoint(point, xBase + xOff, yBase)
    _G[self.checkboxDisenchant:GetName() .. "Text"]:SetText("DE mode")
    xOff = xOff - 76
  end
  if self.db.checkboxProspect and self.checkboxProspect then
    if xOff < -100 then
      _G[self.checkboxDelete:GetName() .. "Text"]:SetText("Del")
      _G[self.checkboxDisenchant:GetName() .. "Text"]:SetText("DE")
      _G[self.checkboxProspect:GetName() .. "Text"]:SetText("Pct")
      self.checkboxDelete:SetPoint(point, xBase + 30, yBase)
      self.checkboxDisenchant:SetPoint(point, xBase - 18, yBase)
      self.checkboxProspect:SetPoint(point, xBase - 70, yBase)
    else
      self.checkboxProspect:SetPoint(point, xBase + xOff, yBase)
      _G[self.checkboxProspect:GetName() .. "Text"]:SetText("Pct mode")
    end
  end
end

function LTMisc:ForEachContainerItemButton(func, ...)
  local containerItemFormat, _G = "ContainerFrame%dItem%d", _G
  for containerNr = 1, 5 do
    for slot = 1, 36 do
      func(self, _G[_G.format(containerItemFormat, containerNr, slot)], ...)
    end
  end
end

function LTMisc:SetItemAction(type)
  self:ForEachContainerItemButton(self.SetSecureAction, type)
end

function LTMisc:SetSecureAction(frame, type)
  local button = frame.action
  if type then
    button:SetAttribute('spell', type == 'Prospect' and "Prospecting" or type)
    button:SetAttribute('target-bag', button:GetParent():GetParent():GetID())
    button:SetAttribute('target-slot', button:GetParent():GetID())
    button:Show()
  else
    button:Hide()
  end
end

function LTMisc:SetItemOverlayColors(r, g, b, a)
  self:ForEachContainerItemButton(self.SetOverlayColor, r, g, b, a)
end

function LTMisc:SetOverlayColor(frame, r, g, b, a)
  local overlay = frame.overlay
  if r then
    overlay:SetVertexColor(r, g, b, a)
    overlay:Show()
  else
    overlay:Hide()
  end
end

function LTMisc:DisableAllCheckboxes()
  if self.checkboxDelete and self.checkboxDelete:GetChecked() then self:DisableDeleteCheckbox() end
  if self.checkboxDisenchant and self.checkboxDisenchant:GetChecked() then self:DisableDisenchantCheckbox() end
  if self.checkboxProspect and self.checkboxProspect:GetChecked() then self:DisableProspectCheckbox() end
end

function LTMisc:RevertCheckbox(checkbox)
  checkbox:SetChecked(not checkbox:GetChecked())
  self:Print(LazyTown:GetChat(), "Cannot toggle disenchant or prospect checkboxes in combat.")
end
