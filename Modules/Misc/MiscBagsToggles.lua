
function LTMisc:ToggleCheckboxDelete()
  if self.checkboxDelete:GetChecked() then
    self:DisableAllCheckboxes()
    self:EnableDeleteCheckbox()
  else
    self:DisableDeleteCheckbox()
  end
end

function LTMisc:EnableDeleteCheckbox()
  self:HookAllContainerItems()
  self:SetItemOverlayColors(1, 0.9, 0, 0.35)
  self.checkboxDelete:SetChecked(true)
end

function LTMisc:HookAllContainerItems()
  self:ForEachContainerItemButton(self.HookContainerButton)
end

function LTMisc:HookContainerButton(frame)
  self:SecureHookScript(frame, 'OnClick', "ContainerItem_OnClick")
end

function LTMisc:DisableDeleteCheckbox()
  self:UnhookAllContainerItems()
  self:SetItemOverlayColors()
  self.checkboxDelete:SetChecked(false)
end

function LTMisc:ContainerItem_OnClick(itemButton, mouseButton)
  if self.checkboxDelete:GetChecked() then
    if mouseButton == 'LeftButton' then
      ClearCursor()
      PickupContainerItem(itemButton:GetParent():GetID(), itemButton:GetID())
      DeleteCursorItem()
    elseif mouseButton == 'RightButton' then
      self:DisableDeleteCheckbox()
    end
  end
end

function LTMisc:UnhookAllContainerItems()
  self:ForEachContainerItemButton(self.UnhookContainerButton)
end

function LTMisc:UnhookContainerButton(frame)
  self:Unhook(frame, 'OnClick')
end

function LTMisc:ToggleCheckboxDisenchant()
  if InCombatLockdown() then  self:RevertCheckbox(self.checkboxDisenchant) return  end
  if self.checkboxDisenchant:GetChecked() then
    self:DisableAllCheckboxes()
    self:EnableDisenchantCheckbox()
  else
    self:DisableDisenchantCheckbox()
  end
end

function LTMisc:EnableDisenchantCheckbox()
  self:HookAllContainerItems()
  self:SetItemOverlayColors(0.8, 0.1, 1, 0.2)
  self:SetItemAction('Disenchant')
  self.checkboxDisenchant:SetChecked(true)
end

function LTMisc:DisableDisenchantCheckbox()
  self:UnhookAllContainerItems()
  self:SetItemOverlayColors()
  self:SetItemAction()
  self.checkboxDisenchant:SetChecked(false)
end

function LTMisc:ToggleCheckboxProspect()
  if InCombatLockdown() then  self:RevertCheckbox(self.checkboxProspect) return  end
  if self.checkboxProspect:GetChecked() then
    self:DisableAllCheckboxes()
    self:EnableProspectCheckbox()
  else
    self:DisableProspectCheckbox()
  end
end

function LTMisc:EnableProspectCheckbox()
  self:HookAllContainerItems()
  self:SetItemOverlayColors(1, 0.1, 0, 0.3)
  self:SetItemAction('Prospect')
  self.checkboxProspect:SetChecked(true)
end

function LTMisc:DisableProspectCheckbox()
  self:UnhookAllContainerItems()
  self:SetItemOverlayColors()
  self:SetItemAction()
  self.checkboxProspect:SetChecked(false)
end
