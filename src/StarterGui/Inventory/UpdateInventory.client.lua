inventory = script.Parent.Frame:WaitForChild("FullInventory")
template = inventory:WaitForChild("Template")
UIGridLayout = inventory.Slots.UIGridLayout
numCells = 32
cellsPerRow = UIGridLayout.FillDirectionMaxCells
--create inventory cells
for i = 1 , numCells do
	local clone = template:Clone()
	clone.Parent = inventory.Slots
	clone.Name = i
	
	--make first row dark
	if(i <= cellsPerRow)then
		clone.ImageColor3 = Color3.new(255/255, 43/255, 43/255)
	end
	
	--put item in first position
	if(i == 1)then
		clone["Default"].Name = "test"
		clone["test"].BackgroundColor3 = Color3.new(0,1,0)
		clone["test"].BackgroundTransparency = 0
	end
end
template:Destroy()