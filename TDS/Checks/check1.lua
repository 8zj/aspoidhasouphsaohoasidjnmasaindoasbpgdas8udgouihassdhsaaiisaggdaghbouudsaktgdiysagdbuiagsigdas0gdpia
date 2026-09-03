local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local CONFIG = {
	Timeout = 600,
	Message = "/PSH Hub",
	ForceFieldColor = Color3.fromRGB(0, 170, 255),
	OutlineColor = Color3.fromRGB(80, 220, 255),
}

local State = {
	Connections = {},
	CharacterConnections = {},
	Started = os.clock(),
}

local function fail(message)
	warn("[ x ] " .. message)
end

local function disconnect(connection)
	if connection and connection.Connected then
		connection:Disconnect()
	end
end

local function disconnectList(list)
	for index, connection in ipairs(list) do
		disconnect(connection)
		list[index] = nil
	end
end

local function waitForLocalPlayer()
	local deadline = State.Started + CONFIG.Timeout

	while not Player and os.clock() < deadline do
		Player = Players.LocalPlayer
		task.wait(0.1)
	end

	if not Player then
		fail("LocalPlayer not found")
		return false
	end

	return true
end

local function waitForPlayerGui()
	local deadline = State.Started + CONFIG.Timeout
	local playerGui

	repeat
		playerGui = Player:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			return playerGui
		end

		task.wait(0.1)
	until os.clock() >= deadline

	fail("PlayerGui not found")
	return nil
end

local function waitForLoadingScreen(playerGui)
	local deadline = State.Started + CONFIG.Timeout
	local content

	repeat
		local loadingScreen = playerGui:FindFirstChild("LoadingScreen")

		if loadingScreen then
			content = loadingScreen:FindFirstChild("content")
		end

		if content then
			return content
		end

		task.wait(0.1)
	until os.clock() >= deadline

	fail("LoadingScreen.content not found")
	return nil
end

local function waitForLoadingComplete(content)
	local deadline = State.Started + CONFIG.Timeout

	while content.Parent and content.Visible do
		if os.clock() >= deadline then
			fail("Loading screen timed out")
			return false
		end

		task.wait(0.1)
	end

	return true
end

local function stylePart(part)
	if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" then
		return
	end

	if part:GetAttribute("BlueFFTransparency") == nil then
		part:SetAttribute("BlueFFTransparency", part.Transparency)
	end

	part.Material = Enum.Material.ForceField
	part.Color = CONFIG.ForceFieldColor
	part.CastShadow = false
end

local function createHighlight(character)
	local highlight = character:FindFirstChild("BlueForceField")

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "BlueForceField"
		highlight.Parent = character
	end

	highlight.FillColor = CONFIG.ForceFieldColor
	highlight.OutlineColor = CONFIG.OutlineColor
	highlight.FillTransparency = 0.65
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	return highlight
end

local function addBlueForceField(character)
	if not character or not character.Parent then
		return
	end

	disconnectList(State.CharacterConnections)

	local highlight = createHighlight(character)

	for _, object in ipairs(character:GetDescendants()) do
		stylePart(object)
	end

	table.insert(State.CharacterConnections, character.DescendantAdded:Connect(function(object)
		if object:IsA("BasePart") then
			task.defer(stylePart, object)
		end
	end))

	local pulseTime = 0

	table.insert(State.CharacterConnections, RunService.RenderStepped:Connect(function(deltaTime)
		if not character.Parent or not highlight.Parent then
			disconnectList(State.CharacterConnections)
			return
		end

		pulseTime += deltaTime * 2.5

		local pulse = (math.sin(pulseTime) + 1) * 0.5
		local green = 130 + math.floor(pulse * 70)

		highlight.FillTransparency = 0.55 + pulse * 0.2
		highlight.OutlineTransparency = 0.05 + pulse * 0.2
		highlight.FillColor = Color3.fromRGB(0, green, 255)

		local partColor = Color3.fromRGB(
			0,
			150 + math.floor(pulse * 20),
			255
		)

		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
				object.Color = partColor
			end
		end
	end))
end

local function updateTag()
	local tag = Player:FindFirstChild("Tag")

	if tag and tag:IsA("StringValue") then
		tag.Value = "Chatty"
	end
end

local function waitForNametag()
	local deadline = State.Started + CONFIG.Timeout
	local nametagFolder
	local nametag

	repeat
		nametagFolder = Workspace:FindFirstChild("Nametags")

		if nametagFolder then
			nametag = nametagFolder:FindFirstChild(Player.Name)
		end

		if nametag then
			return nametag
		end

		task.wait(0.1)
	until os.clock() >= deadline

	fail("Nametag not found for " .. Player.Name)
	return nil
end

local function startNametagAnimation(nametag)
	local display = nametag:FindFirstChild("Display")
	local frame = display and display:FindFirstChild("Frame")
	local richText = frame and frame:FindFirstChild("RichText")
	local text = richText and richText:FindFirstChild("1")

	if not text or not text:IsA("TextLabel") and not text:IsA("TextButton") then
		fail("Nametag text object not found")
		return
	end

	local message = CONFIG.Message
	local prefixLength = #"/PSH"

	task.spawn(function()
		while text.Parent do
			text.Text = ""

			for index = 1, #message do
				if not text.Parent then
					return
				end

				text.Text = message:sub(1, index)
				task.wait(0.05)
			end

			task.wait(1)

			for index = #message, prefixLength + 1, -1 do
				if not text.Parent then
					return
				end

				text.Text = message:sub(1, index)
				task.wait(0.05)
			end

			task.wait(0.5)

			for index = prefixLength, 1, -1 do
				if not text.Parent then
					return
				end

				text.Text = message:sub(1, index - 1)
				task.wait(0.05)
			end

			task.wait(0.5)
		end
	end)
end

local function setupCharacter(character)
	if not character or not character.Parent then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		humanoid = character:WaitForChild("Humanoid", 5)
	end

	if not humanoid then
		fail("Humanoid not found")
		return
	end

	addBlueForceField(character)
end

if not waitForLocalPlayer() then
	return
end

local playerGui = waitForPlayerGui()

if not playerGui then
	return
end

local content = waitForLoadingScreen(playerGui)

if not content then
	return
end

if not waitForLoadingComplete(content) then
	return
end

task.wait(5)

print("[ + ] Loading Screen Passed.")

updateTag()

local nametag = waitForNametag()

if not nametag then
	return
end

startNametagAnimation(nametag)

if Player.Character then
	task.spawn(setupCharacter, Player.Character)
end

table.insert(State.Connections, Player.CharacterAdded:Connect(function(character)
	setupCharacter(character)
end))

table.insert(State.Connections, Player.AncestryChanged:Connect(function(_, parent)
	if not parent then
		disconnectList(State.Connections)
		disconnectList(State.CharacterConnections)
	end
end))
