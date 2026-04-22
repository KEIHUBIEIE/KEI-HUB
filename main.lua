--[[
    KIM HUB - GOD MODE (FIXED SPEED)
    - Combat: Direct Lock 100%, Wall Check, FOV Circle
    - Visuals: 2D Box, Health Bar (Left), Tool ESP, Name on Body
    - Settings: WalkSpeed (Fixed!), Noclip
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- เคลียร์ค่าเก่าป้องกันการรันซ้ำ
if getgenv().AimCircle then pcall(function() getgenv().AimCircle:Remove() end) end
getgenv().KEIHUB_LOADED = true
getgenv().AimPart = "Head"
getgenv().AimbotFOV = 150
getgenv().WallCheck = false
getgenv().WalkSpeedEnabled = false -- ดึงกลับมาแล้ว!

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [ ฟังชั่นเช็คกำแพง ]
local function isVisible(part)
    if not getgenv().WallCheck then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {Client.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude, raycastParams)
    return (result and result.Instance:IsDescendantOf(part.Parent)) or not result
end

-- [ ลอจิก Aimbot แบบล็อค 100% ]
local function GetClosestPlayer()
    local Target = nil
    local MaxDist = getgenv().AimbotFOV or 150
    local ShortestMouseDist = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local Part = v.Character:FindFirstChild(getgenv().AimPart)
            if Part then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                if OnScreen and isVisible(Part) then
                    local MouseDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if MouseDist < MaxDist and MouseDist < ShortestMouseDist then
                        ShortestMouseDist = MouseDist
                        Target = Part
                    end
                end
            end
        end
    end
    return Target
end

-- [ ระบบวาด ESP 2D ]
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    local HealthBarOutline = Drawing.new("Square")
    local HealthBar = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local NameText = Drawing.new("Text")
    local ToolText = Drawing.new("Text")
    local DistText = Drawing.new("Text")

    Box.Visible = false; Box.Thickness = 1; Box.Filled = false
    HealthBarOutline.Visible = false; HealthBarOutline.Color = Color3.new(0,0,0); HealthBarOutline.Filled = true
    HealthBar.Visible = false; HealthBar.Color = Color3.new(0, 1, 0); HealthBar.Filled = true
    Tracer.Visible = false; Tracer.Thickness = 1
    NameText.Visible = false; NameText.Center = true; NameText.Outline = true; NameText.Size = 13; NameText.Color = Color3.new(1, 1, 1)
    ToolText.Visible = false; ToolText.Center = true; ToolText.Outline = true; ToolText.Size = 12; ToolText.Color = Color3.fromRGB(255, 200, 0)
    DistText.Visible = false; DistText.Center = true; DistText.Outline = true; DistText.Size = 12; DistText.Color = Color3.new(1, 1, 1)

    RunService.RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
            local Root = plr.Character.HumanoidRootPart
            local Hum = plr.Character.Humanoid
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen and getgenv().ShowVisualsMaster then
                local SizeX = 2000 / Pos.Z
                local SizeY = 3000 / Pos.Z
                local BoxPos = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)

                if getgenv().ShowESPBox then Box.Size = Vector2.new(SizeX, SizeY); Box.Position = BoxPos; Box.Color = Color3.new(1,0,0); Box.Visible = true else Box.Visible = false end
                if getgenv().ShowHealthESP then
                    local HealthHeight = (Hum.Health / Hum.MaxHealth) * SizeY
                    HealthBarOutline.Size = Vector2.new(4, SizeY); HealthBarOutline.Position = Vector2.new(BoxPos.X - 6, BoxPos.Y); HealthBarOutline.Visible = true
                    HealthBar.Size = Vector2.new(2, HealthHeight); HealthBar.Position = Vector2.new(BoxPos.X - 5, BoxPos.Y + (SizeY - HealthHeight)); HealthBar.Visible = true
                else HealthBar.Visible = false; HealthBarOutline.Visible = false end
                if getgenv().ShowTracers then Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0); Tracer.To = Vector2.new(Pos.X, Pos.Y - SizeY/2); Tracer.Color = Color3.new(1,0,0); Tracer.Visible = true else Tracer.Visible = false end
                if getgenv().ShowNames then NameText.Text = plr.Name; NameText.Position = Vector2.new(Pos.X, Pos.Y - 5); NameText.Visible = true else NameText.Visible = false end
                if getgenv().ShowInventory then
                    local Tool = plr.Character:FindFirstChildOfClass("Tool")
                    ToolText.Text = Tool and "[" .. Tool.Name .. "]" or "[None]"
                    ToolText.Position = Vector2.new(Pos.X, Pos.Y + 10); ToolText.Visible = true
                else ToolText.Visible = false end
                if getgenv().ShowDistance then
                    local Dist = math.floor((Client.Character.HumanoidRootPart.Position - Root.Position).Magnitude)
                    DistText.Text = Dist .. " Studs"; DistText.Position = Vector2.new(Pos.X, Pos.Y + SizeY/2 + 5); DistText.Visible = true
                else DistText.Visible = false end
            else Box.Visible = false; HealthBar.Visible = false; HealthBarOutline.Visible = false; Tracer.Visible = false; NameText.Visible = false; ToolText.Visible = false; DistText.Visible = false end
        else Box.Visible = false; HealthBar.Visible = false; HealthBarOutline.Visible = false; Tracer.Visible = false; NameText.Visible = false; ToolText.Visible = false; DistText.Visible = false end
    end)
