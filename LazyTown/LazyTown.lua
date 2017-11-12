--[[
Licence: Modified MIT Licence

Permission is hereby granted, free of charge, to any person obtaining a copy of this software,
to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute and/or sublicense copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software or in a stand-alone file named 'licence.txt' located in the root directory
of the software.                                                                                ]]--


local getPriceById = LibStub('ItemPrice-1.1').GetPriceById
local origGetSellValue = GetSellValue

--- LazyTown provides the USER-API function GetSellValue through ItemPrice-1.1(r51)
-- http://www.wowwiki.com/USERAPI_GetSellValue?oldid=1340149
-- Tekkub's hooking version:
function GetSellValue(item)
  local id = type(item) == "number" and item or type(item) == "string" and tonumber(item:match("item:(%d+)"))

  if not id and type(item) == "string" then -- Convert item name to itemid, only works if the player has the item in his bags
    local _, link = GetItemInfo(item)
    id = link and tonumber(link:match("item:(%d+)"))
  end

  return id and (getPriceById(_, id) or origGetSellValue and origGetSellValue(id))
end

--- ValueToMoneyString takes in a value in copper and returns a string-
--  representation of that value in gold, silver and copper
function ValueToMoneyString(value, case)
  local copper = {upper = 'C', lower = 'c', coin = "|TInterface\\AddOns\\LazyTown\\Textures\\CopperIcon:0:0:1|t"}
  local silver = {upper = 'S', lower = 's', coin = "|TInterface\\AddOns\\LazyTown\\Textures\\SilverIcon:0:0:1|t"}
  local  gold  = {upper = 'G', lower = 'g', coin = "|TInterface\\AddOns\\LazyTown\\Textures\\GoldIcon:0:0:1|t"}
  local key = case or 'coin'
  if value < 100 then
    return value .. copper[key]
  elseif value < 10000 then
    return floor(value / 100) .. silver[key] .. " " .. (value % 100) .. copper[key]
  else
    return floor(value / 10000) .. gold[key] .. " " .. floor((value / 100) % 100) .. silver[key] .. " " .. (value % 100) .. copper[key]
  end
end

function LazyTown.SaveAllPoints(frame)
  local numPoints = frame:GetNumPoints()
  for i = 1, numPoints do
    frame.db.points[i] = {}
    local p = frame.db.points[i]
    p.point, p.relativeTo, p.relativePoint, p.xOffset, p.yOffset = frame:GetPoint(i)
  end
end

function LazyTown.RestoreAllPoints(frame, defaultPoint)
  frame:ClearAllPoints()
  local numPoints = #frame.db.points
  if numPoints == 0 then
    frame:SetPoint(defaultPoint or 'CENTER')
  else
    for i = 1, numPoints do
      local p = frame.db.points[i]
      frame:SetPoint(p.point, p.relativeTo, p.relativePoint, p.xOffset, p.yOffset)
    end
  end
end
