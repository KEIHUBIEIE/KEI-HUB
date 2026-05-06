if not game:IsLoaded() then game.Loaded:Wait() end

-- [ SETTINGS ]
getgenv().SilentAimEnabled = false
getgenv().HitSoundEnabled = true -- เปิด/ปิดเสียงยิงโดน
getgenv().HitSoundID = "rbxassetid://160432334" -- ID เสียง (เสียง Bell)
getgenv().AimPart = "Head"
getgenv().SilentAimFOV = 150
getgenv().RGB_Speed = 1.5

getgenv().ShowVisualsMaster = false
getgenv().ESP_Box = false 
getgenv().ESP_Name = false

getgenv().WalkSpeedEnabled = false
getgenv().WalkSpeedValue = 50

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponHit = ReplicatedStorage:WaitForChild("Eventos", 5):WaitForChild("WeaponHit", 5)

-- [ FUNCTIONS ]
local function PlayHitSound()
    if getgenv().HitSoundEnabled then
        local Sound = Instance.new("Sound")
        Sound.SoundId = getgenv().HitSoundID
        Sound.Volume = 2
        Sound.Parent = game:GetService("SoundService")
        Sound:Play()
        Sound.Ended:Connect(function()
            Sound:Destroy()
        end)
    end
end

local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = getgenv().SilentAimFOV
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local Part = v.Character:FindFirstChild(getgenv().AimPart)
            if Part then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    if Dist < ShortestDist then
                        ShortestDist = Dist
                        Target = v.Character
                    end
                end
            end
        end
    end
    return Target
end

-- [ BEAM SYSTEM ]
local function CreateBeam(StartPos, EndPos)
    if not getgenv().SilentAimEnabled then return end
    local BeamPart = Instance.new("Part")
    BeamPart.Name = "KeiHub_Beam"
    BeamPart.Transparency = 1
    BeamPart.CanCollide = false
    BeamPart.Anchored = true
    BeamPart.Parent = workspace.Terrain
    local Attachment0 = Instance.new("Attachment", BeamPart)
    local Attachment1 = Instance.new("Attachment", BeamPart)
    Attachment0.WorldPosition = StartPos
    Attachment1.WorldPosition = EndPos
    local Beam = Instance.new("Beam", BeamPart)
    Beam.Attachment0 = Attachment0
    Beam.Attachment1 = Attachment1
    local Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    Beam.Color = ColorSequence.new(Color)
    Beam.Width0 = 0.2; Beam.Width1 = 0.2; Beam.FaceCamera = true
    task.delay(0.5, function()
        for i = 0, 1, 0.1 do
            if Beam:IsA("Beam") then Beam.Transparency = NumberSequence.new(i) end
            task.wait(0.02)
        end
        BeamPart:Destroy()
    end)
end

-- [ ESP SYSTEM ]
local function CreateESP(Player)
    local Lines = {
        TL1 = Drawing.new("Line"), TL2 = Drawing.new("Line"),
        TR1 = Drawing.new("Line"), TR2 = Drawing.new("Line"),
        BL1 = Drawing.new("Line"), BL2 = Drawing.new("Line"),
        BR1 = Drawing.new("Line"), BR2 = Drawing.new("Line")
    }
    local Name = Drawing.new("Text")
    Name.Size = 16; Name.Center = true; Name.Outline = true; Name.Font = 2
    RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.Humanoid.Health > 0 then
            local Root = Player.Character.HumanoidRootPart
            local Head = Player.Character:FindFirstChild("Head")
            local RootPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if OnScreen and getgenv().ShowVisualsMaster then
                local RGB = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                if getgenv().ESP_Box then
                    local HeadP = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                    local LegP = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))
                    local H = math.abs(HeadP.Y - LegP.Y); local W = H / 1.5
                    local X, Y = RootPos.X - W/2, RootPos.Y - H/2; local S = W/4
                    local function L(Line, F, T)
                        Line.From = F; Line.To = T; Line.Color = RGB; Line.Thickness = 1.8; Line.Visible = true
                    end
                    L(Lines.TL1, Vector2.new(X, Y), Vector2.new(X + S, Y)); L(Lines.TL2, Vector2.new(X, Y), Vector2.new(X, Y + S))
                    L(Lines.TR1, Vector2.new(X + W, Y), Vector2.new(X + W - S, Y)); L(Lines.TR2, Vector2.new(X + W, Y), Vector2.new(X + W, Y + S))
                    L(Lines.BL1, Vector2.new(X, Y + H), Vector2.new(X + S, Y + H)); L(Lines.BL2, Vector2.new(X, Y + H), Vector2.new(X, Y + H - S))
                    L(Lines.BR1, Vector2.new(X + W, Y + H), Vector2.new(X + W - S, Y + H)); L(Lines.BR2, Vector2.new(X + W, Y + H), Vector2.new(X + W, Y + H - S))
                else for _,v in pairs(Lines) do v.Visible = false end end
                if getgenv().ESP_Name then
                    Name.Position = Vector2.new(RootPos.X, RootPos.Y - 40)
                    Name.Text = Player.Name; Name.Color = Color3.new(1,1,1); Name.Visible = true
                else Name.Visible = false end
            else for _,v in pairs(Lines) do v.Visible = false end Name.Visible = false end
        else for _,v in pairs(Lines) do v.Visible = false end Name.Visible = false end
    end)
