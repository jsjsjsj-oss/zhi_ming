local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/1379qpalzmtygvezimaliexcvbnqplasdfg/199/refs/heads/main/%E4%BA%91Ul.txt"))()
local Window = Library:new("Gold/Diamond道具透视")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local Settings = {
    GoldESP = true,
    DiamondESP = true,
    CopperESP = true,
    JadeESP = true,
    ShowLabel = true,
    Fly = false,
    Noclip = false,
    AutoInteract = false,
    FastInteract = false,
    SliderValue = 1
}
local function GetRealRange(sliderVal)
    return 21 - sliderVal
end

local GoldColor = Color3.fromRGB(255, 215, 0)
local DiamondColor = Color3.fromRGB(80, 220, 255)
local CopperColor = Color3.fromRGB(184, 115, 51)
local JadeColor = Color3.fromRGB(0, 168, 107)

local GoldItemNames = {"Gold","Gold Coin","GoldCoin","Knob","Knobs","Coin","Coins"}
local DiamondItemNames = {"Diamond","Gem","Crystal","Gem Pile","GemPile","Blue Gem"}
local CopperItemNames = {"Copper","铜"}
local JadeItemNames = {"Jade","翡翠"}
local BlacklistNames = {"Spawn","Spawner","Generate","Generator","Drop","Dropper","Point","Location","Marker","Trigger","Gold Pile","GoldPile"}

local Tab = Window:Tab("功能面板", '5436396975')
local SecESP = Tab:section("物品透视", true)
local SecMove = Tab:section("移动功能", true)

SecESP:Toggle("透视金币本体","GoldESP",true,function(v) Settings.GoldESP = v end)
SecESP:Toggle("透视钻石本体","DiamondESP",true,function(v) Settings.DiamondESP = v end)
SecESP:Toggle("透视铜","CopperESP",true,function(v) Settings.CopperESP = v end)
SecESP:Toggle("透视翡翠","JadeESP",true,function(v) Settings.JadeESP = v end)
SecESP:Toggle("显示文字标签","ShowLabel",true,function(v) Settings.ShowLabel = v end)
SecESP:Button("清除全部透视",function()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:GetAttribute("GoldDiaESP") then
            v:Destroy()
        end
    end
    print("已清除全部透视高亮")
end)

--飞行
SecMove:Toggle("飞行","Fly",false,function(v)
    Settings.Fly = v
    if v then
        print("正在加载飞行脚本")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
        print("飞行加载完成")
    end
end)

--低负载穿墙Noclip
local noclipConnection
SecMove:Toggle("穿墙(Noclip)","Noclip",false,function(v)
    Settings.Noclip = v
    if v then
        print("穿墙开启")
        noclipConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Noclip then return end
            local character = player.Character
            if not character then return end
            for _,part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        print("穿墙关闭")
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
            local character = player.Character
            if character then
                for _,part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end)

--快速互动
local fastInteractConn
SecMove:Toggle("快速互动(取消长按)","FastInteract",false,function(v)
    Settings.FastInteract = v
    if v then
        print("快速互动开启")
        fastInteractConn = RunService.Heartbeat:Connect(function()
            for _,prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
        end)
    else
        print("快速互动关闭")
        if fastInteractConn then
            fastInteractConn:Disconnect()
            fastInteractConn = nil
        end
    end
end)

--反向滑块
SecMove:Slider("互动距离(米)","SliderValue",1,20,Settings.SliderValue,function(v)
    Settings.SliderValue = v
    print("互动距离滑块值更新，实际距离："..GetRealRange(v))
end)

