--this script keeps track of the remotes starting with the word 'Get' and returns the specified item

remotes = game.ReplicatedStorage.Remotes

placedItems = require(game.ServerScriptService.ItemPlacement.PlacedItems)
playerData = require(game.ServerScriptService.PlayerDataModule)

function remotes.GetData.OnServerInvoke(player)
	return playerData:Get(player)
end

function remotes.GetPlacedItems.OnServerInvoke(player, itemType, model)
	return placedItems:GetInstance(player.Name, itemType, model)
end

