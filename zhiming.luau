local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/jsjsjsj-oss/ui/d153c32c075e60c065f279068eef7f18c8601e08/2.lua"))()
local Window = Library:new("致命猿")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local Settings = {
    GoldESP = false,
    DiamondESP = false,
    CopperESP = false,
    EmeraldESP = false,
    BlackGemESP = false,
    RubyESP = false,
    AmethystESP = false,
    PlayerESP = false,
    NpcESP = false,
    ShowLabel = false,
    Fly = false,
    Noclip = false,
    AutoInteract = false,
    FastInteract = false,
    SliderValue = 1,
    LoopTeleportMineral = false
}
local teleportLoopThread = nil

local function GetRealRange(sliderVal)
    return 21 - sliderVal
end

local GoldColor = Color3.fromRGB(255, 215, 0)
local DiamondColor = Color3.fromRGB(80, 220, 255)
local CopperColor = Color3.fromRGB(184, 115, 51)
local EmeraldColor = Color3.fromRGB(0, 255, 128)
local BlackGemColor = Color3.fromRGB(40, 40, 55)
local RubyColor = Color3.fromRGB(255, 0, 128)
local AmethystColor = Color3.fromRGB(153, 50, 204)
local EnemyColor = Color3.fromRGB(255, 0, 0)
local AllyColor = Color3.fromRGB(0, 255, 0)
local NpcColor = Color3.fromRGB(255, 100, 0)

local GoldItemNames = {"Gold","Gold Coin","GoldCoin","Knob","Knobs","Coin","Coins"}
local DiamondItemNames = {"Diamond","Gem","Crystal","Gem Pile","GemPile","Blue Gem"}
local CopperItemNames = {"Copper","铜"}
local EmeraldItemNames = {"Emerald","绿宝石","绿晶","GreenGem"}
local BlackGemItemNames = {"Crystalized Slime"}
local RubyItemNames = {"Ruby","红宝石"}
local AmethystItemNames = {"Amethyst","紫宝石"}

local TeleportMineralLists = {
    GoldItemNames,
    DiamondItemNames,
    CopperItemNames,
    EmeraldItemNames,
    RubyItemNames,
    AmethystItemNames
}

local BlacklistNames = {
    "Spawn","Spawner","Generate","Generator","Drop","Dropper",
    "Point","Location","Marker","Trigger","Gold Pile","GoldPile",
    "spawnlocation"
}

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
        return obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function IsHeldByPlayer(obj)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Character and obj:IsDescendantOf(plr.Character) then
            return true
        end
    end
    return false
end

-- ==========致命猿专用怪物驱逐函数==========
local function RepelApeMonster(hrp, range)
    local foundMonster = false
    local monsterNames = {"Dus","Bloodman","Sandman","Gus","Kus","Ashy","Gooba","Lost","Lurker","Scar"}
    for _,obj in ipairs(Workspace:GetDescendants()) do
        local isMonster = false
        for _,mName in monsterNames do
            if obj.Name:lower():find(mName:lower()) then
                isMonster = true
                break
            end
        end
        if isMonster and obj:IsA("Model") then
            local monsterRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("RootPart")
            if monsterRoot then
                local dist = (hrp.Position - monsterRoot.Position).Magnitude
                if dist <= range then
                    monsterRoot.CFrame = hrp.CFrame + Vector3.new(0,5,20)
                    foundMonster = true
                    print("⚠️怪物已推开，距离:"..math.floor(dist))
                end
            end
        end
    end
    return foundMonster
end

local function TeleportToNearestMineral()
    pcall(function()
        local character = player.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local hasMonster = RepelApeMonster(hrp,10)
        if hasMonster then
            return
        end

        local nearestMineral = nil
        local nearestDistance = math.huge

        for _,obj in ipairs(Workspace:GetDescendants()) do
            if not (obj:IsA("Model") or obj:IsA("BasePart")) then continue end
            if IsBlack(obj.Name) then continue end
            if IsHeldByPlayer(obj) then continue end

            local isMineral = false
            for _,list in ipairs(TeleportMineralLists) do
                if HasNameMatch(obj.Name, list) then
                    isMineral = true
                    break
                end
            end
            if not isMineral then continue end

            local mp = GetMainPart(obj)
            if not mp then continue end
            if mp.Transparency >= 0.9 then continue end
            local dist = (hrp.Position - mp.Position).Magnitude
            if dist < nearestDistance then
                nearestDistance = dist
                nearestMineral = mp
            end
        end

        if nearestMineral then
            hrp.CFrame = nearestMineral.CFrame + Vector3.new(0,3,0)
            print("✅传送矿石，距离:"..math.floor(nearestDistance))
        else
            print("❌无矿石")
        end
    end)
