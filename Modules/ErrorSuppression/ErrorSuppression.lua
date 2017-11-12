
function ErrorSuppression:UIErrorsFrame_OnEvent(event, message, ...)

  if self:ShouldSuppressNow() then
    local dbError = self.db

    if dbError.filterExact[message] or dbError.filterCustom[message] then
      return
    end

    for startsWidth, enabled in pairs(dbError.filterStartsWidth) do
      if enabled then
        if message:find("^" .. startsWidth) then
          return
        end
      end
    end
  end

  self.hooks.UIErrorsFrame_OnEvent(event, message, ...)
end

function ErrorSuppression:ShouldSuppressNow()
  local when = self.db.when
  if     when == 'always' then return true
  elseif when == 'combat' then return InCombatLockdown()
  elseif when == 'pvp'    then return self:IsInPvPZone()
  elseif when == 'raid'   then return self:IsInRaid()
  end
end

function ErrorSuppression:IsInPvPZone()
  local inInstance, instanceType = IsInInstance()
--  if mainZone == "Warsong Gulch" or mainZone == "Arathi Basin" or mainZone == "Alterac Valley" or mainZone == "Eye of the Storm" or
--      mainZone == "Ruins of Lordaeron" or mainZone == "Ring of Trials" or mainZone == "Circle of Blood" then
  if inInstance then
    if instanceType == 'pvp' or instanceType == 'arena' then
      return true
    else
      return false
    end
  else
    local mainZone, subZone = GetRealZoneText(), GetSubZoneText()
    if mainZone == "Eastern Plaguelands" and (subZone == "Crown Guard Tower" or subZone == "Eastwall Tower" or
                                              subZone == "Northpass Tower" or subZone == "Plaguewood Tower") then
      return true
    elseif mainZone == "Silithus" then
      return true
    elseif mainZone == "Hellfire Peninsula" and (subZone == "The Overlook" or subZone == "The Stadium" or subZone == "Broken Hill") then
      return true
    elseif mainZone == "Nagrand" and subZone == "Halaa" then
      return true
    elseif mainZone == "Terokkar Forest" and subZone == "The Bone Wastes" then
      return true
    elseif mainZone == "Zangarmarsh" and subZone == "Twin Spire Ruins" then
      return true
    end
  end
end

function ErrorSuppression:IsInRaid()
  local inInstance, instanceType = IsInInstance()
  if inInstance and instanceType == 'raid' then
    return true
  end
end
