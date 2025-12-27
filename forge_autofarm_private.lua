--[[========================================================
    THE FORGE - PRIVATE AUTO FARM FRAMEWORK
    Style: Dark Purple / Blue / Black
    Platform: Roblox (PC + Mobile)
    Usage: Private / Personal

    Arquitetura limpa, segura e extensível
==========================================================]]

----------------------------------------------------------
-- 🔒 ANTI DOUBLE LOAD
----------------------------------------------------------
if _G.__FORGE_PRIVATE_LOADED then
	warn("[Forge] Script já carregado.")
	return
end
_G.__FORGE_PRIVATE_LOADED = true

----------------------------------------------------------
-- 🧩 SERVICES
----------------------------------------------------------
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInput      = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

----------------------------------------------------------
-- ⚙ CONFIGURAÇÕES GERAIS
----------------------------------------------------------
local CONFIG = {
	SearchRadius   = 80,
	ActionDelay   = 0.35,
	MoveTimeout   = 3,
	HumanOffset   = Vector3.new(0, 0, 3),
}

----------------------------------------------------------
-- 📍 ÁREAS CONFIGURÁVEIS
----------------------------------------------------------
local AREAS = {
	["Mine A"] = {
		Center = Vector3.new(0, 0, 0),
		Radius = 90
	},
	["Mine B"] = {
		Center = Vector3.new(250, 0, 300),
		Radius = 120
	},
	["Deep Mine"] = {
		Center = Vector3.new(-400, 0, 800),
		Radius = 160
	}
}

----------------------------------------------------------
-- 💎 FILTROS DE MINÉRIO
----------------------------------------------------------
local FILTERS = {
	WhitelistEnabled = false,

	Whitelist = {
		["Diamond"] = true,
		["Mythic"]  = true,
	},

	Blacklist = {
		["Stone"] = true,
		["Coal"]  = true,
	}
}

----------------------------------------------------------
-- 🔄 ESTADO GLOBAL
----------------------------------------------------------
local STATE = {
	AutoFarm   = false,
	AutoSell   = false,
	CurrentArea = "Mine A",
	Status     = "Idle"
}

----------------------------------------------------------
-- 🧠 FUNÇÕES AUXILIARES
----------------------------------------------------------
local function setStatus(text)
	STATE.Status = text
end

local function isInsideArea(pos, area)
	return (pos - area.Center).Magnitude <= area.Radius
end

local function oreAllowed(name)
	if FILTERS.Blacklist[name] then
		return false
	end
	if FILTERS.WhitelistEnabled then
		return FILTERS.Whitelist[name] == true
	end
	return true
end

----------------------------------------------------------
-- 🚶 MOVIMENTO SEGURO (ANTI TELEPORT)
----------------------------------------------------------
local function moveToSafe(destination)
	humanoid:MoveTo(destination)
	local reached = humanoid.MoveToFinished:Wait(CONFIG.MoveTimeout)
	return reached
end

----------------------------------------------------------
-- 🔍 DETECÇÃO DE MINÉRIO (GENÉRICA)
----------------------------------------------------------
local function findNearestOre()
	local area = AREAS[STATE.CurrentArea]
	if not area then return nil end

	local closest, minDist = nil, CONFIG.SearchRadius

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.PrimaryPart and obj:FindFirstChild("OreType") then
			if not isInsideArea(obj.PrimaryPart.Position, area) then
				continue
			end

			local oreName = tostring(obj.OreType.Value)
			if not oreAllowed(oreName) then
				continue
			end

			local dist = (hrp.Position - obj.PrimaryPart.Position).Magnitude
			if dist < minDist then
				minDist = dist
				closest = obj
			end
		end
	end

	return closest
end

----------------------------------------------------------
-- ⛏ MINERAÇÃO (GENÉRICA)
----------------------------------------------------------
local function mine()
	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function()
			tool:Activate()
		end)
	end
end

----------------------------------------------------------
-- 💰 AUTO SELL (PLUGÁVEL)
----------------------------------------------------------
local function autoSell()
	-- 🔌 Conecte aqui ao sistema real do jogo
	-- Exemplo:
	-- game.ReplicatedStorage.Remotes.Sell:FireServer()

	print("[Forge] AutoSell executado (placeholder)")
end

----------------------------------------------------------
-- 🎨 UI DARK PREMIUM (MOBILE FRIENDLY)
----------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ForgePrivateUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.45, 0.55)
main.Position = UDim2.fromScale(0.04, 0.22)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 22)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(90, 70, 160)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1, 0.12)
title.Text = "THE FORGE"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(185, 170, 255)
title.TextScaled = true
title.BackgroundTransparency = 1

local statusLabel = Instance.new("TextLabel", main)
statusLabel.Position = UDim2.fromScale(0, 0.12)
statusLabel.Size = UDim2.fromScale(1, 0.08)
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(210, 210, 255)
statusLabel.TextScaled = true
statusLabel.BackgroundTransparency = 1

local function createButton(text, y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.fromScale(0.9, 0.12)
	b.Position = UDim2.fromScale(0.05, y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = Color3.fromRGB(235, 235, 255)
	b.BackgroundColor3 = Color3.fromRGB(65, 55, 130)
	Instance.new("UICorner", b)
	return b
end

local farmBtn = createButton("AUTO FARM: OFF", 0.24)
local sellBtn = createButton("AUTO SELL: OFF", 0.40)
local areaBtn = createButton("AREA: Mine A", 0.56)

----------------------------------------------------------
-- 🕹 BOTÕES
----------------------------------------------------------
farmBtn.MouseButton1Click:Connect(function()
	STATE.AutoFarm = not STATE.AutoFarm
	farmBtn.Text = STATE.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
end)

sellBtn.MouseButton1Click:Connect(function()
	STATE.AutoSell = not STATE.AutoSell
	sellBtn.Text = STATE.AutoSell and "AUTO SELL: ON" or "AUTO SELL: OFF"
end)

areaBtn.MouseButton1Click:Connect(function()
	local keys = {}
	for k in pairs(AREAS) do table.insert(keys, k) end

	local index = table.find(keys, STATE.CurrentArea) or 1
	index = index % #keys + 1
	STATE.CurrentArea = keys[index]
	areaBtn.Text = "AREA: " .. STATE.CurrentArea
end)

----------------------------------------------------------
-- 🔁 LOOP PRINCIPAL
----------------------------------------------------------
task.spawn(function()
	while task.wait(CONFIG.ActionDelay) do
		statusLabel.Text = "Status: " .. STATE.Status

		if not STATE.AutoFarm then
			setStatus("Idle")
			continue
		end

		local ore = findNearestOre()
		if ore and ore.PrimaryPart then
			setStatus("Moving")
			moveToSafe(ore.PrimaryPart.Position + CONFIG.HumanOffset)

			setStatus("Mining")
			mine()
		else
			setStatus("Searching")
		end

		if STATE.AutoSell then
			autoSell()
		end
	end
end)

print("✅ [Forge] Auto Farm Private carregado com sucesso")