end

for _, v in pairs(Players:GetPlayers()) do if v ~= Client then CreateESP(v) end end
Players.PlayerAdded:Connect(function(v) CreateESP(v) end)

-- [ CORE HOOK ]
local OldNC
OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local A = {...}
    if self.Name == "WeaponFired" and getnamecallmethod() == "FireServer" and getgenv().SilentAimEnabled then
        local T = GetClosestPlayer()
        if T and T:FindFirstChild(getgenv().AimPart) then
            local P = T[getgenv().AimPart]
            local Origin = (Client.Character and Client.Character:FindFirstChild("Head")) and Client.Character.Head.Position or Vector3.new(0,0,0)
            
            -- เมื่อกดยิงและระบบ Silent Aim ทำงาน
            CreateBeam(Origin, P.Position)
            PlayHitSound() -- เล่นเสียงเมื่อยิงโดน (Silent Aim ทำงาน)
            
            local NA = {A[1], {p = P.Position, part = P, h = T.Humanoid, d = (Origin - P.Position).Magnitude, sid = A[2] and A[2].sid or "Bullet"}}
            task.spawn(function() WeaponHit:FireServer(unpack(NA)) end)
        end
    end
    return OldNC(self, ...)
end)

-- [ UI WindUI ]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({ 
    Title = "KEI HUB", 
    Author = "Kim", 
    Icon = "rbxassetid://132717838566270", 
    Theme = "Dark" 
})

local Tabs = { 
    Main = Window:Tab({Title = "Combat", Icon = "rbxassetid://132717838566270"}), 
    Visuals = Window:Tab({Title = "Visuals", Icon = "rbxassetid://10734950309"}),
    Settings = Window:Tab({Title = "Settings", Icon = "settings"}) 
}

local AimS = Tabs.Main:Section({Title = "Main Combat"})
AimS:Toggle({Title = "Silent Aim", Callback = function(v) getgenv().SilentAimEnabled = v end})
AimS:Toggle({Title = "Hit Sound", Value = true, Callback = function(v) getgenv().HitSoundEnabled = v end}) -- ปุ่มเปิด/ปิดเสียง
AimS:Slider({Title = "FOV Radius", Step = 1, Value = {Min = 30, Max = 800, Default = 150}, Callback = function(v) getgenv().SilentAimFOV = v end})

local EspS = Tabs.Visuals:Section({Title = "ESP Master"})
EspS:Toggle({Title = "Enable ESP", Callback = function(v) getgenv().ShowVisualsMaster = v end})
EspS:Toggle({Title = "Corner Box", Callback = function(v) getgenv().ESP_Box = v end})
EspS:Toggle({Title = "Player Names", Callback = function(v) getgenv().ESP_Name = v end})

local MoveS = Tabs.Settings:Section({Title = "Misc"})
MoveS:Toggle({Title = "Speed Hack", Callback = function(v) getgenv().WalkSpeedEnabled = v end})
MoveS:Slider({Title = "WalkSpeed", Step = 1, Value = {Min = 16, Max = 250, Default = 50}, Callback = function(v) getgenv().WalkSpeedValue = v end})

-- [ DRAWING LOOP ]
local FOVLines = {}
for i = 1, 8 do
    FOVLines[i] = Drawing.new("Line")
    FOVLines[i].Thickness = 2; FOVLines[i].Visible = false
end
local Snapline = Drawing.new("Line")
Snapline.Thickness = 1.5; Snapline.Visible = false

RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local TChar = GetClosestPlayer()
    local Time = tick() * getgenv().RGB_Speed
    for i = 1, 8 do
        if getgenv().SilentAimEnabled then
            local a1 = math.rad((i-1) * 45); local a2 = math.rad(i * 45)
            FOVLines[i].From = Center + Vector2.new(math.cos(a1) * getgenv().SilentAimFOV, math.sin(a1) * getgenv().SilentAimFOV)
            FOVLines[i].To   = Center + Vector2.new(math.cos(a2) * getgenv().SilentAimFOV, math.sin(a2) * getgenv().SilentAimFOV)
            FOVLines[i].Color = Color3.fromHSV((Time + (i/8)) % 1, 1, 1); FOVLines[i].Visible = true
        else FOVLines[i].Visible = false end
    end
    if TChar and TChar:FindFirstChild(getgenv().AimPart) and getgenv().SilentAimEnabled then
        local Pos, OnS = Camera:WorldToViewportPoint(TChar[getgenv().AimPart].Position)
        if OnS then
            Snapline.From = Center; Snapline.To = Vector2.new(Pos.X, Pos.Y)
            Snapline.Color = Color3.fromHSV(Time % 1, 1, 1); Snapline.Visible = true
        else Snapline.Visible = false end
    else Snapline.Visible = false end
    if getgenv().WalkSpeedEnabled and Client.Character and Client.Character:FindFirstChild("Humanoid") then 
        Client.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue 
    end
end)

WindUI:Notify({Title = "KEI HUB", Content = "Hit Sound & Silent Aim Ready!", Duration = 3})
