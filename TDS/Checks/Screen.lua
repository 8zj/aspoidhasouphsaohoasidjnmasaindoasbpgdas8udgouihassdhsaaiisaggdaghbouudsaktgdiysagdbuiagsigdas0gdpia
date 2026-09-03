local Players = game:GetService("Players")
local PlayerGui
local LoadingScreen
local Content
local Plauer

local TIMEOUT = 600
local CHECK_INTERVAL = 0.1
local START_TIME = os.clock()

local function errorMessage(message)
	warn("[ x ] Error Failed: " .. tostring(message))
end

local function timedOut()
	return os.clock() - START_TIME >= TIMEOUT
end

while not Player do
	if timedOut() then
		errorMessage("Timed out waiting for LocalPlayer")
		return
	end

	Player = Players.LocalPlayer

	if not Player then
		task.wait(CHECK_INTERVAL)
	end
end


while not PlayerGui do
	if timedOut() then
		errorMessage("Timed out waiting for PlayerGui")
		return
	end

	PlayerGui = Player:FindFirstChildOfClass("PlayerGui")

	if not PlayerGui then
		task.wait(CHECK_INTERVAL)
	end
end

while not Content do
	if timedOut() then
		errorMessage("Timed out waiting for LoadingScreen.content")
		return
	end

	LoadingScreen = PlayerGui:FindFirstChild("LoadingScreen")

	if LoadingScreen then
		Content = LoadingScreen:FindFirstChild("content")
	end

	if not Content then
		task.wait(CHECK_INTERVAL)
	end
end

local LoadingFinished = false
while not LoadingFinished do
	if timedOut() then
		errorMessage("Loading screen did not finish within 10 minutes")
		return
	end

	if not Content.Parent then
		LoadingFinished = true
		break
	end

	local Success, Visible = pcall(function()
		return Content.Visible
	end)

	if not Success then
		errorMessage("Failed to read LoadingScreen.content.Visible")
		return
	end

	if Visible == false then
		LoadingFinished = true
		break
	end

	task.wait(CHECK_INTERVAL)
end

local ConfirmStart = os.clock()
while os.clock() - ConfirmStart < 1 do
	if timedOut() then
		errorMessage("Timed out confirming loading completion")
		return
	end

	if Content.Parent then
		local Success, Visible = pcall(function()
			return Content.Visible
		end)

		if Success and Visible then
			LoadingFinished = false

			while true do
				if timedOut() then
					errorMessage("Loading screen did not finish within 10 minutes")
					return
				end

				if not Content.Parent then
					break
				end

				local CheckSuccess, CheckVisible = pcall(function()
					return Content.Visible
				end)

				if not CheckSuccess then
					errorMessage("Failed to check loading state")
					return
				end

				if not CheckVisible then
					break
				end

				task.wait(CHECK_INTERVAL)
			end

			LoadingFinished = true
			ConfirmStart = os.clock()
		end
	end

	task.wait(CHECK_INTERVAL)
end

if not LoadingFinished then
	errorMessage("Loading state could not be confirmed")
	return
end
if timedOut() then
	errorMessage("Total loading timeout reached")
	return
end
task.wait(5)
if timedOut() then
	errorMessage("Timed out during post-loading delay")
	return
end
print("[ + ] Passed")
