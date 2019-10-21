playerData = require(game.ServerScriptService.PlayerDataModule)
placedItems = require(game.ServerScriptService.ItemPlacement.PlacedItems)

startTime = "06:00"
endTime = "08:00"

--convert time strings specified above to minutes
function ConvertToMinutes(givenTime)
	local hours = (tonumber(string.sub(givenTime,1,2)) == 0 and 24) or tonumber(string.sub(givenTime,1,2)) 	--get hour out of givenTime string. if time is 0, make hour 24
	local minutes = tonumber(string.sub(givenTime,4,5)) 	--get the minutes from the givenTime string
	return (hours * 60) + minutes
end
startTimeInMinutes = ConvertToMinutes(startTime)
endTimeInMinutes = ConvertToMinutes(endTime)


--at the end of the day make the players who are already awake faint
function MakePlayersFaint()
	--loop through players in playerdata module
		--if the player is awake, play faint animation for player
		--put the player in bed
end

--play cutscene when a new day starts
function StartCutScene()
	--If the player has a cutscene queued in the cutscenes variable, 
		--Play that cutscene
	--Otherwise, load the default cutscene
end


--Updates crops on a new day. 
function UpdateCrops()
	--loop through the players and update their crops
	for _, player in pairs(game.Players:GetPlayers())do
		local soilTable = placedItems:GetTable(player.Name,"Soil")
		
		if(soilTable)then
			--make dirt unwatered and remove it if it hasn't been watered for a while
			for _, soil in pairs(soilTable) do
				soil:DryOut()
			end
			
			 -- if soil has a crop, water crop. if the crop hasn't been watered enough, kill crop
			for _, soil in pairs(soilTable) do
				if(soil.Crop)then
					soil.Crop:Grow()
				end
			end

		end
	end
end

--This code updates the day and does anything that needs to be run throughout the day.
while true do
	print("start day")
	for currentTime = startTimeInMinutes, endTimeInMinutes do
		wait(.1)
		game.Lighting:SetMinutesAfterMidnight(currentTime)
	end
	UpdateCrops()
	--MakePlayersFaint()
	--StartCutScene()
end
