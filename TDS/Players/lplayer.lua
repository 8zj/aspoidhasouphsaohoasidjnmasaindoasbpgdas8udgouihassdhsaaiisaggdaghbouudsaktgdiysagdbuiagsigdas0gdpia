local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local BLUE = Color3.fromRGB(0, 170, 255)
local DARK_BLUE = Color3.fromRGB(0, 80, 255)
local LIGHT_BLUE = Color3.fromRGB(80, 220, 255)

local connections = {}
local characterConnection

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

	local oldTransparency = part:GetAttribute("BlueFFTransparency")

	if oldTransparency == nil then
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

		local r = 0
		local g = 130 + math.floor(pulse * 70)
		local b = 255

		highlight.FillColor = Color3.fromRGB(r, g, b)

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

if player.Character then
	addBlueForceField(player.Character)
end

characterConnection = player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid", 5)
	addBlueForceField(character)
end)
