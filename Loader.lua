if getgenv().Relief then getgenv().Relief.Notify("Relief already loaded.", 5, Color3.new(1, 1, 0)) return end

-- Config

local Games = {
    [11137575513] = "https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Games/TheChosenOne.lua", -- The Chosen One
    [12943245078] = "https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Games/TheChosenOne.lua", -- The Chosen One XL
    [96017656548489] = "https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Games/BanOrBeBanned.lua", -- Ban or Get Banned
	[17625359962] = "https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Games/Rivals.lua", -- Rivals
	[117398147513099] = "https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Games/Rivals.lua", -- Rivals Match
	[118614517739521] = "https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Games/BlindShot.lua", -- BlindShot
}

-- Universal

local Relief = loadstring(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Util/Ui.lua"))()
getgenv().Relief = Relief

Relief.addCategory("Movement", "rbxassetid://1114393432")
Relief.addCategory("Combat", "rbxassetid://7485051715")
Relief.addCategory("Render", "rbxassetid://13321848320")
Relief.addCategory("Player", "rbxassetid://16149111731")
Relief.addCategory("World", "rbxassetid://17640958405")
Relief.addCategory("Utility", "rbxassetid://1538581893")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function JoinDiscord()
	request({
		Url = "http://127.0.0.1:6463/rpc?v=1",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["Origin"] = "https://discord.com",
		},
		Body = HttpService:JSONEncode({
			cmd = "INVITE_BROWSER",
			args = {
				code = "msFnMfhuhV"
			},
			nonce = HttpService:GenerateGUID(false)
		}),
	})
end

if not isfile("time") then
	writefile("time", tostring(tick()))
	JoinDiscord()
end

local t = readfile("time")
local l = tick() - tonumber(t)
if l > 14400 then
	delfile("time")
	JoinDiscord()
	writefile("time", tostring(tick()))
end