end

local Tab = Window:Tab("功能面板")
local SecESP = Tab:section("物品透视", true)
local SecMove = Tab:section("移动功能", true)

SecESP:Toggle("透视金条","GoldESP",true,function(v) Settings.GoldESP = v end)
SecESP:Toggle("透视钻石","DiamondESP",true,function(v) Settings.DiamondESP = v end)
SecESP:Toggle("透视铜","CopperESP",true,function(v) Settings.CopperESP = v end)
SecESP:Toggle("透视绿宝石","EmeraldESP",true,function(v) Settings.EmeraldESP = v end)
SecESP:Toggle("透视黑宝石","BlackGemESP",true,function(v) Settings.BlackGemESP = v end)
SecESP:Toggle("透视红宝石","RubyESP",true,function(v) Settings.RubyESP = v end)
SecESP:Toggle("透视紫宝石","AmethystESP",true,function(v) Settings.AmethystESP = v end)
SecESP:Toggle("玩家透视","PlayerESP",false,function(v) Settings.PlayerESP = v end)
SecESP:Toggle("NPC透视(不显示名字)","NpcESP",false,function(v) Settings.NpcESP = v end)
SecESP:Toggle("显示文字标签","ShowLabel",true,function(v) Settings.ShowLabel = v end)
SecESP:Button("单次传送最近矿物",TeleportToNearestMineral)
SecESP:Toggle("循环自动传送矿物","LoopTeleportMineral",false,function(v)
    Settings.LoopTeleportMineral = v
    if v then
        print("🔄开启循环传送 0.3s | 10米怪物自动推开")
        teleportLoopThread = task.spawn(function()
            while Settings.LoopTeleportMineral do
                TeleportToNearestMineral()
                task.wait(0.3)
            end
        end)
    else
        print("⏹关闭循环传送")
        if teleportLoopThread then
            task.cancel(teleportLoopThread)
            teleportLoopThread = nil
        end
    end
end)

SecESP:Button("清除全部透视",function()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and (v:GetAttribute("GoldDiaESP") or v:GetAttribute("PlayerESP") or v:GetAttribute("NpcESP")) then
            v:Destroy()
        end
        if v:IsA("BillboardGui") and (v:GetAttribute("GoldDiaESP") or v:GetAttribute("PlayerESP") or v:GetAttribute("NpcESP")) then
            v:Destroy()
        end
    end
    print("已清除全部透视高亮+文字标签")
end)

SecMove:Toggle("飞行","Fly",false,function(v)
    Settings.Fly = v
    if v then
        print("正在加载飞行模块")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
        print("飞行加载完成")
    end
end)

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
        end
        local character = player.Character
        if character then
            for _,part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

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

SecMove:Slider("互动距离(米)","SliderValue",1,20,Settings.SliderValue,function(v)
    Settings.SliderValue = v
    print("互动距离更新："..GetRealRange(v))
end)

local autoInteractConn
SecMove:Toggle("自动互动","AutoInteract",false,function(v)
    Settings.AutoInteract = v
    if v then
        print("自动互动已开启")
        autoInteractConn = task.spawn(function()
            while Settings.AutoInteract do
                local character = player.Character
                if not character then task.wait(0.3) continue end
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(0.3) continue end
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
                        nearestPrompt:InputHoldBegin()
                        nearestPrompt:InputHoldEnd()
                        print("自动互动成功，距离:"..math.floor(nearestDist*10)/10)
                    end)
                end
                task.wait(0.3)
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

local function DrawNpcESP(obj,color,attr)
    local mainPart = GetMainPart(obj)
    if not mainPart then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl:SetAttribute(attr,true)
    hl.Parent = mainPart
end

local function DrawESP(obj,label,color,attr)
    if IsHeldByPlayer(obj) then return end
    local mainPart = GetMainPart(obj)
    if not mainPart then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1,1,1)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl:SetAttribute(attr,true)
    hl.Parent = mainPart

    if Settings.ShowLabel then
        local bill = Instance.new("BillboardGui")
        bill.Adornee = mainPart
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0,100,0,30)
        bill.StudsOffset = Vector3.new(0,2,0)
        bill:SetAttribute(attr,true)
        bill.Parent = mainPart

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = label
        txt.TextColor3 = color
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.new(0,0,0)
        txt.Font = Enum.Font.SourceSans
        txt.TextSize = 16
        txt.Parent = bill
    end
