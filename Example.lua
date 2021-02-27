--!strict
local PlayersService = game:GetService("Players")
local localPlayer = PlayersService.LocalPlayer

local gui = localPlayer:WaitForChild("PlayerGui")
local screenGUI = Instance.new("ScreenGui")
screenGUI.Parent = gui
local button = Instance.new("TextButton")
button.Parent = screenGUI
button.Size = UDim2.new(0,100,0,100)

wait(0.5)
local ActionBinds = require(script.Parent.ActionBinds)

ActionBinds.newAction("reload", {Enum.KeyCode.R, Enum.UserInputType.MouseButton2})
-- Events will activate when keys left or right shift are pressed, as well as the input not being gameprocessed
ActionBinds.newAction("sprint", {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift}, false)
-- Events will activate when key enter is pressed and input has been gameprocessed
ActionBinds.newAction("sendMessage", {Enum.KeyCode.KeypadEnter}, true)


-- This event will run when a reload key has been pressed
ActionBinds.OnActionKeyPressed("reload", function(keycode)
	print("Reload button pressed with key " .. tostring(keycode))
	print(ActionBinds.isActive("sprint")) -- Check if player is sprinting
end)

ActionBinds.OnActionKeyPressed("sprint", function(keycode)
	print("Start sprinting.")
	ActionBinds.disable("reload") -- Disable reload action
end)

-- This event will run when a sprint key has been released
ActionBinds.OnActionKeyReleased("sprint", function(keycode)
	print("Stop sprinting.")
	ActionBinds.enable("reload") -- Enable reload action
end)

print(ActionBinds.isDisabled("sprint")) -- Check if a action has been disabled


ActionBinds.newAction("menu", {Enum.KeyCode.Q})
ActionBinds.ignoreGameProcessed("menu", true) -- Action will ignore gameprocessed rules and will always run events


-- Swap keys for reload and sprint actions
local keyList1 = ActionBinds.getKeys("reload")
local keyList2 = ActionBinds.getKeys("sprint")
ActionBinds.changeKeys("reload", keyList2)
ActionBinds.changeKeys("sprint", keyList1)

-- This will simulate the action keys for reload being pressed the released
ActionBinds.GUIButton("reload", button)

-- This code will simulate the sprint action keys being pressed then released 5 seconds later
ActionBinds.runActionEvents("sprint", 1)
wait(5)
ActionBinds.runActionEvents("sprint", 0)

-- List of all action names
for k, v in pairs(ActionBinds.actionNames) do
	print(v)
end
