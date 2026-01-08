local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

repeat task.wait() until Players.LocalPlayer

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local CA = LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = Character:WaitForChild("Humanoid")
end)

local AnimSocket = {}

function AnimSocket.Connect(Channel)
    local Complete = {}
    local ConnectionStart = math.floor(os.clock() * 10000)

    local Socket = {
        Send = function(self, Message) 
            -- The first part of the payload is the Timestamp ID
            local Payload = string.format("rbxassetid://%s\255%s\255%s", math.floor(os.clock() * 10000), Channel, Message)

            local Animation = Instance.new("Animation")
            Animation.AnimationId = Payload

            local AnimationTrack = Humanoid:LoadAnimation(Animation)
            AnimationTrack:Play()
            AnimationTrack:Stop()
            
            AnimationTrack:Destroy()
            Animation:Destroy()
        end,
        OnMessage = {
            Connections = {},
            Connect = function(self, f)
                table.insert(self.Connections, f)
            end,
            Fire = function(self, ...)
                for _, f in pairs(self.Connections) do
                    f(...)
                end
            end
        },
        OnClose = function() end
    }

    local C = RunService.RenderStepped:Connect(function()
        for _, Player in pairs(Players:GetPlayers()) do
            pcall(function()
                local Char = Player.Character
                local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
                if not Hum then return end

                for _, Animation in pairs(Hum:GetPlayingAnimationTracks()) do
                    local AnimId = Animation.Animation.AnimationId
                    if not AnimId or #AnimId < 14 then continue end

                    local DataStr = string.sub(AnimId, 14, -1)
                    local Data = string.split(DataStr, "\255")
                    
                    local MsgID = tonumber(Data[1])

                    if MsgID and MsgID < ConnectionStart then
                        continue 
                    end

                    if not Complete[Data[1]] then
                        Complete[Data[1]] = true

                        if Data[2] == Channel then
                            local Source, Error = pcall(function()
                                for i = 1, 2 do
                                    table.remove(Data, 1)
                                end
                                Socket.OnMessage:Fire(Player, table.concat(Data, "\255"))
                            end)

                            if not Source then
                                warn(Error)
                            end
                        end
                    end
                end
            end)
        end
    end)

    function Socket:Close()
        C:Disconnect()
		CA:Disconnect()
        Socket:OnClose()
    end

    return Socket
end

return AnimSocket
