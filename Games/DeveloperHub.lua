-- Relief Lib

local Relief = getgenv().Relief
if not Relief then return end

-- Services

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables & Functions

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage.Events
local Functions = ReplicatedStorage.Functions
local Shop = ReplicatedStorage.Resource.Tools.Shop

local Rooms = workspace.Rooms
local function GetRoom()
	for _, Room in Rooms:GetChildren() do
		if Room:GetAttribute("Owner") == LocalPlayer.Name then
			return Room
		end
	end
end

local function RandomString(Length)
    local Compile = {}
    for _ = 1, Length do
        local C = math.random(52)
        Compile[_] = utf8.char(C < 27 and C + 96 or C + 38)
    end
    return table.concat(Compile)
end

local function Convert(Text, FillLength)
    local Compile = ""
    local Letters = Text:split("")
    for _, Letter in Letters do
        if _ == Letters then
            Compile ..= Letter
        else
            Compile ..= ("%s<%s/>"):format(Letter, RandomString(FillLength))
        end
    end
    return Compile
end

local Thread = getgenv().Thread

-- Modules

local Sign = Events.Sign
Relief.AddCommand({"title"}, function(Args)
	local Room = GetRoom()
	if not Room then return end
	
	local Message = table.concat(Args, " ")
	local New = Convert(Message, 2)

	Sign:FireServer(Room, New)
end)

local Buy = Functions.BuyItem
Relief.AddCommand({"crash"}, function(Args)
	local CrashAmount = 3000

	local Tool = Shop["Party Blower"]
	for _ = 1, CrashAmount do
		task.spawn(function()
			Buy:InvokeServer(Tool)
		end)
	end

	LocalPlayer.Character:BreakJoints()
	LocalPlayer.CharacterAppearanceLoaded:Wait()

	local Backpack = LocalPlayer:WaitForChild("Backpack")
	task.wait(2)

	local Char = LocalPlayer.Character

	for _, Tool in Backpack:GetChildren() do
		task.spawn(function()
			if Tool:IsA("Tool") then
				Tool.Parent = Char
				task.defer(function()
					Tool.Handle:Destroy()
				end)
			end
		end)
	end

	Char:BreakJoints()
end)

Relief.addModule("Player", "FrisbeeSpam", function(Toggled)
	if Toggled then
		Thread:New("FrisbeeSpam", function()
			task.wait()

			local Char = LocalPlayer.Character
			if not Char then return end

			local Root = Char:FindFirstChild("HumanoidRootPart")
			if not Root then return end

			local Backpack = LocalPlayer.Backpack
			if not Backpack then return end

			local Frisbee = Backpack:FindFirstChild("Frisbee") or Char:FindFirstChild("Frisbee")
			if not Frisbee then
				Buy:InvokeServer(Shop.Frisbee)
				repeat
					Frisbee = Backpack:FindFirstChild("Frisbee") or Char:FindFirstChild("Frisbee")
					task.wait()
				until Frisbee
			end

			Frisbee.Parent = Char
			Frisbee.RemoteEvent:FireServer(Root.Position)
			Buy:InvokeServer(Shop.Frisbee)
		end)
	else
		Thread:Disconnect("FrisbeeSpam")
	end
end)
