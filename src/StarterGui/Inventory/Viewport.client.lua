viewportFrame = script.Parent.Frame.FullInventory.ViewportFrame
--
----clone player
player = game.Players.LocalPlayer
repeat wait() until player.Character:FindFirstChild("Shirt") or  player.Character:FindFirstChild("Pants")
character = player.Character

--clone character into viewport
character.Archivable = true
clone = character:Clone()
--destroy any scripts inside clone so it doesnt error
for i, v in pairs(clone:GetDescendants())do
	if(v:IsA("Script"))then
		v:Destroy()
	end
end
clone.Parent = viewportFrame

--create camera for viewport and position it to players face
local viewportCamera = Instance.new("Camera")
viewportFrame.CurrentCamera = viewportCamera
viewportCamera.Parent = viewportFrame


--TODO: only run when the inventory is opened
	--Disable moving while in inventory. If player tries to move, close inventory. 
	--Animations when player tries on something
	
----update viewport based on players movements
while(wait(.01))do
	viewportCamera.CFrame = character:GetPrimaryPartCFrame() * CFrame.Angles(math.rad(15),math.rad(150),0) * CFrame.new(0,0,5) 

	for _, child in pairs(character:GetChildren()) do
        if child:IsA("MeshPart") or child:IsA("Part") then
            local clonePart = clone:FindFirstChild(child.Name)
            clonePart.CFrame = child.CFrame
		else 
			if(child:IsA("Accessory"))then
				local clonePart = clone:FindFirstChild(child.Name).Handle
				clonePart.CFrame = child.Handle.CFrame
			end
        end
	end
end
