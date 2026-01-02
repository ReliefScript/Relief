-- Relief Lib

local Relief = getgenv().Relief
if not Relief then return end

-- Services

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables & Functions

local LocalPlayer = Players.LocalPlayer
local FB = workspace.finalBattle

local function HasWeapon()
	local Char = LocalPlayer.Character
	if not Char then return end

	if Char:FindFirstChildOfClass("Model") then
		return 1
	end
end

local function IsShooting()
	return LocalPlayer.atirando.Value
end

local function GetRoot(Target)
	Target = Target or LocalPlayer
	return Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
end

local function GetHum(Target)
	Target = Target or LocalPlayer
	return Target.Character and Target.Character:FindFirstChildOfClass("Humanoid")
end

local function InGame()
	local Hum = GetHum()
	if not Hum then return end

	for _, Track in Hum:GetPlayingAnimationTracks() do
		local Anim = Track.Animation
		if Anim and Anim.AnimationId == "rbxassetid://72263572481954" then
			return 1
		end
	end
end

local HitList = {}

local function UpdateHitList()
    HitList = {}

    for _, Player in Players:GetPlayers() do
        if Player == LocalPlayer then continue end
		
		local Team = LocalPlayer:GetAttribute("GameTeam")
		if Team and Team ~= Player:GetAttribute("GameTeam") then continue end

        local Char = Player.Character
        if not Char then continue end

        local Root = Char:FindFirstChild("HumanoidRootPart")
        if not Root then continue end

        local RightArm = LocalPlayer.Character:FindFirstChild("Right Arm")
        if not RightArm then continue end

        local Origin = RightArm.Position
        local Dir = (Root.Position - Origin).Unit * 100

        local Cast = workspace:Raycast(Origin, Dir)
        if Cast and Cast.Instance then
            local HitChar = Cast.Instance:FindFirstAncestorOfClass("Model")
            if HitChar then
                local HitPlayer = Players:GetPlayerFromCharacter(HitChar)
                if HitPlayer then
                    table.insert(HitList, HitPlayer)
                end
            end
        end
    end
end

task.spawn(function()
	while task.wait(0.1) do
		UpdateHitList()
	end
end)

local function IsHit(Target)
	if table.find(HitList, Target) then
		return 1
	end
end

local function GetClosestPlayer()
	local Root = GetRoot()
	if not Root then return end

	local Dist = math.huge
	local Player = nil

	for _, Target in Players:GetPlayers() do
		if Target == LocalPlayer then continue end

		local TRoot = GetRoot(Target)
		if not TRoot then continue end

		local THum = GetHum(Target)
		if not THum or THum.Health <= 0 then continue end

		local Team = LocalPlayer:GetAttribute("GameTeam")
		if Team and Team == Target:GetAttribute("GameTeam") then continue end
		if IsHit(Target) then continue end

		local Distance = (Root.Position - TRoot.Position).Magnitude
		if Distance < Dist then
			Dist = Distance
			Player = Target
		end
	end

	return Player
end

local Thread = getgenv().Thread

-- Modules

Relief.addModule("Player", "GodMode", function(Toggled)
	if Toggled then
		Thread:New("GodMode", function()
			local Hum = GetHum()
			if not Hum then return task.wait() end

			if InGame() then
				Hum.HipHeight = -2
			else
				Hum.HipHeight = 0
			end
			
			task.wait()
		end)
	else
		Thread:Disconnect("GodMode")

		local Hum = GetHum()
		if not Hum then return end

		Hum.HipHeight = 0
	end
end)

