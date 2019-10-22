--this script keeps track of the remotes starting with the word 'Set' 
--sets the data specified in the function(s)
playerDataModule = require(game.ServerScriptService.PlayerDataModule)
remotes = game.ReplicatedStorage.Remotes

function setData(player, itemName, location, action)
	local data = playerDataModule:Get(player)
	
	if(action == "Remove")then
		if(location == "Inventory")then
			--remove item from inventory
			for _,item in pairs(data.Inventory)do
				--TODO: Differentate between different types
				
				
				if(item.Name == itemName)then
					--the item is permanet so we cannot delete the item, return false
					if(item.Permanent)then
						return false
					end	
					
					return true -- we deleted the item successfully, return true
				end
			end
		end
	end
end
remotes.setData.OnServerInvoke = setData