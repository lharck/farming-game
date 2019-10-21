--Description: This is the server script that catches events ran inside the 'ItemPlacement' script.

--TODO: Right now the furniture and soil scripts are using the same datastore. Change that.
local datastore = game:GetService("DataStoreService"):GetDataStore("PlacementSystem")
local soilClass = require(game.ServerScriptService.ItemPlacement.SoilClass)
--local furnitureClass = require(game.ServerScriptService.FurnitureClass)
local placementClass = require(game:GetService("ReplicatedStorage").ItemPlacement)
local placementObjects = {}

local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

----------------------------------------------------------------------------------------------------------------------------------------------------------------

function remotes.InitPlacement.OnServerInvoke(player, canvasPart)
	placementObjects[player] = placementClass.new(canvasPart)
	return placementObjects[player].GridObjects
end

function remotes.InvokePlacement.OnServerInvoke(player, func, itemType, model, cf, GridObjects)
	if (placementObjects[player]) then
		local clone = model:Clone()
		clone:SetPrimaryPartCFrame(cf)
		clone.Parent = GridObjects
		clone.PrimaryPart.Transparency = 1
		
		if(itemType == "Soil")then
			soilClass.new(player, clone)
		end
	end
end

--TODO: UpdateAsync()
function remotes.DSPlacement.OnServerInvoke(player, saving, useData)
	local key = "player_"..player.UserId
	
	local success, result = pcall(function()
		if (saving and placementObjects[player]) then
			if (useData) then
				datastore:SetAsync(key, placementObjects[player]:Serialize())
			else
				datastore:SetAsync(key, {})
			end
		elseif (not saving) then
			return datastore:GetAsync(key)
		end
	end)
	
	if (success) then
		return saving or result
	else
		warn(result)
	end
end
