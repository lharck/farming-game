--each key (1-9) represents a slot in the players inventory
--equips whatever is in the inventory at the key the player pressed
player = game:GetService("Players").LocalPlayer
repeat wait() until player.Character
character = player.Character
humanoid = character.Humanoid

shovel = game.ReplicatedStorage.Models.Tools.StandardShovel:Clone()
shovel.Parent = character
wait(10)
humanoid:UnequipTools()
