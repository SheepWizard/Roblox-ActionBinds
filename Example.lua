--!strict
local PlayersService = game:GetService("Players")
local localPlayer = PlayersService.LocalPlayer

local gui = localPlayer:WaitForChild("PlayerGui")
local screenGUI = Instance.new("ScreenGui")
screenGUI.Parent = gui
local button = Instance.new("TextButton")
button.Parent = screenGUI
button.Size = UDim2.new(0,100,0,100)

local ActionBinds = require(script.Parent:WaitForChild("ActionBinds"))

ActionBinds.newAction("reload", {Enum.KeyCode.R})

-- Events will activate when keys left or right shift are pressed, as well as the input not being gameprocessed
ActionBinds.newAction("sprint", {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift}, false)

-- Events will activate when key enter is pressed and input has been gameprocessed
ActionBinds.newAction("sendMessage", {Enum.KeyCode.KeypadEnter}, true)

ActionBinds.newAction("mouse1", {Enum.UserInputType.MouseButton1}, false)


-- This event will run when a reload key has been pressed
ActionBinds.onActionKeyPressed("reload", function(keycode)
	print("Reload button pressed with key " .. tostring(keycode))
	print(ActionBinds.isActive("sprint")) -- Check if player is sprinting
end)

ActionBinds.onActionKeyPressed("sprint", function(keycode)
	print("Start sprinting.")
	ActionBinds.disable("reload") -- Disable reload action
end)

-- This event will run when a sprint key has been released
ActionBinds.onActionKeyReleased("sprint", function(keycode)
	print("Stop sprinting.")
	ActionBinds.enable("reload") -- Enable reload action
end)

ActionBinds.onActionKeyPressed("mouse1", function(keycode)
	print("Mouse 1 pressed")
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
task.wait(5)
ActionBinds.runActionEvents("sprint", 0)

-- List of all action names
for k, v in ActionBinds.actionNames do
	print(v)
end
