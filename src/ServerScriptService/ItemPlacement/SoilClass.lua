--[[
	Created By: Lucy / royaltoe ( so pls hmu if you have any questions / rants about my bad code)
	Description: This script creates instances of those soil you make when you shovel dirt.
]]
local Crop = require(game.ServerScriptService.ItemPlacement.CropClass)
local PlacedItems = require(game.ServerScriptService.ItemPlacement.PlacedItems)
Data  = require(game.ServerScriptService.PlayerDataModule)
cropModels = game.ReplicatedStorage.Models.Crops

Soil = {}
Soil.__index = Soil

---------------------------------------------------------------------
-- 							[Constructors] 
---------------------------------------------------------------------
function Soil.new(player, model)
	local playerData = Data:Get(player)
	local self = setmetatable({}, Soil)

	--create a folder to store the soil if it doesn't already exist
	if(not game.Workspace:FindFirstChild(player.Name.."'s ".."Crops"))then
		local folder = Instance.new("Folder", workspace)
		folder.Name = player.Name.."'s ".."Crops"
	end
	
	self.Owner = player.Name
	self.Folder = game.Workspace:FindFirstChild(player.Name.."'s ".."Crops")

	self.Model = model
	model.Parent = self.Folder
	
	self.Crop = nil
	self.daysWithoutCrop = 0
	self.IsFertilized = false
	self.IsWatered = false

	--create click event for tile
	self.Model.PrimaryPart.ClickDetector.MouseClick:Connect(function(whoClicked)
		if(whoClicked == player)then
			self:Clicked(playerData)
		end
	end)
	
	PlacedItems:Add("Soil", self)
	return self
end

--TODO: Load soil from datastore and place onto plot
function Soil.FromDataStore()
end


---------------------------------------------------------------------
-- 							[Functions] 
---------------------------------------------------------------------
function Soil:Fertilize()
	if(not self.IsFertilized)then
		self.IsFertilized = true
	end
end

function Soil:Water()
	self.IsWatered = true
	self.Model.Soil.BrickColor = BrickColor.new("Brown")
end

function Soil:PlantSeed(cropName)
	local cropModel = cropModels[cropName]["Stage1"]:Clone()
	cropModel:SetPrimaryPartCFrame(self.Model.PrimaryPart.CFrame)
	cropModel.Parent = game.Workspace:FindFirstChild(self.Owner.."'s ".."Crops")
	
	local player = game.Players:FindFirstChild(self.Owner)
	local crop = Crop.new(player, cropName, cropModel, self.IsFertilized)
	
	return crop
end

--make the dirt unwatered, destroy the tile if it's been too many days without water
function Soil:DryOut()
	self.Model.Dirt.BrickColor = BrickColor.new("Dirt brown")
	self.IsWatered = false
	
	if(not self.Crop)then
		self.daysWithoutCrop = self.daysWithoutCrop + 1
		
		if(self.daysWithoutCrop >= 1)then
			PlacedItems:Remove("Soil", self)
		end
	end
end

function Soil:Destroy()	
	self.Model:Destroy()

	if(self.Crop)then
		self.Crop:Destroy()
		self.Crop = nil
	end
	
	self = nil
end

--function that gets fired when the soil is clicked
function Soil:Clicked(playerData)
	--the player is currently holding seed, atempt to plant the seed
	if(not self.Crop and playerData.Equipped.ItemType == "Seed")then
		local crop = self:PlantSeed(playerData.Equipped.ItemName)
		self.Crop = crop
		
	--take the crop if it's done growing
	elseif(self.Crop)then
		if(self.Crop.CanHarvest)then
			self.Crop:Take(playerData)
			self.Crop = nil
		end
	end		
end

return Soil
