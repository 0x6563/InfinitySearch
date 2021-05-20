local addon = InfinitySearch;
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local Media = LibStub("LibSharedMedia-3.0");
local addon = InfinitySearch;
local Config = {
};

local options = {
    type = "group",
    args = {general = {type = "group", name = "General", args = {}}}
}
Media:Register("font", "AlegreyaSansSC-Bold", [[Interface\AddOns\InfinitySearch\fonts\AlegreyaSansSC-Bold.ttf]])
Media:Register("font", "AlegreyaSansSC-ExtraBold", [[Interface\AddOns\InfinitySearch\fonts\AlegreyaSansSC-ExtraBold.ttf]])
function addon:loadConfig()
    self.db = LibStub("AceDB-3.0"):New("InfinitySearchDB", { profile = Config:BaseProfile() });
    self.db.RegisterCallback(self, "OnProfileChanged", "ProfileVersionUpgrade");
    self.db.RegisterCallback(self, "OnProfileReset", "ProfileVersionUpgrade");
    addon:ProfileVersionUpgrade();
    local generalConfig = {
        Config:HeaderFactory('Positioning'),
        {
            type = 'toggle',
            name = 'Lock Position',
            get = function() return addon.lockMovement end,
            set = function(_, val) 
                addon.lockMovement = val;
                if addon.lockMovement then
                    addon:close();
                else
                    addon:show();
                end
            end
        }, {
            type = 'select',
            name = 'Flyout Direction',
            values = { up = "Up", down = "Down"},
            get = function() return addon.db.profile.direction end,
            set = function(_, val) addon.db.profile.direction = val; addon:UpdateLayout(); end
        }, 
        Config:HeaderFactory('Collections'),
        Config:CollectionToggleFactory('Toys', 'collections', 'toys'),
        Config:CollectionToggleFactory('Pets', 'collections', 'pets'),
        Config:CollectionToggleFactory('Spells', 'collections', 'spells'),
        Config:CollectionToggleFactory('Mounts', 'collections', 'mounts'),
        Config:CollectionToggleFactory('Consumables', 'collections', 'consumables'),
        Config:HeaderFactory('Keybinds'),
        Config:KeybindFactory('Toggle Infinity Search', "INFINITYSEARCH_TOGGLE"),
        Config:KeybindFactory('Select Option 1', "CLICK InfinitySearchOption1:LeftButton"),
        Config:KeybindFactory('Select Option 2', "CLICK InfinitySearchOption2:LeftButton"),
        Config:KeybindFactory('Select Option 3', "CLICK InfinitySearchOption3:LeftButton"),
        Config:KeybindFactory('Select Option 4', "CLICK InfinitySearchOption4:LeftButton"),
        Config:KeybindFactory('Select Option 5', "CLICK InfinitySearchOption5:LeftButton")
    };

    local themeConfig = {
        Config:HeaderFactory('Searchbar'),
        Config:FontConfigFactory("Font", "searchbar", "font"),
        Config:RangeConfigFactory("Font Size", "searchbar", "fontSize", 6, 24, 1),
        Config:ColorConfigFactory('Font Color', 'searchbar', 'fontColor' ),
        Config:ColorConfigFactory('Font Highlight Color', 'searchbar', 'fontColorHighlight' ),
        Config:ColorConfigFactory('Backdrop Color', 'searchbar', 'backdropColor' ),
        Config:ColorConfigFactory('Highlight Color', 'searchbar', 'backdropColorHighlight' ),
        Config:HeaderFactory('Option 1'),
        Config:FontConfigFactory("Font", "opt1", "font"),
        Config:RangeConfigFactory("Font Size", "opt1", "fontSize", 6, 24, 1),
        Config:ColorConfigFactory('Font Color', 'opt1', 'fontColor' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt1', 'fontColorHighlight' ),
        Config:ColorConfigFactory('Backdrop Color', 'opt1', 'backdropColor' ),
        Config:ColorConfigFactory('Highlight Color', 'opt1', 'backdropColorHighlight' ),
        Config:HeaderFactory('Option 2'),
        Config:FontConfigFactory("Font", "opt2", "font"),
        Config:RangeConfigFactory("Font Size", "opt2", "fontSize", 6, 24, 1),
        Config:ColorConfigFactory('Font Color', 'opt2', 'fontColor' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt2', 'fontColorHighlight' ), 
        Config:ColorConfigFactory('Backdrop Color', 'opt2', 'backdropColor' ),
        Config:ColorConfigFactory('Highlight Color', 'opt2', 'backdropColorHighlight' ), 
        Config:HeaderFactory('Option 3'),
        Config:FontConfigFactory("Font", "opt3", "font"),
        Config:RangeConfigFactory("Font Size", "opt3", "fontSize", 6, 24, 1),
        Config:ColorConfigFactory('Font Color', 'opt3', 'fontColor' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt3', 'fontColorHighlight' ),
        Config:ColorConfigFactory('Backdrop Color', 'opt3', 'backdropColor' ),
        Config:ColorConfigFactory('Highlight Color', 'opt3', 'backdropColorHighlight' ),
        Config:HeaderFactory('Option 4'),
        Config:FontConfigFactory("Font", "opt4", "font"),
        Config:RangeConfigFactory("Font Size", "opt4", "fontSize", 6, 24, 1),
        Config:ColorConfigFactory('Font Color', 'opt4', 'fontColor' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt4', 'fontColorHighlight' ), 
        Config:ColorConfigFactory('Backdrop Color', 'opt4', 'backdropColor' ),
        Config:ColorConfigFactory('Highlight Color', 'opt4', 'backdropColorHighlight' ), 
        Config:HeaderFactory('Option 5'),
        Config:FontConfigFactory("Font", "opt5", "font"),
        Config:RangeConfigFactory("Font Size", "opt5", "fontSize", 6, 24, 1),
        Config:ColorConfigFactory('Font Color', 'opt5', 'fontColor' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt5', 'fontColorHighlight' ),
        Config:ColorConfigFactory('Backdrop Color', 'opt5', 'backdropColor' ),
        Config:ColorConfigFactory('Highlight Color', 'opt5', 'backdropColorHighlight' )
    }

    local options = {
        type = "group",
        args = {
            general = {
                type = "group",
                name = "General",
                args = Config:ArrayToDictionary(generalConfig)
            },
            theme = {
                type = "group",
                name = "Theme",
                args = Config:ArrayToDictionary(themeConfig)
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
        }
    };

    AceConfigRegistry:RegisterOptionsTable("InfinitySearch", options);
    AceConfigDialog:AddToBlizOptions("InfinitySearch", "InfinitySearch");
    AceConfigDialog:AddToBlizOptions("InfinitySearch", "General", "InfinitySearch", "general");
    AceConfigDialog:AddToBlizOptions("InfinitySearch", "Theme", "InfinitySearch", "theme");
    AceConfigDialog:AddToBlizOptions("InfinitySearch", "Profiles", "InfinitySearch", "profiles");
end

function addon:ProfileVersionUpgrade()
    self.db.profile.version = self.db.profile.version or 0;
    if self.db.profile.version < 1.2 then
        self.db.profile = Config:BaseProfile();
    end
    if InfinitySearchParent then
        addon:UpdateLayout()
    end
end
function Config:BaseProfile(   )
    return {
        version = 1.2,
        searchbar = Config:FrameConfigFactory("AlegreyaSansSC-ExtraBold", 20, {0, 0, 0, 1 }),
        opt1 = Config:FrameConfigFactory("AlegreyaSansSC-ExtraBold", 18, {.7, .91, .45, 1}),
        opt2 = Config:FrameConfigFactory("AlegreyaSansSC-ExtraBold", 18, {.89, .16, .95, 1}),
        opt3 = Config:FrameConfigFactory("AlegreyaSansSC-ExtraBold", 18, {.15, .43, .96, 1}),
        opt4 = Config:FrameConfigFactory("AlegreyaSansSC-ExtraBold", 18, {100, 0, .19, 1}),
        opt5 = Config:FrameConfigFactory("AlegreyaSansSC-ExtraBold", 18, {100, .55, 0, 1}),
        direction = "down",
        collections = {
            toys = true,
            pets = true,
            spells = true,
            mounts = true,
            consumables = true
        }
    }
end

function Config:FrameConfigFactory(font, fontSize, highlight)
    return {
        font = font,
        fontSize = fontSize,
        fontColor = {1, 1, 1, 1},
        fontColorHighlight = {1, 1, 1, 1},
        backdropColor = {0, 0, 0, 1},
        backdropColorHighlight = highlight
    }
end

function Config:ArrayToDictionary(ary)
    local dictionary = {}
    for i, item in ipairs(ary) do
        item.order = i;
        dictionary['item' .. i] = item;
    end
    return dictionary;
end

function Config:HeaderFactory(label) return {type = 'header', name = label} end

function Config:ColorConfigFactory(label, target, property)
    return {
        type = 'color',
        name = label,
        get = function() return unpack(addon.db.profile[target][property]) end,
        set = function(_, r, g, b, a)
            addon.db.profile[target][property] = {r, g, b, a};
            addon:UpdateLayout();
        end
    }
end

function Config:CollectionToggleFactory(label, target, property)
    return {
        type = 'toggle',
        name = label,
        get = function() return addon.db.profile[target][property] end,
        set = function(_, val) 
            addon.db.profile[target][property] = val;
            addon:UpdateLayout();
        end
    }
end

function Config:FontConfigFactory(label, target, property)
    return {
        type = 'select',
        dialogControl = 'LSM30_Font',
        name = label,
        values = Media:HashTable("font"),
        get = function() return addon.db.profile[target][property] end,
        set = function(self, val) 
            addon.db.profile[target][property] = val;
            addon:UpdateLayout(); 
        end
    };
end

function Config:RangeConfigFactory(label, target, property, min, max, step)
    return 	{
		type = "range",
		name = label,
		min = min,
		max = max,
		step = step,
        get = function() return addon.db.profile[target][property] end,
        set = function(self, val) 
            addon.db.profile[target][property] = val;
            addon:UpdateLayout(); 
        end
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