end

-- สร้างวงกลม FOV
getgenv().AimCircle = Drawing.new("Circle")
getgenv().AimCircle.Thickness = 1.5
getgenv().AimCircle.NumSides = 60
getgenv().AimCircle.Color = Color3.fromRGB(255, 255, 255)
getgenv().AimCircle.Filled = false

-- Start ESP
for _, v in pairs(Players:GetPlayers()) do if v ~= Client then CreateESP(v) end end
Players.PlayerAdded:Connect(function(v) if v ~= Client then CreateESP(v) end end)

-- [ UI Setup ]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "KEI HUB",
    Icon = "rbxassetid://120071332053245",
    Author = "Kim",
    Theme = "Dark"
})

local Tabs = { 
    Combat = Window:Tab({Title = "Combat", Icon = "crosshair"}), 
    Visuals = Window:Tab({Title = "Visuals", Icon = "eye"}), 
    Settings = Window:Tab({Title = "Settings", Icon = "settings"}) 
}

-- Combat
local CombatSec = Tabs.Combat:Section({Title = "Aimbot"})
CombatSec:Toggle({Title = "Aimbot", Value = false, Callback = function(v) getgenv().AimbotEnabled = v end})
CombatSec:Toggle({Title = "Wall Check", Value = false, Callback = function(v) getgenv().WallCheck = v end})
CombatSec:Toggle({Title = "FOV", Value = false, Callback = function(v) getgenv().ShowFOV = v end})
CombatSec:Dropdown({Title = "ตำแหน่งล็อคเป้า", Values = {"Head", "HumanoidRootPart"}, Callback = function(v) getgenv().AimPart = v end})
CombatSec:Slider({Title = "ขนาด FOV", Step = 1, Value = {Min = 30, Max = 800, Default = 150}, Callback = function(v) getgenv().AimbotFOV = v end})

-- Visuals
local VisSec = Tabs.Visuals:Section({Title = "ESP 2D Config"})
VisSec:Toggle({Title = "Open Visuals", Value = false, Callback = function(v) getgenv().ShowVisualsMaster = v end})
VisSec:Toggle({Title = "Esp Box", Value = false, Callback = function(v) getgenv().ShowESPBox = v end})
VisSec:Toggle({Title = "Esp Health Bar", Value = false, Callback = function(v) getgenv().ShowHealthESP = v end})
VisSec:Toggle({Title = "Tracers", Value = false, Callback = function(v) getgenv().ShowTracers = v end})
VisSec:Toggle({Title = "Esp Name", Value = false, Callback = function(v) getgenv().ShowNames = v end})
VisSec:Toggle({Title = "Esp Inventory", Value = false, Callback = function(v) getgenv().ShowInventory = v end})
VisSec:Toggle({Title = "Distance", Value = false, Callback = function(v) getgenv().ShowDistance = v end})

-- Settings (จุดที่แก้ WalkSpeed)
local MoveSec = Tabs.Settings:Section({Title = "Movement"})
MoveSec:Toggle({
    Title = "Walk Speed", 
    Value = false, 
    Callback = function(v) 
        getgenv().WalkSpeedEnabled = v 
        if not v then pcall(function() Client.Character.Humanoid.WalkSpeed = 16 end) end
    end
})
MoveSec:Slider({Title = "ความเร็ว", Step = 1, Value = {Min = 16, Max = 250, Default = 50}, Callback = function(v) getgenv().WalkSpeedValue = v end})
MoveSec:Toggle({Title = "Noclip", Value = false, Callback = function(v) getgenv().NoclipEnabled = v end})

-- [ Loop หลัก ]
RunService.RenderStepped:Connect(function()
    if getgenv().AimCircle then
        getgenv().AimCircle.Visible = getgenv().ShowFOV or false
        getgenv().AimCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        getgenv().AimCircle.Radius = getgenv().AimbotFOV or 150
    end
    
    if getgenv().AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
    end
end)

RunService.Stepped:Connect(function()
    pcall(function()
        if getgenv().WalkSpeedEnabled and Client.Character and Client.Character:FindFirstChild("Humanoid") then
            Client.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue or 50
        end
        if getgenv().NoclipEnabled and Client.Character then
            for _, v in pairs(Client.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)
end)

WindUI:Notify({Title = "KEI Hub", Content = "Runเรียบร้อย!", Duration = 5})
