-- Relief Lib

local Relief = getgenv().Relief
if not Relief then return end

-- Services

local Players = game:GetService("Players")
local RStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

-- Variables & Functions

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Camera = workspace.CurrentCamera

local BrickFolder = workspace.Bricks

local function GetFolder()
	for _, F in TextChatService:GetChildren() do
		if F:IsA("Folder") and F.Name == "TextChannels" and #F:GetChildren() >= 1 then
			return F
		end
	end
end

local Folder = GetFolder()

local function GetBricks()
	local Bricks = {}

	for _, Model in BrickFolder:GetChildren() do
		for _, Brick in Model:GetChildren() do
			table.insert(Bricks, Brick)
		end
	end

	return Bricks
end

local AdminTeam = Teams.Chosen
local function GetAdmin()
	for _, Player in Players:GetPlayers() do
		if Player.Team == AdminTeam then
			return Player
		end
	end
end

local function GetOthers()
	local Others = {}
	for _, Player in Players:GetPlayers() do
		if Player ~= LocalPlayer then
			table.insert(Others, Player)
		end
	end
	return Others
end

local function GetPlayer(Query)
	if not Query then return end

	Query = Query:lower()
	if Query == "all" then return Players:GetPlayers() end
	if Query == "others" then return GetOthers() end
	if Query == "me" then return {LocalPlayer} end

	local function Find(Input, Output)
		return (Input:lower()):find(Output)
	end

	for _, Player in Players:GetPlayers() do
		if Find(Player.Name, Query) or Find(Player.DisplayName, Query) then
			return {Player}
		end
	end
end

local Thread = getgenv().Thread

local function OnCharacter(Name, Callback)
	local function HandleCharacter(Character)
		if not Character then return end

		Callback(Character)
	end

	HandleCharacter(LocalPlayer.Character)
	Thread:Maid(Name .. "_Added", LocalPlayer.CharacterAdded:Connect(Callback))
end

local function UnOnCharacter(Name)
	Thread:Unmaid(Name .. "_Unadded")
end

local function Repeat(Callback, Until)
	repeat
		Callback()
	until Until()
end

local Flinging = false

-- Modules

local LastEquipped = nil
Relief.addModule("World", "DeleteAura", function(Toggled)
	if Toggled then
		Thread:New("DeleteAura", function()
			task.wait()
			local Char = LocalPlayer.Character
			if not Char then return end

			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if not Hum then return end

			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return end

			local Delete = Hum:FindFirstChild("Delete")
			if not Delete then return end

			local Event = Delete.Script.Event

			for _, Brick in GetBricks() do
				local Distance = (Root.Position - Brick.Position).Magnitude
				if Distance > 24 then continue end

				Event:FireServer(Brick, Brick.Position)
				task.wait(0.05)
			end
		end)

		Thread:New("Equipping", function()
			task.wait()
			local Backpack = LocalPlayer.Backpack
			if not Backpack then return end

			local Char = LocalPlayer.Character
			if not Char then return end

			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if not Hum then return end

			local Delete = Backpack:FindFirstChild("Delete")
			if not Delete then return end

			Delete.Parent = Char
			Delete.Parent = Hum
			task.wait()
			Delete.Parent = Backpack
			task.wait(0.5)
		end)
	else
		Thread:Disconnect("DeleteAura")
		Thread:Disconnect("Equipping")
	end
end)

Relief.addModule("Player", "AntiFreeze", function(Toggled)
	if Toggled then
		local Old = nil

		local Char = LocalPlayer.Character
		if Char then
			if Char:FindFirstChild("Hielo") then
				Char:BreakJoints()
				local Root = Char:FindFirstChild("HumanoidRootPart")
				if Root then
					Old = Root.CFrame
				end
			end
		end

		OnCharacter("AntiFreeze", function(Character)
			if Old then
				local Root = Character:WaitForChild("HumanoidRootPart")
				Root.CFrame = Old
			end
			
			Thread:Maid("AntiFreeze", Character.ChildAdded:Connect(function(Obj)
				if Obj.Name == "Hielo" then
					Character:BreakJoints()

					local Root = Character:FindFirstChild("HumanoidRootPart")
					if not Root then return end

					Old = Root.CFrame
				end
			end))
		end)
	else
		UnOnCharacter("AntiFreeze")
		Thread:Unmaid("AntiFreeze")
	end
end)

Relief.addModule("Player", "AntiToxic", function(Toggled)
	if Toggled then
		OnCharacter("AntiToxic", function(Character)
			local Hum = Character:WaitForChild("Humanoid")
			if Hum.Health ~= 0 then
				Hum.MaxHealth = 9e7
				Hum.Health = 9e7
			end
		end)
	else
		UnOnCharacter("AntiToxic")
		
		local Char = LocalPlayer.Character
		if not Char then return end

		local Hum = Char:FindFirstChildOfClass("Humanoid")
		if not Hum then return end

		Hum.MaxHealth = 100
	end
end)

