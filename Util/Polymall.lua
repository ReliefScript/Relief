local Polymall = {}

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:FindFirstChild("BloxbizRemotes")
if not Remotes then return end

local LocalPlayer = Players.LocalPlayer
local Apply = Remotes.CatalogOnApplyToRealHumanoid

local AccessoryTypes = {
  	[1] = Enum.AccessoryType.Unknown,
  	[8] = Enum.AccessoryType.Hat,
  	[19] = Enum.AccessoryType.Eyebrow,
  	[20] = Enum.AccessoryType.Eyelash,
  	[41] = Enum.AccessoryType.Hair,
  	[42] = Enum.AccessoryType.Face,
  	[43] = Enum.AccessoryType.Neck,
  	[44] = Enum.AccessoryType.Shoulder,
  	[45] = Enum.AccessoryType.Front,
  	[46] = Enum.AccessoryType.Back,
  	[47] = Enum.AccessoryType.Waist,
  	[64] = Enum.AccessoryType.TShirt,
  	[65] = Enum.AccessoryType.Shirt,
  	[66] = Enum.AccessoryType.Pants,
  	[67] = Enum.AccessoryType.Jacket,
  	[68] = Enum.AccessoryType.Sweater,
  	[69] = Enum.AccessoryType.Shorts,
  	[70] = Enum.AccessoryType.LeftShoe,
  	[71] = Enum.AccessoryType.RightShoe,
  	[72] = Enum.AccessoryType.DressSkirt,
}

local function EnumCheck(Name, Query)
	local List = Enum[Name]
	for _, Item in List:GetEnumItems() do
		if Item == Query then
			return 1
		end
	end
end

local LayeredEnums = {
    Enum.AccessoryType.TShirt,
    Enum.AccessoryType.Shirt,
    Enum.AccessoryType.Pants,
    Enum.AccessoryType.Jacket,
    Enum.AccessoryType.Sweater,
    Enum.AccessoryType.Shorts,
    Enum.AccessoryType.LeftShoe,
    Enum.AccessoryType.RightShoe,
    Enum.AccessoryType.DressSkirt,
}

local function IsLayered(Query)
    if type(Query) == "number" then
      	if Query >= 64 and Query <= 72 then
      		return 1
      	end
    elseif type(Query) == EnumCheck("AccessoryType", Query) then
        if table.find(LayeredEnums, Query) then
            return 1
        end
    end
end

-- Create avatar from scratch
Polymall.Outfit = {}
Polymall.Outfit.__index = Polymall.Outfit

function Polymall.Outfit:New()
  	local self = setmetatable({}, Polymall.Outfit)
    
  	self.Accessories = {}
  	self.Colors = {}
  	self.Scales = {}
    self.Animations = {}
    self.Meshes = {}
    self.Face = 0
    self.Shirt = 0
    self.Pants = 0
    self.TShirt = 0
    
  	return self
end

function Polymall.Outfit:HasHat(Id)
    for _, Accessory in self.Accessories do
        if Accessory.AssetId == Id then
            return Accessory, _
        end
    end
end

function Polymall.Outfit:Add(Id)
  	if not Id or type(Id) ~= "number" then return end
    if self:HasHat(Id) then return end
  
  	local Success, Info = pcall(function()
        return MarketplaceService:GetProductInfoAsync(Id)
  	end)
  
  	if not Success then return end
  
  	table.insert(self.Accessories, {
        AssetId = Id,
        AccessoryType = AccessoryTypes[Info.AssetTypeId],
        IsLayered = IsLayered(Info.AssetTypeId),
        Order = 1
  	})
end

function Polymall.Outfit:Remove(Id)
    if not Id or type(Id) ~= "number" then return end

    local Accessory, Index = self:HasHat(Id)
    if Accessory and Index then
        table.remove(self.Accessories, Index)
    end
end

local function UnpackProperties(Table, Properties, Data, Value)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local Description = Humanoid and Humanoid:FindFirstChildOfClass("HumanoidDescription")
    
    for _, Property in Properties do
        if Data == "All" then
            Table[Property] = Value
            continue
        end

        Table[Property] = Data[Property]
		or Table[Property]
		or (Description and Description[Property])
		or 0
    end
end

function Polymall.Outfit:Scale(Data, Value)
    if not Data then return end

    UnpackProperties(
        self.Scales,
        {"BodyTypeScale", "WidthScale", "ProportionScale", "HeadScale", "HeightScale", "DepthScale"},
        Data,
        Value
    )
end

function Polymall.Outfit:Color(Data, Value)
    if not Data then return end

    UnpackProperties(
        self.Colors,
        {"HeadColor", "LeftArmColor", "LeftLegColor", "RightArmColor", "RightLegColor", "TorsoColor"},
        Data,
        Value
    )
