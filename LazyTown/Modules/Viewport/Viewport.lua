
function LTViewport:OnInitialize()
  self:GeneralSetup('viewport')
  self:ExtractResolutionAndSetScale(GetCVar('gxResolution'))
end

function LTViewport:OnEnable()
  self.cvarBucket = self:RegisterBucketEvent('CVAR_UPDATE', 0.1, 'CVAR_UPDATE')
  self:Update()
end

function LTViewport:OnDisable()
  self:UnregisterBucket(self.cvarBucket)
  self:ResetLTViewport()
  self:HideOverlays()
end

function LTViewport:CVAR_UPDATE(eventName, cvarName, value)
  self:ExtractResolutionAndSetScale(GetCVar('gxResolution'))
  self:Update()
end

function LTViewport:ExtractResolutionAndSetScale(resolution)
  self.resX, self.resY = LibStub('KaraLib-1.0'):tonumbers(resolution:match("(%d+)x(%d+)"))
  self.scale = 768 / self.resY
end

function LTViewport:ResetLTViewport()
  WorldFrame:SetPoint('TOPLEFT', 0, 0)
  WorldFrame:SetPoint('BOTTOMRIGHT', 0, 0)
end

function LTViewport:HideOverlays()
  self.gradLeft:SetPoint('BOTTOMRIGHT', UIParent, 'TOPLEFT', -1, 1)
  self.gradRight:SetPoint('TOPLEFT', UIParent, 'BOTTOMRIGHT', 1, -1)
  self.gradTop:SetPoint('BOTTOMRIGHT', UIParent, 'TOPLEFT', -1, 1)
  self.gradBottom:SetPoint('TOPLEFT', UIParent, 'BOTTOMRIGHT', 1, -1)
end

function LTViewport:Update()
  if not self:IsEnabled() then return end

  self:UpdateLTViewports()
  self:UpdateOverlays()
end

function LTViewport:UpdateLTViewports()
  WorldFrame:SetPoint('TOPLEFT', self.db.left * self.scale, -self.db.top * self.scale)
  WorldFrame:SetPoint('BOTTOMRIGHT', -self.db.right * self.scale, self.db.bottom * self.scale)
end

function LTViewport:UpdateOverlays()
  if not self.gradTop then
    self:CreateOverlayTextures()
  end
  self:UpdateOverlayTextures()
end

function LTViewport:CreateOverlayTextures()
  self.gradLeft = WorldFrame:CreateTexture(nil, 'BORDER')
  self.gradLeft:SetTexture(1, 1, 1, 1)
  self.gradLeft:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', -1, 1)

  self.gradRight = WorldFrame:CreateTexture(nil, 'BORDER')
  self.gradRight:SetTexture(1, 1, 1, 1)
  self.gradRight:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', 1, -1)

  self.gradTop = WorldFrame:CreateTexture(nil, 'BORDER')
  self.gradTop:SetTexture(1, 1, 1, 1)
  self.gradTop:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', -1, 1)

  self.gradBottom = WorldFrame:CreateTexture(nil, 'BORDER')
  self.gradBottom:SetTexture(1, 1, 1, 1)
  self.gradBottom:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', 1, -1)
end

function LTViewport:UpdateOverlayTextures()
  self.gradLeft:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMLEFT', self.db.left * self.scale, -1)
  self.gradRight:SetPoint('TOPLEFT', UIParent, 'TOPRIGHT', -self.db.right * self.scale, 1)
  self.gradTop:SetPoint('BOTTOMRIGHT', UIParent, 'TOPRIGHT', 1, -self.db.top * self.scale)
  self.gradBottom:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', -1, self.db.bottom * self.scale)

  local edge = self.db.fillEdge
  local center

  if self.db.fillStyle == 'gradient' then
    center = self.db.fillCenter
  else
    center = edge
  end

  self.gradLeft:SetGradient('HORIZONTAL', edge[1], edge[2], edge[3], unpack(center))
  self.gradRight:SetGradient('HORIZONTAL', center[1], center[2], center[3], unpack(edge))
  self.gradTop:SetGradient('VERTICAL', center[1], center[2], center[3], unpack(edge))
  self.gradBottom:SetGradient('VERTICAL', edge[1], edge[2], edge[3], unpack(center))
end
