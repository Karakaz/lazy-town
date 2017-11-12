
local LTViewport = _G.LTViewport

local moduleOptions = {
  name = function(info) return LazyTown:ApplyStateColor('Viewport', LTViewport.db.enabled) end,
  handler = LTViewport,
  disabled = LazyTown.IsDisabled,
  type = 'group',
  args = {
    enabled = {
      name = "Enabled",
      order = 10,
      type = 'toggle',
      set = "SetModuleState",
      get = function(info) return LTViewport.db.enabled end,
    },
    top = {
      name = "Top",
      desc = "For more precision, click and edit the 'editbox'",
      order = 50,
      width = 'full',
      type = 'range',
      min = 0,
      max = 400,
      step = 1,
      set = function(info, val)
              LTViewport.db.top = val
              LTViewport:Update()
            end,
      get = function(info) return LTViewport.db.top end,
    },
    bottom = {
      name = "Bottom",
      desc = "For more precision, click and edit the 'editbox'",
      order = 60,
      width = 'full',
      type = 'range',
      min = 0,
      max = 400,
      step = 1,
      set = function(info, val)
              LTViewport.db.bottom = val
              LTViewport:Update()
            end,
      get = function(info) return LTViewport.db.bottom end,
    },
    left = {
      name = "Left",
      desc = "For more precision, click and edit the 'editbox'",
      order = 70,
      width = 'full',
      type = 'range',
      min = 0,
      max = 400,
      step = 1,
      set = function(info, val)
              LTViewport.db.left = val
              LTViewport:Update()
            end,
      get = function(info) return LTViewport.db.left end,
    },
    right = {
      name = "Right",
      desc = "For more precision, click and edit the 'editbox'",
      order = 80,
      width = 'full',
      type = 'range',
      min = 0,
      max = 400,
      step = 1,
      set = function(info, val)
              LTViewport.db.right = val
              LTViewport:Update()
            end,
      get = function(info) return LTViewport.db.right end,
    },
    fillStyle = {
      name = "Void fill style",
      order = 20,
      type = 'select',
      values = {
        solid = "Solid color",
        gradient = "Gradient color",
      },
      set = function(info, val)
              LTViewport.db.fillStyle = val
              LTViewport:Update()
            end,
      get = function(info) return LTViewport.db.fillStyle end,
    },
    fillEdge = {
      name = "Edge color",
      order = 40,
      type = 'color',
      set = function(info, r, g, b, a)
              LTViewport.db.fillEdge = {r, g, b}
              LTViewport:Update()
            end,
      get = function(info) return unpack(LTViewport.db.fillEdge) end,
    },
    fillCenter = {
      name = "Center color",
      order = 30,
      disabled = function(info) return LTViewport.db.fillStyle ~= 'gradient' end,
      type = 'color',
      set = function(info, r, g, b, a)
              LTViewport.db.fillCenter = {r, g, b}
              LTViewport:Update()
            end,
      get = function(info) return unpack(LTViewport.db.fillCenter) end,
    },
  },
}

LazyTown:AddModuleOptions("viewportGroup", moduleOptions)
