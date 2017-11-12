
local ErrorSuppression = _G.ErrorSuppression

local moduleOptions = {
  name = function(info) return LazyTown:ApplyStateColor("ErrorSuppression", ErrorSuppression.db.enabled) end,
  handler = ErrorSuppression,
  disabled = LazyTown.IsDisabled,
  type = 'group',
  childGroups = 'tab',
  args = {
    enabled = {
      name = "Enabled",
      order = 10,
      type = 'toggle',
      set = "SetModuleState",
      get = function(info) return ErrorSuppression.db.enabled end,
    },

    generalGroup = {
      name = "General",
      order = 50,
      type = 'group',
      args = {
        description = {
          name = "ErrorSuppression prevents selected error messages from clogging up your screen.\nSadly, the audio cannot be " ..
                 "turned off in quite the same way, but all can be turned on/off collectively. (Below or in sound options)",
          order = 10,
          type = 'description',
        },
        errorSound = {
          name = "Error speech",
          order = 40,
          type = 'toggle',
          set = function(info, val) ErrorSuppression.db.sound = val
                                    ErrorSuppression:UpdateErrorSpeech() end,
          get = function(info) return ErrorSuppression.db.sound end,
        },
        whenToSuppress = {
          name = "When to suppress",
          order = 30,
          type = 'select',
          values = {
            always = "Always",
            combat = "In combat",
            pvp = "PvP zones",
            raid = "In raids",
          },
          set = function(info, val) ErrorSuppression.db.when = val end,
          get = function(info) return ErrorSuppression.db.when end,
        },
        whatToSupress = {
          name = "What to suppress",
          order = 20,
          type = 'select',
          values = {
            all = "All in list",
            mostFrequent = "Most frequently triggered",
            custom = "Custom",
          },
          set = function(info, val) ErrorSuppression.db.what = val ErrorSuppression:UpdateErrors() end,
          get = function(info) return ErrorSuppression.db.what end,
        },
        customGroup = {
          name = "Custom Errors/Messages to suppress",
          order = 50,
          type = 'group',
          inline = true,
          args = {
            customInput = {
              name = "Input",
              desc = "Case sensitive. Supports dragging and dropping of items on it.",
              order = 10,
              width = 'double',
              type = 'input',
              set = function(info, val) ErrorSuppression.currentInput = val:match("^%s*(.-)%s*$") end,
              get = function(info) return ErrorSuppression.currentInput end,
            },
            customAdd = {
              name = "Add",
              desc = "Add item to custom errors list",
              order = 20,
              type = 'execute',
              func = "AddToCustomList",
            },
            customRemove = {
              name = "Remove",
              desc = "Remove item from custom errors list",
              order = 30,
              type = 'execute',
              func = "RemoveFromCustomList",
            },
            customPrint = {
              name = "Print custom errors list",
              desc = "Print the custom errors list to chat",
              order = 40,
              type = 'execute',
              func = "PrintCustomList",
            },
            customClear = {
              name = "Clear list",
              desc = "Clears the entire custom errors list",
              order = 50,
              confirm = true,
              type = 'execute',
              func = "ClearCustomList",
            },
          },
        },
      },
    },
    errorsGroup = {
      name = "Errors & Messages",
      order = 60,
      type = 'group',
      args = {
        -- inserted below
      },
    },
  },
}

local errorCount = 1
for k, v in pairs(LazyTown.defaults.profile.error.filterExact) do
  moduleOptions.args.errorsGroup.args["error" .. errorCount] = {
    name = k,
    type = 'toggle',
    set = function(info, val) ErrorSuppression.db.filterExact[k] = val
                              ErrorSuppression.db.what = 'custom' end,
    get = function(info) return ErrorSuppression.db.filterExact[k] end,
  }
  errorCount = errorCount + 1
end

for k, v in pairs(LazyTown.defaults.profile.error.filterStartsWidth) do
  moduleOptions.args.errorsGroup.args["error" .. errorCount] = {
    name = k .. "[...]",
    type = 'toggle',
    set = function(info, val) ErrorSuppression.db.filterStartsWidth[k] = val
                              ErrorSuppression.db.what = 'custom' end,
    get = function(info) return ErrorSuppression.db.filterStartsWidth[k] end,
  }
  errorCount = errorCount + 1
end

LazyTown:AddModuleOptions("errorSuppressionGroup", moduleOptions)
