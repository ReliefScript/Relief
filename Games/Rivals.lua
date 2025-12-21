-- Relief Lib

local Relief = getgenv().Relief
if not Relief then return end

-- Services

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Variables & Functions

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Thread = getgenv().Thread

-- Modules

local AimbotFov = 200
local AimbotStrength = 0.25
local AimbotWallcheck = true
local AimbotTargetPart = "Closest"

local function GetEnemies()
	local Enemies = {}

	local Container
	pcall(function()
		Container = LocalPlayer.PlayerGui.MainGui.MainFrame.DuelInterfaces.DuelInterface.Top.Scores.Teams.Right.DuelScoresTeamSlot.Container.Teammates
	end)
	if not Container then return Enemies end

	for _, Slot in Container:GetChildren() do
		if Slot:IsA("Frame") then
			local Headshot = Slot.Container.Headshot.Image
			local Isolated = Headshot:match("userId=(%d+)")
			local Id = tonumber(Isolated)
			local Target = Players:GetPlayerByUserId(Id)
			if Target then
				table.insert(Enemies, Target)
			end
		end
	end

	return Enemies
end

local Screen = Instance.new("ScreenGui")
Screen.Parent = game:GetService("CoreGui")

local State = Instance.new("TextLabel")
State.Parent = Screen
State.Size = UDim2.new(0.5, 0, 0.1, 0)
State.BackgroundTransparency = 1
State.TextScaled = true
State.AnchorPoint = Vector2.new(0.5, 0.5)
State.Position = UDim2.new(0.5, 0, 0.5, 0)
State.TextColor3 = Color3.new(1, 1, 1)
State.TextStrokeTransparency = 0

local function GetClosestPlayer()
	local Char = LocalPlayer.Character
	if not Char then State.Text = "NO CHAR" return end

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = { workspace.Arena }
	Params.FilterType = Enum.RaycastFilterType.Whitelist

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum or Hum.Health <= 0 then State.Text = "NO HUM / DEAD" return end

	local TargetDistance, Target = AimbotFov, nil
	local Center = Vector2.new(Camera.ViewportSize.X / 2 , Camera.ViewportSize.Y / 2)

	local Enemies = GetEnemies()
	if not Enemies then State.Text = "ENEMIES NOT FOUND"return end

	for _, Player in Enemies do
		if Player == LocalPlayer then continue end
		
		local TChar = Player.Character
		if not TChar then continue end
		
		local THum = TChar:FindFirstChildOfClass("Humanoid")
		if not THum or THum.Health <= 0 then continue end
		
		local TargetPart
		if AimbotTargetPart == "Closest" then
			local Closest = math.huge
			for _, BP in TChar:GetChildren() do
				if BP:IsA("BasePart") then
					local ScreenPos, OnScreen = Camera:WorldToViewportPoint(BP.Position)
					if OnScreen then
						local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
						if Distance < Closest then
							Closest = Distance
							TargetPart = BP
						end
					end
				end
			end
		else
			TargetPart = TChar:FindFirstChild(AimbotTargetPart)
		end
		if not TargetPart then continue end
		
		local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
		if not OnScreen then continue end
		
		local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
		if Distance > TargetDistance then continue end
		
		if AimbotWallcheck then
			local IsWall = workspace:Raycast(Camera.CFrame.Position, TargetPart.Position - Camera.CFrame.Position, Params)
			if IsWall and not IsWall.Instance:IsDescendantOf(Char) then State.Text = "WALL IN WAY" continue end
		end
	
		Target = TargetPart
		TargetDistance = Distance
		State.Text = "AIMING"
    end
    
    return Target
end

