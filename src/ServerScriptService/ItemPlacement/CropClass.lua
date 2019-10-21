--[[
	Created By: Lucy / royaltoe ( so pls hmu if you have any questions / rants about my bad code)
	Description: This is a class instance for a crop - all the functions and variables that make up a crop.
]]

local modelsFolder = game.ReplicatedStorage.Models.Crops
local cropInfo = require(game.ReplicatedStorage.Constants.Crops)
local AllPlayerData = require(game.ServerScriptService.PlayerDataModule)
local PlacedItems = require(game.ServerScriptService.ItemPlacement.PlacedItems)

local Crop = {}
Crop.__index = Crop

---------------------------------------------------------------------
-- 							[Constructors] 
---------------------------------------------------------------------
function Crop.new(player, cropType, model, isFertilized)
	local playerData = AllPlayerData:Get(player)
	
	local self = setmetatable({}, Crop)
	self.Owner = player.Name
	self.Model = model
	
	self.Stage = 1
	self.TotalGrowTime = cropInfo[cropType].totalGrowTime
	
	self.DaysGrowing = 0--time this crop has been around in in-game days
		
	self.CanHarvest = false
	self.CropType = cropType
	
	self.DaysWithoutWater = 0
	self.IsRegrowable = cropInfo[cropType].isRegrowable
	self.IsFertilized = isFertilized
	
	return self
end

--TODO: Load soil from datastore and place onto plot
function Crop.FromDataStore()
end
---------------------------------------------------------------------
-- 							[Private Function] 
---------------------------------------------------------------------

--determines the quality of the crop
function getQuality(isFertilized)
	return (isFertilized and math.random(2,3)) or 1
end

---------------------------------------------------------------------
-- 							[Public Function] 
---------------------------------------------------------------------
function Crop:Grow()
	if(self.Stage < self.TotalGrowTime)then
		self.Stage = self.Stage + 1
		
		if(self.Stage == self.TotalGrowTime)then
			self.CanHarvest = true
		end
		
		self:ChangeModel("Stage"..self.Stage)
	end
end

function Crop:Die()
	local DeadCropModel =  game.ReplicatedStorage[self.CropType]["StageDead"]:Clone()
	DeadCropModel:SetPrimaryPartCFrame(self.Model)
	self.Model:Destroy()
	self.Model = DeadCropModel
	self.Stage = -1
end

function Crop:Take(playerData)
	local cropInfo = {Item = self.CropType, Type = "crop", Quality = getQuality(self.IsFertilized)}
	table.insert(playerData.Inventory, cropInfo)

	print(#playerData.Inventory)
	if(self.IsRegrowable)then
		self:ChangeModel("StagePicked")
		self.CanHarvest = false
		self.TotalGrowTime = self.TotalGrowTime + cropInfo[self.CropType].growthTimeAfterHarvest
		--TODO: Next stages are 4,5,6 etc, set up model like that
	else
		self:Destroy()
	end 
end

function Crop:Destroy()
	self.Model:Destroy()
	self = nil
end

function Crop:ChangeModel(newName)
	local newModel = modelsFolder[self.CropType][newName]:Clone()
	newModel:SetPrimaryPartCFrame(self.Model.PrimaryPart.CFrame)
	self.Model:Destroy()
	self.Model = newModel
	self.Model.Parent = game.Workspace:FindFirstChild(self.Owner.."'s ".."Crops")
end

return Crop