Relief.addModule("Player", "AntiSit", function(Toggled)
	if Toggled then
		OnCharacter("AntiSit", function(Character)
			local Hum = Character:WaitForChild("Humanoid")
			Hum:SetStateEnabled(13, false)
		end)
	else
		UnOnCharacter("AntiSit")

		local Char = LocalPlayer.Character
		if not Char then return end

		local Hum = Char:FindFirstChildOfClass("Humanoid")
		if not Hum then return end

		Hum:SetStateEnabled(13, true)
	end
end)

Relief.addModule("Render", "AntiBlind", function(Toggled)
	if Toggled then
		local Found = PlayerGui:FindFirstChild("Blind")
		if Found then Found.Parent = RStorage end
	else
		local Found = RStorage:FindFirstChild("Blind")
		if Found then Found.Parent = PlayerGui end
	end
end)

Relief.addModule("Render", "AntiMyopic", function(Toggled)
	if Toggled then
		local Found = Lighting:FindFirstChild("Blur")
		if Found then Found.Parent = RStorage end

		Thread:Maid("AntiMyopic", Lighting.ChildAdded:Connect(function(Obj)
			if Obj.Name == "Blur" then
				Obj.Parent = RStorage
			end
		end))
	else
		local Found = RStorage:FindFirstChild("Blur")
		if Found then Found.Parent = Lighting end
	end
end)

Relief.addModule("Render", "AntiCameraGlitch", function(Toggled)
	if Toggled then
		local Custom = Enum.CameraType.Custom
		Thread:Maid("Camera", Camera:GetPropertyChangedSignal("CameraType"):Connect(function()
			if Camera.CameraType ~= Custom then
				Camera.CameraType = Custom
			end
		end))
	else
		Thread:Unmaid("Camera")
	end
end)

Relief.addModule("Movement", "AntiGlitch", function(Toggled)
	if Toggled then
		local Old = nil
		Thread:New("AntiGlitch", function()
			task.wait()
			if Flinging then return end

			local Char = LocalPlayer.Character
			if not Char then return end

			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return end

			if not Old then
				Old = Root.CFrame
				return
			end

			if Root.CFrame.Y >= 1_000_000 then
				Root.CFrame = Old
			end

			Old = Root.CFrame
		end)
	else
		Thread:Disconnect("AntiGlitch")
	end
end)

Relief.addModule("Player", "AntiInvisible", function(Toggled)
	if Toggled then
		OnCharacter("AntiInvisible", function(Character)
			local Head = Character:WaitForChild("Head")
			Thread:Maid("Head", Head:GetPropertyChangedSignal("Transparency"):Connect(function()
				if Head.Transparency == 1 then
					Character:BreakJoints()
				end
			end))
		end)
	else
		UnOnCharacter("AntiInvisible")
		Thread:Unmaid("Head")
	end
end)

Relief.addModule("Player", "AntiResize", function(Toggled)
	if Toggled then
		OnCharacter("AntiResize", function(Character)
			local Root = Character:WaitForChild("HumanoidRootPart")
			local Old = Root.Size
			Thread:Maid("Resize", Root:GetPropertyChangedSignal("Size"):Connect(function()
				if Root.Size ~= Old then
					Character:BreakJoints()
				end
			end))
		end)
	else
		UnOnCharacter("AntiResize")
		Thread:Unmaid("Resize")
	end
end)

local OldPosition = nil
local KeepTools = false
Relief.addModule("Movement", "AntiOof", function(Toggled)
	if Toggled then
		Thread:New("AntiOof", function()
			task.wait()
			local Char = LocalPlayer.Character
			if not Char then return end
			
			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return end

			OldPosition = Root.CFrame
		end)

		local Tools = {}

		local function HandleCharacter(Character)
			if not Character then return end
			
			local Hum = Character:WaitForChild("Humanoid")
			local Root = Character:WaitForChild("HumanoidRootPart")

			if KeepTools then
				for _, Tool in Tools do
					if Tool then
						Hum:EquipTool(Tool)
					end
				end
			end
			
			if KeepTools then
				Hum.Died:Connect(function()
					task.wait(Players.RespawnTime - 0.2)
				
					Tools = {}
					for _, Tool in LocalPlayer.Backpack:GetChildren() do
						if Tool:IsA("Tool") then
							Tool.Parent = Character
						end
					end
					for _, Tool in Character:GetChildren() do
						if Tool:IsA("Tool") then
							Tool.Parent = workspace
							table.insert(Tools, Tool)
						end
					end
				end)
			end
			
			if OldPosition then
				Root.CFrame = OldPosition
			end
		end

		Thread:Maid("AO_CharacterAdded", LocalPlayer.CharacterAdded:Connect(HandleCharacter))
		HandleCharacter(LocalPlayer.Character)
	else
		Thread:Disconnect("AntiOof")
		Thread:Unmaid("AO_CharacterAdded")
	end
end, {
	{
		["Type"] = "Toggle",
		["Title"] = "KeepTools",
		["Default"] = true,
		["Callback"] = function(Toggled)
			KeepTools = Toggled
		end
	}
})

