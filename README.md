# Roblox ActionBinds

Roblox ActionBinds is a module that will allow you to create actions that can be controlled my key presses other means.
## Installation

Copy the contents of [ActionBinds.lua](https://raw.githubusercontent.com/SheepWizard/Roblox-ActionBinds/master/ActionBinds.lua) into a module in StarterPlayerScripts. 

## Basic usage

Below is a basic example of a local script creating two actions and controlling the actions events.
```lua
local ActionBinds = require(script.Parent:WaitForChild("ActionBinds"))

-- Create a action called 'sprint' whos events will be controlled by left or right shift.
ActionBinds.newAction("sprint", {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift}, false)
ActionBinds.newAction("reload", {Enum.KeyCode.R}, false)

-- When 'R' is pressed this event will run.
ActionBinds.OnActionKeyPressed("reload", function(keycode)
	print("Reload button pressed with key " .. tostring(keycode))
end)
-- When left or right shift is pressed this event will run, disabling the reload event.
ActionBinds.OnActionKeyPressed("sprint", function(keycode)
	print("Start sprinting.")
	ActionBinds.disable("reload") -- Disable reload action
end)	
-- When left or right shift is released this even will run, enabling the reload event
ActionBinds.OnActionKeyReleased("sprint", function(keycode)
	print("Stop sprinting.")
	ActionBinds.enable("reload") -- Enable reload action
end)
```
You can also see a basic example of all functions being used here: https://github.com/SheepWizard/Roblox-ActionBinds/blob/master/Example.lua

## API

### ActionBinds.newAction
Creates a new action.
```lua
ActionBinds.newAction(name: string, keys: KeyList, gameProcessed: boolean?): Action
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| name     | Name of the action |
| keys    | List of key code enums which will trigger action events. There is no limit on how many keycodes you can use      |
| gameProcessed | If action events should trigger if gameProcessed is true or false (optional)      |

Example:
```lua
ActionBinds.newAction("sprint", {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift}, false)
```

### ActionBinds.OnActionKeyPressed
Add a key pressed event to the action. When one of the actions keys is pressed this event will run.
```lua
ActionBinds.OnActionKeyPressed(actionName: string, event: (Enum.KeyCode?) -> any?)
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |
| event    | Function to run when one of actions keys is pressed. The key that is pressed is given as a parameter     |

Example:
```lua
ActionBinds.OnActionKeyPressed("sprint", function(keycode)
	print("Start sprinting.")
end)
```

### ActionBinds.OnActionKeyReleased
Add a key released event to the action. When one of the actions keys is released this event will run.
```lua
ActionBinds.OnActionKeyReleased(actionName: string, event: (Enum.KeyCode?) ->any?)
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |
| event    | Function to run when one of actions keys is released. The key that is pressed is given as a parameter     |

Example:
```lua
ActionBinds.OnActionKeyReleased("sprint", function(keycode)
	ActionBinds.enable("reload")
end)
```

### ActionBinds.isActive
Returns true or false if the action is currently active. A action will be active if one of its key is pressed.
```lua
ActionBinds.isActive(actionName: string): boolean
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |
Example:

```lua
print(ActionBinds.isActive("sprint"))
```

### ActionBinds.disable
Disable events from running on a action.
```lua
ActionBinds.disable(actionName: string)
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |
Example:

```lua
ActionBinds.disable("reload") 
```

### ActionBinds.enable
Enable events on a action.
```lua
ActionBinds.enable(actionName: string)
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |

Example:
```lua
ActionBinds.enable("reload") 
```

### ActionBinds.isDisabled
Check is a actions events have been disabled
```lua
ActionBinds.isDisabled(actionName: string): boolean
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |

Example:
```lua
print(ActionBinds.isDisabled("sprint"))
```

### ActionBinds.ignoreGameProcessed
If set to true action events will ignore all gameProcessed rules and the event will run when gameProcessed is both true or false.
```lua
ActionBinds.ignoreGameProcessed(actionName: string, bool: boolean)
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |
| bool    | If gameProcessed should be ignored or not   |

Example:
```lua
ActionBinds.ignoreGameProcessed("menu", true)
```

### ActionBinds.getKeys
Get a list of all keys bound to a action.
```lua
ActionBinds.getKeys(actionName: string): KeyList
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |

Example:
```lua
local keyList1 = ActionBinds.getKeys("reload")
```

### ActionBinds.changeKeys
Give a new list of keys that will run the actions events, replacing the old ones.
```lua
ActionBinds.changeKeys(actionName: string, keys: KeyList)
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |
| keys    | New list of keycode enums     |

Example:
```lua
ActionBinds.changeKeys("sprint", {Enum.KeyCode.KeypadEnter})
```

### ActionBinds.getActionObject
Get the Action object.
```lua
ActionBinds.getActionObject(actionName: string): Action
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |

Example:
```lua
local action = ActionBinds.getActionObject("reload")
```

### ActionBinds.GUIButton
When the GUI button is activated it will run the actions key pressed events then immediately run the key released events.
The keycode given for events run by GUI buttons will be Enum.KeyCode.Unknown
```lua
ActionBinds.GUIButton(actionName: string, button: GuiButton)
```
| Parameter        | Description           | 
| ------------- |:-------------:|
| actionName     | Name of the action |
| button    | The GUI button you want to use to run action events     |

Example:
```lua
local button = Instance.new("TextButton")
ActionBinds.GUIButton("reload", button)
```

### ActionBinds.runActionEvents
Run events for a action manually. Best to run both event to simulate a key press and release.
If eventType 1 is used the actions 'active' property will be set to true and stay that way until a key released event is pressed.
The keycode given for event run by this function will be Enum.KeyCode.Unknown
```lua
ActionBinds.runActionEvents(actionName: string, eventType: number)
```
| Parameter | Description    
| ------------- |:-------------:|
| actionName     | Name of the action |
| eventType    | Either 0 or 1. 0 for key released events, 1 for key pressed events     |

Example:
```lua
ActionBinds.runActionEvents("sprint", 1)
wait(5)
ActionBinds.runActionEvents("sprint", 0)
```

### ActionBinds.actionNames
A table of all action names.
Example:
```lua
for k, v in pairs(ActionBinds.actionNames) do
	print(v)
end
```

## Types
```lua
type KeyList = {[number]: Enum.KeyCode}

type Action = {
	name: string,
	keys: KeyList,
	gameProcessed: boolean?,
	ingoreGameProcessed: boolean?,
	disabled: boolean,
	active: boolean,
	keyPressedEvents: {[number]: (Enum.KeyCode?) -> any?},
	keyReleasedEvents: {[number]: (Enum.KeyCode?) -> any?},
}

```


