--!strict
-- Created by Sheep Wizard / paap15
local UserInputService = game:GetService("UserInputService")

export type KeyList = {Enum.KeyCode | "MouseButton1" | "MouseButton2" | "MouseButton3"}

export type EventType = "keyPressedEvents" | "keyReleasedEvents"

export type Action = {
	name: string,
	keys: KeyList,
	gameProcessed: boolean?,
	ingoreGameProcessed: boolean?,
	disabled: boolean,
	active: boolean,
	keyPressedEvents: {(Enum.KeyCode?) -> nil?},
	keyReleasedEvents: {(Enum.KeyCode?) -> nil?},
}

local actionsList: {Action} = {}

local ActionBinds = {}

-- A list the name for all actions
ActionBinds.actionNames = {}

-- Create a new action
-- name: The name of the action
-- keys: A list of keycodes that can activate the function e.g. {Enum.KeyCode.R, Enum.KeyCode.Z}
-- gameProcessed: If you want the action to run if the game has processed the input or not. If not specified default is false
-- Returns a Action object
function ActionBinds.newAction(name: string, keys: KeyList, gameProcessed: boolean?): Action

	for _, action in actionsList do
		if action.name == name then
			warn("You already have a action with the name " .. name .. ".")
		end
	end

	table.insert(actionsList, {
		name = name,
		keys = keys,
		gameProcessed = gameProcessed or false,
		ingoreGameProcessed = false,
		disabled = false,
		active = false,
		keyPressedEvents = {},
		keyReleasedEvents = {}		
	})

	ActionBinds.actionNames[name] = name
	return actionsList[#actionsList]
end

local function getActionFromName(actionName: string): Action?
	for _, action in actionsList do
		if action.name == actionName then
			return action
		end
	end
	return
end

-- Run a function when a key assigned to a action is pressed
-- actionName: Name of the action you want this to apply too
-- event: Function that will run. The keycode enum that is pressed will passed as a function paramater.
-- if event is called from different source (e.g. gui) then the keycode will be Enum.KeyCode.Unknown
function ActionBinds.onActionKeyPressed(actionName: string, event: (Enum.KeyCode?) -> any?)
	local action = getActionFromName(actionName)
	if action then
		action.keyPressedEvents[#action.keyPressedEvents+1] = event
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Run a function when a key assigned to a action is released
-- actionName: Name of the action you want this to apply too
-- event: Function that will run. The keycode enum that is released will passed as a function paramater.
-- if event is called from different source (e.g. gui) then the keycode will be Enum.KeyCode.Unknown
function ActionBinds.onActionKeyReleased(actionName: string, event: (Enum.KeyCode?) ->any?)
	local action = getActionFromName(actionName)
	if action then
		action.keyReleasedEvents[#action.keyReleasedEvents+1] = event
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Returns true if the action is active. It will be active if the key pressed event runs
-- actionName: Name of the action
function ActionBinds.isActive(actionName: string): boolean
	local action = getActionFromName(actionName)
	if action then
		return action.active
	else
		warn("Action not found " .. actionName .. ".")
		return false
	end
end

local function setActionDisable(actionName: string, bool: boolean)
	local action = getActionFromName(actionName)
	if action then
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
	local action: Action? = getActionFromName(actionName)
	if action then
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
	local action = getActionFromName(actionName)
	if action then
		action.ingoreGameProcessed = bool
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Returns keys assigned to a action
-- actionName: Name of the action
function ActionBinds.getKeys(actionName: string): KeyList
	local action = getActionFromName(actionName)
	if action then
		return action.keys
	else
		warn("Action not found " .. actionName .. ".")
		return {}
	end
end

-- Give a new list of keys that will activate the actions events, replacing the old ones
-- actionName: Name of the action
function ActionBinds.changeKeys(actionName: string, keys: KeyList)
	local action = getActionFromName(actionName)
	if action then
		action.keys = keys
	else
		warn("Action not found " .. actionName .. ".")
	end
end

-- Returns the action object
-- actionName: Name of the action
function ActionBinds.getActionObject(actionName: string): Action?
	local action = getActionFromName(actionName)
	if action then
		return action
	else
		warn("Action not found " .. actionName .. ".")
		return
	end
end

local function checkEvents(input, gameProcessedEvent: boolean, eventType: EventType, activeStatus: boolean)
	
	for _, action in actionsList do
		if action.disabled then continue end
		if action.gameProcessed ~= gameProcessedEvent and not action.ingoreGameProcessed then continue end
	
		for _, key in action.keys do
			if key ~= input then continue end
			action.active = activeStatus
			for _, event in action[eventType] do
				event(input)
			end
		end
	end
end

-- Will run the actions key pressed events then immediately run the key released events when button is activated
-- The keycode given for event run by GUI button will be Enum.KeyCode.Unknown
-- actionName: Name of the action
-- button: GUI button
function ActionBinds.GUIButton(actionName: string, button: GuiButton)
	local action = getActionFromName(actionName)
	if action then
		button.Activated:Connect(function()
			if action.disabled then return end

			for _, keyPressedEvent in action.keyPressedEvents do
				keyPressedEvent(Enum.KeyCode.Unknown)
			end

			for _, keyReleasedEvent in action.keyReleasedEvents do
				keyReleasedEvent(Enum.KeyCode.Unknown)
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
function ActionBinds.runActionEvents(actionName: string, eventType: EventType)
	local action = getActionFromName(actionName)
	if action then
		if action.disabled then return end
		if eventType == "keyReleasedEvents" then
			action.active = false
			for _, keyReleasedEvent in action.keyReleasedEvents do
				keyReleasedEvent(Enum.KeyCode.Unknown)
			end	
			return
		elseif eventType == "keyPressedEvents" then
			action.active = true
			for _, keyPressedEvent in action.keyPressedEvents do
				keyPressedEvent(Enum.KeyCode.Unknown)
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
	local keyCode = input.KeyCode
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		keyCode = "MouseButton1"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		keyCode = "MouseButton2"
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		keyCode = "MouseButton3"
	end

	checkEvents(keyCode, gameProcessedEvent, "keyPressedEvents", true)
end

local function inputEnded(input, gameProcessedEvent)
	local keyCode = input.KeyCode
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		keyCode = "MouseButton1"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		keyCode = "MouseButton2"
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		keyCode = "MouseButton3"
	end
	
	checkEvents(keyCode, gameProcessedEvent, "keyReleasedEvents", false)
end

UserInputService.InputBegan:Connect(inputBegan)
UserInputService.InputEnded:Connect(inputEnded)

return ActionBinds
