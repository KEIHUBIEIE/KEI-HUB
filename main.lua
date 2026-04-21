--[[
    KEI HUB | PRO MAX EDITION (WindUI)
    - Combat: Aimbot (Distance), Aim Part, RGB FOV (ใหม่!)
    - Visuals: RGB Name, ESP Box (Fixed), Inventory, Health ESP
    - Team: Manual & Auto Team Check
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- เคลียร์ค่าเก่าป้องกันการรันซ้ำ
if getgenv().AimCircle then pcall(function() getgenv().AimCircle:Remove() end) end
getgenv().KEIHUB_LOADED = true
getgenv().ExcludedPlayers = {} 
getgenv().AimPart = "Head"

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [ ฟังชั่นเช็ครายชื่อคนยกเว้น ]
local function isPlayerExcluded(player)
    for _, excluded in ipairs(getgenv().ExcludedPlayers) do
        if excluded == player then return true end
    end
    if getgenv().AutoTeamCheck and player.Team ~= nil and player.Team == Client.Team then
        return true
    end
    return false
end

-- [ สร้างวงกลม FOV ]
local function CreateFOV()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Thickness = 2
    circle.Transparency = 1
    circle.NumSides = 100
    circle.Radius = getgenv().AimbotFOV or 150
    circle.Filled = false
    circle.Color = Color3.fromRGB(255, 255, 255)
    return circle
end
getgenv().AimCircle = CreateFOV()

-- [ ลอจิก Aimbot ล็อคคนที่ใกล้ที่สุด ]
local function GetClosestPlayer()
    local Target = nil
    local MaxDist = getgenv().AimbotFOV or 150
    local ShortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if isPlayerExcluded(v) then continue end

            local Part = v.Character:FindFirstChild(getgenv().AimPart)
            if Part then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                if OnScreen then
                    local DistanceFromMe = (Client.Character.HumanoidRootPart.Position - Part.Position).Magnitude
                    local MouseDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    
                    if MouseDist < MaxDist and DistanceFromMe < ShortestDistance then
                        ShortestDistance = DistanceFromMe
                        Target = Part
                    end
                end
            end
        end
    end
    return Target
end

-- [ Loop หลัก ]
RunService.RenderStepped:Connect(function()
    local Hue = tick() % 5 / 5
    local RGBColor = Color3.fromHSV(Hue, 1, 1)
    local GreenColor = Color3.fromRGB(0, 255, 127)

    -- 1. FOV (รองรับระบบรุ้ง)
    if getgenv().AimCircle then
        getgenv().AimCircle.Visible = getgenv().ShowFOV or false
        getgenv().AimCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        getgenv().AimCircle.Radius = getgenv().AimbotFOV or 150
        -- เช็คว่าเปิดโหมดรุ้งหรือไม่
        getgenv().AimCircle.Color = getgenv().FOV_RGB and RGBColor or Color3.fromRGB(255, 255, 255)
    end

    -- 2. Aimbot
    if getgenv().AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target then
            local SmoothValue = getgenv().SmoothnessEnabled and (getgenv().SmoothAmount or 5) or 1
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Position), 1/SmoothValue)
        end
    end

    -- 3. Visuals & ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Client and p.Character and p.Character:FindFirstChild("Humanoid") then
            local Hum = p.Character.Humanoid
            local isTeam = isPlayerExcluded(p)
            local CurrentColor = isTeam and GreenColor or RGBColor
            
            -- Name & Health ESP
            if getgenv().ShowNamesRGB and p.Character:FindFirstChild("HumanoidRootPart") then
                local tag = p.Character.HumanoidRootPart:FindFirstChild("KEI_ESP")
                if not tag then
                    tag = Instance.new("BillboardGui", p.Character.HumanoidRootPart)
                    tag.Name = "KEI_ESP"
                    tag.Size = UDim2.new(0, 250, 0, 70)
                    tag.AlwaysOnTop = true
                    tag.StudsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", tag)
                    l.Name = "Label"
                    l.Size = UDim2.new(1, 0, 0.5, 0)
                    l.BackgroundTransparency = 1
                    l.TextSize = 14
                    l.Font = Enum.Font.GothamBold
                    local hp = Instance.new("TextLabel", tag)
                    hp.Name = "HPLabel"
                    hp.Size = UDim2.new(1, 0, 0.4, 0)
                    hp.Position = UDim2.new(0, 0, 0.5, 0)
                    hp.BackgroundTransparency = 1
                    hp.TextSize = 12
                    hp.Font = Enum.Font.GothamBold
                end
                
                local ToolName = p.Character:FindFirstChildOfClass("Tool") and p.Character:FindFirstChildOfClass("Tool").Name or "None"
                tag.Label.Text = p.Name .. (getgenv().ShowInventory and " [" .. ToolName .. "]" or "")
                tag.Label.TextColor3 = CurrentColor
                
                if getgenv().ShowHealthESP then
                    tag.HPLabel.Visible = true
                    tag.HPLabel.Text = "HP: " .. math.floor(Hum.Health)
                    tag.HPLabel.TextColor3 = Color3.fromHSV(math.clamp(Hum.Health/Hum.MaxHealth, 0, 1) * 0.3, 1, 1)
                else
                    tag.HPLabel.Visible = false
                end
                tag.Enabled = true
            end

            -- ESP Box
            if getgenv().ShowESPBox then
                local box = p.Character:FindFirstChild("KEI_BOX_ADORN")
                if not box then
                    box = Instance.new("SelectionBox")
                    box.Name = "KEI_BOX_ADORN"
                    box.Parent = p.Character
                    box.LineThickness = 0.05
                    box.Adornee = p.Character
                end
                box.Visible = true
                box.Color3 = CurrentColor
            else
                if p.Character:FindFirstChild("KEI_BOX_ADORN") then p.Character.KEI_BOX_ADORN:Destroy() end
            end
        end
    end
end)

