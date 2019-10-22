--Description: allows the player to interact with inventory
mouse = game.Players.LocalPlayer:GetMouse()
mouseMoveEvent = nil
inventory = script.Parent.Frame:WaitForChild("FullInventory")
template = inventory.Template
remotes = game.ReplicatedStorage.Remotes

--The following controls work for mobile and pc. 
currentSlot = nil 
itemBeingDragged = nil
startingSlot = nil

--if the player is dragging an item across the screen, 
--move the item every time the player moves their mouse
function onMouseMove()
	if(itemBeingDragged)then
		itemBeingDragged.Position = UDim2.new(0, mouse.X - (itemBeingDragged.Size.X.Offset/2), 0, mouse.Y - (itemBeingDragged.Size.Y.Offset/2))
	end
end

--allow player to drag item across screen when the click down on their mouse 
function onClicked(item)
	print("clicked")
	if(item.Name ~= "Default")then
		mouseMoveEvent = mouse.Move:Connect(onMouseMove)

		startingSlot = item.Parent
		currentSlot = startingSlot
		
		--scale item based on screen resolution so we can change it's parent and maintain aspect ratio
		item.Size = UDim2.new(0, item.AbsoluteSize.X, 0, item.AbsoluteSize.Y)
		itemBeingDragged = item
		itemBeingDragged.Parent = script.Parent.Frame
		itemBeingDragged.Position = UDim2.new(0, mouse.X - (itemBeingDragged.Size.X.Offset/2), 0, mouse.Y - (itemBeingDragged.Size.Y.Offset/2))
	end
end

--move item back to most recently visited slot when player stops clicking
function onClickEnded(item)
	print("click ended")
	mouseMoveEvent = (not mouseMoveEvent) or mouseMoveEvent:Disconnect() -- stop using our mouse moved event
	
	--player dragged item to trash
	if(currentSlot.Name == "Trash")then
		--TODO: remove deleted slot from inventory
		local deltedItem = remotes.setData:InvokeServer(item.Name, "Inventory", "Remove")
		
		if(deltedItem)then
			item.Parent = startingSlot --put slot back into starting slot and make it an empty slot
			item.Name = "Default"
			item.ViewportFrame:FindFirstChildWhichIsA("Model"):Destroy()
		else
			warn(item.Name .. " is undeletable. ")	
		end	
	end
	
	if(startingSlot)then --player placed item in another item slot
		local emptyItem = currentSlot:FindFirstChild("Default")
		
		--we are in an empty slot, place our item into there
		if(emptyItem)then
			item.Parent = currentSlot
			emptyItem.Parent = startingSlot
		else	
			item.Parent = startingSlot 	--we aren't in an empty slot/this is our starter slot so place back at starter slot
		end
	end
	item.Position = UDim2.new(0.1,0,0.1,0)
	itemBeingDragged, startingSlot=nil, nil
end

--change most recently entered slot when the player enters a new slot
function onMouseEnter(slot) currentSlot = slot end

--this is used by slots such as 'trash' who we don't want to save as our most recent slot when we leave the button area. 
function onMouseLeave() currentSlot = startingSlot end

--create events for slots
function createEvents(children)
	for _, slot in pairs(children) do
		local item = slot:FindFirstChildWhichIsA("ImageButton")
		if(item)then
			item.MouseButton1Down:Connect(function() onClicked(item) end)
			item.MouseButton1Up:Connect(function() onClickEnded(item) end)
			slot.MouseEnter:Connect(function() onMouseEnter(slot) end)
		elseif(slot.Name == "Trash")then
			slot.MouseButton1Down:Connect(function() onClicked(item) end)
			slot.MouseButton1Up:Connect(function() onClickEnded(item) end)
			slot.MouseEnter:Connect(function() onMouseEnter(slot) end)
			slot.MouseLeave:Connect(onMouseLeave)
		end
	end
end
createEvents(inventory.BackpackSlots:GetChildren())
createEvents(inventory.InventorySlots:GetChildren())
createEvents({inventory:WaitForChild("Trash")})


