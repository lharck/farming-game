local module = {}

--[[Format:
	module.ItemType = {
		["royaltoe"] = {["model location"] = ItemClass, ["model location"] = ItemClass, , ["model location"] = ItemClass,},
		["Telamon"] = {["model location"] = ItemClass, ["model location"] = ItemClass, , ["model location"] = ItemClass,},
		["Shedletsky"] = {["model location"] = ItemClass, ["model location"] = ItemClass, , ["model location"] = ItemClass,},
	}
]]

module.Furniture = {}
module.Soil = {}

--add an item to one of the tables above
function module:Add(itemType, instance)
	local playerName, model = instance.Owner, instance.Model
	
	if(not module[itemType][playerName])then
		module[itemType][playerName] = {}
	end
	
	module[itemType][playerName][model] = instance
end

function module:GetInstance(playerName, tableName, Model)
	local Table = self:GetTable(playerName, tableName)

	if(Table and Table[Model])then
		return Table[Model]
	end	
end

function module:GetTable(playerName, tableName)
	if(not module[tableName] or not module[tableName][playerName])then
		return nil
	end
	
	return module[tableName][playerName]
end


function module:Remove(itemType, instance)
	module[itemType][instance.Owner][instance.Model] = nil
	instance:Destroy()
end

return module