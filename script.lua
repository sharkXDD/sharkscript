-- LocalScript

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = game.Workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 330)
frame.Position = UDim2.new(0.5, -125, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Меню"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- === Функция создания секции ===
local function createSliderSection(parent, yOffset, name, valueRange)
	local section = {}

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 10, 0, yOffset)
	label.Size = UDim2.new(0, 230, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = name .. ": " .. tostring(valueRange.default)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	local slider = Instance.new("TextButton")
	slider.Position = UDim2.new(0, 10, 0, yOffset + 25)
	slider.Size = UDim2.new(0, 230, 0, 20)
	slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	slider.Text = ""
	slider.AutoButtonColor = false
	slider.Parent = parent

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 10, 1, 0)
	knob.Position = UDim2.new(0, 0, 0, 0)
	knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	knob.BorderSizePixel = 0
	knob.Parent = slider

	local checkBox = Instance.new("TextButton")
	checkBox.Position = UDim2.new(0, 10, 0, yOffset + 60)
	checkBox.Size = UDim2.new(0, 20, 0, 20)
	checkBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	checkBox.Text = ""
	checkBox.Parent = parent

	local checkMark = Instance.new("TextLabel")
	checkMark.Size = UDim2.new(1, 0, 1, 0)
	checkMark.BackgroundTransparency = 1
	checkMark.Text = ""
	checkMark.TextColor3 = Color3.new(0, 1, 0)
	checkMark.Font = Enum.Font.SourceSansBold
	checkMark.TextSize = 18
	checkMark.Parent = checkBox

	local checkLabel = Instance.new("TextLabel")
	checkLabel.Position = UDim2.new(0, 35, 0, yOffset + 60)
	checkLabel.Size = UDim2.new(0, 200, 0, 20)
	checkLabel.BackgroundTransparency = 1
	checkLabel.Text = "Автосет " .. name:lower()
	checkLabel.TextColor3 = Color3.new(1, 1, 1)
	checkLabel.Font = Enum.Font.SourceSans
	checkLabel.TextSize = 16
	checkLabel.TextXAlignment = Enum.TextXAlignment.Left
	checkLabel.Parent = parent

	-- переменные
	section.value = valueRange.default
	section.active = false

	local function updateSlider(x)
		local rel = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		local val = math.floor(valueRange.min + (valueRange.max - valueRange.min) * rel)
		section.value = val
		knob.Position = UDim2.new(rel, -5, 0, 0)
		label.Text = name .. ": " .. val
	end

	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateSlider(input.Position.X)
		end
	end)

	slider.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			updateSlider(input.Position.X)
		end
	end)

	checkBox.MouseButton1Click:Connect(function()
		section.active = not section.active
		checkMark.Text = section.active and "✓" or ""
	end)

	return section
end

-- === Секции ===
local speedSection = createSliderSection(frame, 40, "Скорость", {min = 15, max = 100, default = 16})
local jumpSection = createSliderSection(frame, 140, "Прыжок", {min = 20, max = 200, default = 50})
local fovSection = createSliderSection(frame, 240, "FOV", {min = 60, max = 120, default = 70})

-- === Постоянное применение значений ===
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char or not char:FindFirstChild("Humanoid") then return end

	if speedSection.active then
		char.Humanoid.WalkSpeed = speedSection.value
	end
	if jumpSection.active then
		char.Humanoid.JumpPower = jumpSection.value
	end
	if fovSection.active then
		camera.FieldOfView = fovSection.value
	end
end)

-- === Клавиши Insert и F8 ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		frame.Visible = not frame.Visible
	elseif input.KeyCode == Enum.KeyCode.F8 then
		screenGui:Destroy()
		script:Destroy()
	end
end)