local FovCircle = nil
Relief.addModule("Combat", "Aimbot", function(Toggled)
    if Toggled then
		FovCircle = Drawing.new("Circle")
		FovCircle.Thickness = 1
		FovCircle.Color = Color3.fromRGB(255,0,0)
		FovCircle.Filled = false
		FovCircle.Visible = true
		FovCircle.Radius = AimbotFov
		FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2 , Camera.ViewportSize.Y / 2)
		
        Thread:New("Aimbot", function()
            task.wait()
            
            if Camera.CameraType ~= Enum.CameraType.Scriptable then return end
      
            local Target = GetClosestPlayer()
            if not Target then return end
      
            local TargetPos = Camera:WorldToViewportPoint(Target.Position)
            local mousePos = UserInputService:GetMouseLocation()
			local target2D = Vector2.new(TargetPos.X, TargetPos.Y)
			
			local delta = target2D - mousePos
			mousemoverel(delta.X * AimbotStrength, delta.Y * AimbotStrength)
        end)
  	else
		Thread:Disconnect("Aimbot")
		if FovCircle then FovCircle:Remove() end
  	end
end)

local Pressing = false
Relief.addModule("Combat", "TriggerBot", function(Toggled)
    if Toggled then
        Thread:New("TriggerBot", function()
            task.wait()

			local function RELEASE()
				if Pressing then
					mouse1release()
				end
				Pressing = false
			end

			if Camera.CameraType ~= Enum.CameraType.Scriptable then return RELEASE() end

			local C = LocalPlayer.Character if not C then return RELEASE() end
			local H = C:FindFirstChildOfClass("Humanoid") if not H or H.Health <= 0 then return RELEASE() end
            
            local Target = Mouse.Target
			if not Target then return RELEASE() end

			local Char = Target.Parent
			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if not Hum or Hum.Health <= 0 then return RELEASE() end

			local Player = Players:GetPlayerFromCharacter(Char)
			if not Player then return RELEASE() end

			local Enemies = GetEnemies()
			if not Enemies or not table.find(Enemies, Player) then return RELEASE() end
			
			if not Pressing then
				mouse1press()
			end
			Pressing = true
        end)
  	else
		Thread:Disconnect("TriggerBot")
  	end
end)

local ESPConnections = {}
local HighlightInstances = {}

Relief.addModule("Render", "ESP", function(Toggled)
	if Toggled then
		local function HandleCharacter(Char)
			if not Char then return end
			
			local Highlight = Instance.new("Highlight")
			Highlight.OutlineTransparency = 0.75
			Highlight.OutlineColor = Color3.new(0, 0, 0)
			Highlight.FillTransparency = 0.75
			Highlight.Parent = Char

			table.insert(HighlightInstances, Highlight)
		end

		local function HandlePlayer(Player)
			local Enemies = nil
			repeat Enemies = GetEnemies() task.wait() until Enemies ~= nil

			if not table.find(Enemies, Player) then return end
			HandleCharacter(Player.Character)
			table.insert(ESPConnections, Player.CharacterAdded:Connect(HandleCharacter))
		end

		for _, Player in Players:GetPlayers() do
			HandlePlayer(Player)
		end

		table.insert(ESPConnections, Players.PlayerAdded:Connect(HandlePlayer))
	else
		for _, C in ESPConnections do
			C:Disconnect()
		end

		for _, H in HighlightInstances do
			if H then
				H:Destroy()
			end
		end

		HighlightInstances = {}
		ESPConnections = {}
	end
end)

local function SimulateKey(Key)
	VirtualInputManager:SendKeyEvent(true, Key, false, game)
    VirtualInputManager:SendKeyEvent(false, Key, false, game)
end

local Debounce = false
Relief.addModule("Movement", "Bhop", function(Toggled)
	if Toggled then
		Thread:New("Bhop", function()
			task.wait()

			if Debounce then return end
			Debounce = true

			task.spawn(function()
				task.wait(0.1)
				Debounce = false
			end)
					
			local Char = LocalPlayer.Character
			if not Char then return end
	
			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if not Hum then return end

			local State = Hum:GetState()
			if State ~= Enum.HumanoidStateType.Running or State ~= Enum.HumanoidStateType.Landing then return end

			SimulateKey(Enum.KeyCode.C)
			RunService.Stepped:Wait()
			SimulateKey(Enum.KeyCode.Space)
		end)
	else
		Thread:Disconnect("Bhop")
	end
end)