local isArenaTP = false
local Trophy = workspace:FindFirstChild("Trophy")
Relief.addModule("World", "MoneyFarm", function(Toggled)
	if Toggled then
		local Old = nil
		Thread:New("MoneyFarm", function()
			task.wait()

			local Root = GetRoot()
			if not Root then return end

			local Hum = GetHum()
			if not Hum then return end

			if Relief.getSetting("MoneyFarm", "AntiWarp") and not InGame() and Hum.Health > 0 and not isArenaTP and not FB.Value then
				if not Old then Old = Root.CFrame end

				local Distance = (Root.Position - Old.Position).Magnitude
				if Distance >= 5 then
					Root.CFrame = Old
					Old = nil
				else
					Old = Root.CFrame
				end
			end

			if Relief.getSetting("MoneyFarm", "AutoReset") and HasWeapon() and Hum.Health > 0 then
				LocalPlayer.Character:BreakJoints()
				return
			end

			Trophy.Transparency = 1
			Trophy.CFrame = Root.CFrame
			task.wait()
			Trophy.CFrame = CFrame.new(0, 9e9, 0)
		end)
	else
		Thread:Disconnect("MoneyFarm")
		Trophy.Transparency = 0
	end
end, {
	{
		["Type"] = "Toggle",
		["Title"] = "AutoReset",
		["Callback"] = function()end
	},
	{
		["Type"] = "Toggle",
		["Title"] = "AntiWarp",
		["Callback"] = function()end
	}
})

local Part = workspace.chao
Relief.addModule("Combat", "AutoKill", function(Toggled)
	if Toggled then
		Thread:New("AutoKill", function()
			task.wait()

			if not HasWeapon() then return end
			if IsShooting() then return end

			local Char = LocalPlayer.Character
			if not Char then return end

			local Hum = GetHum()
			if not Hum then return end

			local Root = GetRoot()
			if not Root then return end

			Root.Anchored = false

			local RightArm = Char:FindFirstChild("Right Arm")
			if not RightArm then return end

			local Target = GetClosestPlayer()
			if not Target then return end

			local TRoot = GetRoot(Target)
			if not TRoot then return end

			local Direction = (TRoot.Position - RightArm.Position).Unit

			Direction = Vector3.new(Direction.X, 0, Direction.Z)
			if Direction.Magnitude == 0 then return end
			Direction = Direction.Unit

			if Relief.getSetting("AutoKill", "DoesTP") then
				local Mode = Relief.getSetting("AutoKill", "TP Mode")
				local Pos = Part.Position
				local Location =
				    (Mode == "Middle" and
						Vector3.new(
							Pos.X,
							(Pos.Y + (Part.Size.Y / 2)) + (Root.Size.Y / 2),
							Pos.Z
					    )
					)
				or (Mode == "Edge" and
						Vector3.new(
							Pos.X - (Part.Size.X / 2) + 1,
							(Pos.Y + (Part.Size.Y / 2)) + (Root.Size.Y / 2),
							Pos.Z
						)
					)

				Root.CFrame = CFrame.new(Location, Location + Direction)

				for _, BP in Char:GetChildren() do
					if BP:IsA("BasePart") then
						BP.Velocity = Vector3.zero
						BP.RotVelocity = Vector3.zero
					end
				end

				for _, Track in Hum:GetPlayingAnimationTracks() do
					local Anim = Track.Animation
					if Anim and Anim.AnimationId ~= "rbxassetid://72263572481954" then
						Track:Stop()
					end
				end
			else
				Root.CFrame = CFrame.new(Root.Position, Root.Position + Direction)
			end
		end)
	else
		Thread:Disconnect("AutoKill")
	end
end, {
	{
		["Type"] = "Dropdown",
		["Options"] = {"Edge", "Middle"},
		["Default"] = "Middle",
		["Title"] = "TP Mode",
		["Callback"] = function()end
	},
	{
		["Type"] = "Toggle",
		["Title"] = "DoesTP",
		["Callback"] = function()end
	}
})

