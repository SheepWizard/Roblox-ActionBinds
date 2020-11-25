--!strict
-- Created by Sheep Wizard / paap15
local UserInputService = game:GetService("UserInputService")

export type KeyList = {[number]: Enum.KeyCode}

export type Action = {
	name: string,
	keys: KeyList,
	gameProcessed: boolean?,
	ingoreGameProcessed: boolean?,
	disabled: boolean,
	active: boolean,
	keyPressedEvents: {[number]: (Enum.KeyCode?) -> any?},
	keyReleasedEvents: {[number]: (Enum.KeyCode?) -> any?},
}

local actionsList: {[number]: Action} = {}

local ActionBinds = {}

-- A list the name for all actions
ActionBinds.actionNames = {}

-- Create a new action
-- name: The name of the action
-- keys: A list of keycodes that can activate the function e.g. {Enum.KeyCode.R, Enum.KeyCode.Z}
-- gameProcessed: If you want the action to run if the game has processed the input or not. If not specified default is false
-- Returns a Action object
function ActionBinds.newAction(name: string, keys: KeyList, gameProcessed: boolean?): Action
	for i = 1, #actionsList do
		if actionsList[i].name == name then
			warn("You already have a action with the name " .. name .. ".")
		end
	end
	actionsList[#actionsList+1] = {
		name = name,
		keys = keys,
		gameProcessed = gameProcessed or false,
		ingoreGameProcessed = false,
		disabled = false,
		active = false,
		keyPressedEvents = {},
		keyReleasedEvents = {}
	}
	ActionBinds.actionNames[name] = name
	return actionsList[#actionsList]
end

local function getActionFromName(actionName: string): Action
	for i = 1, #actionsList do
		if actionsList[i].name == actionName then
			return actionsList[i]
		end
	end
	return nil
end

-- Run a function when a key assigned to a action is pressed
-- actionName: Name of the action you want this to apply too
-- event: Function that will run. The keycode enum that is pressed will passed as a function paramater.
-- if event is called from different source (e.g. gui) then the keycode will be Enum.KeyCode.Unknown
function ActionBinds.OnActionKeyPressed(actionName: string, event: (Enum.KeyCode?) -> any?)
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		action.keyPressedEvents[#action.keyPressedEvents+1] = event
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Run a function when a key assigned to a action is released
-- actionName: Name of the action you want this to apply too
-- event: Function that will run. The keycode enum that is released will passed as a function paramater.
-- if event is called from different source (e.g. gui) then the keycode will be Enum.KeyCode.Unknown
function ActionBinds.OnActionKeyReleased(actionName: string, event: (Enum.KeyCode?) ->any?)
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		action.keyReleasedEvents[#action.keyReleasedEvents+1] = event
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Returns true if the action is active. It will be active if the key pressed event runs
-- actionName: Name of the action
function ActionBinds.isActive(actionName: string): boolean
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		return action.active
	else
		warn("Action not found " .. actionName .. ".")
		return false
	end
end

local function setActionDisable(actionName: string, bool: boolean)
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		action.disabled = bool
		if bool == true then
			action.active = false
		end
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Disable all events for the action
-- actionName: Name of the action
function ActionBinds.disable(actionName: string)
	setActionDisable(actionName, true)
end

-- Enable all events for the action
-- actionName: Name of the action
function ActionBinds.enable(actionName: string)
	setActionDisable(actionName, false)
end

-- Returns if the action is diabled or not
-- actionName: Name of the action
function ActionBinds.isDisabled(actionName: string): boolean
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		return action.disabled
	else
		warn("Action not found " .. actionName .. ".")
		return false
	end
end

-- Set a action to ignore gameprocessed rules. If set to true event will run if the key has or hasnt been gameprocessed
-- actionName: Name of the action
-- bool: true or false
function ActionBinds.ignoreGameProcessed(actionName: string, bool: boolean)
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		action.ingoreGameProcessed = bool
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Returns keys assigned to a action
-- actionName: Name of the action
function ActionBinds.getKeys(actionName: string): KeyList
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		return action.keys
	else
		warn("Action not found " .. actionName .. ".")
		return {}
	end
end

-- Give a new list of keys that will activate the actions events, replacing the old ones
-- actionName: Name of the action
function ActionBinds.changeKeys(actionName: string, keys: KeyList)
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		action.keys = keys
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Returns the action object
-- actionName: Name of the action
function ActionBinds.getActionObject(actionName: string): Action
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		return action
	else
		warn("Action not found " .. actionName .. ".")
		return nil
	end
end

local function checkEvents(input, gameProcessedEvent: boolean, eventType: string, activeStatus: boolean, updateActive: boolean)
	for i = 1, #actionsList do
		for z = 1, #actionsList[i].keys do
			if actionsList[i].keys[z] == input then
				if not actionsList[i].disabled and ((actionsList[i].gameProcessed == gameProcessedEvent) or actionsList[i].ingoreGameProcessed) then
					actionsList[i].active = activeStatus
					for x = 1, #actionsList[i][eventType] do
						actionsList[i][eventType][x](input)
					end
				end
			end
		end
	end
end

-- Will run the actions key pressed events then immediately run the key released events when button is activated
-- The keycode given for event run by GUI button will be Enum.KeyCode.Unknown
-- actionName: Name of the action
-- button: GUI button
function ActionBinds.GUIButton(actionName: string, button: GuiButton)
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		button.Activated:Connect(function()
			if action.disabled then return end
			for x = 1, #action.keyPressedEvents do
				action.keyPressedEvents[x](Enum.KeyCode.Unknown)
			end
			for x = 1, #action.keyReleasedEvents do
				action.keyReleasedEvents[x](Enum.KeyCode.Unknown)
			end
		end)
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Run event for a action manually. Best to run both event to simulate a key press and release.
-- If eventType 1 is used the actions 'active' property will be set to true and stay that way until a key released event is pressed
-- The keycode given for event run by this function will be Enum.KeyCode.Unknown
-- actionName: Name of the action
-- eventType: 0 for key released, 1 for key pressed
function ActionBinds.runActionEvents(actionName: string, eventType: number)
	local action: Action = getActionFromName(actionName)
	if type(action) ~= "nil" then
		if action.disabled then return end
		if eventType == 0 then
			action.active = false
			for x = 1, #action.keyReleasedEvents do
				action.keyReleasedEvents[x](Enum.KeyCode.Unknown)
			end
			return
		elseif eventType == 1 then
			action.active = true
			for x = 1, #action.keyPressedEvents do
				action.keyPressedEvents[x](Enum.KeyCode.Unknown)
			end
			return
		else
			warn("Event type not found. use 0 for key released events and 1 for key pressed events.")
			return
		end
	else
		warn("Action not found " .. actionName .. ".")
	end
end

local function inputBegan(input, gameProcessedEvent)
	checkEvents(input.KeyCode, gameProcessedEvent, "keyPressedEvents", true, true)
end

local function inputEnded(input, gameProcessedEvent)
	checkEvents(input.KeyCode, gameProcessedEvent, "keyReleasedEvents", false, true)
end

UserInputService.InputBegan:Connect(inputBegan)
UserInputService.InputEnded:Connect(inputEnded)

return ActionBinds