-- [ UI Setup - WindUI ]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "KEI HUB | PRO MAX",
    Icon = "rbxassetid://120071332053245",
    Author = "Kim",
    Folder = "KeiHubConfig",
    Size = UDim2.fromOffset(360, 540),
    Transparent = true,
    Theme = "Dark"
})

local Tabs = {
    Combat = Window:Tab({Title = "Combat", Icon = "crosshair"}),
    Visuals = Window:Tab({Title = "Visuals", Icon = "eye"}),
    Team = Window:Tab({Title = "Team", Icon = "users"}),
    Settings = Window:Tab({Title = "Settings", Icon = "settings"})
}

-- Combat Section (เพิ่ม FOV รุ้ง)
local CombatSec = Tabs.Combat:Section({Title = "Aimbot Settings"})
CombatSec:Toggle({Title = "เปิดใช้งาน Aimbot", Value = false, Callback = function(v) getgenv().AimbotEnabled = v end})
CombatSec:Toggle({Title = "Auto Team Check", Value = false, Callback = function(v) getgenv().AutoTeamCheck = v end})
CombatSec:Dropdown({Title = "ตำแหน่งล็อคเป้า", Values = {"Head", "HumanoidRootPart"}, Callback = function(v) getgenv().AimPart = v end})

local FOVSec = Tabs.Combat:Section({Title = "FOV Customization"})
FOVSec:Toggle({Title = "แสดงวงกลม FOV", Value = false, Callback = function(v) getgenv().ShowFOV = v end})
FOVSec:Toggle({Title = "FOV สีรุ้ง (RGB)", Value = false, Callback = function(v) getgenv().FOV_RGB = v end})
Tabs.Combat:Slider({Title = "ขนาด FOV", Step = 1, Value = {Min = 50, Max = 800, Default = 150}, Callback = function(v) getgenv().AimbotFOV = v end})

-- Visuals Section
local VisualSec = Tabs.Visuals:Section({Title = "Visuals & ESP"})
VisualSec:Toggle({Title = "มองชื่อ (Name ESP)", Value = false, Callback = function(v) getgenv().ShowNamesRGB = v end})
VisualSec:Toggle({Title = "มองเลือด (Health ESP)", Value = false, Callback = function(v) getgenv().ShowHealthESP = v end})
VisualSec:Toggle({Title = "มองกล่อง (ESP Box)", Value = false, Callback = function(v) getgenv().ShowESPBox = v end})
VisualSec:Toggle({Title = "มองของในมือ", Value = false, Callback = function(v) getgenv().ShowInventory = v end})

-- Team Section
local TeamSec = Tabs.Team:Section({Title = "Manual Selection"})
local PlayerSelect = TeamSec:Dropdown({Title = "เพื่อนที่ยกเว้น", Multi = true, Values = {}, Callback = function(List)
    local newList = {}
    for name, state in pairs(List) do if state then table.insert(newList, Players:FindFirstChild(name)) end end
    getgenv().ExcludedPlayers = newList
end})
TeamSec:Button({Title = "รีเฟรชรายชื่อ", Callback = function() 
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= Client then table.insert(names, p.Name) end end
    PlayerSelect:SetValues(names) 
end})

-- Settings Section
local AimSetSec = Tabs.Settings:Section({Title = "Aimbot Config"})
AimSetSec:Toggle({Title = "Smooth Lock", Value = true, Callback = function(v) getgenv().SmoothnessEnabled = v end})
Tabs.Settings:Slider({Title = "ความนิ่ง", Step = 1, Value = {Min = 1, Max = 20, Default = 5}, Callback = function(v) getgenv().SmoothAmount = v end})

WindUI:Notify({Title = "Kei Hub", Content = "เพิ่มระบบ FOV สีรุ้ง เรียบร้อยแล้วครับ!", Duration = 5})
