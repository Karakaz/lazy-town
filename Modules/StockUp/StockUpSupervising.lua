
function StockUp:OnInitialize()
  self:GeneralSetup('stockUp')
  self.localizedClass, self.class = UnitClass('player')
end

function StockUp:OnEnable()
  self:RegisterEvent('MERCHANT_SHOW')
end

function StockUp:OnDisable()
  self:UnregisterEvent('MERCHANT_SHOW')
end

function StockUp:PopInput()
  local s = self.currentInput
  self.currentInput = nil
  return s
end

function StockUp:AddToCustomList()
  local input = self:PopInput()
  if input and input:len() > 0 then
    self.db.custom[input] = {enabled = true, range = 1, stacks = self.db.customStacks}
    self:Print(LazyTown:GetChat(), "Added custom item: " .. input .. ", " .. self.db.customStacks .. " stacks")
  end
end

function StockUp:RemoveFromCustomList()
  local input = self:PopInput()
  if input and input:len() > 0 then
    self.db.custom[input] = nil
    self:Print(LazyTown:GetChat(), "Removed custom item: " .. input)
  end
end

function StockUp:ClearCustomList()
  local customItems = self.db.custom
  if customItems then
    for k, v in pairs(customItems) do
      customItems[k] = nil
    end
  end
end

function StockUp:PrintCustomList()
  local chat = LazyTown:GetChat()
  local color = "|cffeeff22"
  chat:AddMessage(color .. "StockUp, Custom items list:|r")

  local t = {}

  for itemName, stacks in pairs(self.db.custom) do
    table.insert(t, {name = itemName, stacks = stacks})
  end

  if #t == 0 then
    chat:AddMessage(color .. "~~ empty ~~|r")
    return
  end

  table.sort(t, function(itemA, itemB) return itemA.name < itemB.name end)

  for i = 1, #t do
    chat:AddMessage(color .. t[i].name .. ", " .. t[i].stacks .. " stacks|r")
  end
end
