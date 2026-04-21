--[[
    KEIHUB
    - Updated: Removed Icon & Toggle Button
    - Combat: Aimbot, RGB FOV, Team Check
    - Visuals: RGB Name, ESP Box, Health ESP
    - Settings: Speed Hack (1-200), Noclip
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- เคลียร์ค่าเก่า
if getgenv().AimCircle then pcall(function() getgenv().AimCircle:Remove() end) end
getgenv().KEIHUB_LOADED = true
getgenv().ExcludedPlayers = {} 
getgenv().AimPart = "Head"
getgenv().WalkSpeedValue = 16

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [ ฟังก์ชัน Noclip ]
RunService.Stepped:Connect(function()
    if getgenv().NoclipEnabled and Client.Character then
        for _, part in pairs(Client.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- [ เช็คเพื่อน/ทีม ]
local function isPlayerExcluded(player)
    for _, excluded in ipairs(getgenv().ExcludedPlayers) do
        if excluded == player then return true end
    end
    if getgenv().AutoTeamCheck and player.Team ~= nil and player.Team == Client.Team then
        return true
    end
    return false
end

-- [ ลอจิก Aimbot ]
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
    local RGBColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    local GreenColor = Color3.fromRGB(0, 255, 127)

    -- Speed Hack
    if Client.Character and Client.Character:FindFirstChild("Humanoid") then
        Client.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
    end

    -- FOV
    if getgenv().AimCircle then
        getgenv().AimCircle.Visible = getgenv().ShowFOV or false
        getgenv().AimCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        getgenv().AimCircle.Radius = getgenv().AimbotFOV or 150
        getgenv().AimCircle.Color = getgenv().FOV_RGB and RGBColor or Color3.fromRGB(255, 255, 255)
    end

    -- Aimbot
    if getgenv().AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target then
            local SmoothValue = getgenv().SmoothnessEnabled and (getgenv().SmoothAmount or 5) or 1
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Position), 1/SmoothValue)
        end
    end

    -- Visuals
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Client and p.Character and p.Character:FindFirstChild("Humanoid") then
            local Hum = p.Character.Humanoid
            local CurrentColor = isPlayerExcluded(p) and GreenColor or RGBColor
            
            if getgenv().ShowNamesRGB and p.Character:FindFirstChild("HumanoidRootPart") then
                local tag = p.Character.HumanoidRootPart:FindFirstChild("KEI_ESP")
                if not tag then
                    tag = Instance.new("BillboardGui", p.Character.HumanoidRootPart)
                    tag.Name = "KEI_ESP"
                    tag.Size = UDim2.new(0, 200, 0, 50)
                    tag.AlwaysOnTop = true
                    tag.StudsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", tag)
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.TextSize = 14
                    l.Font = Enum.Font.GothamBold
                    l.Name = "Label"
                end
                tag.Label.Text = p.Name .. (getgenv().ShowHealthESP and " ["..math.floor(Hum.Health).."]" or "")
                tag.Label.TextColor3 = CurrentColor
                tag.Enabled = true
            end

            if getgenv().ShowESPBox then
                local box = p.Character:FindFirstChild("KEI_BOX")
                if not box then
                    box = Instance.new("SelectionBox", p.Character)
                    box.Name = "KEI_BOX"
                    box.LineThickness = 0.05
                    box.Adornee = p.Character
                end
                box.Visible = true
                box.Color3 = CurrentColor
            elseif p.Character:FindFirstChild("KEI_BOX") then
                p.Character.KEI_BOX:Destroy()
            end
        end
    end
end)

-- [ UI Setup - เปลี่ยนชื่อและเอา Icon ออก ]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "KEIHUB", -- เปลี่ยนชื่อแล้ว
    Icon = nil,        -- เอาอนิเมะ/ไอคอนออกแล้ว
    Author = "Kim",
    Folder = "KeiHubConfig",
    Size = UDim2.fromOffset(360, 560),
    Transparent = true,
    Theme = "Dark"
})

local Tabs = {
    Combat = Window:Tab({Title = "Combat", Icon = "crosshair"}),
    Visuals = Window:Tab({Title = "Visuals", Icon = "eye"}),
    Settings = Window:Tab({Title = "Settings", Icon = "settings"}),
    Team = Window:Tab({Title = "Team", Icon = "users"})
}

-- Combat
local CombatSec = Tabs.Combat:Section({Title = "Aimbot Settings"})
CombatSec:Toggle({Title = "เปิดใช้งาน Aimbot", Value = false, Callback = function(v) getgenv().AimbotEnabled = v end})
CombatSec:Toggle({Title = "Auto Team Check", Value = false, Callback = function(v) getgenv().AutoTeamCheck = v end})
CombatSec:Dropdown({Title = "ตำแหน่งล็อคเป้า", Values = {"Head", "HumanoidRootPart"}, Callback = function(v) getgenv().AimPart = v end})
CombatSec:Toggle({Title = "แสดงวงกลม FOV", Value = false, Callback = function(v) getgenv().ShowFOV = v end})
CombatSec:Toggle({Title = "FOV สีรุ้ง (RGB)", Value = false, Callback = function(v) getgenv().FOV_RGB = v end})
Tabs.Combat:Slider({Title = "ขนาด FOV", Step = 1, Value = {Min = 50, Max = 800, Default = 150}, Callback = function(v) getgenv().AimbotFOV = v end})

-- Visuals
local VisualSec = Tabs.Visuals:Section({Title = "ESP Options"})
VisualSec:Toggle({Title = "มองชื่อ (Name ESP)", Value = false, Callback = function(v) getgenv().ShowNamesRGB = v end})
VisualSec:Toggle({Title = "มองเลือด (Health ESP)", Value = false, Callback = function(v) getgenv().ShowHealthESP = v end})
VisualSec:Toggle({Title = "มองกล่อง (ESP Box)", Value = false, Callback = function(v) getgenv().ShowESPBox = v end})

-- Settings
local MoveSec = Tabs.Settings:Section({Title = "Movement Settings"})
Tabs.Settings:Slider({
    Title = "ความเร็วการเคลื่อนที่ (Speed)", 
    Step = 1, 
    Value = {Min = 16, Max = 200, Default = 16}, 
    Callback = function(v) getgenv().WalkSpeedValue = v end
})
MoveSec:Toggle({Title = "เดินทะลุกำแพง (Noclip)", Value = false, Callback = function(v) getgenv().NoclipEnabled = v end})

local AimSetSec = Tabs.Settings:Section({Title = "Aimbot Config"})
AimSetSec:Toggle({Title = "Smooth Lock", Value = true, Callback = function(v) getgenv().SmoothnessEnabled = v end})
Tabs.Settings:Slider({Title = "ความนิ่ง", Step = 1, Value = {Min = 1, Max = 20, Default = 5}, Callback = function(v) getgenv().SmoothAmount = v end})

-- Team
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

-- ลบปุ่มปิด (Toggle Button) ออกแล้ว ถ้าต้องการปิดเมนูให้กดปุ่ม Insert หรือ RightControl ตามมาตรฐานของ UI ครับ

WindUI:Notify({Title = "KEIHUB", Content = "อัปเดต UI ให้คลีนตามคำขอแล้วครับ!", Duration = 5})
