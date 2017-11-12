
function LTMisc:CreateItemOverlays()
  self:ForEachContainerItemButton(self.CreateItemOverlay)
  self.hasCreatedItemOverlays = true
end

function LTMisc:CreateItemOverlay(frame)
  local t = frame:CreateTexture(frame:GetName() .. "_Overlay", 'OVERLAY')
  t:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
  t:SetPoint('CENTER')
  t:SetWidth(70)
  t:SetHeight(70)
  t:SetBlendMode('ADD')
  t:Hide()
  frame.overlay = t
end

function LTMisc:CreateItemActionButtons()
  self:ForEachContainerItemButton(self.CreateItemActionButton)
  self.hasCreatedActionButtons = true
end

function LTMisc:CreateItemActionButton(frame)
  local f = CreateFrame('Button', frame:GetName() .. "_Action", frame, "SecureActionButtonTemplate")
  f:SetPoint('CENTER')
  f:SetWidth(40)
  f:SetHeight(40)
  f:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
  f:SetAttribute('type1', 'spell')
  f:SetAttribute('type2', 'disable_func')
  f.disable_func = function() if LTMisc.checkboxDisenchant and LTMisc.checkboxDisenchant:GetChecked() then LTMisc:DisableDisenchantCheckbox() end
                              if LTMisc.checkboxProspect and LTMisc.checkboxProspect:GetChecked() then LTMisc:DisableProspectCheckbox() end end
  f:Hide()
  f:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_TOP')
                                        GameTooltip:SetBagItem(self:GetParent():GetParent():GetID(), self:GetParent():GetID())
                                        GameTooltip:Show() end)
  f:SetScript('OnLeave', function(self) GameTooltip:Hide() end)
  frame.action = f
end

function LTMisc:CreateBasicCheckbox(type)
  local checkboxName = "LTMisc_" .. type .. "Checkbox"
  local checkbox = CreateFrame('CheckButton', checkboxName, UIParent, 'ChatConfigCheckButtonTemplate')
  checkbox:SetScale(0.83)
  if type == 'Delete' then  _G[checkboxName .. "Text"]:SetTextColor(1, 0.9, 0)
  elseif type == 'Disenchant' then _G[checkboxName .. "Text"]:SetTextColor(0.8, 0.1, 1)
  elseif type == 'Prospect' then _G[checkboxName .. "Text"]:SetTextColor(1, 0.2, 0) end
  self:HookScript(checkbox, 'OnClick', "ToggleCheckbox" .. type)
  checkbox:SetScript('OnLeave', function(self) GameTooltip:Hide() end)
  checkbox:SetScript('OnEnter', function(self) GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
                                               GameTooltip:SetText("Toggle one-click " .. type:lower() .. " item mode.\nLeft click: Do action, Right click: Turn off mode")
                                               GameTooltip:Show() end)
  self["checkbox" .. type] = checkbox
end

function LTMisc:FixCheckboxForOriginal(type)
  local checkbox = self["checkbox" .. type]
  checkbox:SetParent(ContainerFrame1)
  checkbox:SetPoint('TOPRIGHT', -70, -33)
  checkbox:SetFrameLevel(ContainerFrame1:GetFrameLevel() + 1)
  self:SecureHookScript(ContainerFrame1, 'OnShow', "ContainerFrame1_OnShow")
  self:SecureHookScript(ContainerFrame1, 'OnHide', "ContainerFrame1_OnHide")
  self:ContainerFrame1_OnShow()
end

function LTMisc:ContainerFrame1_OnShow(frame)
  if ContainerFrame1Name:GetText() == "Backpack" then
    if self.checkboxDelete and self.db.checkboxDelete then  self.checkboxDelete:Show()  end
    if self.checkboxDisenchant and self.db.checkboxDisenchant then  self.checkboxDisenchant:Show()  end
    if self.checkboxProspect and self.db.checkboxProspect then  self.checkboxProspect:Show()  end
  else
    if self.checkboxDelete then     self.checkboxDelete:Hide() end
    if self.checkboxDisenchant then self.checkboxDisenchant:Hide() end
    if self.checkboxProspect then   self.checkboxProspect:Hide() end
  end
end

function LTMisc:ContainerFrame1_OnHide(frame)
  if ContainerFrame1Name:GetText() == "Backpack" then
    self:DisableAllCheckboxes()
  end
end

function LTMisc:FixCheckboxForBagnon(type)
  local checkbox = self["checkbox" .. type]
  checkbox:SetParent(BagnonFrame0)
  checkbox:SetPoint('BOTTOM', 5, 6)
  checkbox:Show()
  self:HookScript(BagnonFrame0, 'OnHide', "DisableAllCheckboxes")
end
