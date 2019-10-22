players = game.Players
data = require(script.Parent)

players.PlayerAdded:Connect(function(player)
	--data:Wipe(player)
	local selectedSlot = "slot1"
	data:LoadFromDataStore(player, selectedSlot)
	
	local playerData = data:Get(player) -- getting players data
end)

players.PlayerRemoving:Connect(function(player)	
	data:Save(player)
	data:Remove(player)
end)

----save data when server closes
--game:BindToClose(function()
--	data:AutoSave()
--end)

--save data every 2 mins
while(wait(60*2))do
	data:AutoSave()
end
