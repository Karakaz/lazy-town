
local MoveNameplates = _G.MoveNameplates

local moduleOptions = {
  name = function(info) return LazyTown:ApplyStateColor('MoveNameplates', MoveNameplates.db.enabled) end,
  handler = MoveNameplates,
  disabled = LazyTown.IsDisabled,
  type = 'group',
  args = {
    enabled = {
      name = "Enabled",
      order = 10,
      type = 'toggle',
      set = function(info, val)  if not val then MoveNameplates.mustReloadUI = true end
                                 MoveNameplates:SetModuleState(val)  end,
      get = function(info) return MoveNameplates.db.enabled end,
    },
    xOff = {
      name = "X-Offset",
      desc = "Legal X range: [-10, 10]  (other values works, but then nameplates aren't clickable)",
      order = 30,
      width = 'full',
      type = 'range',
      min = -200,
      max = 200,
      step = 1,
      set = function(info, val)
              MoveNameplates.db.xOff = val
              MoveNameplates.mustReloadUI = true
            end,
      get = function(info) return MoveNameplates.db.xOff end,
    },
    yOff = {
      name = "Y-Offset",
      desc = "Legal Y range: [-40, 20]  (other values works, but then nameplates aren't clickable)",
      order = 40,
      width = 'full',
      type = 'range',
      min = -200,
      max = 200,
      step = 1,
      set = function(info, val)
              MoveNameplates.db.yOff = val
              MoveNameplates.mustReloadUI = true
            end,
      get = function(info) return MoveNameplates.db.yOff end,
    },
    clickable = {
      name = "Clickable nameplates",
      desc = "Only usable for legal offset ranges",
      order = 20,
      disabled = function(info) return not MoveNameplates:IsLegalRange() end,
      type = 'toggle',
      set = function(info, val)
              MoveNameplates.db.clickable = val
              MoveNameplates.mustReloadUI = true
            end,
      get = "IsNameplatesClickable",
    },
    saveChanges = {
      name = "Save changes",
      desc = "Must reload UI to apply the changes",
      order = 50,
      confirm = true,
      disabled = function(info) return not MoveNameplates.mustReloadUI end,
      type = 'execute',
      func = function(info) ReloadUI() end,
    },
  },
}

LazyTown:AddModuleOptions("moveNPGroup", moduleOptions)

--------------------------------------------------------------------------------------------------------

function MoveNameplates:OnInitialize()
  self:GeneralSetup('moveNP')
  self.nameplates = {}
  self.debugging = false
  self.frame = CreateFrame('Frame', "MoveNameplateFrame")
end

function MoveNameplates:OnEnable()
  if self:ShouldModifyNameplates() then
    self.frame:SetScript("OnUpdate", self.FrameOnUpdate)
  end
end

function MoveNameplates:OnDisable()
  self.frame:SetScript("OnUpdate", nil)
end

function MoveNameplates:ShouldModifyNameplates()
  return self.db.xOff ~= 0 or self.db.yOff ~= 0
end

function MoveNameplates:IsNameplatesClickable()
  return self.db.clickable and self:IsLegalRange()
end

function MoveNameplates:IsLegalRange()
  return self.db.xOff >= -10 and self.db.xOff <= 10 and
         self.db.yOff >= -40 and self.db.yOff <= 20
end
