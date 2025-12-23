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

local AimbotWallcheck = true

local function GetInterface()
	local Interfaces = LocalPlayer.PlayerGui
		:WaitForChild("MainGui")
		:WaitForChild("MainFrame")
		:WaitForChild("DuelInterfaces")
	
	for _, Interface in Interfaces:GetChildren() do
		local Top = Interface:FindFirstChild("Top")
		if not Top then continue end

		local Scores = Top:FindFirstChild("Scores")
		if not Scores then continue end

		local Teams = Scores:FindFirstChild("Teams")
		if not Teams then continue end
		
		local Left = Teams:FindFirstChild("Left")
		if not Left then continue end
		
		local Scores = Left:FindFirstChild("DuelScoresTeamSlot")
		if not Scores then continue end

		local Container = Scores:FindFirstChild("Container")
		if not Container then continue end

		local Teammates = Container:FindFirstChild("Teammates")
		if not Teammates then continue end
		
		local Targets = {}

		for _, Slot in Teammates:GetChildren() do
			if Slot:IsA("Frame") and Slot.Name == "TeammateSlot" then
				local Headshot = Slot.Container.Headshot.Image
				local Isolated = Headshot:match("userId=(%d+)")
				local Id = tonumber(Isolated)
				local Target = Players:GetPlayerByUserId(Id)
				if Target then
					table.insert(Targets, Target)
				end
			end
		end

		if table.find(Targets, LocalPlayer) then
			return Interface
		end
	end
end

local function GetEnemies()
	local Enemies = {}

	local Interface = GetInterface()
	if not Interface then return Enemies end

	local Container = Interface.Top.Scores.Teams.Right.DuelScoresTeamSlot.Container.Teammates

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

local function GetClosestPlayer()
	local Char = LocalPlayer.Character
	if not Char then return end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum or Hum.Health <= 0 then return end

	local TargetDistance, Target = Relief.getSetting("Aimbot", "FOV"), nil
	local Center = Vector2.new(Camera.ViewportSize.X / 2 , Camera.ViewportSize.Y / 2)

	local Enemies = GetEnemies()
	if not Enemies then return end

	local AimbotTargetPart = Relief.getSetting("Aimbot", "Target Part")

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
		
		if Relief.getSetting("Aimbot", "Wall Check") then
			local IsWall = workspace:Raycast(Camera.CFrame.Position, TargetPart.Position - Camera.CFrame.Position)
			if IsWall and not IsWall.Instance:IsDescendantOf(TChar) then continue end
		end
	
		Target = TargetPart
		TargetDistance = Distance
    end
    
    return Target
end

local FovCircle = nil
local WillDraw = true
local function DrawFov()
	if not WillDraw then return end
	FovCircle = Drawing.new("Circle")
	FovCircle.Thickness = 1
	FovCircle.Color = Color3.fromRGB(255,0,0)
	FovCircle.Filled = false
	FovCircle.Visible = true
	FovCircle.Radius = Relief.getSetting("Aimbot", "FOV")
	FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2 , Camera.ViewportSize.Y / 2)
end

Relief.addModule("Combat", "Aimbot", function(Toggled)
    if Toggled then
		DrawFov()
        Thread:New("Aimbot", function()
            RunService.RenderStepped:Wait()
            
            if Camera.CameraType ~= Enum.CameraType.Scriptable then return end
      
            local Target = GetClosestPlayer()
            if not Target then return end

			local screenPos, onScreen = Camera:WorldToViewportPoint(Target.Position)
            if not onScreen then return end
      
            local viewport = Camera.ViewportSize
            local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
            local target2D = Vector2.new(screenPos.X, screenPos.Y)
			
			local delta = target2D - screenCenter
            delta *= Relief.getSetting("Aimbot", "Strength")

            VirtualInputManager:SendMouseMoveDeltaEvent(
                delta.X,
                delta.Y,
                game
            )
        end)
  	else
		Thread:Disconnect("Aimbot")
		if FovCircle then FovCircle:Remove() end
  	end
end, {
	{
		["Type"] = "Dropdown",
		["Options"] = {"Head", "Closest"},
		["Default"] = "Head",
		["Title"] = "Target Part",
		["Callback"] = function(Option)end
	},
	{
		["Type"] = "Slider",
		["Default"] = 200,
		["Min"] = 0,
		["Max"] = 1000,
		["Title"] = "FOV",
		["Callback"] = function(Num)
			if FovCircle then FovCircle:Remove() end
			DrawFov()
		end
	},
	{
		["Type"] = "Slider",
		["Default"] = 0.25,
		["Min"] = 0,
		["Max"] = 1,
		["Title"] = "Strength",
		["Callback"] = function(Num)end
	},
	{
		["Type"] = "Toggle",
		["Title"] = "Wall Check",
		["Default"] = true,
		["Callback"] = function(Toggled)end
	},
	{
		["Type"] = "Toggle",
		["Title"] = "Draw FOV",
		["Default"] = true,
		["Callback"] = function(Toggled)
			if not Toggled and FovCircle then
				FovCircle:Remove()
			end
		end
	}
})