Relief.addModule("Render", "ESP", function(Toggled)
	if Toggled then
		local function HandleCharacter(Char)
			if not Char then return end

			for _, BP in Char:GetChildren() do
				if BP:IsA("BasePart") and BP.Name ~= "HumanoidRootPart" and BP.Name ~= "hitbox" then
					BP.Transparency = 0
					BP:GetPropertyChangedSignal("Transparency"):Connect(function()
						if BP.Transparency ~= 0 then
							BP.Transparency = 0
						end
					end)
				end
			end

			task.spawn(function()
				while Char do
					RunService.PreRender:Wait()

					local Weapon = Char:FindFirstChildOfClass("Model")
					if not Weapon then continue end

					local Ponto = Weapon:FindFirstChild("ponto")
					if not Ponto then continue end

					local Beam = Ponto:FindFirstChild("Beam")
					if not Beam then continue end

					Beam.Enabled = true
				end
			end)
		end

		local function HandlePlayer(Player)
			HandleCharacter(Player.Character)
			Thread:Maid("ESP_CA", Player.CharacterAppearanceLoaded:Connect(HandleCharacter))
		end

		for _, Target in Players:GetPlayers() do
			if Target == LocalPlayer then continue end
			HandlePlayer(Target)
		end

		Thread:Maid("ESP_PA", Players.PlayerAdded:Connect(HandlePlayer))
	else
		Thread:Unmaid("ESP_CA")
		Thread:Unmaid("ESP_PA")
	end
end)

Relief.addModule("Combat", "FistAura", function(Toggled)
	if Toggled then
		Thread:New("FistAura", function()
			task.wait()
			
			local Fists = LocalPlayer.Backpack:FindFirstChild("Fists") or LocalPlayer.Character:FindFirstChild("Fists")
			if not Fists then return end

			Fists.Parent = LocalPlayer.Character
			
			local Target = nil
			for _, T in Players:GetPlayers() do
				if T == LocalPlayer then continue end
				
				if T.Backpack and T.Backpack:FindFirstChild("Fists") then
					Target = T
					break
				end

				if T.Character and T.Character:FindFirstChild("Fists") then
					Target = T
					break
				end
			end

			if not Target then return end

			local Root = GetRoot()
			if not Root then return end

			local TRoot = GetRoot(Target)
			local Remote = Fists:FindFirstChild("fistremote") or Fists:WaitForChild("fistremote")
			
			local P = TRoot and TRoot.CFrame or CFrame.new(1, 0, -8)
			Root.CFrame = CFrame.new(P.X, -2, P.Z)

			for _, BP in LocalPlayer.Character:GetChildren() do
				if BP:IsA("BasePart") then
					BP.Velocity = Vector3.zero
					BP.RotVelocity = Vector3.zero
				end
			end

			Remote:FireServer("lmb")
		end)
	else
		Thread:Disconnect("FistAura")
	end
end)

local NameConvert = {
	["Classic"] = "Solo",
	["RNG"] = "GunnerRNG",
	["RedVsBlue"] = "RedVsBlue"
}

local StartVote = ReplicatedStorage.StartVote
local SubmitVote = ReplicatedStorage.SubmitVote

Relief.addModule("Utility", "AutoVote", function(Toggled)
	if Toggled then
		Thread:Maid("AutoVote", StartVote.OnClientEvent:Connect(function()
			local Setting = Relief.getSetting("AutoVote", "Mode")
			local Name = NameConvert[Setting]
			SubmitVote:FireServer(Name)
		end))
	else
		Thread:Unmaid("AutoVote")
	end
end, {
	{
		["Type"] = "Dropdown",
		["Title"] = "Mode",
		["Options"] = {"Classic", "RNG", "RedVsBlue"},
		["Default"] = "Classic",
		["Callback"] = function()end
	}
})

Relief.AddCommand({"arena"}, function()
	local Root = GetRoot()
	if not Root then return end

	local Pos = Part.Position
	isArenaTP = true
	Root.CFrame = CFrame.new(Pos.X, (Pos.Y + (Part.Size.Y / 2)) + (LocalPlayer.Character:GetExtentsSize().Y / 2), Pos.Z)
	RunService.PreRender:Wait()
	isArenaTP = false
end)
