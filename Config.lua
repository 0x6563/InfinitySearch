local addon = InfinitySearch;
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local media = LibStub("LibSharedMedia-3.0");
local addon = InfinitySearch;
local Config = {};
local options = {
    type = "group",
    args = {
        general = {
            type = "group",
            name = "General",
            args = { }
        }
    }
}
function addon:loadConfig ()
    self.db = LibStub("AceDB-3.0"):New("InfinitySearchDB", {
        profile = {
            opt1 = {backdropColor = {.7, .91, .45, 1}},
            opt2 = {backdropColor = {.89, .16, .95, 1}},
            opt3 = {backdropColor = {.15, .43, .96, 1}},
            opt4 = {backdropColor = {100, 0, .19, 1}},
            opt5 = {backdropColor = {100, .55, 0, 1}},
            direction = "down",
            collections = {
                toys = true,
                pets = true,
                spells = true,
                mounts = true,
                consumables = true
            }
        }
    })
    addon.db.profile.direction = addon.db.profile.direction or "down"
    local generalConfig = { 
        Config:HeaderFactory('Positioning'),
        {
            type = 'toggle',
            name = 'Lock Position',
            get = function() return addon.lockMovement end,
            set = function(_, val)  addon.lockMovement = val end
        },
        {
            type = 'select',
            name = 'Flyout Direction',
            values = { up = "Up", down = "Down" },
            get = function() return addon.db.profile.direction end,
            set = function(_, val)  addon:updateFlyout(val) end
        },
        Config:HeaderFactory('Collections'),
        Config:CollectionToggleFactory('Toys', 'toys'),
        Config:CollectionToggleFactory('Pets', 'pets'),
        Config:CollectionToggleFactory('Spells', 'spells'),
        Config:CollectionToggleFactory('Mounts', 'mounts'),
        Config:CollectionToggleFactory('Consumables', 'consumables'),
        Config:HeaderFactory('Keybinds'),
        Config:KeybindFactory('Toggle Infinity Search', "INFINITYSEARCH_TOGGLE"),
        Config:KeybindFactory('Select Option 1', "CLICK InfinitySearchOption1:LeftButton"),
        Config:KeybindFactory('Select Option 2', "CLICK InfinitySearchOption2:LeftButton"),
        Config:KeybindFactory('Select Option 3', "CLICK InfinitySearchOption3:LeftButton"),
        Config:KeybindFactory('Select Option 4', "CLICK InfinitySearchOption4:LeftButton"),
        Config:KeybindFactory('Select Option 5', "CLICK InfinitySearchOption5:LeftButton"),
        Config:HeaderFactory('Colors'),
        Config:OptionConfigFactory(1),
        Config:OptionConfigFactory(2),
        Config:OptionConfigFactory(3),
        Config:OptionConfigFactory(4),
        Config:OptionConfigFactory(5),
    };
    
    local options = {
        type = "group",
        args = {
            general = { 
                type = "group",
                name = "General",
                args = Config:ArrayToDictionary(generalConfig)
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        }
    };
    
	AceConfigRegistry:RegisterOptionsTable("InfinitySearch", options)
    AceConfigDialog:AddToBlizOptions("InfinitySearch", "InfinitySearch")
    AceConfigDialog:AddToBlizOptions("InfinitySearch", "General", "InfinitySearch", "general")
    AceConfigDialog:AddToBlizOptions("InfinitySearch", "Profiles", "InfinitySearch", "profiles")
end

function Config:ArrayToDictionary(ary)
    local dictionary = {}
    for i, item in ipairs(ary) do
        item.order = i;
        dictionary['item'..i] = item;
    end
    return dictionary;
end

function Config:HeaderFactory(label)
  return  { type = 'header', name = label }
end

function Config:OptionConfigFactory(n)
    return {
        type = 'color',
        name = 'Option '.. n ..' Highlight Color',
        get = function() return unpack(addon.db.profile['opt'..n].backdropColor) end,
        set = function(_, r, g, b ,a)  addon.db.profile['opt'..n].backdropColor = {r, g, b, a} end
    }
end
function Config:CollectionToggleFactory(label, type)
    return {
        type = 'toggle',
        name = label,
        get = function() return addon.db.profile.collections[type] end,
        set = function(_, val)  addon.db.profile.collections[type] = val end
    }
end
function Config:KeybindFactory(label, cmd)
    return {
        type = 'keybinding',
        name = label,
        get = function() return GetBindingKey(cmd) end,
        set = function(_, val) addon:setKeybind(val, cmd) end
    }
end