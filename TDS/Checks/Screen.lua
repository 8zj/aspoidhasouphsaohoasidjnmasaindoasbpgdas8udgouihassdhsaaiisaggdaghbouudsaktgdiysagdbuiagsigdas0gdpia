local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local BLUE = Color3.fromRGB(0, 170, 255)
local LIGHT_BLUE = Color3.fromRGB(80, 220, 255)

local connections = {}

local timeout = 600
local started = os.clock()

local Player
local PlayerGui
local Content
local Nametag

local function fail(msg)
	warn("[ x ] Error Failed: " .. msg)
end

local function disconnectAll()
	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)
end

local function stylePart(part)
	if not part:IsA("BasePart") then
		return
	end

	if part.Name == "HumanoidRootPart" then
		return
	end

	part.Material = Enum.Material.ForceField
	part.Color = BLUE
	part.CastShadow = false

	if part:GetAttribute("BlueFFTransparency") == nil then
		part:SetAttribute("BlueFFTransparency", part.Transparency)
	end
end

local function addBlueForceField(character)
	disconnectAll()

	local highlight = character:FindFirstChild("BlueForceField")

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "BlueForceField"
		highlight.Parent = character
	end

	highlight.FillColor = BLUE
	highlight.OutlineColor = LIGHT_BLUE
	highlight.FillTransparency = 0.65
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	for _, object in ipairs(character:GetDescendants()) do
		stylePart(object)
	end

	table.insert(connections, character.DescendantAdded:Connect(function(object)
		if object:IsA("BasePart") then
			task.defer(stylePart, object)
		end
	end))

	local pulseTime = 0

	table.insert(connections, RunService.RenderStepped:Connect(function(deltaTime)
		if not character.Parent or not highlight.Parent then
			return
		end

		pulseTime += deltaTime * 2.5

		local pulse = (math.sin(pulseTime) + 1) / 2

		highlight.FillTransparency = 0.55 + (pulse * 0.2)
		highlight.OutlineTransparency = 0.05 + (pulse * 0.2)

		highlight.FillColor = Color3.fromRGB(
			0,
			130 + math.floor(pulse * 70),
			255
		)

		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
				object.Color = Color3.fromRGB(
					0,
					150 + math.floor(pulse * 20),
					255
				)
			end
		end
	end))
end

repeat
	Player = Players.LocalPlayer
	task.wait(0.1)
until Player or os.clock() - started >= timeout

if not Player then
	fail("LocalPlayer not found")
	return
end

repeat
	PlayerGui = Player:FindFirstChildOfClass("PlayerGui")
	task.wait(0.1)
until PlayerGui or os.clock() - started >= timeout

if not PlayerGui then
	fail("PlayerGui not found")
	return
end

repeat
	local LoadingScreen = PlayerGui:FindFirstChild("LoadingScreen")

	if LoadingScreen then
		Content = LoadingScreen:FindFirstChild("content")
	end

	task.wait(0.1)
until Content or os.clock() - started >= timeout

if not Content then
	fail("LoadingScreen.content not found")
	return
end

while Content.Parent and Content.Visible do
	if os.clock() - started >= timeout then
		fail("Loading screen timed out")
		return
	end

	task.wait(0.1)
end

task.wait(5)

print("[ + ] Passed")

local Tag = Player:FindFirstChild("Tag")

if Tag and Tag:IsA("StringValue") then
	Tag.Value = "Chatty"
end

repeat
	Nametag = Workspace:FindFirstChild("Nametags")

	if Nametag then
		Nametag = Nametag:FindFirstChild(Player.Name)
	end

	task.wait(0.1)
until Nametag or os.clock() - started >= timeout

if not Nametag then
	fail("Nametag not found for " .. Player.Name)
	return
end

local Text = Nametag.Display.Frame.RichText["1"]
local Message = "/PSH Hub"

task.spawn(function()
	while true do
		if not Text or not Text.Parent then
			break
		end

		Text.Text = ""

		for i = 1, #Message do
			if not Text or not Text.Parent then
				return
			end

			Text.Text = Message:sub(1, i)
			task.wait(0.05)
		end

		task.wait(1)

		for i = #Message, #"/PSH" + 1, -1 do
			if not Text or not Text.Parent then
				return
			end

			Text.Text = Message:sub(1, i)
			task.wait(0.05)
		end

		task.wait(0.5)

		for i = #"/PSH", 1, -1 do
			if not Text or not Text.Parent then
				return
			end

			Text.Text = Message:sub(1, i - 1)
			task.wait(0.05)
		end

		task.wait(0.5)
	end
end)

if player.Character then
	addBlueForceField(player.Character)
end

player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid", 5)
	addBlueForceField(character)
end)
