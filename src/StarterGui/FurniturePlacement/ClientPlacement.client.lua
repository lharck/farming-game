--[[
	Description: Places furniture items in a player's house on a specified grid. 
	Uses the 'ItemPlacement' script to accomplish this. ^^ 
]]

local grid = game.Workspace.FloorsBounds.Part
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local furniture = game:GetService("ReplicatedStorage"):WaitForChild("Models").Furniture
local placementClass = require(game:GetService("ReplicatedStorage"):WaitForChild("ItemPlacement"))

local placement = placementClass.fromDataStore(grid, remotes.DSPlacement:InvokeServer(false, false))
placement.GridUnit = 2
local rotation = 0

local mouse = game.Players.LocalPlayer:GetMouse()

local model = nil --model you want to use
inEditMode = false --check if you're in edit mode to activate placement.
renderedStepEvent, userInputEvent = nil

----------------------------------------------------------------------------------------
--					FUNCTIONS CALLED BY KEY PRESS o___o 
----------------------------------------------------------------------------------------

local function rotateModel(actionName, userInputState, input)
	if (userInputState == Enum.UserInputState.Begin) then
		rotation = rotation + math.pi/2
	end
end

local function placeModel(actionName, userInputState, input)
	local cf = placement:GetPlacementCFrame(model, mouse.Hit.p, rotation)
--	placement:Place(furniture[model.Name], cf, placement:isColliding(model))
	placement:Place(furniture[model.Name], cf, false)

end

local function clearFurniture(actionName, userInputState, input)
	model.Parent = nil
	placement:Clear()
	model.Parent = mouse.TargetFilter
end

local function savePlacement(actionName, userInputState, input)
	placement:Save()
end

----------------------------------------------------------------------------------------
--								 GUI CONTROLS 
----------------------------------------------------------------------------------------
editButton = script.Parent.Frame.editModeButton

--Turn on edit mode if the the player clicks the edit button
editButton.Activated:Connect(function()
	if(inEditMode)then
		renderedStepEvent:Disconnect()
		userInputEvent:Disconnect()
		inEditMode = false
		
		editButton.Text = "Click To Edit"
		model:Destroy()
		mouse.TargetFilter = nil		
	else
		inEditMode = true
		editButton.Text = "Click To Stop Editing"
		
		--clone new model into workspace and add it to the mouse's target filter
		model = furniture.ExplodingBarrel:Clone()

		model.Parent = placement.GridObjects
		mouse.TargetFilter = placement.GridObjects
		
		renderedStepEvent = game:GetService("RunService").RenderStepped:Connect(onRenderedStep) 
		userInputEvent = game:GetService("UserInputService").InputBegan:Connect(onKeyPressed)
		--TODO: Tween camera/furniture 
	end
end)

----------------------------------------------------------------------------------------
--									EVENT FUNCTIONS: 
----------------------------------------------------------------------------------------

function onRenderedStep() 
	local target = mouse.Target
	
	if(target and target.Parent.Name == "FloorsBounds")then
		placement.GridPart = target
		placement.Surface = mouse.TargetSurface 
	end
	
	local cf = placement:GetPlacementCFrame(model, mouse.Hit.p, rotation)
	model:SetPrimaryPartCFrame(cf)
	
	--check if placement is colliding to turn model's primary part a differnt color
	placement:isColliding(model, true)
end

function onKeyPressed(input, gameProcessed)
	if(gameProcessed)then
		return
	end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local keyPressed = input.KeyCode
		
		if(keyPressed == Enum.KeyCode.R)then
			rotateModel()
		elseif(keyPressed == Enum.KeyCode.C)then
			clearFurniture()
		elseif(keyPressed == Enum.KeyCode.F)then
			savePlacement()
		end
				
	--When the player clicks the mouse in edit mode, place the model. 
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		placeModel()
	end
end
