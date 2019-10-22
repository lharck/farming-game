inventoryButton = script.Parent.Frame.Inventory
inventory = script.Parent.Parent.Inventory.Frame.FullInventory

inventoryButton.MouseButton1Click:Connect(function()
	if(not inventory.Visible)then
		inventory.Visible = true
	else
		inventory.Visible = false
	end
end)

