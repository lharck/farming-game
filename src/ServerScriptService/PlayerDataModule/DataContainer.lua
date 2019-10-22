--[[
	Description: This is what each save slot consists of
	All we know about the player goes in this table. 
]]

module = {}

dataContainer = {
	Equipped = {ItemName = "Potato", ItemType = "Seed"}, 
	Coins = 10,
	DateCreated = "",
	
	Inventory = {
	    {Name = "Potato", Type = "Crop", Quality = 1, Permanent = true},
	    --{Name = "axe", Type = "Tool", tier = 1}
	},
	
	Character = {
		Shirt     = "",	
		Pants     = "",	
		Face      = "",
		SkinColor = "",
		Hat       = "",
		Hair      = "",
	},
	
	House = {
		HouseType = "Basic", 
				
		Furniture = {
			InStorage = {
				--FORMAT: "LovelyChair", "Bed", "BunkBed", "BunkBed", "Table" etc..
			},
			InHouse = {
				--FORMAT: "LovelyChair", "Bed", "BunkBed", "BunkBed", "Table" etc..
			}		
		}, 
	},
}

---------------------------------------------------------------------------------------------

-- Save copied tables in `copies` instead of a shallow copy  of dataContainer
function DeepCopy(orig, copies)
    copies = copies or {}

    local copy = nil

    if type(orig) == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, DeepCopy(getmetatable(orig), copies))

            for orig_key, orig_value in next, orig, nil do
                copy[DeepCopy(orig_key, copies)] = DeepCopy(orig_value, copies)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--returns a copy of the dataContainer table we have above
function module.new()
	return DeepCopy(dataContainer)
end


return module