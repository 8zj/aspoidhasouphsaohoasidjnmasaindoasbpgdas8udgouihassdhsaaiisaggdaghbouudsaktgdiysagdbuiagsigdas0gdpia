local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local RequiredTag = "v2.8.1"

local function getVersion()
	local VersionModule = ReplicatedStorage:FindFirstChild("Version")

	if not VersionModule then
		return nil, "Version module not found"
	end

	if not VersionModule:IsA("ModuleScript") then
		return nil, "Version is not a ModuleScript"
	end

	local Success, VersionData = pcall(require, VersionModule)

	if not Success then
		return nil, "Failed to load Version"
	end

	if typeof(VersionData) ~= "table" then
		return nil, "Invalid Version data"
	end

	return VersionData
end

local Version, Error = getVersion()

if not Version then
	LocalPlayer:Kick("Please Upgrade | " .. Error)
	return
end

local CurrentTag = tostring(Version.tag or "")

if CurrentTag == "" then
	LocalPlayer:Kick("Please Upgrade | Version tag missing")
	return
end
if CurrentTag ~= RequiredTag then
	LocalPlayer:Kick(
		"Please Upgrade\nRequired: " ..
		CurrentTag ..
		"\nCurrent: " ..
		RequiredTag
	)
	return
end
