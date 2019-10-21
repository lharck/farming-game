remotes = game.ReplicatedStorage.Remotes
player = game.Players.LocalPlayer
mouse = player:GetMouse()


script.Parent.Activated:Connect(function()
	local target = mouse.Target
	if(not target or not target.Name == "Soil")then return end

	--get the soil's soil class instance
	local soil = remotes.GetPlacedItems:InvokeServer("Soil", target.Parent)
	soil:Water()
	
	--TODO: ONLY if the watering can contains water, then water plant
end)