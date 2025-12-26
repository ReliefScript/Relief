local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Recolorable = {}
local Connections = {}
local Library = {}

Library.Keybinds = {Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt}
Library.CommandBarBinds = {Enum.KeyCode.LeftBracket}

local ThemeColor = Color3.fromRGB(75, 156, 255)

local Screen = Instance.new("ScreenGui")
Screen.Parent = CoreGui
Screen.IgnoreGuiInset = true
Screen.DisplayOrder = 1e5
Screen.Name = "Relief"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Holder = Instance.new("Frame")
Holder.Parent = Screen
Holder.BackgroundTransparency = 0
Holder.BackgroundColor3 = Color3.new(0, 0, 0)
Holder.Size = UDim2.new(1, 0, 0.05, 0)
Holder.AnchorPoint = Vector2.new(0, 1)
Holder.Position = UDim2.new(0, 0, 0, -3)

local CommandBar = Instance.new("TextBox")
CommandBar.Parent = Holder
CommandBar.Size = UDim2.new(1, 0, 1, 0)
CommandBar.BackgroundTransparency = 1
CommandBar.TextScaled = true
CommandBar.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
CommandBar.TextColor3 = Color3.new(1, 1, 1)
CommandBar.TextXAlignment = Enum.TextXAlignment.Left
CommandBar.Text = ""
CommandBar.PlaceholderText = "cmd here"
CommandBar.ZIndex = 3

local AutoComplete = Instance.new("TextLabel")
AutoComplete.Parent = CommandBar
AutoComplete.Size = UDim2.new(1, 0, 1, 0)
AutoComplete.BackgroundTransparency = 1
AutoComplete.TextScaled = true
AutoComplete.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
AutoComplete.TextColor3 = Color3.new(1, 1, 1)
AutoComplete.TextXAlignment = Enum.TextXAlignment.Left
AutoComplete.Text = ""
AutoComplete.ZIndex = 2
AutoComplete.TextTransparency = 0.5

local CommandSeparator = Instance.new("Frame")
CommandSeparator.Parent = Holder
CommandSeparator.Size = UDim2.new(1, 0, 0, 2)
CommandSeparator.Position = UDim2.new(0, 0, 1, 1)
CommandSeparator.BackgroundColor3 = ThemeColor
CommandSeparator.BorderSizePixel = 0
table.insert(Recolorable, CommandSeparator)

local CommandBarPadding = Instance.new("UIPadding")
CommandBarPadding.Parent = CommandBar
CommandBarPadding.PaddingTop = UDim.new(0.2, 0)
CommandBarPadding.PaddingBottom = UDim.new(0.2, 0)
CommandBarPadding.PaddingLeft = UDim.new(0.01, 0)

local Arrow = Instance.new("ImageButton")
Arrow.Parent = Holder
Arrow.BackgroundTransparency = 1
Arrow.AnchorPoint = Vector2.new(0.5, 0)
Arrow.Position = UDim2.new(0.5, 0, 1, 0)
Arrow.Image = "rbxassetid://16844851226"
Arrow.Size = UDim2.new(1, 0, 1, 0)
Arrow.Rotation = 180

local ArrowRatio = Instance.new("UIAspectRatioConstraint")
ArrowRatio.Parent = Arrow

local ClickGui = Instance.new("Frame")
ClickGui.Parent = Screen
ClickGui.ZIndex = 0
ClickGui.BorderSizePixel = 0
ClickGui.BackgroundColor3 = Color3.new(0, 0, 0)
ClickGui.AnchorPoint = Vector2.new(0.5, 0.5)
ClickGui.BackgroundTransparency = 0.75
ClickGui.Size = UDim2.new(1, 0, 1, 0)
ClickGui.Position = UDim2.new(0.5, 0, 0.5, 0)
ClickGui.Name = "ClickGui"

local Watermark = Instance.new("ImageLabel")
Watermark.Parent = ClickGui
Watermark.ImageTransparency = 0.5
Watermark.AnchorPoint = Vector2.new(0.5, 0.5)
Watermark.Image = "rbxassetid://17640797571"
Watermark.Size = UDim2.new(0.1278, 0, 0.7186, 0)
Watermark.Name = "Watermark"
Watermark.BackgroundTransparency = 1
Watermark.Position = UDim2.new(0.0639, 0, 0.933, 0)

local Module = Instance.new("Frame")
Module.BorderSizePixel = 0
Module.BackgroundTransparency = 1
Module.Size = UDim2.new(1, 0, 0.07, 0)
Module.Name = "Module"

local ModuleTitle = Instance.new("TextLabel")
ModuleTitle.Parent = Module
ModuleTitle.TextScaled = true
ModuleTitle.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
ModuleTitle.TextColor3 = Color3.new(1, 1, 1)
ModuleTitle.Size = UDim2.new(1, 0, 1, 0)
ModuleTitle.Name = "Title"
ModuleTitle.BackgroundTransparency = 1

local TitlePadding = Instance.new("UIPadding")
TitlePadding.Parent = ModuleTitle
TitlePadding.PaddingTop = UDim.new(0.25, 0)
TitlePadding.PaddingRight = UDim.new(0.1, 0)
TitlePadding.PaddingBottom = UDim.new(0.25, 0)
TitlePadding.PaddingLeft = UDim.new(0.1, 0)

local ModuleExpand = Instance.new("ImageLabel")
ModuleExpand.Parent = Module
ModuleExpand.Image = "rbxassetid://11552476728"
ModuleExpand.Size = UDim2.new(0.14244, 0, 0.74, 0)
ModuleExpand.Name = "Expand"
ModuleExpand.Rotation = -90
ModuleExpand.BackgroundTransparency = 1
ModuleExpand.Position = UDim2.new(0.85, 0, 0.13, 0)

local ExpandRatio = Instance.new("UIAspectRatioConstraint")
ExpandRatio.Parent = ModuleExpand

local Settings = Instance.new("CanvasGroup")
Settings.BackgroundTransparency = 1
Settings.Size = UDim2.new(1, 0, 0.3, 0)
Settings.Name = "Settings"