local ViewModels
task.spawn(function()
	repeat task.wait() until workspace:FindFirstChild("ViewModels")
	ViewModels = workspace.ViewModels
end)

local function GetPlayerWeapons()
	local Weapons = {}
	if not ViewModels then return Weapons end
	
	for _, Model in ViewModels:GetChildren() do
		if Model.Name == "FirstPerson" then continue end
		local Data = Model.Name:split(" - ")
		local Target = Players:FindFirstChild(Data[1])
		table.insert(Weapons, {
			Target = Target,
			Name = Data[2]
		})
	end
	
	return Weapons
end

local function MouseClick()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local KatanaCheck = false
local TriggerDelay = 0.05

Relief.addModule("Combat", "TriggerBot", function(Toggled)
    if Toggled then
        Thread:New("TriggerBot", function()
            task.wait()

			if Camera.CameraType ~= Enum.CameraType.Scriptable then return end

			local C = LocalPlayer.Character if not C then return end
			local H = C:FindFirstChildOfClass("Humanoid") if not H or H.Health <= 0 then return end
            
            local Target = Mouse.Target
			if not Target then return end

			if KatanaCheck then
				local Weapons = GetPlayerWeapons()
				if not Weapons then return end

				local HasKatana = false
				for _, Weapon in Weapons do
					if Weapon.Target == Target and Weapon.Name == "Katana" then 
						HasKatana = true
						break
					end
				end

				if HasKatana then return end
			end

			local Char = Target.Parent
			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if not Hum or Hum.Health <= 0 then return end
			
			local TRoot = Char:FindFirstChild("HumanoidRootPart")
			if not TRoot then return end
			if TRoot.Velocity.Magnitude >= 75 then return end

			local Player = Players:GetPlayerFromCharacter(Char)
			if not Player then return end

			local Enemies = GetEnemies()
			if not Enemies or not table.find(Enemies, Player) then return end
			
			task.spawn(function()
				task.wait(TriggerDelay)
				MouseClick()
			end)
        end)
  	else
		Thread:Disconnect("TriggerBot")
  	end
end, {
	{
		["Type"] = "Toggle",
		["Title"] = "KatanaCheck",
		["Default"] = true,
		["Callback"] = function(Toggled)
			KatanaCheck = Toggled
		end
	},
	{
		["Type"] = "Slider",
		["Title"] = "Delay",
		["Default"] = 0.05,
		["Min"] = 0,
		["Max"] = 0.3,
		["Callback"] = function(Num)
			TriggerDelay = Num
		end
	}
})

local Old = {}

Relief.addModule("Render", "ESP", function(Toggled)
	if Toggled then
		Thread:New("ESP", function()
			task.wait()

			for _, Box in Old do
				Box:Remove()
			end

			Old = {}

			local Enemies = GetEnemies()
			if not Enemies then return end

			for _, Enemy in Enemies do
				local Char = Enemy.Character
				if not Char then continue end

				local Hum = Char:FindFirstChildOfClass("Humanoid")
				if not Hum or Hum.Health <= 0 then continue end

				local Root = Char:FindFirstChild("HumanoidRootPart")
				if not Root then continue end

				local CF, Size = Char:GetBoundingBox()

					local Top = CF.Position + Vector3.new(0, Size.Y / 2, 0)
					local Bottom = CF.Position - Vector3.new(0, Size.Y / 2, 0)

					local Top2D, OnTop = Camera:WorldToViewportPoint(Top)
					local Bot2D, OnBot = Camera:WorldToViewportPoint(Bottom)
					if not (OnTop and OnBot) then continue end

					local Height = math.abs(Top2D.Y - Bot2D.Y)
					local Width = Height * 0.6

					local Box = Drawing.new("Square")
					Box.Thickness = 1
					Box.Color = Color3.new(1, 0, 0)
					Box.Size = Vector2.new(Width, Height)
					Box.Position = Vector2.new(
						Top2D.X - (Width / 2),
						Top2D.Y
					)

				table.insert(Old, Box)
			end
		end)
	else
		Thread:Disconnect("ESP")

		for _, Box in Old do
			Box:Remove()
		end

		Old = {}
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
			local Char = LocalPlayer.Character
			if not Char then return task.wait() end

			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if not Hum then return task.wait() end

			local State = Hum:GetState()
			if State ~= Enum.HumanoidStateType.Landed and State ~= Enum.HumanoidStateType.Running then return task.wait() end
			if Hum.FloorMaterial == Enum.Material.Air then return task.wait() end

			if Debounce then return task.wait() end
			Debounce = true
			task.spawn(function()
				task.wait(0.1)
				Debounce = false
			end)
			
			SimulateKey(Enum.KeyCode.C)
			task.wait()
			SimulateKey(Enum.KeyCode.Space)
		end)
		Thread:Maid("BhopCA", LocalPlayer.CharacterAdded:Connect(HandleCharacter))
	else
		Thread:Disconnect("Bhop")
		Thread:Unmaid("BhopCA")
	end
end)
