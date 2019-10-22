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
		clone.Name = i
		
		--if we are parenting the slots to the backpack slots frame, make backpack slot dark
		if(whereToPlaceSlot.Name == "BackpackSlots")then  
			clone.ImageColor3 = Color3.new(156/255, 255/255, 94/255)
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

function insertItem(item, ViewportFrame)
	local modelClone = item:Clone()
	modelClone.Parent = ViewportFrame
	ViewportFrame.Parent.Name = item.Name 
		
	local viewportCamera = Instance.new("Camera")
	ViewportFrame.CurrentCamera = viewportCamera
	viewportCamera.Parent = ViewportFrame
	viewportCamera.CFrame = modelClone.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(60),0) * CFrame.new(0,0,3) 
end

--TODO: Sort by type
function updateInventoryGUI()
	--put everything in inventory into 
	for i, item in pairs(playerData.Inventory)do 
		local slot = script.Parent.Frame.FullInventory.InventorySlots[i]
		local model = game:GetService("ReplicatedStorage").Models.ForViewports:FindFirstChild(item.Name)

		if(slot:FindFirstChild("Default"))then
			insertItem(model, slot.Default.ViewportFrame)
		end
	end
end

updateInventoryGUI()