local SF = Instance.new("Frame")
SF.Parent = Settings
SF.ZIndex = 4
SF.BorderSizePixel = 0
SF.BackgroundColor3 = Color3.new(0, 0, 0)
SF.BackgroundTransparency = 0.4
SF.Size = UDim2.new(1, 0, 1, 0)
SF.Position = UDim2.new(0, 0, 0, 0)
SF.Name = "dacontainer"

local Settings_SF = Instance.new("ScrollingFrame")
Settings_SF.Parent = SF
Settings_SF.ZIndex = 4
Settings_SF.BackgroundTransparency = 1
Settings_SF.Size = UDim2.new(1, 0, 0.8, 0)
Settings_SF.Position = UDim2.new(0, 0, 0.1, 0)
Settings_SF.ScrollBarImageColor3 = Color3.new(0, 0, 0)
Settings_SF.BorderColor3 = Color3.fromRGB(0, 0, 0)
Settings_SF.Name = "SF"
Settings_SF.AutomaticCanvasSize = Enum.AutomaticSize.Y
Settings_SF.CanvasSize = UDim2.new(0, 0, 0, 0)

local Layout = Instance.new("UIListLayout")
Layout.Parent = Settings_SF
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Padding = UDim.new(0, 5)

local SettingsSeparator = Instance.new("Frame")
SettingsSeparator.Parent = Settings
SettingsSeparator.ZIndex = 5
SettingsSeparator.BorderSizePixel = 0
SettingsSeparator.BackgroundColor3 = Color3.fromRGB(75, 156, 255)
SettingsSeparator.Size = UDim2.new(0, 4, 1, 0)
SettingsSeparator.Name = "Separator"

local Category = Instance.new("Frame")
Category.AnchorPoint = Vector2.new(0.5, 0.5)
Category.BackgroundTransparency = 1
Category.Size = UDim2.new(0.093, 0, 0.5279, 0)
Category.Position = UDim2.new(0.25, 0, 0.5, 0)
Category.Name = "Category"

local CategorySeparator = Instance.new("Frame")
CategorySeparator.Parent = Category
CategorySeparator.ZIndex = 2
CategorySeparator.BorderSizePixel = 0
CategorySeparator.BackgroundColor3 = Color3.fromRGB(75, 156, 255)
CategorySeparator.Size = UDim2.new(1, 0, 0, 2)
CategorySeparator.Position = UDim2.new(0, 0, 0.067, 0)
CategorySeparator.Name = "Separator"

local ModulesFix = Instance.new("CanvasGroup")
ModulesFix.Parent = Category
ModulesFix.GroupTransparency = 0.3
ModulesFix.BackgroundTransparency = 1
ModulesFix.Size = UDim2.new(1, 0, 0.929, 0)
ModulesFix.Position = UDim2.new(0, 0, 0.071, 0)
ModulesFix.Name = "modulesFix"

local Fix = Instance.new("Frame")
Fix.Parent = ModulesFix
Fix.BorderSizePixel = 0
Fix.BackgroundColor3 = Color3.new(0, 0, 0)
Fix.Size = UDim2.new(1, 0, 0.06, 0)
Fix.BorderColor3 = Color3.new(0, 0, 0)
Fix.Position = UDim2.new(0, 0, 0, 0)
Fix.Name = "Fix"
Fix.BackgroundTransparency = 0

local Modules = Instance.new("Frame")
Modules.Parent = ModulesFix
Modules.BorderSizePixel = 0
Modules.BackgroundColor3 = Color3.new(0, 0, 0)
Modules.Size = UDim2.new(1, 0, 1, 0)
Modules.Name = "Modules"
Modules.BackgroundTransparency = 0

local ModulesCorner = Instance.new("UICorner")
ModulesCorner.Parent = Modules
ModulesCorner.CornerRadius = UDim.new(0.05, 0)

local TabFix = Instance.new("CanvasGroup")
TabFix.Parent = Category
TabFix.GroupTransparency = 0.15
TabFix.BackgroundTransparency = 1;
TabFix.Size = UDim2.new(1, 0, 0.068, 0)
TabFix.Name = "tabFix"

local TabFrame = Instance.new("Frame")
TabFrame.Parent = TabFix
TabFrame.BorderSizePixel = 0
TabFrame.BackgroundColor3 = Color3.new(0, 0, 0)
TabFrame.Size = UDim2.new(1, 0, 1, 0)
TabFrame.Name = "Tab"

local TabCorner = Instance.new("UICorner")
TabCorner.Parent = TabFrame
TabCorner.CornerRadius = UDim.new(0.15, 0)

local Fix = Instance.new("Frame")
Fix.Parent = TabFix
Fix.ZIndex = 0
Fix.BorderSizePixel = 0
Fix.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Fix.AnchorPoint = Vector2.new(0.5, 0.5)
Fix.Size = UDim2.new(1, 0, 0.5765, 0)
Fix.Position = UDim2.new(0.5, 0, 0.7559, 0)
Fix.Name = "Fix"

local Tab = Instance.new("Frame")
Tab.Parent = Category
Tab.BackgroundTransparency = 1
Tab.Size = UDim2.new(1, 0, 0.0712, 0)
Tab.Name = "Tab"

local TabTitle = Instance.new("TextLabel")
TabTitle.Parent = Tab
TabTitle.TextScaled = true
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
TabTitle.TextColor3 = Color3.new(1, 1, 1)
TabTitle.Size = UDim2.new(1, 0, 1, 0)
TabTitle.Name = "Title"
TabTitle.BackgroundTransparency = 1

local TitlePadding = Instance.new("UIPadding")
TitlePadding.Parent = TabTitle
TitlePadding.PaddingTop = UDim.new(0.25, 0)
TitlePadding.PaddingBottom = UDim.new(0.25, 0)
TitlePadding.PaddingLeft = UDim.new(0.25, 0)

local Expand = Instance.new("TextLabel")
Expand.Parent = Tab
Expand.TextScaled = true
Expand.Font = Enum.Font.Merriweather
Expand.TextColor3 = Color3.new(1, 1, 1)
Expand.AnchorPoint = Vector2.new(0.5, 0.5)
Expand.Size = UDim2.new(0.1738, 0, 1, 0)
Expand.Text = "-"
Expand.Name = "Expand"
Expand.BackgroundTransparency = 1
Expand.Position = UDim2.new(0.912, 0, 0.5, 0)

