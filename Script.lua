local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configurações do Speed Glitch
local NORMAL_SPEED = 16
local MAX_SPEED_GRADUAL = 200
local MAX_SPEED_BRUTE = 350
local MIN_ROTATION_THRESHOLD = 0.012
local BASE_ACCELERATION = 1200

local currentSpeed = NORMAL_SPEED
local lastCameraCF = camera.CFrame
local isBruteMode = false
local isMinimized = false
local isHidden = false
local isSpeedEnabled = true
local isNoclipActive = false
local isInfJumpActive = false
local isFullbrightActive = false
local isEspActive = false

local espCache = {}

-- Salva iluminação original
local defaultBrightness = Lighting.Brightness
local defaultClockTime = Lighting.ClockTime
local defaultFogEnd = Lighting.FogEnd
local defaultGlobalShadows = Lighting.GlobalShadows
local defaultAmbient = Lighting.Ambient

-- Interface Principal do Hub
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Iv4dScriptsHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Borda Externa Animada
local borderFrame = Instance.new("Frame")
borderFrame.Name = "BorderFrame"
borderFrame.Size = UDim2.new(0, 235, 0, 350)
borderFrame.Position = UDim2.new(0.5, -117, 0.16, 0)
borderFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
borderFrame.BorderSizePixel = 0
borderFrame.Active = true
borderFrame.Draggable = true
borderFrame.Parent = screenGui

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 10)
borderCorner.Parent = borderFrame

local borderGradient = Instance.new("UIGradient")
borderGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 255, 127)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 100, 50)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(50, 255, 170)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 127))
}
borderGradient.Rotation = 0
borderGradient.Parent = borderFrame

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, -4, 1, -4)
mainFrame.Position = UDim2.new(0, 2, 0, 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 15)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = borderFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Barra Superior
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(22, 28, 22)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -70, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Iv4d Scripts"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Botão Esconder Hub (Olho)
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 30, 0, 30)
hideButton.Position = UDim2.new(1, -64, 0, 2)
hideButton.BackgroundTransparency = 1
hideButton.Text = "👁️"
hideButton.TextColor3 = Color3.fromRGB(0, 255, 127)
hideButton.TextSize = 14
hideButton.Font = Enum.Font.GothamBold
hideButton.Parent = topBar

-- Botão Flutuante para Reabrir o Hub
local unhideButton = Instance.new("TextButton")
unhideButton.Name = "UnhideButton"
unhideButton.Size = UDim2.new(0, 45, 0, 45)
unhideButton.Position = UDim2.new(0.05, 0, 0.4, 0)
unhideButton.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
unhideButton.Text = "🙈"
unhideButton.TextSize = 22
unhideButton.Active = true
unhideButton.Draggable = true
unhideButton.Visible = false
unhideButton.Parent = screenGui

local unhideCorner = Instance.new("UICorner")
unhideCorner.CornerRadius = UDim.new(1, 0)
unhideCorner.Parent = unhideButton

local unhideStroke = Instance.new("UIStroke")
unhideStroke.Color = Color3.fromRGB(0, 255, 127)
unhideStroke.Thickness = 2
unhideStroke.Parent = unhideButton

-- Botão Minimizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -32, 0, 2)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(0, 255, 127)
minimizeButton.TextSize = 18
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = topBar

-- Container de Conteúdo
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -35)
contentContainer.Position = UDim2.new(0, 0, 0, 35)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local function createMenuButton(text, posy)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 32)
	btn.Position = UDim2.new(0, 10, 0, posy)
	btn.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(180, 180, 180)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamMedium
	btn.Parent = contentContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 70, 70)
	stroke.Thickness = 1.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn

	return btn, stroke
end

local modeButton, btnStroke1 = createMenuButton("Modo: Gradual (200)", 6)
modeButton.TextColor3 = Color3.fromRGB(0, 255, 127)
btnStroke1.Color = Color3.fromRGB(0, 255, 127)

local toggleSpeedButton, btnStrokeToggle = createMenuButton("Speed Glitch: ON ⚡", 42)
toggleSpeedButton.BackgroundColor3 = Color3.fromRGB(25, 50, 35)
toggleSpeedButton.TextColor3 = Color3.fromRGB(0, 255, 127)
btnStrokeToggle.Color = Color3.fromRGB(0, 255, 127)

local espButton, btnStrokeEsp = createMenuButton("ESP Roles (MM2): OFF 👁️", 78)
local noclipButton, btnStrokeNoclip = createMenuButton("Noclip: OFF 👻", 114)
local infJumpButton, btnStrokeJump = createMenuButton("Infinite Jump: OFF 🦘", 150)
local fullbrightButton, btnStrokeBright = createMenuButton("Fullbright: OFF 💡", 186)