end

task.spawn(function()
    while task.wait(0.5) do
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Highlight") or v:IsA("BillboardGui") then
                local attr = v:GetAttribute("GoldDiaESP") or v:GetAttribute("PlayerESP") or v:GetAttribute("NpcESP")
                if attr then
                    v:Destroy()
                end
            end
        end

        if Settings.GoldESP or Settings.DiamondESP or Settings.CopperESP or Settings.EmeraldESP or Settings.BlackGemESP or Settings.RubyESP or Settings.AmethystESP then
            for _,obj in ipairs(Workspace:GetDescendants()) do
                if not (obj:IsA("Model") or obj:IsA("BasePart")) then continue end
                if IsBlack(obj.Name) then continue end
                if IsHeldByPlayer(obj) then continue end
                local mp = GetMainPart(obj)
                if not mp or mp.Transparency >= 0.9 then continue end

                local targetLabel,targetColor
                if Settings.GoldESP and HasNameMatch(obj.Name,GoldItemNames) then
                    targetLabel,targetColor = "金条",GoldColor
                elseif Settings.DiamondESP and HasNameMatch(obj.Name,DiamondItemNames) then
                    targetLabel,targetColor = "钻石",DiamondColor
                elseif Settings.CopperESP and HasNameMatch(obj.Name,CopperItemNames) then
                    targetLabel,targetColor = "铜",CopperColor
                elseif Settings.EmeraldESP and HasNameMatch(obj.Name,EmeraldItemNames) then
                    targetLabel,targetColor = "绿宝石",EmeraldColor
                elseif Settings.BlackGemESP and HasNameMatch(obj.Name,BlackGemItemNames) then
                    targetLabel,targetColor = "黑宝石",BlackGemColor
                elseif Settings.RubyESP and HasNameMatch(obj.Name,RubyItemNames) then
                    targetLabel,targetColor = "红宝石",RubyColor
                elseif Settings.AmethystESP and HasNameMatch(obj.Name,AmethystItemNames) then
                    targetLabel,targetColor = "紫宝石",AmethystColor
                end

                if targetLabel then
                    DrawESP(obj,targetLabel,targetColor,"GoldDiaESP")
                end
            end
        end

        if Settings.NpcESP then
            for _,obj in ipairs(Workspace:GetDescendants()) do
                if not obj:IsA("Model") then continue end
                local isMonster = false
                local monsterNames = {"Dus","Bloodman","Sandman","Gus","Kus","Ashy","Gooba","Lost","Lurker","Scar"}
                for _,mName in monsterNames do
                    if obj.Name:lower():find(mName:lower()) then
                        isMonster = true
                        break
                    end
                end
                if isMonster then
                    local mp = GetMainPart(obj)
                    if mp and mp.Transparency < 0.9 then
                        DrawNpcESP(obj,NpcColor,"NpcESP")
                    end
                end
            end
        end

        -- =========修复玩家ESP 队伍颜色逻辑=========
        if Settings.PlayerESP then
            for _,targetPlr in ipairs(Players:GetPlayers()) do
                if targetPlr ~= player and targetPlr.Character then
                    local charPlr = targetPlr.Character
                    local hum = charPlr:FindFirstChildOfClass("Humanoid")
                    local mp = charPlr:FindFirstChild("HumanoidRootPart")
                    if hum and mp then
                        -- 判断队伍
                        local playerColor = (targetPlr.Team == player.Team) and AllyColor or EnemyColor
                        DrawESP(charPlr, targetPlr.Name, playerColor, "PlayerESP")
                    end
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.1)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    if Settings.Noclip then
        for _,part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
local StarterGui = game:GetService("StarterGui")
local function PopNotify(title,msg,time)
    StarterGui:SetCore("SendNotification",{
        Title = title,
        Text = msg,
        Duration = time
    })
end
PopNotify("致命猿","脚本加载成功",3)
PopNotify("制作人","龙乐乐",3)