local TabIcon = Instance.new("ImageLabel")
TabIcon.Parent = Tab
TabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
TabIcon.Image = "rbxassetid://7485051715"
TabIcon.Size = UDim2.new(0.1222, 0, 0.6912, 0)
TabIcon.Name = "Icon"
TabIcon.BackgroundTransparency = 1
TabIcon.Position = UDim2.new(0.132, 0, 0.5, 0)

local IconRatio = Instance.new("UIAspectRatioConstraint")
IconRatio.Parent = TabIcon

local TabCorner = Instance.new("UICorner")
TabCorner.Parent = Tab
TabCorner.CornerRadius = UDim.new(0.15, 0)

local CategoryModules = Instance.new("Frame")
CategoryModules.Parent = Category
CategoryModules.BackgroundTransparency = 1
CategoryModules.Size = UDim2.new(1, 0, 0.929, 0)
CategoryModules.Position = UDim2.new(0, 0, 0.0712, 0)
CategoryModules.Name = "Modules"

local ModulesCorner = Instance.new("UICorner")
ModulesCorner.Parent = CategoryModules
ModulesCorner.CornerRadius = UDim.new(0.05, 0)

local ModuleLayout = Instance.new("UIListLayout")
ModuleLayout.Parent = CategoryModules
ModuleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local List = Instance.new("Frame")
List.BackgroundTransparency = 1
List.Size = UDim2.new(0.5466, 0, 0.03, 0)
List.Position = UDim2.new(0.4534, 0, 0.97, 0)
List.Name = "List"

local ListBar = Instance.new("Frame")
ListBar.Parent = List
ListBar.BorderSizePixel = 0
ListBar.BackgroundColor3 = Color3.fromRGB(75, 156, 255)
ListBar.Size = UDim2.new(0, 4, 1, 0)
ListBar.BorderColor3 = Color3.new(0, 0, 0)
ListBar.Name = "Bar"

local ListTitle = Instance.new("TextLabel")
ListTitle.Parent = List
ListTitle.BorderSizePixel = 0
ListTitle.TextScaled = true
ListTitle.BackgroundColor3 = Color3.new(0, 0, 0)
ListTitle.Font = Enum.Font.Ubuntu
ListTitle.TextColor3 = Color3.new(1, 1, 1)
ListTitle.Size = UDim2.new(0.985, 0, 1, 0)
ListTitle.BorderColor3 = Color3.new(0, 0, 0)
ListTitle.Name = "Title"
ListTitle.BackgroundTransparency = 0.4
ListTitle.Position = UDim2.new(0, 4, 0, 0)
ListTitle.TextXAlignment = Enum.TextXAlignment.Right

local TitlePadding = Instance.new("UIPadding")
TitlePadding.Parent = ListTitle
TitlePadding.PaddingTop = UDim.new(0, 2)
TitlePadding.PaddingRight = UDim.new(0, 4)
TitlePadding.PaddingBottom = UDim.new(0, 2)
TitlePadding.PaddingLeft = UDim.new(0, 0)

local Hud = Instance.new("Frame")
Hud.Parent = Screen
Hud.BackgroundTransparency = 1
Hud.Size = UDim2.new(1, 0, 1, 0)
Hud.Name = "Hud"

local WatermarkRatio = Instance.new("UIAspectRatioConstraint")
WatermarkRatio.Parent = Watermark
WatermarkRatio.AspectRatio = 1.4451

local ModuleList = Instance.new("Frame")
ModuleList.Parent = Hud
ModuleList.BackgroundTransparency = 1;
ModuleList.Size = UDim2.new(0.1, 0, 1, 0);
ModuleList.Position = UDim2.new(0.9, 0, 0, 0);
ModuleList.Name = "ModuleList"

local ModuleListLayout = Instance.new("UIListLayout")
ModuleListLayout.Parent = ModuleList
ModuleListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ModuleListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local MobileButton = Instance.new("TextButton")
MobileButton.Parent = Screen
MobileButton.BorderSizePixel = 0;
MobileButton.AutoButtonColor = false
MobileButton.TextScaled = true
MobileButton.BackgroundColor3 = Color3.new(0, 0, 0)
MobileButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
MobileButton.TextColor3 = ThemeColor
MobileButton.Size = UDim2.new(0.0314, 0, 0.0714, 0)
MobileButton.Name = "MobileButton"
MobileButton.BorderColor3 = Color3.new(0, 0, 0)
MobileButton.Text = "-"
MobileButton.Position = UDim2.new(0.5, 0, 0.15, 0)
MobileButton.AnchorPoint = Vector2.new(0.5, 0.5)
MobileButton.BackgroundTransparency = 0.2
table.insert(Recolorable, MobileButton)

local MobileRatio = Instance.new("UIAspectRatioConstraint")
MobileRatio.Parent = MobileButton

local MobileCorner = Instance.new("UICorner")
MobileCorner.Parent = MobileButton
MobileCorner.CornerRadius = UDim.new(0.25, 0)

local Blur = Instance.new("BlurEffect")
Blur.Name = "ReliefBlur"
Blur.Enabled = true
Blur.Parent = Lighting
Blur.Size = 15

MobileButton.MouseButton1Down:Connect(function()
	ClickGui.Visible = not ClickGui.Visible
	Blur.Enabled = ClickGui.Visible
	if ClickGui.Visible then
		MobileButton.TextColor3 = Color3.fromRGB(74, 155, 255)
		MobileButton.Text = "-"
	else
		MobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		MobileButton.Text = "+"
	end
end)

Connections[#Connections + 1] = UserInputService.InputBegan:Connect(function(Input, GPE)
	if GPE then return end
	if table.find(Library.Keybinds, Input.KeyCode) then
		ClickGui.Visible = not ClickGui.Visible
		Blur.Enabled = ClickGui.Visible
		if ClickGui.Visible then
			MobileButton.TextColor3 = Color3.fromRGB(74, 155, 255)
			MobileButton.Text = "-"
		else
			MobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			MobileButton.Text = "+"
		end
	end
end)