local floatIconButton, btnStrokeFloat = createMenuButton("Bolinha Speed ⚡", 226)
floatIconButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
floatIconButton.TextColor3 = Color3.fromRGB(150, 200, 255)
btnStrokeFloat.Color = Color3.fromRGB(100, 150, 255)

-- Mini Botão Flutuante de Speed
local miniFloat = Instance.new("TextButton")
miniFloat.Name = "MiniFloatButton"
miniFloat.Size = UDim2.new(0, 45, 0, 45)
miniFloat.Position = UDim2.new(0.85, 0, 0.35, 0)
miniFloat.BackgroundColor3 = Color3.fromRGB(15, 35, 20)
miniFloat.Text = "⚡"
miniFloat.TextColor3 = Color3.fromRGB(0, 255, 127)
miniFloat.TextSize = 20
miniFloat.Active = true
miniFloat.Draggable = true
miniFloat.Visible = false
miniFloat.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniFloat

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(0, 255, 127)
miniStroke.Thickness = 2
miniStroke.Parent = miniFloat

-- Animação da Borda
RunService.RenderStepped:Connect(function()
	borderGradient.Rotation = (borderGradient.Rotation + 2) % 360
end)

-- Minimizar / Expandir
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
minimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		minimizeButton.Text = "+"
		TweenService:Create(borderFrame, tweenInfo, {Size = UDim2.new(0, 235, 0, 39)}):Play()
		TweenService:Create(contentContainer, TweenInfo.new(0.2), {Position = UDim2.new(0, 0, 0, 275)}):Play()
	else
		minimizeButton.Text = "-"
		TweenService:Create(borderFrame, tweenInfo, {Size = UDim2.new(0, 235, 0, 350)}):Play()
		TweenService:Create(contentContainer, TweenInfo.new(0.2), {Position = UDim2.new(0, 0, 0, 35)}):Play()
	end
end)

-- Esconder / Mostrar Hub
hideButton.MouseButton1Click:Connect(function()
	isHidden = true
	borderFrame.Visible = false
	unhideButton.Visible = true
end)

unhideButton.MouseButton1Click:Connect(function()
	isHidden = false
	borderFrame.Visible = true
	unhideButton.Visible = false
end)

-- Alternar Modo Speed
modeButton.MouseButton1Click:Connect(function()
	isBruteMode = not isBruteMode
	if isBruteMode then
		modeButton.Text = "Modo: BRUTO ⚡ (350)"
		modeButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
		modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		btnStroke1.Color = Color3.fromRGB(255, 60, 60)
	else
		modeButton.Text = "Modo: Gradual (200)"
		modeButton.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
		modeButton.TextColor3 = Color3.fromRGB(0, 255, 127)
		btnStroke1.Color = Color3.fromRGB(0, 255, 127)
	end
end)

-- Toggle Speed Global
local function toggleSpeedState()
	isSpeedEnabled = not isSpeedEnabled
	if isSpeedEnabled then
		toggleSpeedButton.Text = "Speed Glitch: ON ⚡"
		toggleSpeedButton.BackgroundColor3 = Color3.fromRGB(25, 50, 35)
		toggleSpeedButton.TextColor3 = Color3.fromRGB(0, 255, 127)
		btnStrokeToggle.Color = Color3.fromRGB(0, 255, 127)
		miniStroke.Color = Color3.fromRGB(0, 255, 127)
		miniFloat.BackgroundColor3 = Color3.fromRGB(15, 35, 20)
	else
		toggleSpeedButton.Text = "Speed Glitch: OFF ❌"
		toggleSpeedButton.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
		toggleSpeedButton.TextColor3 = Color3.fromRGB(255, 100, 100)
		btnStrokeToggle.Color = Color3.fromRGB(255, 100, 100)
		miniStroke.Color = Color3.fromRGB(255, 100, 100)
		miniFloat.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
	end
end

toggleSpeedButton.MouseButton1Click:Connect(toggleSpeedState)
miniFloat.MouseButton1Click:Connect(toggleSpeedState)

-- Toggle ESP
espButton.MouseButton1Click:Connect(function()
	isEspActive = not isEspActive
	if isEspActive then
		espButton.Text = "ESP Roles (MM2): ON 👁️"
		espButton.BackgroundColor3 = Color3.fromRGB(25, 50, 35)
		espButton.TextColor3 = Color3.fromRGB(0, 255, 127)
		btnStrokeEsp.Color = Color3.fromRGB(0, 255, 127)
	else
		espButton.Text = "ESP Roles (MM2): OFF 👁️"
		espButton.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
		espButton.TextColor3 = Color3.fromRGB(180, 180, 180)
		btnStrokeEsp.Color = Color3.fromRGB(70, 70, 70)

		for _, espObj in pairs(espCache) do
			if espObj then espObj:Remove() end
		end
		espCache = {}
	end
end)

