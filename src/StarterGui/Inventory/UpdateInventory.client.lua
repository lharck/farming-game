--Description: creates the inventory and updates it when need be
local player = game:GetService("Players").LocalPlayer 
local playerData = game:GetService("ReplicatedStorage").Remotes.GetData:InvokeServer()
inventory = script.Parent.Frame:WaitForChild("FullInventory")
template = inventory:WaitForChild("Template")
numInventorySlots, numBackpackSlots = 27, 9

-----------------------------------------------------------------------------------------
--					create slots for the inventory
-----------------------------------------------------------------------------------------
function createSlots(numSlots, whereToPlaceSlot)
		
	for i = 1 , numSlots do
		--create a new slot and insert it into the slots frame
		local clone = template:Clone()
		clone.Parent = whereToPlaceSlot
		clone.Name = "Slot"
		
		--if we are parenting the slots to the backpack slots frame, make backpack slot dark
		if(whereToPlaceSlot.Name == "BackpackSlots")then  
			clone.ImageColor3 = Color3.new(156/255, 255/255, 94/255)
		end
		
		--put item in first position for testing
		if(i == 1)then
			clone["Default"].Name = "test"
			clone["test"].BackgroundColor3 = Color3.new(0,1,0)
			clone["test"].BackgroundTransparency = 0
		end
	end
end

createSlots(numInventorySlots, inventory.InventorySlots) --create inventory slots
createSlots(numBackpackSlots, inventory.BackpackSlots) --create backpack slots

template.Visible = false --hide template
script.Parent.Controls.Disabled = false --since we loaded the slots, we can now create the controls for the slots
-----------------------------------------------------------------------------------------
--							UPDATE INVENTORY
-----------------------------------------------------------------------------------------
--update inventory based on the player data on the server

--TODO: Sort by type
function updateInventoryGUI()
	--put everything in inventory into 
	for i, item in pairs(playerData.Inventory)do 
		local itemModel = game:GetService("ReplicatedStorage").Models.ForViewports:FindFirstChild(item.Name)
		local clone = itemModel:Clone()
		clone.Parent = script.Parent.Frame.FullInventory.InventorySlots[i]
	end
end

updateInventoryGUI()