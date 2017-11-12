
local LazyTown = _G.LazyTown  --This is so the options don't have to look up the global LazyTown table every time

-- Option table related methods  --------------------------------------------------------
function LazyTown:AddModuleOptions(varName, moduleGroup)
  self.options.args[varName] = moduleGroup
end

function LazyTown:OptionTableVSpace(order, linefeeds)
  return {name = linefeeds or "\n", order = order, type = 'description'}
end

-- Option table  ------------------------------------------------------------------------
LazyTown.options = {
  name = "LazyTown",
  handler = LazyTown,
  type = 'group',
  childGroups = 'tree',
  args = {
    general = {
      name = "General",
      order = 10,
      type = 'group',
      args = {
        enable = {
          name = "Addon enabled",
          desc = "Enables / disables LazyTown",
          order = 10,
          type = 'toggle',
          set = function(info, val) if val then LazyTown:Enable()
                                    else LazyTown:Disable() end end,
          get = function(info) return LazyTown.db.profile.enabled end,
        },
        outputWindow = {
          name = "Output window",
          desc = "Where all of the addons output will be printed",
          order = 30,
          type = 'select',
          values =  function(info)  local valueTable = {DEFAULT_CHAT_FRAME = 'DEFAULT_CHAT_FRAME'}
                                    for i = 1, NUM_CHAT_WINDOWS do
                                      local name = (GetChatWindowInfo(i))
                                      if name and name:len() > 0 then
                                        valueTable["ChatFrame" .. i] = name
                                      else
                                        valueTable["ChatFrame" .. i] = "ChatFrame" .. i
                                      end
                                    end
                                    return valueTable end,
          set = function(info, val) if getglobal(LazyTown.db.profile.chat) then
                                      LazyTown.db.profile.chat = val
                                    else
                                      LazyTown.db.profile.chat = 'DEFAULT_CHAT_FRAME'
                                    end end,
          get = function(info)  if getglobal(LazyTown.db.profile.chat) then
                                  return LazyTown.db.profile.chat
                                else
                                  return 'DEFAULT_CHAT_FRAME'
                                end end,
        },
        enableAllModules = {
          name = "Enable all modules",
          order = 20,
          type = 'execute',
          func = "EnableAllModules",
        },
        disableAllModules = {
          name = "Disable all modules",
          order = 40,
          type = 'execute',
          func = "DisableAllModules",
        },
        vSpace1 = LazyTown:OptionTableVSpace(45),
        wayToOptions = {
          name = "How to get here",
          order = 50,
          type = 'header',
        },
        slashDesc = {
          name = "You can always use /lt or /lazytown to open this window. LazyTown supports FuBar with the addon 'Broker2FuBar' installed.",
          order = 60,
          type = 'description',
        },
        minimapButton = {
          name = "Minimap button",
          order = 70,
          type = 'toggle',
          set = function(info, val) LazyTown.db.profile.minimapButton.enabled = val LazyTown:UpdateMinimapButton() end,
          get = function(info) return LazyTown.db.profile.minimapButton.enabled end,
        },
        createMacro = {
          name = "Create Macro",
          desc = "Creates a macro you can place on your action bars. Will use the 'LazyTownSquare' icon if it is " ..
                 "installed in the folder 'Interface\\Icons'",
          order = 80,
          type = 'execute',
          func = "CreateMacro",
        },
        startupMessage = {
          name = "Startup message",
          order = 90,
          type = 'toggle',
          set = function(info, val) LazyTown.db.profile.startupMessage = val end,
          get = function(info) return LazyTown.db.profile.startupMessage end,
        },
      },
    },
    technical = {
      name = "Technical",
      order = 30,
      type = 'group',
      args = {
        distanceGroup = {
          name = "Distance caps",
          order = 10,
          type = 'group',
          inline = true,
          args = {
            farclip = {
              name = "Terrain",
              desc = "Also known as farclip, this covers everything you see in the game world except the terrain itself. " ..
                     "777 is the recommended maximum, however it is possible to go over that ;)",
              order = 10,
              type = 'range',
              step = 1,
              bigStep = 50,
              min = 177,
              max = 1277,
              set = function(info, val) LazyTown.db.profile.cvars.farclip = val SetCVar('farclip', val) end,
              get = function(info) return LazyTown.db.profile.cvars.farclip end,
            },
            horizonfarclip = {
              name = "Horizon",
              desc = "Also knowns as horizonfarclip, this covers the terrain",
              order = 20,
              type = 'range',
              step = 1,
              bigStep = 50,
              min = 212,
              max = 2112,
              set = function(info, val) LazyTown.db.profile.cvars.horizonfarclip = val SetCVar('horizonfarclip', val) end,
              get = function(info) return LazyTown.db.profile.cvars.horizonfarclip end,
            },
            targetNearest = {
              name = "Target nearest",
              desc = "Maximum 'tab-target' distance",
              order = 30,
              type = 'range',
              step = 1,
              min = 25,
              max = 50,
              set = function(info, val) LazyTown.db.profile.cvars.targetNearestDistance = val SetCVar('targetNearestDistance', val) end,
              get = function(info) return LazyTown.db.profile.cvars.targetNearestDistance end,
            },
            cameraMax = {
              name = "Camera",
              desc = "Max camera distance",
              order = 40,
              type = 'range',
              step = 1,
              min = 10,
              max = 34,
              set = function(info, val) LazyTown.db.profile.cvars.cameraDistanceMax = val SetCVar('cameraDistanceMax', val) end,
              get = function(info) return LazyTown.db.profile.cvars.cameraDistanceMax end,
            },
          },
        },
        vSpace1 = LazyTown:OptionTableVSpace(15),
        ultraDetails = {
          name = "Ultra+ gfx details",
          desc = "Sets various graphics detail settings to maximum\n|cff999999(specifically the CVars: " ..
                  "groundEffectDensity, groundEffectDist, detailDoodadAlpha, smallcull, characterAmbient and skycloudlod)|r",
          order = 20,
          type = 'toggle',
          set = function(info, val) LazyTown.db.profile.ultraDetails = val LazyTown:UpdateUltraDetailsAndSet() end,
          get = function(info) return LazyTown.db.profile.ultraDetails end,
        },
        violence = {
          name = "Violence Level",
          desc = "Yeah, this exists!",
          order = 30,
          type = 'range',
          step = 1,
          min = 0,
          max = 5,
          set = function(info, val) LazyTown.db.profile.cvars.violenceLevel = val SetCVar('violenceLevel', val) end,
          get = function(info) return LazyTown.db.profile.cvars.violenceLevel end,
        },
        vSpace2 = LazyTown:OptionTableVSpace(35),
        screenshotFormat = {
          name = "Screenshot format",
          order = 40,
          type = 'select',
          values = {
            tga = 'tga',
            jpeg = 'jpeg',
          },
          set = function(info, val) LazyTown.db.profile.cvars.screenshotFormat = val SetCVar('screenshotFormat', val) end,
          get = function(info) return LazyTown.db.profile.cvars.screenshotFormat end,
        },
        screenshotQuality = {
          name = "Screenshot quality",
          order = 50,
          type = 'range',
          step = 1,
          min = 1,
          max = 10,
          set = function(info, val) LazyTown.db.profile.cvars.screenshotQuality = val SetCVar('screenshotQuality', val) end,
          get = function(info) return LazyTown.db.profile.cvars.screenshotQuality end,
        },
        vSpace3 = LazyTown:OptionTableVSpace(55),
        reset = {
          name = "Reset to defaults",
          desc = "Resets this window to default settings",
          order = 60,
          type = 'execute',
          func = "ResetCVarsToDefaults",
        },
        vSpace4 = LazyTown:OptionTableVSpace(65),
        memory = {
          name = function(info) UpdateAddOnMemoryUsage()
                                return format("LazyTown memory usage: %.2fMB", GetAddOnMemoryUsage("LazyTown") / 1000) end,
          order = 70,
          type = 'description',
        },
      },
    },
    about = {
      name = "About",
      order = 40,
      type = 'group',
      args = {
        historyHeader = {
          name = "Inspiration to create LazyTown",
          order = 10,
          type = 'header',
        },
        history = {
          name = "Most addons do one thing or cover one area. What they do, they do great and with many options as well, but they still only cover that one thing. " ..
                 "I wanted to create a relatively lightweight addon that includes the basics everything. Well, not everything, but much of what I've needed or thought " ..
                 "was cool over the years of playing. The biggest inspiration comes from the addon Leatrix Plus, which also attempts to equip the user with the basics, " ..
                 "while being completely modular. However since it wasn't created until after TBC, it couldn't be used without modifying it, which was fuel enough " ..
                 "for me to create LazyTown instead.\n",
          order = 20,
          type = 'description',
        },
        whatItDoesHeader = {
          name = "What LazyTown has to offer",
          order = 30,
          type = 'header',
        },
        whatItDoes = {
          name = "LazyTown is built to provide comfort and luxury to its users, by taking care of many repetitive tasks, providing more information and new ways to handle" ..
                 " things, as well as making things look cleaner. All is optional of course, so you can still use your specialised addon for more options if you so desire.\n",
          order = 40,
          type = 'description',
        },
        whatItDoesNotDoHeader = {
          name = "What LazyTown doesn't do",
          order = 50,
          type = 'header',
        },
        whatItDoesNotDo = {
          name = "LazyTown does not cover everything and that is not its purpose. Here are some areas LazyTown does not cover and some examples of addons that goes well " ..
                 "with it:\n\nBags:   Bagnon\nChat:   Prat, Chatter, WIM\nMisc:   BuyEmAll\n",
          order = 60,
          type = 'description',
        },
        version = {
          name = "\n\n\n\n\n\n\nVersion " .. GetAddOnMetadata("LazyTown", 'version'),
          order = 70,
          type = 'description',
        },
      },
    },
  },
}
