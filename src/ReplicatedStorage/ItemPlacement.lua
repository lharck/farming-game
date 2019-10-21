--[[
	Created By: Lucy / royaltoe ( so pls hmu if you have any questions / rants about my bad code)
	Description: This is the logic behind placing items in game. 
	Any script that places an item (onto a grid) in game should use this script. 
]]

local isServer = game:GetService("RunService"):IsServer()
local furniture = game:GetService("ReplicatedStorage").Models.Furniture
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

local Placement = {}
Placement.__index = Placement

---------------------------------------------------------------------
-- 							[Constructors] 
---------------------------------------------------------------------
function Placement.new(gridPart, itemType)
	local self = setmetatable({}, Placement)

	self.GridPart = gridPart
	self.GridObjects = nil
	self.ItemType = itemType
	
	if (isServer) then
		self.GridObjects = Instance.new("Folder")
		self.GridObjects.Name = "GridObjects"
		self.GridObjects.Parent = game.Workspace --TODO: Parent this to the house model instead of the workspace
	else
		self.GridObjects = remotes.InitPlacement:InvokeServer(gridPart)
	end
	
	self.Surface = Enum.NormalId.Top
	self.GridUnit = 1 -- you can specify the grid unit when you're creating the grid placement
	self.Rotation = 0  --current rotation

	return self
end

-- Starts new grid placement while also loading in items from datastore.
--TODO: Should probably have a better way of storing this. Right now it's just in its own datastore. 
function Placement.fromDataStore(gridPart, data, itemType)
	local self = Placement.new(gridPart, itemType)
	local gridCF = gridPart.CFrame
	data = data or {}
	
	for cf, name in pairs(data) do
		local model = furniture:FindFirstChild(name)
		if (model) then
			local components = {}
			for num in string.gmatch(cf, "[^%s,]+") do
				components[#components+1] = tonumber(num)
			end
			
			self:Place(model, gridCF * CFrame.new(unpack(components)), false)
		end
	end
	
	return self
end

---------------------------------------------------------------------
-- 							[Functions] 
---------------------------------------------------------------------

--Calculates the grid part's size / cframe so we can place the part on any surface we want.
--Also used to calculate the placement boundries. 
function Placement:GetGridInfo()
	local gridSize = self.GridPart.Size
	
	--Creating new rotation matrix so our current surface acts as our 'top' surface:
	local up = Vector3.new(0, 1, 0)
	local back = -Vector3.FromNormalId(self.Surface)

	--if we are using the top or bottom we treat right as up
	local dot = back:Dot(Vector3.new(0, 1, 0))
	local axis = (math.abs(dot) == 1) and Vector3.new(-dot, 0, 0) or up
	
	--rotate around the axis by 90 degrees to get right vector
	local right = CFrame.fromAxisAngle(axis, math.pi/2) * back
	--use the cross product to find the final vector
	local top = back:Cross(right).unit

	--convert to world space
	local cf = self.GridPart.CFrame * CFrame.fromMatrix(-back*gridSize/2, right, top, back)
	--use object space vectors to find the width and height
	local size = Vector2.new((gridSize * right).magnitude, (gridSize * top).magnitude)

	return cf, size
end

-- Returns where the model should be placed in the workspace. 
function Placement:GetPlacementCFrame(model, position, rotation)
	local cf, size = self:GetGridInfo()

	local modelSize = CFrame.fromEulerAnglesYXZ(0, rotation, 0) * model.PrimaryPart.Size
	modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))

	local localPosition = cf:pointToObjectSpace(position);
	
	--constrain part to the current gridPart variable
	local size2 = (size - Vector2.new(modelSize.x, modelSize.z))/2
	local x,y = localPosition.x, localPosition.y

	--theres a case where our surface is too small to keep object in bounds so we're avoiding that with an if statement
	if(-size2.x < size2.x and -size2.y < size2.y)then 
		x = math.clamp(localPosition.x, -size2.x, size2.x);
		y = math.clamp(localPosition.y, -size2.y, size2.y);
		
		--round position to specified grid
		local g = self.GridUnit
		if (g > 0) then
			x = math.floor(x / g + 0.5 ) * g
			y = math.floor(y / g + 0.5 ) * g
			--TODO: This rounding is glitching at the moment so we're using the more standard method of rounding for now. 
--			x = math.sign(x)*((math.abs(x) - math.abs(x) % g) + (size2.x % g))
--			y = math.sign(y)*((math.abs(y) - math.abs(y) % g) + (size2.y % g))
		end
	end
	--return the new placement
	return cf * CFrame.new(x, y, -modelSize.y/2) * CFrame.Angles(-math.pi/2, rotation, 0)
end

--Check if the model we're about to place is colliding with anything by using GetTouchingParts()
--Does not place if the model is touching anything
function Placement:isColliding(model, isTool)
	local isColliding = false

	local touch = model.PrimaryPart.Touched:Connect(function() end) --can collided true parts need a touch event if they want to use GetTouchingParts
	local touching = model.PrimaryPart:GetTouchingParts()
	
	--see if any of the parts are touching our model
	for i = 1, #touching do
		if (not touching[i]:IsDescendantOf(model)) then
			isColliding = true
			break
		end
	end
	
	if(not isColliding and not isTool)then
		model.PrimaryPart.BrickColor = BrickColor.new("Bright green")
	else
		model.PrimaryPart.BrickColor = BrickColor.new("Really red")
	end

	touch:Disconnect()
	
	return isColliding
end

--Place the object. 
function Placement:Place(model, cf, isColliding)
	if(not isColliding)then
		remotes.InvokePlacement:InvokeServer("Place", self.ItemType, model, cf, self.GridObjects)
	end
end

--Convert model data positions so we can save it in the datastore. 
function Placement:Serialize()
	local serializedData = {}
	
	local cFrameInverse = self.GridPart.CFrame:inverse()
	local children = self.GridObjects:GetChildren()
	
	for i = 1, #children do
		serializedData[tostring(cFrameInverse * children[i].PrimaryPart.CFrame)] = children[i].Name 
	end
	
	return serializedData
end

--Save current models in GridObjects folder into datastore
function Placement:Save()
	local success = remotes.DSPlacement:InvokeServer(true, true)
	
	if (success) then
		print("Saved")
	end
end

--Clear all the current models in GridObjects
function Placement:Clear()
	self.GridObjects:ClearAllChildren()
	
	if (not isServer) then
		remotes.InvokePlacement:InvokeServer("Clear")
		local success = remotes.DSPlacement:InvokeServer(true, false)
		if (success) then
			print("Cleared")
		end
	end
end


return Placement