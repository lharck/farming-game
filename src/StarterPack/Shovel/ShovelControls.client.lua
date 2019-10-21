--[[
	Created By: Lucy / royaltoe ( so pls ask if you have any questions / rants about my bad code )
	Description: Lets the player 'shovel' dirt. Includes a preview of where the player is about to shovel dirt. 
	Uses the 'ItemPlacement' script to accomplish this. ^^ 
]]

local localPlayer = game:GetService("Players").LocalPlayer
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local assetFolder = game:GetService("ReplicatedStorage").Models.Soil

local placementClass = require(game.ReplicatedStorage.ItemPlacement)
local placement = placementClass.fromDataStore(game.Workspace.FarmBounds.Part, remotes.DSPlacement:InvokeServer(false, false), "Soil")

local mouse = game.Players.LocalPlayer:GetMouse()

local selectionBox = nil --model that tells player where theyre about to shovel into 
placement.GridUnit = 4.2

--Place model when the player clicks the ground
local function placeModel(actionName, userInputState, input)
	local cf = placement:GetPlacementCFrame(selectionBox, mouse.Hit.p, 0)
	selectionBox:SetPrimaryPartCFrame(cf)
	placement:Place(assetFolder.Soil, cf, placement:isColliding(selectionBox, true))
end

--Call place model when the player clicks their mouse
script.Parent.Activated:Connect(function()
	--TODO: server Check if placing on players plot by checking farm name (target.Parent.Parent.Name?)
	placeModel()
end)

function onRenderedStep()
	--When shovel is equipped, position 'soil' preview to mouse 
	if(script.Parent.Parent.Name == localPlayer.Name)then
		--update the target to where the mouse currently is
		local target = mouse.Target
		
		if(target and target.Parent.Name == "FarmBounds")then
			placement.GridPart = target
		end
		--get the cframe where our selectionBox model should be (at the position of the mouse)
		local cf = placement:GetPlacementCFrame(selectionBox, mouse.Hit.p, 0) --rotation is 0 degrees
		selectionBox:SetPrimaryPartCFrame(cf)
		
		--check if placement is colliding to turn model's primary part a different color
		placement:isColliding(selectionBox, true)
	end
end

------------------------------------------------------------
renderedStepEvent = nil
script.Parent.Equipped:Connect(function() 
	selectionBox = assetFolder["SelectionBox"]:Clone()
	selectionBox.Parent = placement.GridObjects

	mouse.TargetFilter = placement.GridObjects 
	renderedStepEvent = game:GetService("RunService").RenderStepped:Connect(onRenderedStep) 	
end)

script.Parent.Unequipped:Connect(function() 
	mouse.TargetFilter = nil 
	selectionBox:Destroy()
	renderedStepEvent:Disconnect()
end)