end

function Polymall.Outfit:Animate(Data, Value)
    if not Data then return end

    UnpackProperties(
        self.Animations,
        {"ClimbAnimation", "FallAnimation", "IdleAnimation", "JumpAnimation", "MoodAnimation", "RunAnimation", "SwimAnimation", "WalkAnimation"},
        Data,
        Value
    )
end

function Polymall.Outfit:SetMesh(Data, Value)
    if not Data then return end

    UnpackProperties(
        self.Meshes,
        {"Head", "LeftArm", "LeftLeg", "RightArm", "RightLeg", "Torso"},
        Data,
        Value
    )
end

function Polymall.Outfit:SetFace(Id)
    if not Id or not type(Id) == "number" then return end

    self.Face = Id
end

function Polymall.Outfit:SetShirt(Id)
    if not Id or not type(Id) == "number" then return end

    self.Shirt = Id
end

function Polymall.Outfit:SetPants(Id)
    if not Id or not type(Id) == "number" then return end

    self.Pants = Id
end

function Polymall.Outfit:SetTShirt(Id)
    if not Id or not type(Id) == "number" then return end

    self.TShirt = Id
end

function Polymall.Outfit:Copy(Target)
    if not Target:IsA("Player") then return end
    
    local Character = Target.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    local Description = Humanoid:FindFirstChildOfClass("HumanoidDescription")
    if not Description then return end

    local Accessories = {}

    for _, Accessory in Description:GetAccessories(true) do
        table.insert(Accessories, {
			AssetId = Accessory.AssetId,
			AccessoryType = Accessory.AccessoryType,
			IsLayered = IsLayered(Accessory.AccessoryType),
			Order = 1
		})
    end
    
    self.Accessories = Accessories

    local function Dump(Name, Properties)
        for _, Property in Properties do
            self[Name][Property] = Description[Property]
        end
    end

    Dump("Colors", {"HeadColor", "LeftArmColor", "LeftLegColor", "RightArmColor", "RightLegColor", "TorsoColor"})
  	Dump("Scales", {"BodyTypeScale", "DepthScale", "HeadScale", "HeightScale", "ProportionScale", "WidthScale"})
    Dump("Animations", {"ClimbAnimation", "FallAnimation", "IdleAnimation", "JumpAnimation", "MoodAnimation", "RunAnimation", "SwimAnimation", "WalkAnimation"})
    Dump("Meshes", {"Head", "LeftArm", "LeftLeg", "RightArm", "RightLeg", "Torso"})
    
    self.Face = Description.Face
    self.Shirt = Description.Shirt
    self.Pants = Description.Pants
    self.TShirt = Description.GraphicTShirt
end

function Polymall.Outfit:Load()
  	local Data = {}

	local function Dump(Table)
		for Name, Value in Table do
			Data[Name] = Value
		end
	end
  
  	Data.Accessories = self.Accessories
    Data.Face = self.Face
    Data.Shirt = self.Shirt
    Data.Pants = self.Pants
    Data.GraphicTShirt = self.TShirt
    
    Dump(self.Scales)
    Dump(self.Colors)
    Dump(self.Animations)
    Dump(self.Meshes)
  
  	Remotes.CatalogOnApplyOutfit:FireServer(Data)
end

-- Applies to current avatar
function Polymall:Equip(Id, Type)
    if not Id or not type(Id) == "number" then return end
    
    local Success, Info = pcall(function()
		return MarketplaceService:GetProductInfo(Id)
	end)

    if not Success then return end

    local Accessory = {
        AccessoryData = {
            AccessoryType = AccessoryTypes[Info.AssetTypeId],
            AssetId = Id,
            Order = 0
        }
    }
    
    if Type and tostring(Type) == "string" then
        Accessory.Property = Type
    end

    Apply:FireServer(Accessory)
end

function Polymall:Unequip(Id, Type)
    if not Id or not type(Id) == "number" then return end
    
    if Type and type(Type) == "string" then
		Apply:FireServer({Property = Type, AssetId = Id})
	else
		Apply:FireServer({AssetId = Id})
	end
end

function Polymall:Reset()
    Remotes.CatalogOnResetOutfit:FireServer()
end

function Polymall:Color(Color)
    if not typeof(Color) == "Color3" then return end
    
    Apply:FireServer({BodyColor = Color})
end

function Polymall:Scale(Data, Value)
    if not Data then return end

    if Data == "All" and type(Value) == "number" then
        Apply:FireServer({
    		BodyScale = {
    			HeadScale = Value,
    			WidthScale = Value,
    			HeightScale = Value,
    			BodyTypeScale = Value,
    			ProportionScale = Value,
    		}
    	})
    elseif type(Data) == "table" then
        Apply:FireServer(Data)
    end
end

return Polymall