--自动互动：改用InputHoldBegin+InputHoldEnd模拟手动点击，完全无P开头服务
local autoInteractConn
SecMove:Toggle("自动互动","AutoInteract",false,function(v)
    Settings.AutoInteract = v
    if v then
        print("自动互动已开启")
        autoInteractConn = task.spawn(function()
            while Settings.AutoInteract do
                local character = player.Character
                if not character then task.wait(0.05) continue end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(0.05) continue end
                local realRange = GetRealRange(Settings.SliderValue)

                local nearestPrompt = nil
                local nearestDist = math.huge
                for _,prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local part = prompt.Parent
                        if not part:IsA("BasePart") then continue end
                        local dist = (hrp.Position - part.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestPrompt = prompt
                        end
                    end
                end

                if nearestPrompt and nearestDist <= realRange then
                    pcall(function()
                        --模拟手动按住再松开，替代单纯Trigger()，解决Doors限制
                        nearestPrompt:InputHoldBegin()
                        nearestPrompt:InputHoldEnd()
                        print("模拟按键互动成功，距离:"..math.floor(nearestDist*100)/100)
                    end)
                end
                task.wait(0.05)
            end
        end)
    else
        print("自动互动关闭")
        if autoInteractConn then
            task.cancel(autoInteractConn)
            autoInteractConn = nil
        end
    end
end)

local function ClearAllESP()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:GetAttribute("GoldDiaESP") then
            v:Destroy()
        end
    end
end

local function HasNameMatch(name,list)
    local lowName = name:lower()
    for _,n in ipairs(list) do
        if lowName == n:lower() then
            return true
        end
    end
    return false
end

local function IsBlack(name)
    local lowName = name:lower()
    for _,n in ipairs(BlacklistNames) do
        if lowName:find(n:lower(),1,true) then
            return true
        end
    end
    return false
end

local function GetMainPart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function DrawESP(obj,label,color)
    local mainPart = GetMainPart(obj)
    if not mainPart then return end

    local hl = Instance.new("Highlight")
    hl:SetAttribute("GoldDiaESP",true)
    hl.Adornee = mainPart
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = mainPart

    if Settings.ShowLabel then
        local bill = Instance.new("BillboardGui")
        bill:SetAttribute("GoldDiaESP",true)
        bill.Adornee = mainPart
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0,100,0,30)
        bill.StudsOffset = Vector3.new(0,2,0)
        bill.Parent = mainPart

        local txt = Instance.new("TextLabel")
        txt:SetAttribute("GoldDiaESP",true)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = label
        txt.TextColor3 = color
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.new(0,0,0)
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 16
        txt.Parent = bill
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if not Settings.GoldESP and not Settings.DiamondESP and not Settings.CopperESP and not Settings.JadeESP then
            ClearAllESP()
            continue
        end
        ClearAllESP()

        for _,obj in ipairs(Workspace:GetDescendants()) do
            if not (obj:IsA("Model") or obj:IsA("BasePart")) then continue end
            if IsBlack(obj.Name) then continue end

            local mp = GetMainPart(obj)
            if not mp then continue end
            if mp.Transparency >= 0.9 then continue end

            if Settings.GoldESP and HasNameMatch(obj.Name,GoldItemNames) then
                DrawESP(obj,"金币",GoldColor)
            elseif Settings.DiamondESP and HasNameMatch(obj.Name,DiamondItemNames) then
                DrawESP(obj,"钻石",DiamondColor)
            elseif Settings.CopperESP and HasNameMatch(obj.Name,CopperItemNames) then
                DrawESP(obj,"铜",CopperColor)
            elseif Settings.JadeESP and HasNameMatch(obj.Name,JadeItemNames) then
                DrawESP(obj,"翡翠",JadeColor)
            end
        end
    end
end)

--角色重生重置穿墙
player.CharacterAdded:Connect(function()
    task.wait(0.1)
    char = player.Character
    root = char:WaitForChild("HumanoidRootPart")
    print("角色重生，重置穿墙")
    if Settings.Noclip then
        noclipConnection = RunService.Heartbeat:Connect(function()
            local character = player.Character
            if not character then return end
            for _,part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

print("脚本加载完成：物品透视+飞行+穿墙+模拟按键自动互动+快速互动")