Relief.addModule("Movement", "AntiRagdoll", function(Toggled)
	if Toggled then
		OnCharacter("AntiRagdoll", function(Character)
			local Hum = Character:WaitForChild("Humanoid")
			Hum:SetStateEnabled(14, false)
		end)
	else
		UnOnCharacter("AntiRagdoll")

		local Char = LocalPlayer.Character
		if not Char then return end

		local Hum = Char:FindFirstChildOfClass("Humanoid")
		if not Hum then return end

		Hum:SetStateEnabled(14, true)
	end
end)

-- Chat Admin

local function Chat(Message)
	Folder.RBXGeneral:SendAsync(Message)
end

local function NumFix(x)
	return math.round(x * 255)
end

local function PrefixFormat(Sender)
	local TeamColor = Sender.Team and Sender.Team.TeamColor.Color
	if TeamColor then
		local Pre = ('<i><font color="rgb(%s, %s, %s)">(')
		:format(NumFix(TeamColor.R), NumFix(TeamColor.G), NumFix(TeamColor.B))
		return Pre .. Sender.DisplayName .. ")</font></i> "
	else
		local Pre = ('<i><font color="#%s">(')
		:format("999999")
		return Pre .. Sender.DisplayName .. ")</font></i> "
	end
end

TextChatService.OnIncomingMessage = function(Message)
    local Source = Message.TextSource
	local Text = Message.Text

	if Source then
		local Sender = Players:GetPlayerByUserId(Source.UserId)
		local Status = Message.Status
		
		Message.PrefixText = PrefixFormat(Sender)
		
		if Text:sub(1, 1) == ";" then
			if Sender.UserId ~= LocalPlayer.UserId then
				Message.Text = ('<u><font color="#FFFF00">%s</font></u>'):format(Message.Text)
			end
		end
    end
end

Relief.AddCommand({"admin"}, function(Args)
	local Targets = GetPlayer(Args[1])
	if not Targets then return end

	local Admin = GetAdmin()
	local AdminTime = Admin.leaderstats.Time.Value
	local LocalTime = LocalPlayer.leaderstats.Time.Value

	for _, Target in Targets do
		if Target == Admin or Target == LocalPlayer then continue end
		
		local TargetTime = Target.leaderstats.Time.Value
		local Give = AdminTime - TargetTime

		if Give <= 0 then continue end
		if Give > LocalTime then continue end

		Chat((";donate %s %s"):format(Target.DisplayName, Give))
	end
end)

Relief.AddCommand({"shareadmin"}, function(Args)
	local Targets = GetPlayer(Args[1])
	if not Targets then return end

	local LocalTime = LocalPlayer.leaderstats.Time.Value

	for _, Target in Targets do
		if Target == LocalPlayer then continue end
		
		local TargetTime = Target.leaderstats.Time.Value
		local Give = (LocalTime - TargetTime) / 2

		if Give <= 0 then continue end

		local Parts = {}

		for Part in Target.DisplayName:gmatch("[A-Za-z]+") do
			table.insert(Parts, Part)
		end

		local CleanedName = Parts[1]:lower()

		task.wait(0.45)
		Chat(("donate %s %s"):format(CleanedName, Give))
	end
end)

local function RunCommand(Cmd)
	Chat(Cmd)
	task.wait(0.45)
end

Relief.AddCommand({"grief"}, function(Args)
	RunCommand(";clearinv o")
	RunCommand(";maptide nan")
	RunCommand(";fog nan")
	RunCommand(";oof others")
	RunCommand(";blind o")
	RunCommand(";myopic o")
	RunCommand(";delcubes a")
end)

local NewChar = {
	["a"] = "а",
	["b"] = "ƅ",
	["c"] = "с",
	["d"] = "ԁ",
	["e"] = "е",
	["f"] = "F",
	["g"] = "ɡ",
	["h"] = "һ",
	["i"] = "і",
	["j"] = "ј",
	["k"] = "K",
	["l"] = "ӏ",
	["m"] = "Μ",
	["n"] = "Ν",
	["o"] = "о",
	["p"] = "р",
	["q"] = "ԛ",
	["r"] = "г",
	["s"] = "ꜱ",
	["t"] = "Τ",
	["u"] = "υ",
	["v"] = "ν",
	["w"] = "ԝ",
	["x"] = "х",
	["y"] = "у",
	["z"] = "ʐ"
}

local function Convert(Query)
	local New = ""
	for _ = 1, #Query do
		local Letter = Query:sub(_, _)
		local Found = NewChar[Letter]
		New = New .. (Found or Letter)
	end
	return New
end

Relief.AddCommand({"iqbypass", "iqby"}, function(Args)
	local Message = table.concat(Args, " ")
	task.defer(function()
		Chat(Convert(Message))
	end)
end)
