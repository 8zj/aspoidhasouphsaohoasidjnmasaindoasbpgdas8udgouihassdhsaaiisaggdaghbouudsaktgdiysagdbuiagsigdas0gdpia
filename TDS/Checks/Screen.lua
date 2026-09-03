local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- [ Variables ] --
local Player
local PlayerGui
local Content
local Nametag

local timeout = 600
local started = os.clock()

-- [ Functions ] --
local function fail(msg)
	warn("[ x ] Error Failed: " .. msg)
end

-- [ Loading ] --
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

-- [ Nametag ] --
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


-- [ Animation ] --
local Text = Nametag.Display.Frame.RichText["1"]
local Message = "/PSH Hub"

while true do
	Text.Text = ""

	for i = 1, #Message do
		Text.Text = Message:sub(1, i)
		task.wait(0.05)
	end

	task.wait(1)

	for i = #Message, #"/PSH" + 1, -1 do
		Text.Text = Message:sub(1, i)
		task.wait(0.05)
	end

	task.wait(0.5)

	for i = #"/PSH", 1, -1 do
		Text.Text = Message:sub(1, i - 1)
		task.wait(0.05)
	end

	task.wait(0.5)
end

local function addBlueForceField(character)
	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Material = Enum.Material.ForceField
			object.Color = Color3.fromRGB(0, 170, 255)
		end
	end

	local highlight = character:FindFirstChild("BlueForceField")

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "BlueForceField"
		highlight.Parent = character
	end

	highlight.FillColor = Color3.fromRGB(0, 170, 255)
	highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
	highlight.FillTransparency = 0.65
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
end

if player.Character then
	addBlueForceField(player.Character)
end

player.CharacterAdded:Connect(addBlueForceField)
