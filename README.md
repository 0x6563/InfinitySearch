# InfinitySearch

## Description
Originally, InfinitySearch was about quickly accessing and using toys, mounts, and pets. That lasted about a week. It now allows opening UI panels, executing addon commands, casting spells, and macros.

## Usage
- Set a keybind to **Toggle InfinitySearch**
- Hit said keybind
- Start typing
- Press Tab to cycle through options
- Press Enter *Twice* (Once to exit the editbox, the second to activate the option)
- Or Click on an option

## Configuration 
Configuration options can be accessed via the Interface Panel or by searching for **InfinitySearch: Options** in the search bar.

Moving the bar can be done by searching and selecting **InfinitySearch: Drag Mode**

To disable a collection of commands, open the configuration screen and toggle on/off whichever collection you would like to enable/disable.

## Registering your addon with InfinitySearch
There are two APIs for registering and one for unregistering. Registered commands are executed from a SecureActionButton and are only executed out of combat. For examples and boilerplate code please refer to [Extras.lua](https://github.com/0x6563/InfinitySearch/blob/main/Extras.lua).

### InfinitySearch:RegisterAddonMacrotext(addon, command, icon, action)
 The name of your addon is prepended to the command, so there is no need to include your addon name in the command name. 
| Argument    | Type   | Optional | Description                                    |
| ----------- | ------ | -------- | ---------------------------------------------- |
| **addon**   | string |          | The name of your addon                         |
| **command** | string |          | The text that shows up in the option selection |
| **icon**    | string | yes      | The icon for your command                      |
| **action**  | string |          | The macrotext to run  i.e. `/happy`            |

### InfinitySearch:RegisterAddonFunction(addon, command, icon, action)
 The name of your addon is prepended to the command, so there is no need to include your addon name in the command name. 
| Argument    | Type     | Optional | Description                                    |
| ----------- | -------- | -------- | ---------------------------------------------- |
| **addon**   | string   |          | The name of your addon                         |
| **command** | string   |          | The text that shows up in the option selection |
| **icon**    | string   | yes      | The icon for your command                      |
| **action**  | function |          | The function to run                            |

### InfinitySearch:UnregisterAddonCommand(addon, command)
| Argument    | Type   | Optional | Description                                    |
| ----------- | ------ | -------- | ---------------------------------------------- |
| **addon**   | string |          | The name of your addon                         |
| **command** | string |          | The text that shows up in the option selection |

### Examples
```
InfinitySearch:RegisterAddonFunction("Extras: InfinitySearch", "Options", nil, function() InfinitySearch:ShowConfig(); end);
InfinitySearch:RegisterAddonMacrotext("Extras: Bartender4", "Options", nil, "/bt4");
InfinitySearch:UnregisterAddonCommand("Extras: Bartender4", "Options");

```
