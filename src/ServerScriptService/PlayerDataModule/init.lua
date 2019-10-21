--[[
	Description: require() this script when you want to access the player's data.
	If you want to get the player's data fire the GetData remote function.
]]
	
DSVersion = "1.33"
local DataStoreService = game:GetService("DataStoreService")
local playerDataDS = DataStoreService:GetDataStore("PlayerData"..DSVersion)
dataContainer = require(script.DataContainer) --This is the player's data for each save slot

data = {}
data.allData = {} --	Table consisting of the player's names and their data.

--default table to save to datastore. 
defaultData = {
	["slot1"] = dataContainer.new();
	["slot2"] = dataContainer.new();
	["slot3"] = dataContainer.new();
	
	Version = 0;
	currentSaveSlot = nil;
}

--------------------------------------------------------------
--					PRIVATE FUNCTIONS
--------------------------------------------------------------

--Go through all the possible paths inside the default data. If any paths don't exist, create them.
--This function is used when we change the default data. 
function CheckForChanges(currentRoot, location)
	--loop through current root's children
	for index, data in pairs(currentRoot)do
		if(not location[index])then
			location[index] = data
		end
		--if the child is a table, look inside it's paths and see if they don't exist
		if(type(data) == "table" and next(data))then
			local newLocation = location[index]
			CheckForChanges(data, newLocation)    		
		end
	end
end

--------------------------------------------------------------
--					PUBLIC FUNCTIONS
--------------------------------------------------------------
--gets the player's in game data (from allData variable, NOT directly from DataStore)
function data:Get(player)
	local playerData = data.allData[player.Name] --get player data from data table

	if(playerData)then
		return playerData[playerData.currentSaveSlot]
	else
		error("[ERROR]: The player's data does not exist. PlayerDataModule - GetData()")
	end
end

--saves the player's data in allData to the datastore
function data:Save(player)	
	local key = tostring(player.UserId)
	
	playerDataDS:UpdateAsync(tostring(player.UserId), function(oldData)
		local previousData = oldData or defaultData --if the previous data doesn't exist, use the defaultSaveDS this is our first time saving the player's data, otherwise use the old data
		local playerData = data.allData[player.Name] --get player data from data table
		
		if(playerData)then --attempt save if the data exists
		    if playerData.Version == previousData.Version then --if the data is valid, update the data's version number and save the data
		        playerData.Version = playerData.Version + 1
		        return playerData
		    else
				warn("[ERROR]: Data for ", player.Name, " did not save properly. PlayerDataModule - Save()")
		        return nil --if it's not valid, don't save data
		    end
		else
			error("[ERROR]: Data for ", player.Name, " does not exist. PlayerDataModule - Save()")
		end 
	end)
end

--loads player data from datastore
function data:LoadFromDataStore(player, selectedSlot)
	if(data.allData[player])then return end
	
	local success, dataFromDS = pcall(function()
		return playerDataDS:GetAsync(player.UserId)
	end)

	if(success)then

		if(dataFromDS)then --give player their data from DS
			data.allData[player.Name] = dataFromDS
			data.allData[player.Name]["currentSaveSlot"] = selectedSlot
			--update player data by comparing it to the default data and adding anything that doesn't exist.
			CheckForChanges(dataContainer, data.allData[player.Name][selectedSlot])
		else --give player default data
			data.allData[player.Name] = defaultData --load the chosen save slot
			data.allData[player.Name]["currentSaveSlot"] = selectedSlot
			data:Save(player)
		end

	else
		error("[ERROR:] Failed to get ", player.Name, "'s data from datastore.")
	end
end

function data:AutoSave()
	print("autosaving...")
	for playerName, playerData in pairs(data.allData)do
		local player = game.Players:FindFirstChild(playerName)
		
		if(player)then
			data:Save(player)
		end
	end
end

function data:Remove(player)	
	data.allData[player.Name] = nil
end

--wipe players data. 
function data:Wipe(player)
	print("wiping data...")
	
	local success, val = pcall(function()
		return playerDataDS:RemoveAsync(player.UserId)
	end)
	if(not success)then
		error("data did not load successfully")
	end
 
end

return data