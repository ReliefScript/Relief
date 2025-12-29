-- Relief Lib

local Relief = getgenv().Relief
if not Relief then return end

-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables & Functions

local Thread = _G.Thread

local function Chat(Text)
    ReplicatedStorage.Remotes.ChattedEvent:FireServer("Chatted", Text)
end

local Chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local function RandomString(Length)
  	local Compile = ""
  	for _ = 1, Length do
    		local RandomNum = math.random(1, Chars:len())
    		local RandomLetter = Chars:sub(RandomNum, RandomNum)
    		Compile ..= RandomLetter
  	end
  	return Compile
end

local function GenerateRich()
  	return "<" .. RandomString(4) .. "/>"
end

local function Convert(Text)
  	local Compile = {}
  	local Letters = Text:split("")
  	table.insert(Compile, GenerateRich())
  
  	for _, Letter in Letters do
    		local Add = Letter .. GenerateRich()
    		table.insert(Compile, Add)
  	end
  
  	return table.concat(Compile, "")
end

local function Bypass(Message)
  	local Compile = {}
  
  	for _, Word in Message:split(" ") do
    		table.insert(Compile, Convert(Word))
  	end
  
  	return table.concat(Compile, " ")
end

Relief.AddCommand({"richbypass", "rb"}, function(Args)
    local Message = table.concat(Args, " ")
    local Bypassed = Bypass(Message)
    Chat(Bypassed)
end)

local function Decode(Tbl)
    local Msg = ""
    for _, Letter in Tbl do
        Msg ..= string.char(Letter)
    end
    return Msg
end

local Messages = {
	{74, 79, 73, 78, 32, 84, 79, 32, 66, 89, 80, 65, 83, 83, 32, 78, 73, 71, 71, 69, 82},
	{82, 69, 76, 73, 69, 70, 32, 79, 78, 32, 84, 79, 80, 32, 78, 73, 71, 71, 65},
	{73, 77, 32, 71, 79, 78, 78, 65, 32, 82, 65, 80, 69, 32, 85, 32, 65, 76, 76},
	{74, 79, 73, 78, 32, 79, 82, 32, 73, 76, 76, 32, 65, 77, 80, 85, 84, 65, 84, 69, 32, 85, 82, 32, 76, 73, 77, 66, 83, 32, 70, 65, 71, 71, 79, 84},
	{74, 69, 83, 85, 83, 32, 73, 83, 32, 75, 73, 78, 71},
	{74, 79, 73, 78, 32, 84, 72, 69, 32, 70, 85, 67, 75, 73, 78, 71, 32, 83, 69, 82, 86, 69, 82},
	{73, 77, 32, 65, 32, 80, 69, 68, 79, 80, 72, 73, 76, 69},
	{78, 73, 71, 71, 65, 83, 32, 67, 65, 78, 84, 32, 66, 65, 78, 32, 77, 69},
	{73, 77, 32, 65, 32, 66, 79, 84, 32, 78, 73, 71, 71, 65},
}

local Invite = "discord . gg/msFnMfhuhV"
Relief.deleteModule("Advertise")
Relief.addModule("Utility", "Advertise", function(Toggled)
    if Toggled then
        Thread:New("Advertise", function()
            for _, Message in Messages do
                if not Relief.isToggled("Advertise") then break end
        		Chat("<font color='#0F0' size='40'><b>"..Bypass(Invite .. " | " .. Decode(Message))..'</b></font>')
        		task.wait(5.3)
        	end
        end)
    else
        Thread:Disconnect("Advertise")
    end
end)
