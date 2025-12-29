-- Relief Lib

local Relief = getgenv().Relief
if not Relief then return end

-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables & Functions

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
