local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local CONFIG = {
    Timeout = 60,
    Message = "/PSH Hub",
    ForceFieldColor = Color3.fromRGB(80, 220, 255),
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
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function disconnectList(list)
    for i = #list, 1, -1 do
        disconnect(list[i])
        list[i] = nil
    end
end

local function waitForChild(parent, name, timeout)
    if not parent then
        return nil
    end

    local object = parent:FindFirstChild(name)

    if object then
        return object
    end

    local success, result = pcall(function()
        return parent:WaitForChild(name, timeout or CONFIG.Timeout)
    end)

    if success then
        return result
    end

    return nil
end

local function waitForLocalPlayer()
    local deadline = os.clock() + CONFIG.Timeout

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
    local deadline = os.clock() + CONFIG.Timeout

    while os.clock() < deadline do
        local gui = Player:FindFirstChildOfClass("PlayerGui")

        if gui then
            return gui
        end

        task.wait(0.25)
    end

    fail("PlayerGui not found")
    return nil
end

local function waitForLoadingScreen(playerGui)
    local deadline = os.clock() + CONFIG.Timeout

    while os.clock() < deadline do
        local loadingScreen = playerGui:FindFirstChild("LoadingScreen")

        if loadingScreen then
            local content = loadingScreen:FindFirstChild("content")

            if content then
                return content
            end
        end

        task.wait(0.25)
    end

    fail("LoadingScreen.content not found")
    return nil
end

local function waitForLoadingComplete(content)
    local deadline = os.clock() + CONFIG.Timeout

    while os.clock() < deadline do
        if not content or not content.Parent then
            return true
        end

        if not content.Visible then
            return true
        end

        task.wait(0.25)
    end

    fail("Loading screen timed out")
    return false
end

local function stylePart(part)
    if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" then
        return
    end

    if part:GetAttribute("PSH_OriginalMaterial") == nil then
        part:SetAttribute("PSH_OriginalMaterial", part.Material.Name)
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
    local parts = {}

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
            stylePart(object)
            parts[#parts + 1] = object
        end
    end

    table.insert(State.CharacterConnections, character.DescendantAdded:Connect(function(object)
        if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" then
            stylePart(object)
            parts[#parts + 1] = object
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

        for i = #parts, 1, -1 do
            local part = parts[i]

            if not part or not part.Parent then
                table.remove(parts, i)
            else
                part.Color = partColor
            end
        end
    end))
end

local function updateTag()
    local tag = Player:FindFirstChild("Tag")

    if tag and tag:IsA("StringValue") then
        pcall(function()
            tag.Value = "Chatty"
        end)
    end
end

local function waitForNametag()
    local deadline = os.clock() + CONFIG.Timeout

    while os.clock() < deadline do
        local folder = Workspace:FindFirstChild("Nametags")

        if folder then
            local nametag = folder:FindFirstChild(Player.Name)

            if nametag then
                return nametag
            end
        end

        task.wait(0.25)
    end

    fail("Nametag not found for " .. Player.Name)
    return nil
end

local function getNametagText(nametag)
    local display = nametag:FindFirstChild("Display")

    if not display then
        return nil
    end

    local frame = display:FindFirstChild("Frame")

    if not frame then
        return nil
    end

    local richText = frame:FindFirstChild("RichText")

    if not richText then
        return nil
    end

    local text = richText:FindFirstChild("1")

    if text and (text:IsA("TextLabel") or text:IsA("TextButton")) then
        return text
    end

    return nil
end

local function startNametagAnimation(nametag)
    task.spawn(function()
        while nametag and nametag.Parent do
            local text = getNametagText(nametag)

            if not text then
                task.wait(0.5)
                continue
            end

            local message = CONFIG.Message
            local prefixLength = #"/PSH"

            text.Text = ""

            for index = 1, #message do
                if not text.Parent or not nametag.Parent then
                    return
                end

                text.Text = message:sub(1, index)
                task.wait(0.05)
            end

            task.wait(1)

            for index = #message, prefixLength + 1, -1 do
                if not text.Parent or not nametag.Parent then
                    return
                end

                text.Text = message:sub(1, index)
                task.wait(0.05)
            end

            task.wait(0.5)

            for index = prefixLength, 1, -1 do
                if not text.Parent or not nametag.Parent then
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

    task.defer(function()
        if character.Parent then
            addBlueForceField(character)
        end
    end)
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

task.wait(2)

print("[ + ] Loading Screen Passed.")

updateTag()

local nametag = waitForNametag()

if nametag then
    startNametagAnimation(nametag)
end

if Player.Character then
    task.defer(setupCharacter, Player.Character)
end

table.insert(State.Connections, Player.CharacterAdded:Connect(function(character)
    task.wait(0.5)

    if character.Parent then
        setupCharacter(character)
    end
end))

table.insert(State.Connections, Player.AncestryChanged:Connect(function(_, parent)
    if not parent then
        disconnectList(State.Connections)
        disconnectList(State.CharacterConnections)
    end
end))