-- Toggle Noclip
noclipButton.MouseButton1Click:Connect(function()
	isNoclipActive = not isNoclipActive
	if isNoclipActive then
		noclipButton.Text = "Noclip: ON 👻"
		noclipButton.BackgroundColor3 = Color3.fromRGB(25, 50, 35)
		noclipButton.TextColor3 = Color3.fromRGB(0, 255, 127)
		btnStrokeNoclip.Color = Color3.fromRGB(0, 255, 127)
	else
		noclipButton.Text = "Noclip: OFF 👻"
		noclipButton.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
		noclipButton.TextColor3 = Color3.fromRGB(180, 180, 180)
		btnStrokeNoclip.Color = Color3.fromRGB(70, 70, 70)
	end
end)

-- Toggle Infinite Jump
infJumpButton.MouseButton1Click:Connect(function()
	isInfJumpActive = not isInfJumpActive
	if isInfJumpActive then
		infJumpButton.Text = "Infinite Jump: ON 🦘"
		infJumpButton.BackgroundColor3 = Color3.fromRGB(25, 50, 35)
		infJumpButton.TextColor3 = Color3.fromRGB(0, 255, 127)
		btnStrokeJump.Color = Color3.fromRGB(0, 255, 127)
	else
		infJumpButton.Text = "Infinite Jump: OFF 🦘"
		infJumpButton.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
		infJumpButton.TextColor3 = Color3.fromRGB(180, 180, 180)
		btnStrokeJump.Color = Color3.fromRGB(70, 70, 70)
	end
end)

-- Toggle Fullbright
fullbrightButton.MouseButton1Click:Connect(function()
	isFullbrightActive = not isFullbrightActive
	if isFullbrightActive then
		fullbrightButton.Text = "Fullbright: ON ☀️"
		fullbrightButton.BackgroundColor3 = Color3.fromRGB(25, 50, 35)
		fullbrightButton.TextColor3 = Color3.fromRGB(0, 255, 127)
		btnStrokeBright.Color = Color3.fromRGB(0, 255, 127)
	else
		fullbrightButton.Text = "Fullbright: OFF 💡"
		fullbrightButton.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
		fullbrightButton.TextColor3 = Color3.fromRGB(180, 180, 180)
		btnStrokeBright.Color = Color3.fromRGB(70, 70, 70)

		Lighting.Brightness = defaultBrightness
		Lighting.ClockTime = defaultClockTime
		Lighting.FogEnd = defaultFogEnd
		Lighting.GlobalShadows = defaultGlobalShadows
		Lighting.Ambient = defaultAmbient
	end
end)

-- Mostrar / Ocultar Bolinha Speed
floatIconButton.MouseButton1Click:Connect(function()
	miniFloat.Visible = not miniFloat.Visible
end)

-- Lógica Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if not isInfJumpActive then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Verificação Shift Lock
local function isShiftLocked()
	local localChar = player.Character
	if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return false end

	local cameraFlatLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
	local rootFlatLook = Vector3.new(localChar.HumanoidRootPart.CFrame.LookVector.X, 0, localChar.HumanoidRootPart.CFrame.LookVector.Z).Unit

	return cameraFlatLook:Dot(rootFlatLook) > 0.85
end

