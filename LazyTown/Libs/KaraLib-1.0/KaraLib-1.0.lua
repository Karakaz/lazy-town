
local MAJOR, MINOR = 'KaraLib-1.0', 1

local KaraLib = LibStub:NewLibrary(MAJOR, MINOR)

-------------------------------------------------------------------------------

local TAB = '     '

local function localPrint(indent, str)
  DEFAULT_CHAT_FRAME:AddMessage(indent .. str)
end

local function localPrintTab(indent, str)
  DEFAULT_CHAT_FRAME:AddMessage(indent .. TAB .. str)
end

function KaraLib:PrintTable(tbl, indent, depthLevel)
  indent = indent or ''
  if tbl == nil then
    localPrint(indent, "table is nil")
  else
    localPrint(indent, '{')
    for key, value in pairs(tbl) do

      if type(value) == 'table' then
        if next(value) == nil then
          localPrintTab(indent, tostring(key) .. '= ' .. tostring(value) .. ' {}')
        else
          localPrintTab(indent, tostring(key) .. '= ' .. tostring(value))
          if #indent <= (depthLevel or 5) * 5 then
            self:PrintTable(value, indent .. TAB)
          end
        end
      else
        localPrintTab(indent, tostring(key) .. '= ' .. tostring(value))
      end
    end
    localPrint(indent, '}')
  end
end

function KaraLib:tonumbers(...)
  if select('#', ...) > 1 then
    return tonumber((...)), self:tonumbers(select(2, ...))
  else
    return tonumber((...))
  end
end

function KaraLib:NextMultiple(number, multipleOf)
  return ceil(number / multipleOf) * multipleOf
end

function KaraLib:IsTableEmpty(table)
  return next(table) == nil
end

function KaraLib:WipeTable(table)
  for k, _ in pairs(table) do
    table[k] = nil
  end
end

function KaraLib:ColorHexToRGB(hex)
  hex = strmatch(hex, "|cff([0-9a-f]{6})") or hex
  local color = {}
  for i = 1, 5, 2 do
    tinsert(color, tonumber(strsub(hex, i, i + 1)) / 255)
  end  
  return unpack(color)
end
