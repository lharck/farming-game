timeLabel = script.Parent.Frame.Time.TextLabel
timeString=nil

--convert in game time to 12 hour time for displaying time in gui
while(wait(.1))do
	local timeOfDay = "PM"
	
	timeString = string.sub(game.Lighting.TimeOfDay,1,5)
	local hour = tonumber(string.sub(timeString, 1,2))
	local minutes = tonumber(string.sub(timeString, 4,5))
	
	
	--determine if we should use am/pm and subtract 12 if we're in the afternoon 
	if(hour < 12 and hour > 0)then --morning 
		timeOfDay = "AM"
	else --afternoon
		hour = hour - 12 --subtract 12 hours since we're in pm b/c millitary time
		timeOfDay = "PM"
	end
	
	--make hour 12 if we're at 12 am / 12 pm
	if(hour == 0 or hour == -12)then
		hour = 12			
	end
	
	--display minutes as "12:00" instead of "12:0"
	if(minutes == 0)then
		minutes = "00"
	end
	
	timeLabel.Text = hour .. ":" .. minutes .. " " .. timeOfDay
end