local Categories = {}

local function Dragify(Category)
	if not Category:IsA("Frame") then return end

	local Tab = Category.Tab
	local Expand = Tab.Expand
	local Modules = Category.Modules
	local moduleFix = Category.modulesFix.Modules
	local fix = Category.modulesFix.Fix

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local originalSize = Modules.Size
	local originalSize2 = moduleFix.Size
	local originalSize3 = fix.Size
	local isExpanded = true

	local lastMousePosition
	local lastUpdateTime

	local function update(input)
		local currentTime = tick()
		local delta = input.Position - dragStart
		local goalPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

		local speed = 0
		if lastMousePosition and lastUpdateTime then
			local timeDelta = currentTime - lastUpdateTime
			local positionDelta = (input.Position - lastMousePosition).Magnitude
			speed = positionDelta / timeDelta
		end

		local rotationDirection = 1
		if lastMousePosition.X < input.Position.X then
			rotationDirection = 1
		elseif lastMousePosition.X > input.Position.X then
			rotationDirection = -1
		end

		lastMousePosition = input.Position
		lastUpdateTime = currentTime

		local rotationAngle = speed * 0.003 * rotationDirection

		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local positionTween = TweenService:Create(Category, tweenInfo, {Position = goalPosition})
		local rotationTween = TweenService:Create(Category, tweenInfo, {Rotation = rotationAngle})

		positionTween:Play()
		rotationTween:Play()
	end

	Connections[#Connections + 1] = Tab.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Category.Position

			lastMousePosition = input.Position
			lastUpdateTime = tick()

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false

					local rotationTween = TweenService:Create(Category, TweenInfo.new(0.3), {Rotation = 0})
					rotationTween:Play()
				end
			end)
		end
	end)

	Connections[#Connections + 1] = Tab.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	Connections[#Connections + 1] = UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)

	Connections[#Connections + 1] = Expand.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local goalSize, goalSize2, goalSize3
			if isExpanded then
				goalSize = UDim2.new(Modules.Size.X.Scale, Modules.Size.X.Offset, 0, 0)
				goalSize2 = UDim2.new(moduleFix.Size.X.Scale, moduleFix.Size.X.Offset, 0, 0)
				goalSize3 = UDim2.new(fix.Size.X.Scale, fix.Size.X.Offset, 0, 0)
				Expand.Text = "+"
				
				for _, Module in Modules:GetChildren() do
					if Module:IsA("Frame") then
						TweenService:Create(Module.Title, tweenInfo, {TextTransparency = 1}):Play()
					end
				end
			else
				goalSize = originalSize
				goalSize2 = originalSize2
				goalSize3 = originalSize3
				Expand.Text = "-"
				
				for _, Module in Modules:GetChildren() do
					if Module:IsA("Frame") then
						TweenService:Create(Module.Title, tweenInfo, {TextTransparency = 0}):Play()
					end
				end
			end

			TweenService:Create(Modules, tweenInfo, {Size = goalSize}):Play()
			TweenService:Create(moduleFix, tweenInfo, {Size = goalSize2}):Play()
			TweenService:Create(fix, tweenInfo, {Size = goalSize3}):Play()

			isExpanded = not isExpanded
		end
	end)
end

local function repositionCategories()
	for i, CategoryInfo in ipairs(Categories) do
		local NewPosition = UDim2.new(i / (#Categories + 1), 0, 0.5, 0)
		CategoryInfo["UI"].Position = NewPosition
	end
end

Library.addCategory = function(Name, Icon)
	local NewCategory = Category:Clone()
	NewCategory.Separator.BackgroundColor3 = ThemeColor
	table.insert(Recolorable, NewCategory.Separator)
	
	local Tab = NewCategory.Tab
	local Modules = NewCategory.Modules
	local Title = Tab.Title
	local IconElement = Tab.Icon

	Title.Text = Name
	IconElement.Image = Icon
	NewCategory.Name = Name

	NewCategory.Parent = ClickGui

	local CategoryInfo = {
		["Name"] = Name,
		["Icon"] = Icon,
		["Modules"] = {},
		["UI"] = NewCategory
	}
	Categories[#Categories + 1] = CategoryInfo

	repositionCategories()
	Dragify(NewCategory)
end

Library.getCategory = function(Category)
	for _, CategoryInfo in Categories do
		if CategoryInfo["Name"] == Category then
			return CategoryInfo
		end
	end
end

Library.renderModules = function()
	for _, Frame in ModuleList:GetChildren() do
		if Frame:IsA("Frame") then
			Frame:Destroy()
		end
	end

	local ActiveModules = {}
	for _, Category in ipairs(Categories) do
		for _, Module in ipairs(Category.Modules) do
			if Module.Toggle then
				local textSize = TextService:GetTextSize(
					Module.Name,
					20,
					Enum.Font.Ubuntu,
					Vector2.new(math.huge, 20)
				)
				table.insert(ActiveModules, {
					Module = Module,
					Width = textSize.X + 15
				})
			end
		end
	end

	table.sort(ActiveModules, function(a, b)
		return a.Width < b.Width
	end)

	for _, item in ipairs(ActiveModules) do
		local NewList = List:Clone()
		NewList.Bar.BackgroundColor3 = ThemeColor
		table.insert(Recolorable, NewList.Bar)
		
		NewList.Parent = ModuleList
		NewList.Title.Text = item.Module.Name
		NewList.Title.TextSize = 20
		NewList.Size = UDim2.new(0, item.Width, 0, 25)
		NewList.Visible = true
	end
end

Library.addModule = function(Category, Name, Callback, SettingConfig, KeyBind, Default)
	local CategoryInfo = Library.getCategory(Category)
	local CategoryUI = CategoryInfo["UI"]
	local Modules = CategoryUI.Modules

	local NewModule = Module:Clone()
	local Expand = NewModule.Expand
	local Title = NewModule.Title
	local NewSettings = Settings:Clone()
	table.insert(Recolorable, NewSettings.Separator)
	
	local Settings = NewSettings.dacontainer
	local Separator = NewSettings.Separator
	
	NewModule.Name = "Module" .. #CategoryInfo["Modules"]
	NewModule.Parent = Modules
	Title.Text = Name

	local TInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	table.insert(Recolorable, Title)

	local Tree = {
		["Name"] = Name,
		["Callback"] = Callback,
		["Env"] = {},
		["Toggle"] = false,
		["Keybind"] = KeyBind or nil,
		["UI"] = NewModule,
		["Default"] = Default,
		["Settings"] = {},
	}

	Tree["ToggleFunction"] = function(isLoading)
		Tree.Toggle = not Tree.Toggle
		Callback(Tree.Toggle)
		Library.renderModules()
		if Tree.Toggle then
			TweenService:Create(Title, TInfo, { TextColor3 = ThemeColor }):Play()
		else
			TweenService:Create(Title, TInfo, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end
		if Library.SaveName and not Library.Killed and not isLoading then Library.Save(Library.SaveName) end
	end
	
	local SettingToggle = false
	
	if Default then
		Tree.ToggleFunction(1)
	end
	
	Connections[#Connections + 1] = UserInputService.InputBegan:Connect(function(Input, GPE)
		if GPE or not Tree.Keybind then return end
		if Input.KeyCode == Tree.Keybind then
			Tree.ToggleFunction()
		end
	end)

	local isSettings = not SettingConfig or #SettingConfig == 0
	if isSettings then
		Expand.Visible = false
	end

	Connections[#Connections + 1] = NewModule.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 and not isSettings then
			SettingToggle = not SettingToggle
			Settings.Visible = SettingToggle
			Separator.Visible = SettingToggle
			if SettingToggle then
				NewSettings.Parent = Modules
				NewSettings.Name = NewModule.Name .. "a"
				Expand.Rotation = 0
			else
				NewSettings.Parent = nil
				Expand.Rotation = -90
			end
		end
		
		if Tree.Toggle then
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				TweenService:Create(Title, TInfo, { TextColor3 = ThemeColor }):Play()
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Tree.ToggleFunction()
			end
		else
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				TweenService:Create(Title, TInfo, { TextColor3 = ThemeColor }):Play()
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Tree.ToggleFunction()
			end
		end
	end)

	Connections[#Connections + 1] = NewModule.InputEnded:Connect(function(input)
		if not Tree.Toggle and input.UserInputType == Enum.UserInputType.MouseMovement then
			TweenService:Create(Title, TInfo, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end
	end)
	
	NewSettings.Parent = Modules
	if SettingConfig then
		for _, Config in SettingConfig do
			local _T = Config["Type"]
			if _T == "TextBox" then
				local TextBoxSetting = Instance.new("Frame")
				TextBoxSetting.BackgroundTransparency = 1
				TextBoxSetting.Size = UDim2.new(0.8, 0, 0, 60)
				TextBoxSetting.Name = "TextBoxSetting"
				TextBoxSetting.Parent = Settings.SF

				local TextBox = Instance.new("TextBox")
				TextBox.Parent = TextBoxSetting
				TextBox.BorderSizePixel = 0
				TextBox.TextXAlignment = Enum.TextXAlignment.Left
				TextBox.TextScaled = true
				TextBox.BackgroundColor3 = Color3.new(0, 0, 0)
				TextBox.TextColor3 = Color3.new(1, 1, 1)
				TextBox.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				TextBox.BackgroundTransparency = 0.5
				TextBox.Size = UDim2.new(0.8, 0, 0, 50)
				TextBox.Name = "TextBox"
				TextBox.Size = UDim2.new(1, 0, 0.6, 0)
				TextBox.Position = UDim2.new(0, 0, 0.4, 0)
				TextBox.PlaceholderText = Config["Placeholder"]
				TextBox.Text = ""

				local SettingCorner = Instance.new("UICorner")
				SettingCorner.Parent = TextBox
				SettingCorner.CornerRadius = UDim.new(0.2, 0)

				local SettingPadding = Instance.new("UIPadding")
				SettingPadding.Parent = TextBox
				SettingPadding.PaddingTop = UDim.new(0.2, 0)
				SettingPadding.PaddingRight = UDim.new(0.1, 0)
				SettingPadding.PaddingBottom = UDim.new(0.2, 0)
				SettingPadding.PaddingLeft = UDim.new(0.1, 0)

				local Title = Instance.new("TextLabel")
				Title.Parent = TextBoxSetting
				Title.BackgroundTransparency = 1
				Title.TextScaled = true
				Title.Text = Config["Title"]
				Title.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
				Title.TextColor3 = Color3.new(1, 1, 1)
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.Size = UDim2.new(0.5, 0, 0.3, 0)
				Title.Position = UDim2.new(0, 0, 0.05, 0)

				local TitleRatio = Instance.new("UIAspectRatioConstraint")
				TitleRatio.Parent = TBTitle
				TitleRatio.AspectRatio = 11.502

				local SettingTree = {
					Title = Config.Title,
					Type = _T,
					Value = TextBox.Text
				}

				SettingTree.Load = function(Value)
					SettingTree.Value = Value
					TextBox.Text = Value
					Config.Callback(Value)
				end

				table.insert(Tree.Settings, SettingTree)

				Connections[#Connections + 1] = TextBox.FocusLost:Connect(function()
					Config["Callback"](TextBox.Text)
					SettingTree.Value = TextBox.Text
					if Library.SaveName and not Library.Killed then Library.Save(Library.SaveName) end
				end)
			elseif _T == "Toggle" then
				local ToggleSetting = Instance.new("Frame")
				ToggleSetting.BackgroundTransparency = 1
				ToggleSetting.Size = UDim2.new(0.8, 0, 0, 50)
				ToggleSetting.Parent = Settings.SF

				local Title = Instance.new("TextLabel")
				Title.Parent = ToggleSetting
				Title.BackgroundTransparency = 1
				Title.TextScaled = true
				Title.Text = Config["Title"]
				Title.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
				Title.TextColor3 = Color3.new(1, 1, 1)
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.Size = UDim2.new(0.5, 0, 0.35, 0)

				local ToggleTitlePadding = Instance.new("UIPadding")
				ToggleTitlePadding.Parent = ToggleTitle
				ToggleTitlePadding.PaddingTop = UDim.new(0.1, 0);
				ToggleTitlePadding.PaddingBottom = UDim.new(0.1, 0);

				local ToggleTitleRatio = Instance.new("UIAspectRatioConstraint")
				ToggleTitleRatio.Parent = ToggleTitle
				ToggleTitleRatio.AspectRatio = 4.03

				local ToggleBar = Instance.new("TextButton")
				ToggleBar.Parent = ToggleSetting
				ToggleBar.BorderSizePixel = 0
				ToggleBar.AutoButtonColor = false
				ToggleBar.BackgroundColor3 = Color3.fromRGB(167, 167, 167)
				ToggleBar.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				ToggleBar.AnchorPoint = Vector2.new(0.5, 0)
				ToggleBar.Size = UDim2.new(0.15, 0, 0.4, 0)
				ToggleBar.Text = ""
				ToggleBar.Position = UDim2.new(0.1, 0, 0.6, 0)
				ToggleBar.Name = "Bar"
				table.insert(Recolorable, ToggleBar)

				local BarCorner = Instance.new("UICorner")
				BarCorner.Parent = ToggleBar
				BarCorner.CornerRadius = UDim.new(1, 0)

				local BarButton = Instance.new("TextButton")
				BarButton.Parent = ToggleBar
				BarButton.BorderSizePixel = 0
				BarButton.AutoButtonColor = false
				BarButton.BackgroundColor3 = Color3.new(1, 1, 1)
				BarButton.AnchorPoint = Vector2.new(0.5, 0.5)
				BarButton.Size = UDim2.new(1.75, 0, 1.75, 0)
				BarButton.BorderColor3 = Color3.new(0, 0, 0)
				BarButton.Position = UDim2.new(0, 0, 0.5, 0)
				BarButton.Text = ""
				BarButton.Name = "ToggleButton"
				table.insert(Recolorable, BarButton)

				local BarButtonCorner = Instance.new("UICorner")
				BarButtonCorner.Parent = BarButton
				BarButtonCorner.CornerRadius = UDim.new(1, 0)

				local BarButtonRatio = Instance.new("UIAspectRatioConstraint", BarButton)
				BarButtonRatio.Parent = BarButton

				local ToggleBarRatio = Instance.new("UIAspectRatioConstraint")
				ToggleBarRatio.Parent = ToggleBar
				ToggleBarRatio.AspectRatio = 2.157

				local function ApplyBrightness(Col, Amplitude)
					return Color3.new(Col.R * Amplitude, Col.G * Amplitude, Col.B * Amplitude)
				end 

				local SettingTree = {
					Title = Config.Title,
					Type = _T,
					Value = false
				}

				local _Toggle = false
				local function Toggled(isLoading)
					_Toggle = not _Toggle
					SettingTree.Value = _Toggle
					if Library.SaveName and not Library.Killed and not isLoading then Library.Save(Library.SaveName) end
					if _Toggle then
						TweenService:Create(BarButton, TInfo, {
							BackgroundColor3 = ThemeColor,
							Position = UDim2.new(1, 0, 0.5, 0),
						}):Play()
						TweenService:Create(ToggleBar, TInfo, {
							BackgroundColor3 = ApplyBrightness(ThemeColor, 0.8),
						}):Play()
					else
						TweenService:Create(BarButton, TInfo, {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							Position = UDim2.new(0, 0, 0.5, 0),
						}):Play()
						TweenService:Create(ToggleBar, TInfo, {
							BackgroundColor3 = Color3.fromRGB(166, 166, 166),
						}):Play()
					end
					Config["Callback"](_Toggle)
				end

				if Config["Default"] then
					Toggled(1)
				end

				SettingTree.Load = function(Value)
					_Toggle = Value
					SettingTree.Value = _Toggle
					if _Toggle then
						TweenService:Create(BarButton, TInfo, {
							BackgroundColor3 = ThemeColor,
							Position = UDim2.new(1, 0, 0.5, 0),
						}):Play()
						TweenService:Create(ToggleBar, TInfo, {
							BackgroundColor3 = ApplyBrightness(ThemeColor, 0.8),
						}):Play()
					else
						TweenService:Create(BarButton, TInfo, {
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							Position = UDim2.new(0, 0, 0.5, 0),
						}):Play()
						TweenService:Create(ToggleBar, TInfo, {
							BackgroundColor3 = Color3.fromRGB(166, 166, 166),
						}):Play()
					end
					Config["Callback"](_Toggle)
				end

				table.insert(Tree.Settings, SettingTree)

				Connections[#Connections + 1] = BarButton.MouseButton1Click:Connect(Toggled)
				Connections[#Connections + 1] = ToggleBar.MouseButton1Click:Connect(Toggled)
			elseif _T == "Dropdown" then
				local Dropdown = Instance.new("Frame")
				Dropdown.BackgroundTransparency = 1
				Dropdown.Size = UDim2.new(0.8, 0, 0, 50)
				Dropdown.Parent = Settings.SF
				Dropdown.ZIndex = 9

				local Selected = Instance.new("TextButton")
				Selected.Parent = Dropdown
				Selected.Size = UDim2.new(1, 0, 0.75, 0)
				Selected.TextScaled = true
				Selected.Text = Config["Title"] .. " · " .. Config["Default"]
				Selected.BackgroundColor3 = Color3.new(0, 0, 0)
				Selected.BackgroundTransparency = 0--0.85
				Selected.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
				Selected.TextColor3 = Color3.new(1, 1, 1)
				Selected.BackgroundColor3 = ThemeColor
				Selected.BorderSizePixel = 0
				Selected.TextXAlignment = Enum.TextXAlignment.Left
				Selected.ZIndex = 10
				table.insert(Recolorable, Selected)

				local SelectedPadding = Instance.new("UIPadding")
				SelectedPadding.Parent = Selected
				SelectedPadding.PaddingTop = UDim.new(0.2, 0)
				SelectedPadding.PaddingBottom = UDim.new(0.2, 0)
				SelectedPadding.PaddingLeft = UDim.new(0.1, 0)
				SelectedPadding.PaddingRight = UDim.new(0.1, 0)

				local Dropped = false
				local OptionInstances = {}

				local SettingTree = {
					Title = Config.Title,
					Type = _T,
					Value = Config.Default
				}

				SettingTree.Load = function(Value)
					Selected.Text = Config["Title"] .. " · " .. Value
					SettingTree.Value = Value
					Config.Callback(Value)
				end

				table.insert(Tree.Settings, SettingTree)

				for _, Option in Config["Options"] do
					local Clone = Selected:Clone()
					Clone.Parent = Dropdown
					Clone.Position = UDim2.new(Selected.Position.X.Scale, 0, Selected.Position.Y.Scale + (_ * Selected.Size.Y.Scale), 0)
					Clone.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
					Clone.Text = Option
					Clone.Visible = false
					table.insert(OptionInstances, Clone)

					Connections[#Connections + 1] = Clone.MouseButton1Down:Connect(function()
						Selected.Text = Config["Title"] .. " · " .. Option
						SettingTree.Value = Option
						Config.Callback(Option)

						Dropped = false
						for _, Inst in OptionInstances do
							Inst.Visible = false
						end
						if Library.SaveName and not Library.Killed then Library.Save(Library.SaveName) end
					end)
				end
				
				Selected.MouseButton1Down:Connect(function()
					Dropped = not Dropped
					for _, Inst in OptionInstances do
						Inst.Visible = Dropped
					end
				end)
			elseif _T == "Slider" then
				local Slider = Instance.new("Frame")
				Slider.BackgroundTransparency = 1
				Slider.Size = UDim2.new(0.8, 0, 0, 50)
				Slider.Parent = Settings.SF

				local Title = Instance.new("TextLabel")
				Title.Parent = Slider
				Title.BackgroundTransparency = 1
				Title.TextScaled = true
				Title.Text = Config["Title"]
				Title.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
				Title.TextColor3 = Color3.new(1, 1, 1)
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.Size = UDim2.new(0.5, 0, 0.35, 0)

				local Display = Instance.new("TextLabel")
				Display.Parent = Slider
				Display.BackgroundTransparency = 1
				Display.TextScaled = true
				Display.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
				Display.TextColor3 = Color3.new(1, 1, 1)
				Display.TextXAlignment = Enum.TextXAlignment.Right
				Display.Size = UDim2.new(0.5, 0, 0.35, 0)
				Display.Position = UDim2.new(0.5, 0, 0, 0)
				Display.Text = Config["Default"]

				local Bar = Instance.new("Frame")
				Bar.Parent = Slider
				Bar.Size = UDim2.new(0.8, 0, 0.1, 0)
				Bar.AnchorPoint = Vector2.new(0.5, 0)
				Bar.Position = UDim2.new(0.5, 0, 0.65, 0)
				Bar.BorderSizePixel = 0
				Bar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

				local Button = Instance.new("TextButton")
				Button.Parent = Bar
				Button.Size = UDim2.new(1, 0, 3, 0)
				Button.Text = ""
				Button.AnchorPoint = Vector2.new(0.5, 0.5)
				Button.Position = UDim2.new(0, 0, 0.5, 0)
				Button.BackgroundColor3 = ThemeColor
				table.insert(Recolorable, Button)

				local ButtonCorner = Instance.new("UICorner")
				ButtonCorner.Parent = Button
				ButtonCorner.CornerRadius = UDim.new(1, 0)

				local ButtonRatio = Instance.new("UIAspectRatioConstraint")
				ButtonRatio.Parent = Button

				local Dragging = false

				Connections[#Connections + 1] = Button.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
					end
				end)

				Connections[#Connections + 1] = Button.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
						if Library.SaveName and not Library.Killed then Library.Save(Library.SaveName) end
					end
				end)

				local SettingTree = {
					Title = Config.Title,
					Type = _T,
					Value = Config.Default
				}

				SettingTree.Load = function(Value)
					Button.Position = UDim2.new((Value / Config["Max"]), 0, 0.5, 0)
					Display.Text = Value
					Config["Callback"](Value)
					SettingTree.Value = Value
				end

				table.insert(Tree.Settings, SettingTree)

				Connections[#Connections + 1] = UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
						local MouseX = math.clamp(Mouse.X - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X)
						local Value = Config["Min"] + (MouseX / Bar.AbsoluteSize.X) * (Config["Max"] - Config["Min"])
						Value = math.floor(Value * 100) / 100
						Display.Text = Value
						Button.Position = UDim2.new((Value / Config["Max"]), 0, 0.5, 0)
						SettingTree.Value = Value
						Config["Callback"](Value)
					end
				end)

				Button.Position = UDim2.new((Config["Default"] / Config["Max"]), 0, 0.5, 0)
			end
		end
	end
	NewSettings.Parent = nil

	CategoryInfo["Modules"][#CategoryInfo["Modules"] + 1] = Tree
	Library.renderModules()
end

Library.getModule = function(Query)
	for _, Category in Categories do
		for _, Module in Category.Modules do
			if Module.Name:lower() == Query:lower() then
				return Module
			end
		end
	end
end

Library.getSetting = function(ModuleName, SettingName)
	local Module = Library.getModule(ModuleName)
	if not Module then return end

	for _, Setting in Module.Settings do
		if Setting.Title == SettingName then
			return Setting.Value
		end
	end
end

Library.setKeybind = function(Query, Keybind)
	local Module = Library.getModule(Query)
	if not Module then return end

	Module.Keybind = Keybind
	if Library.SaveName and not Library.Killed then Library.Save(Library.SaveName) end
end

Library.getEnv = function(Query)
	local Module = Library.getModule(Query)
	if not Module then return end

	return Module.Env
end

Library.KillScript = function()
	Library.Killed = 1
	if Library.SaveName then Library.Save(Library.SaveName) end
	
	for _, Category in Categories do
		for _, Module in Category.Modules do
			if Module.Toggle then
				Module["ToggleFunction"]()
			end
		end
	end
	
	Screen:Destroy()
	Blur:Destroy()
	
	for _, c in Connections do
		c:Disconnect()
	end
end

Library.isToggled = function(Query)
	local Module = Library.getModule(Query)
	if not Module then return end

	return Module.Toggle
end

local function ApplyBrightness(Col, Amplitude)
	return Color3.new(Col.R * Amplitude, Col.G * Amplitude, Col.B * Amplitude)
end

Library.Recolor = function(NewColor)
	ThemeColor = NewColor
	for _, Inst in Recolorable do
		if Inst:IsA("TextLabel") or Inst:IsA("TextButton") or Inst:IsA("ImageLabel") then
			if Inst.Name == "Bar" then Inst.BackgroundColor3 = ApplyBrightness(NewColor, 0.8) continue end
			if Inst.Name == "ToggleButton" then Inst.BackgroundColor3 = NewColor continue end
			if Inst.TextColor3 ~= Color3.new(1, 1, 1) then
				Inst.TextColor3 = NewColor
			end
			if Inst.BackgroundColor3 ~= Color3.new(0, 0, 0) and Inst.BackgroundColor3 ~= Color3.new(1, 1, 1) and Inst.BackgroundColor3 ~= Color3.fromRGB(166, 166, 166) then
				Inst.BackgroundColor3 = NewColor
			end
		end
		if Inst:IsA("Frame") then
			Inst.BackgroundColor3 = NewColor
		end
		if Inst:IsA("UIStroke") then
			Inst.Color = NewColor
		end
	end
end

local HttpService = game:GetService("HttpService")
makefolder("Relief")

Library.Save = function(Name)
	local FileName = "Relief/" .. Name .. ".json"
	local Data = {}

	for _, Category in Categories do
		for _, Module in Category.Modules do
			local Settings = {}

			for _, Setting in Module.Settings do
				table.insert(Settings, {
					Title = Setting.Title,
					Value = Setting.Value,
				})
			end

			Data[Module.Name] = {Module.Toggle, Module.Keybind and Module.Keybind.Name or "None", Settings}
		end
	end

	writefile(FileName, HttpService:JSONEncode(Data))
end

Library.Load = function(Name)
	task.spawn(function()
		local FileName = "Relief/" .. Name .. ".json"
		if not isfile(FileName) then return end

		local JsonData = HttpService:JSONDecode(readfile(FileName))
		for Name, Data in JsonData do
			local Toggled, Bind, SavedSettings = Data[1], Data[2], Data[3]
			if Name == "KillScript" then continue end
			
			local Module = Library.getModule(Name)
			if not Module then continue end

			if Bind and Bind ~= "None" then
				Module.Keybind = Enum.KeyCode[Bind]
			end

			if Toggled and not Module["Default"] then
				Module["ToggleFunction"](1)
			elseif not Toggled and Module["Default"] then
				Module["ToggleFunction"](1)
			end

			for _, LoadedSetting in SavedSettings do
				local Title, Value = LoadedSetting.Title, LoadedSetting.Value
				for _, Setting in Module.Settings do
					if Setting.Title == Title then
						Setting.Load(Value)
						break
					end
				end
			end
		end

		task.defer(function()
			Library.Recolor(ThemeColor)
		end)
	end)
end

Library.AutoSaveName = function(Name)
	Library.SaveName = Name
end

Library.Commands = {}
Library.AddCommand = function(Aliases, Callback)
	table.insert(Library.Commands, {
		Aliases = Aliases,
		Callback = Callback
	})
end

Library.GetCommand = function(Query)
	for _, Command in Library.Commands do
		for _, Alias in Command.Aliases do
			if Alias:lower() == Query:lower() then
				return Command
			end
		end
	end
end

local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local Intro = TweenService:Create(Holder, Info, { Position = UDim2.new(0, 0, 0.05, 1) })
local Outro = TweenService:Create(Holder, Info, { Position = UDim2.new(0, 0, 0, -3) })

local Toggled = false
Connections[#Connections + 1] = UserInputService.InputEnded:Connect(function(Input, GPE)
	if GPE then return end
	if table.find(Library.CommandBarBinds, Input.KeyCode) then
		Intro:Play()
		CommandBar:CaptureFocus()
		Toggled = true
	end
end)

Connections[#Connections + 1] = CommandBar.FocusLost:Connect(function(enterPressed)
	local Command = CommandBar.Text
	CommandBar.Text = ""
	Outro:Play()
	CommandBar:ReleaseFocus()
	
	if not enterPressed then return end

	Toggled = false
	local Split = Command:split(" ")
	local Command = Library.GetCommand(Split[1])
	if not Command then return end

	table.remove(Split, 1)
	Command.Callback(Split)
end)

local function GetAlias(Query)
	for _, Command in Library.Commands do
		for _, Alias in Command.Aliases do
			if Alias:lower():sub(1, Query:len()) == Query:lower() then
				return Alias
			end
		end
	end
end

local function GetComplete()
	local Complete = ""
	
	local New = CommandBar.Text
	local Split = New:split(" ")
	local Query = Split[1]
	if Query:len() < 1 then return Complete end

	local Alias = GetAlias(Query)
	if Alias then
		Complete ..= Alias
	end

	return Complete
end

Connections[#Connections + 1] = CommandBar:GetPropertyChangedSignal("Text"):Connect(function()
	local New = CommandBar.Text
	if #New:split(" ") > 1 then AutoComplete.Text = "" return end
		
	local Complete = GetComplete()
	AutoComplete.Text = New .. Complete:sub(New:len() + 1)
end)

Arrow.MouseButton1Down:Connect(function()
	Toggled = not Toggled
	if Toggled then
		Arrow.Rotation = 0
		Intro:Play()
		CommandBar:CaptureFocus()
	else
		Arrow.Rotation = 180
		local Command = CommandBar.Text
		CommandBar.Text = ""
		Outro:Play()
		CommandBar:ReleaseFocus()
		
		if not enterPressed then return end

		local Split = Command:split(" ")
		local Command = Library.GetCommand(Split[1])
		if not Command then return end

		table.remove(Split, 1)
		Command.Callback(Split)
	end
end)

Library.ModuleList = ModuleList
Library.MobileButton = MobileButton

return Library
