--// Services

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

--// Variables & Objects

local FPS = 25
local clock = tick()
local PlayerCam = game.Workspace:WaitForChild("Camera")
local Status = Instance.new("StringValue")
Status.Name = "Status"
Status.Parent = Players.LocalPlayer
Status.Value = "Normal"
local Cams
local CamIndex = 1

local GUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("CamGui")
local NextButton = GUI.right
local PrevButton = GUI.left
local NameText = GUI.NameText

local StaticSound = game.SoundService:WaitForChild("Static")
local ClickSound = game.SoundService:WaitForChild("Click")

--//Functions
function UpdateCams()
	Cams = CollectionService:GetTagged("isCamera")
end

function ChangeTransparencies(Cam, Val)
	-- Changes the base and all it's children to become invisible
	local Base = Cam:WaitForChild("Base")
	Base.Transparency = Val
	local BaseChildren = Base:GetChildren()
	for _, child in pairs(BaseChildren) do
		if child:IsA("BasePart") then
			child.Transparency = Val
		end
	end
end

-- Series of tasks that changes the Player's Camera to the Security Camera
function CamView()
	GUI.Enabled = true
	NameText.Text = Cams[CamIndex].Name
	local Base = Cams[CamIndex].Base
	PlayerCam.CameraType = "Scriptable" --> Changes camera type to become scriptable
	PlayerCam.CFrame = Base.CFrame --> Moves the Player's Camera to the security camera
	Lighting.ColorCorrection.Saturation = -1 --> Changes colors to become Black & White
	
	-- Changes the base and all it's children to become invisible
	ChangeTransparencies(Cams[CamIndex], 1)
	task.wait(0.01)
	if not StaticSound.IsPlaying then
		StaticSound:Play()
	end
end

function ChangeCams(Type)
	local prevIndex = CamIndex
	
	if Type == "Previous" then
		if CamIndex > 1 then
			CamIndex = CamIndex - 1
		else
			CamIndex = #Cams
		end
	end
	
	if Type == "Next" then
		if CamIndex < #Cams then
			CamIndex = CamIndex + 1
		else
			CamIndex = 1
		end
	end
	
	ClickSound:Play()
	
	ChangeTransparencies(Cams[prevIndex], 0) --> Makes the previous camera visible again
	
	-- The rest is same as CamView except it doesn't update the amt of cams
	local Base = Cams[CamIndex].Base
	NameText.Text = Cams[CamIndex].Name
	PlayerCam.CameraType = "Scriptable" --> Changes camera type to become scriptable
	PlayerCam.CFrame = Base.CFrame --> Moves the Player's Camera to the security camera
	Lighting.ColorCorrection.Saturation = -1 --> Changes colors to become Black & White

	-- Changes the base and all it's children to become invisible
	ChangeTransparencies(Cams[CamIndex], 1)
	task.wait(0.01)
end

-- Series of tasks that changes the Player's Camera to follow the character
function CharView()
	GUI.Enabled = false
	PlayerCam.CameraType = "Follow" --> Changes camera type to follow an object (Which is the Character)
	Lighting.ColorCorrection.Saturation = 0 --> Changes colors to become normal

	-- Changes the base and all it's children to become visible
	if Cams ~= nil then
		ChangeTransparencies(Cams[CamIndex], 0)
	end
	
	if StaticSound.IsPlaying then
		StaticSound:Stop()
	end
	
	task.wait(0.01)
end

UpdateCams()

NextButton.MouseButton1Down:Connect(function()
	ChangeCams("Next")
end)

PrevButton.MouseButton1Down:Connect(function()
	ChangeCams("Previous")
end)

while true do
	if Players.LocalPlayer:WaitForChild("Status").Value == "Camera" then
		-- Creates a separate thread to artifically lower the FPS
		task.spawn(function()
			while clock + 1/FPS > tick() do end
			wait()
			clock = tick()
			task.wait(0.01)
		end)
		
		CamView()
	else
		CharView()
	end
end