-- TPWalk Script với Modern UI
-- Hoạt động trên Mobile Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Biến chính
local tpWalking = false
local tpSpeed = 50
local mainConnection = nil

-- Hàm lấy root part
local function getRoot(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

-- ==================== TẠO UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TPWalkUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Xử lý cho executor
if syn then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 160, 0, 100)
MainFrame.Position = UDim2.new(0.5, -80, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 120)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Title Bar (Drag Handle)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Fix bottom corners của title bar
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ TPWalk"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Speed Input Container
local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(0, 130, 0, 28)
InputContainer.Position = UDim2.new(0.5, -65, 0, 35)
InputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
InputContainer.BorderSizePixel = 0
InputContainer.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputContainer

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 50, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed:"
SpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
SpeedLabel.TextSize = 11
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = InputContainer

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 70, 0, 22)
SpeedInput.Position = UDim2.new(1, -75, 0.5, -11)
SpeedInput.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
SpeedInput.BorderSizePixel = 0
SpeedInput.Text = "50"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 12
SpeedInput.Font = Enum.Font.GothamSemibold
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = InputContainer

local InputBoxCorner = Instance.new("UICorner")
InputBoxCorner.CornerRadius = UDim.new(0, 6)
InputBoxCorner.Parent = SpeedInput

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 130, 0, 28)
ToggleButton.Position = UDim2.new(0.5, -65, 0, 68)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- ==================== DRAG FUNCTIONALITY ====================
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = newPos}):Play()
    end
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

-- ==================== TPWALK LOGIC ====================
local function startTPWalk()
    if mainConnection then
        mainConnection:Disconnect()
        mainConnection = nil
    end
    
    tpWalking = true
    
    mainConnection = RunService.Heartbeat:Connect(function()
        if not tpWalking then return end
        
        local character = player.Character
        if not character then return end
        
        local root = getRoot(character)
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        
        if not root or not humanoid then return end
        if humanoid.Health <= 0 then return end
        
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            local targetPos = root.Position + (moveDirection * tpSpeed * 0.016)
            root.CFrame = CFrame.new(targetPos, targetPos + moveDirection)
        end
    end)
end

local function stopTPWalk()
    tpWalking = false
    if mainConnection then
        mainConnection:Disconnect()
        mainConnection = nil
    end
end

-- ==================== UI EVENTS ====================
SpeedInput.FocusLost:Connect(function()
    local num = tonumber(SpeedInput.Text)
    if num and num > 0 and num <= 1000 then
        tpSpeed = num
        SpeedInput.Text = tostring(num)
    else
        SpeedInput.Text = tostring(tpSpeed)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    if tpWalking then
        stopTPWalk()
        ToggleButton.Text = "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        }):Play()
    else
        startTPWalk()
        ToggleButton.Text = "ON"
        ToggleButton.TextColor3 = Color3.fromRGB(100, 255, 150)
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 100, 70)
        }):Play()
    end
end)

-- Xử lý khi respawn - giữ nguyên trạng thái
player.CharacterAdded:Connect(function()
    if tpWalking then
        -- Đợi character load xong
        task.wait(0.5)
        -- Không cần làm gì vì Heartbeat connection vẫn chạy
        -- Nó sẽ tự động hoạt động với character mới
    end
end)

-- Cleanup khi script bị dừng
ScreenGui.Destroying:Connect(function()
    stopTPWalk()
end)

print("TPWalk Script Loaded! Drag từ thanh tiêu đề.")