local function ServerHop()
	local StringData = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
	local Data = HttpService:JSONDecode(StringData).data
	local RandomServer = Data[math.random(#Data)]
	TeleportService:TeleportToPlaceInstance(game.PlaceId, RandomServer.id)
	Relief.KillScript()
end

setclipboard("discord.gg/msFnMfhuhV")

local Found = false
local FId = nil
local toLoad = nil
for Id, Link in Games do
    if Id ~= game.PlaceId then continue end
	
	Found = true
	FId = Id
	toLoad = function()
    	loadstring(game:HttpGet(Link))()
    	Relief.Notify(("Relief Hub by Atlas | %d Loaded | Set Discord To Clipboard!"):format(Id), 5)
	end
    break
end

local SaveName = Found and FId or "Universal"
Relief.AutoSaveName(SaveName)

getgenv().Whitelist = {}
getgenv().IsWhitelisted = function(Target)
	if not getgenv().Whitelist then return 1 end
	if table.find(getgenv().Whitelist, Target.UserId) then
		return 1
	end
end

local IsWhitelisted = getgenv().IsWhitelisted

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

local function GetFolder()
	for _, F in TextChatService:GetChildren() do
		if F:IsA("Folder") and F.Name == "TextChannels" and #F:GetChildren() >= 1 then
			return F
		end
	end
end

local Folder = GetFolder()

local function Chat(Message)
	Folder.RBXGeneral:SendAsync(Message)
end

local Special = utf8.char(0x060D)
local function ConvertBypass(Text)
    local Reverse = Text:reverse()
    local Split = Reverse:split(" ")
    local New = {}
 
    for _, Word in Split do
        local Letters = Word:split("")
        local Fill = Special .. table.concat(Letters, Special)
        table.insert(New, Fill)
    end
 
    local Final = table.concat(New, " ")
	return Final
end

local function Repeat(Callback, Until)
    repeat
        Callback()
    until Until()
end

local Thread = {
    Cache = {},
    Connections = {},
	Tables = {}
}
 
function Thread:New(Name, Callback)
    Thread.Cache[Name] = true
    
    task.spawn(function()
        while Thread.Cache[Name] do
            Callback()
        end
    end)
end
 
function Thread:Disconnect(Name)
    if Thread.Cache[Name] then
        Thread.Cache[Name] = nil
    end
end
 
function Thread:Maid(Name, Connection)
    if not Connection then return end
    Thread.Connections[Name] = Connection

	return Connection
end
 
function Thread:Unmaid(Name)
    local Found = Thread.Connections[Name]
    if not Found then return end
 
    Found:Disconnect()
    Thread.Connections[Name] = nil
end

function Thread:Table(Name, Callback)
	if not Thread.Tables[Name] then
		Thread.Tables[Name] = {}
	end

	local T = true
	Thread.Tables[Name] = T

	task.spawn(function()
        while T do
            Callback()
        end
    end)

	local Tree = {}

	function Tree:Disconnect()
		T = nil
	end

	return Tree
end

function Thread:Untable(Name)
	if Thread.Tables[Name] then
        Thread.Tables[Name] = nil
    end
end

getgenv().Thread = Thread

local Old = nil
local ZoomInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

Relief.addModule("Render", "Zoom", function(Toggled)
	if Toggled then
		Old = Camera.FieldOfView
		local Amount = Relief.getSetting("Zoom", "Amount")
		if Relief.getSetting("Zoom", "Smooth") then
			TweenService:Create(Camera, ZoomInfo, { FieldOfView = Amount }):Play()
		else
			Camera.FieldOfView = Amount
		end

		local Module = Relief.getModule("Zoom")
		local Bind = Module.Keybind
		if not Bind then return end

		Thread:Unmaid("Zoom")
		Thread:Maid("Zoom", UserInputService.InputEnded:Connect(function(Input, GPE)
			if Input.KeyCode == Bind then
				Thread:Unmaid("Zoom")
				Module.ToggleFunction()
			end
		end))
	else
		if Relief.getSetting("Zoom", "Smooth") then
			TweenService:Create(Camera, ZoomInfo, { FieldOfView = Old }):Play()
		else
			Camera.FieldOfView = Old
		end
		Thread:Unmaid("Zoom")
	end
end, {
	{
		["Type"] = "Toggle",
		["Title"] = "Smooth",
		["Callback"] = function()end
	},
	{
		["Type"] = "Slider",
		["Title"] = "Amount",
		["Min"] = 1,
		["Max"] = 120,
		["Default"] = 30,
		["Callback"] = function()end
	}
})

Relief.addModule("Utility", "FriendLogs", function()end)

local Log = {}
local Connections = {}

local function FriendLog(Text, Color)
	if Relief.isToggled("FriendLogs") then
		Relief.Notify(Text, 8, Color)
	end
end

local function HandlePlayer(Player)
	Log[Player] = {}

	for _, Target in Players:GetPlayers() do
		Log[Player][Target] = Player:GetFriendStatus(Target)
	end

	Thread:Maid(Player.Name .. "_Added", Players.PlayerAdded:Connect(function(Target)
		if not Players:FindFirstChild(Player.Name) then if Connections[Player] then Connections[Player]:Disconnect() Connections[Player] = nil end return end
		repeat task.wait() until Players:FindFirstChild(Target.Name)
		Log[Player][Target] = Player:GetFriendStatus(Target)
	end))

	Thread:Maid(Player.Name .. "_Handle", Player.FriendStatusChanged:Connect(function(Target, New)
		if New.Value == 4 then
			FriendLog(("<u>%s</u> sent friend request to <u>%s</u>."):format(Target.Name, Player.Name), Color3.new(1, 1, 0))
			Thread:Maid(Target.Name .. "_" .. Player.Name, Player.FriendStatusChanged:Connect(function(NewTarget, NewStatus)
				if NewTarget == Target then
					if NewStatus.Value == 1 then
						FriendLog(("<u>%s</u> declined <u>%s</u>'s friend request."):format(Player.Name, Target.Name), Color3.new(1, 0, 0))
					end

					if NewStatus.Value == 2 then
						FriendLog(("<u>%s</u> accepted <u>%s</u>'s friend request."):format(Player.Name, Target.Name), Color3.new(0, 1, 0))
					end
					
					Thread:Unmaid(Target.Name .. "_" .. Player.Name)
				end
			end))
		end

		if Player == LocalPlayer then return end

		local Old = Log[Player][Target]
		if not Old then return end

		if Old.Value == 2 and New.Value == 1 then
			FriendLog(("<u>%s</u> and <u>%s</u> are no longer friends."):format(Target.Name, Player.Name), Color3.new(1, 0, 0))
		end

		Log[Player][Target] = New
	end))
end

for _, Player in Players:GetPlayers() do
	HandlePlayer(Player)
end

Thread:Maid("HandleFriend", Players.PlayerAdded:Connect(HandlePlayer))

Thread:Maid("FriendLeave", Players.PlayerRemoving:Connect(function(Player)
	local Found = Log[Player]
	if Found then
		Found = nil
	end

	for _, Data in Log do
		local Found = Data[Player]
		if Found then
			Found = nil
		end
	end

	Thread:Unmaid(Player.Name .. "_Added")
end))

local Vehicles = {}

for _, Model in workspace:GetChildren() do
	local Button = Model:FindFirstChild("Button")
	if Button and Model:FindFirstChildOfClass("IntValue") then
		table.insert(Vehicles, Button)
	end
end

if #Vehicles > 0 then
	Relief.addModule("World", "VehicleSpam", function(Toggled)
		if Toggled then
			Thread:New("VehicleSpam", function()
				task.wait()

				local Char = LocalPlayer.Character
				if not Char then return end
				
				local Root = Char:FindFirstChild("HumanoidRootPart")
				if not Root then return end

				for _, Vehicle in Vehicles do
					Vehicle.CFrame = Root.CFrame
				end
			
				task.wait()
			
				for _, Vehicle in Vehicles do
					Vehicle.CFrame = CFrame.new(0, 9e9, 0)
				end
			end)
		else
			
		end
	end)
end

-- SKID 0ZBUG START
local Animations = {
    Idle = {
        Animation1 = 12521158637,
        Animation2 = 12521162526
    },
    Run = {
        RunAnim = 12518152696
    },
    Walk = {
        WalkAnim = 12518152696
    },
    Jump = {
    	JumpAnim = 12520880485,
        ["!ID!"] = 12520880485
    },
    Fall = {
        FallAnim = 12520972571
    },
    Climb = {
    	ClimbAnim = 12520982150
    },
    Dance = {
    	Animation1 = 12521009666,
    	Animation2 = 12521151637,
    	Animation3 = 12521015053
    },
    Dance2 = {
    	Animation1 = 12521169800,
    	Animation2 = 12521173533,
    	Animation3 = 12521027874
    },
    Dance3 = {
    	Animation1 = 12521178362,
    	Animation2 = 12521181508,
    	Animation3 = 12521184133
    },
    Laugh = {
    	LaughAnim = 12521018724
    },
    Cheer = {
    	CheerAnim = 12521021991
    },
    Sit = {
    	SitAnim = 12520993168
    },
    Wave = {
    	WaveAnim = 12521004586
    },
    Point = {
    	PointAnim = 12521007694
    },
    ToolNone = {
    	ToolNoneAnim = 12520996634
    },
    ToolSlash = {
    	ToolSlashAnim = 12520999032
    },
    ToolLunge = {
    	ToolLungeAnim = 12521002003
    }
}

local function StopAnimations(Humanoid)
	for _, Animation in Humanoid:GetPlayingAnimationTracks() do
	    Animation:Stop()
	end
end

local AnimCache = {}
local function LoadAnimations(Animate)
	AnimCache = {}
	for Animation, Child in Animations do
	    for ChildName, ID in Child do
			local Found = Animate:FindFirstChild(Animation:lower())
			if not Found then continue end

			local Child = Found:FindFirstChild(ChildName)
			if not Child then continue end

			table.insert(AnimCache, {Child, Child.AnimationId})
			Child.AnimationId = ("rbxassetid://%s"):format(ID)
	    end
	end
end

local function Animate(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animate = Character:WaitForChild("Animate")
	
	task.wait(0.5)
	
	StopAnimations(Humanoid)
	LoadAnimations(Animate)
	StopAnimations(Humanoid)
end
-- SKID 0ZBUG END

Relief.addModule("Movement", "ForceR6", function(Toggled)
	if Toggled then
		local function HandleCharacter(Char)
			if not Char then return end

			local Hum = Char:WaitForChild("Humanoid")
			if not Hum or Hum.RigType ~= Enum.HumanoidRigType.R15 then return end

			Animate(Char)
		end

		HandleCharacter(LocalPlayer.Character)
		Thread:Maid("R6", LocalPlayer.CharacterAdded:Connect(HandleCharacter))
	else
		Thread:Unmaid("R6")

		local Char = LocalPlayer.Character
		if not Char then return end
		
		local Hum = Char:FindFirstChildOfClass("Humanoid")
		if not Hum or Hum.RigType ~= Enum.HumanoidRigType.R15 then return end

		StopAnimations(Hum)
		for _, Data in AnimCache do
			local Child, Id = Data[1], Data[2]
			if not Child then continue end

			Child.AnimationId = Id
		end
		StopAnimations(Hum)

		AnimCache = {}
	end
end)

local Connector = game:FindFirstChild("GlobalPianoConnector", true)
if Connector then
	Relief.addModule("World", "PianoCrash", function(Toggled)
		if Toggled then
			Thread:New("Crash", function()
				task.wait()

				if not Connector then return end

				for _ = 1, 61 do
					Connector:FireServer("play", _, 12, {"18865849300"})
					onnector:FireServer("stop", _)
				end
			end)
		else
			Thread:Disconnect("Crash")
		end
	end)
end

local SH_TOGGLED = false
local LINK = "gg/msFnMfhuhV"
local ADS = {"RELIEF ON TOP", "JOIN US", "WE OWN YOU", "LOL EZ"}
Relief.addModule("Player", "Advertise", function(Toggled)
	if Toggled then
		Thread:New("Advertise", function()
			for i = 1, #ADS do
				if not Relief.isToggled("Advertise") then break end
				Chat(ConvertBypass(LINK) .. Special .. "｜" .. ADS[i])
				task.wait(10)
			end
		end)
	else
		Thread:Disconnect("Advertise")
	end
end, {
	{
		["Type"] = "Toggle",
		["Title"] = "AutoServerHop",
		["Callback"] = function(Toggled)
			if Toggled then
				SH_TOGGLED = true
				Thread:New("ServerHop", function()
					repeat task.wait() until #Players:GetPlayers() < 5 or not Relief.isToggled("Advertise") or not SH_TOGGLED
					if not Relief.isToggled("Advertise") or not SH_TOGGLED then return end
					ServerHop()
				end)
			else
				Thread:Disconnect("ServerHop")
				SH_TOGGLED = false
			end
		end
	}
})

Relief.addModule("Player", "AutoGrabTools", function(Toggled)
	if Toggled then
		local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local Hum = Char:WaitForChild("Humanoid")
		
		for _, Tool in workspace:GetChildren() do
			if Tool:IsA("Tool") then
				Hum:EquipTool(Tool)
			end
		end

		Thread:Maid("AGT", workspace.ChildAdded:Connect(function(Obj)
			if Obj:IsA("Tool") then
				local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local Hum = Char:WaitForChild("Humanoid")
				Hum:EquipTool(Tool)
			end
		end))
	else
		Thread:Unmaid("AGT")
	end
end)

Relief.addModule("Movement", "AntiWarp", function(Toggled)
	if Toggled then
		local Old = nil
		Thread:New("AntiWarp", function()
			local Char = LocalPlayer.Character
			if not Char then return task.wait() end
			
			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return task.wait() end
			
			if not Old then Old = Root.CFrame task.wait() end
			
			local Distance = (Root.Position - Old.Position).Magnitude
			if Distance >= 15 then
				Root.CFrame = Old
				Old = nil
			else
				Old = Root.CFrame
			end

			task.wait()
		end)
	else
		Thread:Disconnect("AntiWarp")
	end
end)

local function lighten(color, amount)
    return color:Lerp(Color3.new(1, 1, 1), amount)
end

local R, G, B = 0, 0, 0
Relief.addModule("Render", "Theme", function(Toggled)
    if Toggled then
        Relief.Recolor(Color3.fromRGB(R, G, B))
    else
        Relief.Recolor(Color3.fromRGB(75, 156, 255))
    end
end, {
    {
        ["Type"] = "TextBox",
        ["Title"] = "R",
        ["Placeholder"] = "red",
        ["Callback"] = function(Num)
            local New = tonumber(Num) or 0
            R = New
			if Relief.isToggled("Theme") then
            	Relief.Recolor(Color3.fromRGB(R, G, B))
			end
        end
    },
    {
        ["Type"] = "TextBox",
        ["Title"] = "G",
        ["Placeholder"] = "green",
        ["Callback"] = function(Num)
			local New = tonumber(Num) or 0
            G = New
            if Relief.isToggled("Theme") then
            	Relief.Recolor(Color3.fromRGB(R, G, B))
			end
        end
    },
    {
        ["Type"] = "TextBox",
        ["Title"] = "B",
        ["Placeholder"] = "blue",
        ["Callback"] = function(Num)
            local New = tonumber(Num) or 0
            B = New
			if Relief.isToggled("Theme") then
            	Relief.Recolor(Color3.fromRGB(R, G, B))
			end
        end
    },
    {
        ["Type"] = "Toggle",
        ["Title"] = "Rainbow",
        ["Callback"] = function(Toggled)
            if Toggled then
                local x = 0
                Thread:New("Rainbow", function()
                    if not Relief.isToggled("Theme") then return task.wait() end
					local dt = RunService.RenderStepped:Wait()
					x += (dt / 3)
					
					if Relief.isToggled("Theme") then
						local rainbow = Color3.fromHSV(x % 1, 1, 1)
						local brighter = lighten(rainbow, 0.3)
						Relief.Recolor(rainbow)
					end
                    task.wait()
                end)
            else
                Thread:Disconnect("Rainbow")
                if Relief.isToggled("Theme") then
					Relief.Recolor(Color3.fromRGB(R, G, B))
				end
            end
        end
    },
})

Relief.addModule("Combat", "LoopFling", function(Toggled)
    if Toggled then
        workspace.FallenPartsDestroyHeight = 0/0
        Thread:New("LoopFling", function()
            task.wait()
 
            local Old = nil
            local Flung = false
 
            local Char = LocalPlayer.Character
            if not Char then return end
 
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if not Root then return end
 
            local OldPos = Root.CFrame
 
            for _, Target in Players:GetPlayers() do
                if Target == LocalPlayer then continue end
				if IsWhitelisted(Target) then continue end
 
                local Start = tick()
 
                local function Check()
                    if not Relief.isToggled("LoopFling") then return 1 end
                    
                    local Char = LocalPlayer.Character
                    if not Char then return 1 end
 
                    local Root = Char:FindFirstChild("HumanoidRootPart")
                    if not Root then return 1 end
 
                    local TChar = Target.Character
                    if not TChar then return 1 end
 
                    local THum = TChar:FindFirstChildOfClass("Humanoid")
                    if not THum or THum.SeatPart then return 1 end
 
                    local TRoot = TChar:FindFirstChild("HumanoidRootPart")
                    if not TRoot then return 1 end
                    if TRoot.Velocity.Magnitude > 500 then return 1 end
 
                    local TimeFlung = tick() - Start
                    if TimeFlung >= 0.5 then return 1 end
                end
 
                if Check() then continue end
                
                Repeat(function()
                    Flung = true
                    local Char = LocalPlayer.Character
                    local Root = Char.HumanoidRootPart
                    local TChar = Target.Character
                    local TRoot = TChar.HumanoidRootPart
                    local THum = TChar.Humanoid
 
                    for _, BP in Char:GetChildren() do
                        if BP:IsA("BasePart") then
                            BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
                        end
                    end
                    
                    local Prediction = Old and (Old.Position - TRoot.Position) * -75 or Vector3.zero
                    local Offset = CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
                    Root.CFrame = (TRoot.CFrame * CFrame.Angles(os.clock() * 49218, os.clock() * 1849, os.clock() * 32178) * Offset) + Prediction
                    Old = TRoot.CFrame
 
                    Root.Velocity = Vector3.new(9e7, 9e8, 9e7)
                    Root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                    task.wait()
                end, Check)
            end
 
            if not Flung then return end
 
            local Char = LocalPlayer.Character
            if not Char then return end
 
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if not Root then return end
 
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            if not Hum then return end
 
            repeat
                Root.CFrame = OldPos
                Hum:ChangeState(2)
                
                for _, BP in Char:GetDescendants() do
                    if BP:IsA("BasePart") then
                        BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
                    end
                end
            until (Root.Position - OldPos.Position).Magnitude < 1
        end)
    else
        Thread:Disconnect("LoopFling")
    end
end)

local Cache = {}
Relief.addModule("Movement", "Noclip", function(Toggled)
    if Toggled then
        Cache = {}
 
        local Char = LocalPlayer.Character
        if Char then
            for _, BP in Char:GetChildren() do
                if BP:IsA("BasePart") then
                    Cache[BP.Name] = BP.CanCollide
                end
            end
        end
 
        Thread:New("Noclip", function()
            RunService.Stepped:Wait()
            local Char = LocalPlayer.Character
            if not Char then return end
 
            for _, BP in Char:GetChildren() do
                if BP:IsA("BasePart") then
                    BP.CanCollide = false
                end
            end
        end)
    else
        Thread:Disconnect("Noclip")
 
        local Char = LocalPlayer.Character
        if Char then
            for Name, Collides in Cache do
                local Found = Char:FindFirstChild(Name)
                if not Found then continue end
 
                Found.CanCollide = Collides
            end
        end
 
        Cache = {}
    end
end)

Relief.addModule("World", "AntiVoid", function(Toggled)
	if Toggled then
		workspace.FallenPartsDestroyHeight = 0/0
		Thread:Maid("Fallen", workspace:GetPropertyChangedSignal("FallenPartsDestroyHeight"):Connect(function()
			if workspace.FallenPartsDestroyHeight ~= 0/0 then
				workspace.FallenPartsDestroyHeight = 0/0
			end
		end))
	else
		Thread:Unmaid("Fallen")
	end
end)

local Directions = {
    ["W"] = {0, 0, 1},
    ["A"] = {-1, 0, 0},
    ["S"] = {0, 0, -1},
    ["D"] = {1, 0, 0},
    ["Q"] = {0, -1, 0},
    ["E"] = {0, 1, 0},
}

Relief.addModule("Movement", "Fly", function(Toggled)
	local Env = Relief.getEnv("Fly")
    if Toggled then
		Env.FlySpeed = Env.FlySpeed or 1
        Env.OldGrav = Env.OldGrav or workspace.Gravity
        workspace.Gravity = 0
 
        Thread:New("Fly", function()
            task.wait()
			if UserInputService:GetFocusedTextBox() then
				return
			end

            local Char = LocalPlayer.Character
            if not Char then return end
 
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if not Root then return end
 
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            if not Hum or Hum.Health <= 0 then return end
 
            Hum:ChangeState(0)
 
            for _, BP in Char:GetChildren() do
                if BP:IsA("BasePart") then
                    BP.Velocity = Vector3.zero
                    BP.RotVelocity = Vector3.zero
                end
            end
 
            local camCF = Camera.CFrame
            local moveDir = Vector3.zero
 
            for key, dir in Directions do
                if UserInputService:IsKeyDown(Enum.KeyCode[key]) then
                    moveDir += Vector3.new(dir[1], dir[2], dir[3])
                end
            end
 
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end
 
            local velocity =
                camCF.RightVector * moveDir.X +
                camCF.UpVector * moveDir.Y +
                camCF.LookVector * moveDir.Z
 
            local newPos = Root.Position + velocity * Env.FlySpeed
 
            Root.CFrame = CFrame.new(
                newPos,
                newPos + camCF.LookVector
            )
        end)
    else
        Thread:Disconnect("Fly")
        workspace.Gravity = Env.OldGrav
        Env.OldGrav = nil
 
        local Char = LocalPlayer.Character
        if not Char then return end
 
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum or Hum.Health <= 0 then return end
 
        for i = 1, 5 do
            Hum:ChangeState(2)
            task.wait()
        end
    end
end, {
    {
        ["Type"] = "Slider",
        ["Title"] = "Speed",
        ["Min"] = 0,
		["Max"] = 10,
		["Default"] = 0.5,
        ["Callback"] = function(Num)
			local Env = Relief.getEnv("Fly")
            Env.FlySpeed = Num
        end
    }
})

local PlayerTable = {}

for _, Player in Players:GetPlayers() do
	if Player ~= LocalPlayer then
		table.insert(PlayerTable, Player)
	end
end

Thread:Maid("NPC_PA", Players.PlayerAdded:Connect(function(Plr)
	table.insert(PlayerTable, Plr)
end))

Thread:Maid("NPC_PR", Players.PlayerRemoving:Connect(function(Plr)
	local Found = table.find(PlayerTable, Plr)
	if Found then
		table.remove(PlayerTable, Found)
	end
end))

Relief.addModule("Movement", "NoPlayerCollision", function(Toggled)
	if Toggled then
		Thread:New("NoPlayerCollision", function()
			for _, Plr in PlayerTable do
				local Char = Plr.Character
				if not Char then continue end
				
				for _, Inst in Char:GetChildren() do
					local Class = Inst.ClassName
					if Class == "Part" or Class == "MeshPart" then
						Inst.Velocity, Inst.RotVelocity = Vector3.zero, Vector3.zero
						Inst.CanCollide = false
					end

					if Class == "Accessory" or Class == "Tool" then
						local Handle = Inst:FindFirstChild("Handle")
						if Handle then
							Handle.Velocity, Handle.RotVelocity = Vector3.zero, Vector3.zero
							Handle.CanCollide = false
						end
					end
				end
			end

			RunService.Stepped:Wait()
		end)
	else
		Thread:Disconnect("NoPlayerCollision")
		Thread:Unmaid("NPC_PA")
		Thread:Unmaid("NPC_PR")
	end
end)

Relief.addModule("Render", "ModuleList", function(Toggled)
    Relief.ModuleList.Visible = Toggled
end, {}, nil, true)

Relief.addModule("Render", "MobileButton", function(Toggled)
    Relief.MobileButton.Visible = Toggled
	Relief.Arrow.Visible = Toggled
end, {}, nil, true)

Relief.AddCommand({"whitelist", "wl"}, function(Args)
	local Targets = GetPlayer(Args[1])
	if not Targets then return end

	for _, Target in Targets do
		table.insert(getgenv().Whitelist, Target.UserId)
	end
end)

Relief.AddCommand({"unwhitelist", "unwl"}, function(Args)
	local Targets = GetPlayer(Args[1])
	if not Targets then return end

	for _, Target in Targets do
		local Found = table.find(getgenv().Whitelist, Target.UserId)
		if Found then
			table.remove(getgenv().Whitelist, Found)
		end
	end
end)

local LoopFlinging = false
Relief.AddCommand({"loopfling", "lf"}, function(Args)
	LoopFlinging = true
	local Targets = GetPlayer(Args[1])
	if not Targets then return end
	
	workspace.FallenPartsDestroyHeight = 0/0
    Thread:New("LoopFling", function()
		task.wait()
 
		local Old = nil
		local Flung = false
 
		local Char = LocalPlayer.Character
		if not Char then return end
 
		local Root = Char:FindFirstChild("HumanoidRootPart")
		if not Root then return end
 
		local OldPos = Root.CFrame
 
		for _, Target in Targets do
			if Target == LocalPlayer then continue end
			if IsWhitelisted(Target) then continue end
			
			local Start = tick()
                	 
			local function Check()
				if not LoopFlinging then return 1 end

                local Char = LocalPlayer.Character
                if not Char then return 1 end
 
                local Root = Char:FindFirstChild("HumanoidRootPart")
                if not Root then return 1 end
 
                local TChar = Target.Character
                if not TChar then return 1 end
 
                local THum = TChar:FindFirstChildOfClass("Humanoid")
                if not THum or THum.SeatPart then return 1 end
 
                local TRoot = TChar:FindFirstChild("HumanoidRootPart")
                if not TRoot then return 1 end
                if TRoot.Velocity.Magnitude > 500 then return 1 end
 
                local TimeFlung = tick() - Start
                if TimeFlung >= 0.5 then return 1 end
            end
 
            if Check() then continue end
                
            Repeat(function()
                Flung = true
                local Char = LocalPlayer.Character
                local Root = Char.HumanoidRootPart
                local TChar = Target.Character
                local TRoot = TChar.HumanoidRootPart
                local THum = TChar.Humanoid
 
                for _, BP in Char:GetChildren() do
                    if BP:IsA("BasePart") then
                        BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
                    end
                end
                    
                local Prediction = Old and (Old.Position - TRoot.Position) * -75 or Vector3.zero
                local Offset = CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
                Root.CFrame = (TRoot.CFrame * CFrame.Angles(os.clock() * 49218, os.clock() * 1849, os.clock() * 32178) * Offset) + Prediction
                Old = TRoot.CFrame
 
                Root.Velocity = Vector3.new(9e7, 9e8, 9e7)
                Root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                task.wait()
            end, Check)
        end
 
        if not Flung then return end
 
        local Char = LocalPlayer.Character
        if not Char then return end
 
        local Root = Char:FindFirstChild("HumanoidRootPart")
        if not Root then return end
 
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum then return end
 
        repeat
            Root.CFrame = OldPos
            Hum:ChangeState(2)
                
            for _, BP in Char:GetDescendants() do
                if BP:IsA("BasePart") then
                    BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
                end
            end
        until (Root.Position - OldPos.Position).Magnitude < 5
    end)
end)

Relief.AddCommand({"unloopfling", "unlf"}, function(Args)
	Thread:Disconnect("LoopFling")
	LoopFlinging = false
end)

Relief.AddCommand({"fling"}, function(Args)
    local Targets = GetPlayer(Args[1])
    if not Targets then return end
 
    workspace.FallenPartsDestroyHeight = 0/0
    local Old = nil
    local Flung = false
 
    local Char = LocalPlayer.Character
    if not Char then return end
 
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end
 
    local OldPos = Root.CFrame
 
    for _, Target in Targets do
        if Target == LocalPlayer then continue end
		if IsWhitelisted(Target) then continue end

        local Start = tick()
 
        local function Check()
            local Char = LocalPlayer.Character
            if not Char then return 1 end
 
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if not Root then return 1 end
 
            local TChar = Target.Character
            if not TChar then return 1 end
 
            local THum = TChar:FindFirstChildOfClass("Humanoid")
            if not THum then return 1 end
 
            local TRoot = TChar:FindFirstChild("HumanoidRootPart")
            if not TRoot then return 1 end
            if TRoot.Velocity.Magnitude > 500 then return 1 end
 
            local TimeFlung = tick() - Start
            if TimeFlung >= 3 then return 1 end
        end
 
        if Check() then continue end
        
        Repeat(function()
            Flung = true
            local Char = LocalPlayer.Character
            local Root = Char.HumanoidRootPart
            local TChar = Target.Character
            local TRoot = TChar.HumanoidRootPart
            local THum = TChar.Humanoid
 
            for _, BP in Char:GetChildren() do
                if BP:IsA("BasePart") then
                    BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
                end
            end
            
            local Prediction = Old and (Old.Position - TRoot.Position) * -75 or Vector3.zero
            local Offset = CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
            Root.CFrame = (TRoot.CFrame * CFrame.Angles(os.clock() * 49218, os.clock() * 1849, os.clock() * 32178) * Offset) + Prediction
            Old = TRoot.CFrame
 
            Root.Velocity = Vector3.new(9e7, 9e8, 9e7)
            Root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            task.wait()
        end, Check)
    end
 
    if not Flung then return end
 
    local Char = LocalPlayer.Character
    if not Char then return end
 
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end
 
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not Hum then return end
 
    repeat
        Root.CFrame = OldPos
        Hum:ChangeState(2)
        
        for _, BP in Char:GetDescendants() do
            if BP:IsA("BasePart") then
                BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
            end
        end
    until (Root.Position - OldPos.Position).Magnitude < 5
end)

Relief.AddCommand({"goto"}, function(Args)
    local Targets = GetPlayer(Args[1])
    if not Targets then return end
 
    local Target = Targets[1]
 
    local Char = LocalPlayer.Character
    if not Char then return end
 
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Root then return end
 
    local TChar = Target.Character
    if not TChar then return end
 
    local TRoot = TChar:FindFirstChild("HumanoidRootPart")
    if not TRoot then return end
 
    Root.CFrame = TRoot.CFrame
end)
 
Relief.AddCommand({"view"}, function(Args)
    local Targets = GetPlayer(Args[1])
    if not Targets then return end
 
    local Target = Targets[1]
 
    local TChar = Target.Character
    if not TChar then return end
 
    local THum = TChar:FindFirstChildOfClass("Humanoid")
    if not THum then return end
 
    Camera.CameraSubject = THum
end)
 
Relief.AddCommand({"unview"}, function(Args)
    local Char = LocalPlayer.Character
    if not Char then return end
 
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if not Hum then return end
 
    Camera.CameraSubject = Hum
end)
 
Relief.AddCommand({"rejoin", "rj"}, function(Args)
    if #Players:GetPlayers() == 1 then
        LocalPlayer:Kick()
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
end)

Relief.AddCommand({"rejointp", "rjtp"}, function(Args)
	if #Players:GetPlayers() == 1 then
        LocalPlayer:Kick()
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
	
	local Compile = ""
	task.spawn(function()
		local Char = LocalPlayer.Character
		if not Char then return end

		local Root = Char:FindFirstChild("HumanoidRootPart")
		if not Root then return end

		local Pos = Root.Position
		Compile = ("P=game.Players.LocalPlayer C=P.Character or P.CharacterAdded:Wait() R=C:FindFirstChild('HumanoidRootPart') or C:WaitForChild('HumanoidRootPart') R.CFrame = CFrame.new(%s, %s, %s)"):format(Pos.X, Pos.Y, Pos.Z)
	end)
	queue_on_teleport(Compile)
end)

Relief.AddCommand({"bypass", "by"}, function(Args)
    local Text = table.concat(Args, " ")
    task.defer(function()
        Chat(ConvertBypass(Text))
    end)
end)

Relief.AddCommand({"walkspeed", "ws", "speed"}, function(Args)
	local Amount = tonumber(Args[1]) or 16
	
	local Char = LocalPlayer.Character
	if not Char then return end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end

	Hum.WalkSpeed = Amount
end)

Relief.AddCommand({"sit"}, function(Args)
	local Char = LocalPlayer.Character
	if not Char then return end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end

	Hum.Sit = true
end)

Relief.AddCommand({"tospawn"}, function()
	local Char = LocalPlayer.Character
	if not Char then return end
	
	local Root = Char:FindFirstChild("HumanoidRootPart")
	if not Root then return end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end

	local Spawn = workspace:FindFirstChildOfClass("SpawnLocation", true)
	if Spawn then
		repeat
			Root.CFrame = Spawn.CFrame
			Hum:ChangeState(2)
			for _, BP in Char:GetDescendants() do
				if BP:IsA("BasePart") then
					BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
				end
			end
			task.wait()
		until (Root.Position - Spawn.Position).Magnitude < 5
	end
end)

Relief.AddCommand({"reset"}, function()
	local Char = LocalPlayer.Character
	if not Char then return end

	Char:BreakJoints()
end)

Relief.AddCommand({"respawn"}, function()
	local Char = LocalPlayer.Character
	if not Char then return end

	local Root = Char:FindFirstChild("HumanoidRootPart")
	if not Root then return end

	local Old = Root.CFrame
	Char:BreakJoints()

	LocalPlayer.CharacterAdded:Once(function(Char)
		local Root = Char:WaitForChild("HumanoidRootPart")
		Root.CFrame = Old
	end)
end)

local ThreadNames = {}
local function MakeMotionCommand(Name, TargetOffsetFunc, OnStart, OnEnd)
	table.insert(ThreadNames, Name)
	Relief.AddCommand({Name}, function(Args)
		local Targets = GetPlayer(Args[1])
		if not Targets then return end

		local Target = Targets[1]
		if not Target or Target == LocalPlayer then return end

		for _, ThreadName in ThreadNames do
			Thread:Disconnect(ThreadName)
		end

		table.insert(ThreadNames, Name)

		local x = 0
		Thread:New(Name, function()
			local Targets = GetPlayer(Args[1])
			if not Targets then return task.wait() end

			local Target = Targets[1]
			if not Target then return task.wait() end

			local Char = LocalPlayer.Character
			if not Char then return task.wait() end

			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if not Hum then return task.wait() end

			if not Players:FindFirstChild(Target.Name) then return task.wait() end

			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return task.wait() end
			
			local TChar = Target.Character
			if not TChar then return task.wait() end

			local TRoot = TChar:FindFirstChild("HumanoidRootPart")
			if not TRoot then return task.wait() end

			local THum = TChar:FindFirstChildOfClass("Humanoid")
			if not THum then return task.wait() end

			for _, BP in Char:GetChildren() do
				if BP:IsA("BasePart") then
					BP.Velocity, BP.RotVelocity = Vector3.zero, Vector3.zero
				end
			end

			x += 0.03

			if OnStart then OnStart(Hum) end
			
			Root.CFrame = TargetOffsetFunc(Char, Target.Character, Root, TRoot, x)
			task.wait()
		end)
	end)

	Relief.AddCommand({"un" .. Name}, function()
		Thread:Disconnect(Name)

		local Char = LocalPlayer.Character
		if not Char then return end

		local Hum = Char:FindFirstChildOfClass("Humanoid")
		if not Hum then return end

		if OnEnd then OnEnd(Hum) end
	end)
end

MakeMotionCommand(
	"touch",
	function(Char, TChar, Root, TRoot, x)
		return TRoot.CFrame * CFrame.new(0, 0, math.abs(math.sin(x) * 2) + 1)
	end,
	function(Hum) Hum:ChangeState(8) end,
	function(Hum) Hum:ChangeState(2) end
)

MakeMotionCommand(
	"head",
	function(Char, TChar, Root, TRoot, x)
		local THead = TChar:FindFirstChild("Head")
		if not THead then return Root.CFrame end

		return THead.CFrame
		* CFrame.new(0, (Root.Size.Y / 2) - (THead.Size.Y / 2), -math.abs(math.sin(x) * 2) - 1)
		* CFrame.Angles(0, math.rad(180), 0)
	end,
	function(Hum) Hum.Sit = true end,
	function(Hum) Hum.Sit = false Hum:ChangeState(2) end
)

MakeMotionCommand(
	"blow",
	function(Char, TChar, Root, TRoot, x)
		local Head = Char:FindFirstChild("Head")
		if not Head then return Root.CFrame end

		return TRoot.CFrame
		* CFrame.new(0, -(TRoot.Size.Y) - (Head.Size.Y / 2), -math.abs(math.sin(x) * 2) - 1)
		* CFrame.Angles(0, math.rad(180), 0)
	end,
	function(Hum) Hum.Sit = true end,
	function(Hum) Hum.Sit = false Hum:ChangeState(2) end
)

MakeMotionCommand(
	"doggy",
	function(Char, TChar, Root, TRoot, x)
		local Size = Root.Size
		local TSize = TRoot.Size

		return TRoot.CFrame
		* CFrame.new(0, -TSize.Y / 2, 0)
		* CFrame.Angles(math.rad(-90), 0, 0)
		* CFrame.new(0, (Size.Y / 2) + math.abs(math.sin(x) * 2), 0)
	end,
	function(Hum) Hum.Sit = true end,
	function(Hum) Hum.Sit = false Hum:ChangeState(2) end
)

MakeMotionCommand(
	"orbit",
	function(Char, TChar, Root, TRoot, x)
		return TRoot.CFrame
		* CFrame.new(math.sin(x) * 5, 0, math.cos(x) * 5)
		* CFrame.Angles(0, x, 0)
	end,
	function(Hum) Hum:ChangeState(8) end,
	function(Hum) Hum:ChangeState(2) end
)

Relief.AddCommand({"serverhop", "shop"}, ServerHop)
 
local function GetKey(Query)
    for _, KC in Enum.KeyCode:GetEnumItems() do
        if KC.Name:lower() == Query then
            return KC
        end
    end
end
 
Relief.AddCommand({"bind"}, function(Args)
    if #Args < 2 then return end
    
    local Module = Relief.getModule(Args[1])
    if not Module then return end
    
    local Query = Args[2]
    if Query:lower() == "clear" then
        Module.Keybind = nil
    else
        local Bind = GetKey(Args[2])
        if not Bind then return end
        
        Module.Keybind = Bind
    end
end)
 
Relief.AddCommand({"commands", "cmds"}, function(Args)
    Relief.CommandList.Visible = not Relief.CommandList.Visible
end)

Relief.AddCommand({"friendspam", "fs"}, function(Args)
	local Targets = GetPlayer(Args[1])
	if not Targets then return end

	local Target = Targets[1]
	if not Target then return end

	Thread:Disconnect("FriendSpam")
	Thread:New("FriendSpam", function()
		LocalPlayer:RequestFriendship(Target)

		Connection = LocalPlayer.FriendStatusChanged:Connect(function(Player)
			if Player == Target then
				Connection:Disconnect()
				task.wait()
				LocalPlayer:RevokeFriendship(Target)
			end
		end)

		task.wait(5.1)
	end)
end)

Relief.AddCommand({"unfriendspam", "unfs"}, function(Args)
	Thread:Disconnect("FriendSpam")
end)

local Syncing = false
Relief.AddCommand({"animationsync", "animsync", "as"}, function(Args)
	local Targets = GetPlayer(Args[1])
	if not Targets then return end

	local Target = Targets[1]
	if not Target then return end

	Relief.GetCommand("unas").Callback()
	Syncing = true

	local function HandleTrack(Track)
		local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		if not Char then return end

		local Hum = Char:WaitForChild("Humanoid")
		if not Hum then return end

		local Anim = Track.Animation
		local Copy = Hum:LoadAnimation(Anim)
		
		Track.Stopped:Connect(function()
			Copy:Stop()
		end)

		Copy:Play()

		local function Check()
			if not Copy then return 1 end
			if not Track then return 1 end
		end

		task.spawn(function()
			local T T = Thread:Table("TP", function()
				task.wait()
				if Check() then T:Disconnect() return end
				Copy.TimePosition = Track.TimePosition
				task.wait()
			end)
		end)
	end

	local function HandleCharacter(Char)
		local Hum = Char:WaitForChild("Humanoid")

		Thread:Untable("TP")
		Thread:Unmaid("OnTrack")

		for _, Track in Hum:GetPlayingAnimationTracks() do
			HandleTrack(Track)
		end

		Thread:Maid("OnTrack", Hum.AnimationPlayed:Connect(HandleTrack))
	end

	HandleCharacter(Target.Character)
	Thread:Maid("AnimCA", Target.CharacterAdded:Connect(HandleCharacter))

	Thread:Maid("AnimLeft", Players.PlayerRemoving:Connect(function(Plr)
		if Plr == Target then
			Relief.GetCommand("unas").Callback()
		end
	end))
end)

Relief.AddCommand({"unanimationsync", "unanimsync", "unas"}, function()
	Syncing = false
	Thread:Untable("TP")
	Thread:Unmaid("OnTrack")
	Thread:Unmaid("AnimCA")
	Thread:Unmaid("AnimLeft")

	local Char = LocalPlayer.Character
	if not Char then return end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end

	for _, Tracks in Hum:GetPlayingAnimationTracks() do
		Tracks:Stop()
	end
end)

-- Loader

if Found then toLoad() end

Relief.addModule("Utility", "KillScript", function(Toggled)
	if Toggled then
		Relief.KillScript()
		
		for Name, Value in Thread.Cache do
        	Thread.Cache[Name] = nil
    	end
 	
    	for _, Connection in Thread.Connections do
        	Connection:Disconnect()
    	end

		for Name, Data in Thread.Tables do
			Thread.Tables[Name] = nil
		end

		getgenv().Thread = false
		getgenv().Whitelist = false
		getgenv().Relief = false
		getgenv().IsWhitelisted = false
		getgenv().Commands = false
		getgenv().AddCommand = false
		getgenv().GetCommand = false
		TextChatService.OnIncomingMessage = false
	end
end)

Relief.Load(SaveName)

if not Found then
	Relief.Notify("Game not found in Relief Hub | Loading universal | Set Discord To Clipboard!", 5)
end

local AnimSocket = loadstring(game:HttpGet("https://raw.github.com/0zBug/AnimSocket/main/main.lua"))()

local Channel = AnimSocket.Connect("Relief")

Channel.OnMessage:Connect(function(Player, Message)
	if Player ~= LocalPlayer and not table.find(getgenv().Whitelist, Player.UserId) then
		table.insert(getgenv().Whitelist, Player.UserId)
		Channel:Send("i skidded this from 0zbug")
	end
end)

Channel:Send("i skidded this from 0zbug")

Thread:Maid("QUEUE", Players.PlayerRemoving:Connect(function(Player)
	if Player == LocalPlayer then
		queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/Relief/refs/heads/main/Loader.lua"))()')
	end
end))
