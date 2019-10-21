--Description: allows the player to interact with inventory

mouse = game.Players.LocalPlayer:GetMouse()
mouseMoveEvent = nil

inventory = script.Parent.Frame:WaitForChild("FullInventory")
template = inventory:WaitForChild("Template")

-------------------------------------------------------------------------------
-- 								CONTROLS:
-------------------------------------------------------------------------------
--The following controls work for mobile and pc. 

currentCell = nil 
itemBeingDragged = nil
startingCell = nil

--if the player is dragging an item across the screen, 
--move the item every time the player moves their mouse
function onMouseMove()
	if(itemBeingDragged)then
		itemBeingDragged.Position = UDim2.new(0, mouse.X - (itemBeingDragged.Size.X.Offset/2), 0, mouse.Y - (itemBeingDragged.Size.Y.Offset/2))
	end
end

--allow player to drag item across screen when the click down on their mouse 
function onClicked(item)
	mouseMoveEvent = mouse.Move:Connect(onMouseMove)

	if(item.Name ~= "Default")then
		startingCell = item.Parent
		currentCell = startingCell
		
		--scale item based on screen resolution so we can change it's parent and maintain aspect ratio
		item.Size = UDim2.new(0, item.AbsoluteSize.X, 0, item.AbsoluteSize.Y)
		itemBeingDragged = item
		itemBeingDragged.Parent = script.Parent.Frame
		itemBeingDragged.Position = UDim2.new(0, mouse.X - (itemBeingDragged.Size.X.Offset/2), 0, mouse.Y - (itemBeingDragged.Size.Y.Offset/2))
	end
end

--move item back to most recently visited cell when player stops clicking
function onClickEnded(item)
	mouseMoveEvent:Disconnect()
	if(startingCell)then
		local emptyItem = currentCell:FindFirstChild("Default")
		
		--we are in an empty cell, place our item into there
		if(emptyItem)then
			item.Parent = currentCell
			emptyItem.Parent = startingCell
		else	
			print("back")
			--we aren't in an empty cell/this is our starter cell so place back at starter cell
			item.Parent = startingCell
		end
		
		item.Position = UDim2.new(0.1,0,0.1,0)
		itemBeingDragged, startingCell=nil, nil
	end
end

--change most recently entered cell when the player enters a new cell
function onMouseEnter(cell) currentCell = cell end

--create events for the cells we just made
for _, child in pairs(inventory.Slots:GetChildren()) do
	local item = child:FindFirstChildWhichIsA("ImageButton")
	if(item)then
		item.MouseButton1Down:Connect(function() onClicked(item) end)
		item.MouseButton1Up:Connect(function() onClickEnded(item) end)
		child.MouseEnter:Connect(function() onMouseEnter(child) end)
	end
end