-- Loop Principal (ESP + Fullbright + Noclip + Speed Glitch S, A, D)
RunService.RenderStepped:Connect(function(deltaTime)
	if isFullbrightActive then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	end

	-- ESP Roles MM2
	if isEspActive then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local char = p.Character
				local hrp = char.HumanoidRootPart

				if not espCache[p] then
					local textObj = Drawing.new("Text")
					textObj.Visible = false
					textObj.Center = true
					textObj.Outline = true
					textObj.Size = 14
					espCache[p] = textObj
				end

				local espText = espCache[p]
				local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

				if onScreen then
					local roleColor = Color3.fromRGB(0, 255, 0)
					local roleName = "Inocente"

					local hasGun = false
					local hasKnife = false

					local containers = {char, p:FindFirstChild("Backpack")}
					for _, container in ipairs(containers) do
						if container then
							for _, item in ipairs(container:GetChildren()) do
								if item:IsA("Tool") then
									local iName = item.Name:lower()
									if iName:find("gun") or iName:find("revolver") or iName:find("sheriff") then hasGun = true end
									if iName:find("knife") or iName:find("faca") then hasKnife = true end
								end
							end
						end
					end

					if hasGun then
						roleColor = Color3.fromRGB(0, 150, 255)
						roleName = "Xerife"
					elseif hasKnife then
						roleColor = Color3.fromRGB(255, 50, 50)
						roleName = "Assassino"
					end

					espText.Text = p.Name .. " [" .. roleName .. "]"
					espText.Color = roleColor
					espText.Position = Vector2.new(vector.X, vector.Y - 25)
					espText.Visible = true
				else
					espText.Visible = false
				end
			else
				if espCache[p] then espCache[p].Visible = false end
			end
		end
	end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end

	-- Noclip
	if isNoclipActive then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	-- Speed Glitch
	if not isSpeedEnabled then
		currentSpeed = NORMAL_SPEED
		return
	end

	if not isShiftLocked() then
		currentSpeed = NORMAL_SPEED
		humanoid.WalkSpeed = NORMAL_SPEED
		return
	end

	local moveDir = humanoid.MoveDirection
	if moveDir.Magnitude > 0 then
		local forwardVector = rootPart.CFrame.LookVector
		local dotForward = moveDir:Dot(forwardVector)

		-- Só funciona quando NÃO está indo para frente (S, A, D)
		if dotForward >= 0.5 then
			currentSpeed = NORMAL_SPEED
			humanoid.WalkSpeed = NORMAL_SPEED
			return
		end
	else
		currentSpeed = NORMAL_SPEED
		return
	end

	local currentCameraCF = camera.CFrame
	local _, lastY, _ = lastCameraCF:ToOrientation()
	local _, currentY, _ = currentCameraCF:ToOrientation()

	local rotationDelta = math.abs(currentY - lastY)
	lastCameraCF = currentCameraCF

	if rotationDelta > 3.14 then
		rotationDelta = 6.28 - rotationDelta
	end

	local state = humanoid:GetState()
	local isInAir = state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping
	local isRunningOnGround = state == Enum.HumanoidStateType.Running

	local targetMax = isBruteMode and MAX_SPEED_BRUTE or MAX_SPEED_GRADUAL

	if isInAir and rotationDelta > MIN_ROTATION_THRESHOLD then
		if isBruteMode then
			currentSpeed = targetMax
		else
			local dynamicAcceleration = BASE_ACCELERATION + (rotationDelta * 5000)
			currentSpeed = math.min(targetMax, currentSpeed + (dynamicAcceleration * deltaTime))
		end
	elseif isRunningOnGround then
		currentSpeed = NORMAL_SPEED
	end

	humanoid.WalkSpeed = currentSpeed
end)

-- ==========================================
-- ADDON BROOM26 FLY (IV4D SCRIPTS)
-- ==========================================
local TARGET_TOOL_NAME = "Broom26"
local flySpeed = 30
local EQUIP_GRACE_SECONDS = 0.55

local NEON_GREEN = Color3.fromRGB(57, 255, 20) -- #39FF14
local DEEP_BLACK = Color3.fromRGB(5, 5, 5)     -- #050505
local PANEL_DARK = Color3.fromRGB(12, 16, 12)
local INPUT_DARK = Color3.fromRGB(20, 28, 20)

local flying = false
local activeBroomTrack = nil
local currentTool = nil
local lastEquipTime = 0

local flyConn = nil
local animPlayedConn = nil
local animStoppedConn = nil
local bodyVel = nil
local bodyGyro = nil

local speedInput = nil

local function stopFly()
	flying = false
	activeBroomTrack = nil

	if animStoppedConn then
		animStoppedConn:Disconnect()
		animStoppedConn = nil
	end
	if flyConn then
		flyConn:Disconnect()
		flyConn = nil
	end
	if bodyVel then
		bodyVel:Destroy()
		bodyVel = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
	end
end

local function startFly()
	if flying then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	flying = true
	hum.PlatformStand = false

	bodyVel = Instance.new("BodyVelocity")
	bodyVel.Name = "BroomFlyVelocity"
	bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVel.P = 1250
	bodyVel.Velocity = Vector3.zero
	bodyVel.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.Name = "BroomFlyGyro"
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.P = 3000
	bodyGyro.D = 200
	bodyGyro.CFrame = root.CFrame
	bodyGyro.Parent = root

	flyConn = RunService.RenderStepped:Connect(function()
		local charNow = player.Character
		if not flying or not currentTool or not charNow or currentTool.Parent ~= charNow or not root.Parent then
			stopFly()
			return
		end

		local cam = workspace.CurrentCamera
		local moveDir = hum.MoveDirection

		local velocity = Vector3.zero

		if moveDir.Magnitude > 0 then
			local look = cam.CFrame.LookVector
			local right = cam.CFrame.RightVector

			local flatLook = Vector3.new(look.X, 0, look.Z)
			if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end

			local flatRight = Vector3.new(right.X, 0, right.Z)
			if flatRi
