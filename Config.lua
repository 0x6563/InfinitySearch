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
function addon:LoadConfig()
    self.db = LibStub("AceDB-3.0"):New("InfinitySearchDB", { profile = Config:BaseProfile() });
    self.db.RegisterCallback(self, "OnProfileChanged", "ProfileVersionUpgrade");
    self.db.RegisterCallback(self, "OnProfileReset", "ProfileVersionUpgrade");
    addon:ProfileVersionUpgrade();
    local generalConfig = {
        Config:HeaderFactory('Positioning'),
        {
            type = 'toggle',
            name = 'Lock Position',
            get = function() return addon.lock.movement end,
            set = function(_, val) 
                addon.lock.movement = val;
                if addon.lock.movement then
                    addon:Close();
                else
                    addon:Show();
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
        Config:ToggleFactory('Toys', 'collections', 'toys', ''),
        Config:ToggleFactory('Pets', 'collections', 'pets', ''),
        Config:ToggleFactory('Spells', 'collections', 'spells', ''),
        Config:ToggleFactory('Mounts', 'collections', 'mounts', ''),
        Config:ToggleFactory('Consumables', 'collections', 'consumables', ''),
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
        Config:RangeConfigFactory("Font Size", "searchbar", "fontSize", '', 6, 24, 1),
        Config:FontConfigFactory("Font", "searchbar", "font"),
        Config:Break(""),
        Config:ColorConfigFactory('Font Color', 'searchbar', 'fontColor' ),
        Config:ColorConfigFactory('Font Highlight Color', 'searchbar', 'fontColorHighlight' ),
        Config:Break(""),
        Config:ColorConfigFactory('Backdrop Color', 'searchbar', 'backdropColor' ),
        Config:ColorConfigFactory('Highlight Color', 'searchbar', 'backdropColorHighlight' ),
        Config:HeaderFactory('Option 1'),
        {
            type = 'toggle',
            name = 'Copy changes to all bars',
            get = function() return addon.lock.singleOptionTheme end,
            set = function(_, val) 
                addon.lock.singleOptionTheme = val;
                addon:UpdateLayout();
            end,
            width = "full"
        },
        Config:RangeConfigFactory("Font Size", "opt1", "fontSize", '', 6, 24, 1),
        Config:FontConfigFactory("Font", "opt1", "font", ''),
        Config:Break(""),
        Config:ColorConfigFactory('Font Color', 'opt1', 'fontColor', '' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt1', 'fontColorHighlight', '' ),
        Config:Break(""),
        Config:ColorConfigFactory('Backdrop Color', 'opt1', 'backdropColor', '' ),
        Config:ColorConfigFactory('Highlight Color', 'opt1', 'backdropColorHighlight', '' ),
        Config:Break(""),
        Config:HeaderFactory('Option 2', 'singleOptionTheme'),
        Config:RangeConfigFactory("Font Size", "opt2", "fontSize", 'singleOptionTheme', 6, 24, 1),
        Config:FontConfigFactory("Font", "opt2", "font", 'singleOptionTheme'),
        Config:Break(""),
        Config:ColorConfigFactory('Font Color', 'opt2', 'fontColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt2', 'fontColorHighlight', 'singleOptionTheme' ), 
        Config:Break(""),
        Config:ColorConfigFactory('Backdrop Color', 'opt2', 'backdropColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Highlight Color', 'opt2', 'backdropColorHighlight' , 'singleOptionTheme'), 
        Config:HeaderFactory('Option 3', 'singleOptionTheme'),
        Config:RangeConfigFactory("Font Size", "opt3", "fontSize", 'singleOptionTheme', 6, 24, 1),
        Config:FontConfigFactory("Font", "opt3", "font", "singleOptionTheme"),
        Config:Break(""),
        Config:ColorConfigFactory('Font Color', 'opt3', 'fontColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt3', 'fontColorHighlight', 'singleOptionTheme' ),
        Config:Break(""),
        Config:ColorConfigFactory('Backdrop Color', 'opt3', 'backdropColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Highlight Color', 'opt3', 'backdropColorHighlight' , 'singleOptionTheme'),
        Config:HeaderFactory('Option 4', 'singleOptionTheme'),
        Config:RangeConfigFactory("Font Size", "opt4", "fontSize", 'singleOptionTheme', 6, 24, 1),
        Config:FontConfigFactory("Font", "opt4", "font", "singleOptionTheme"),
        Config:Break(""),
        Config:ColorConfigFactory('Font Color', 'opt4', 'fontColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt4', 'fontColorHighlight', 'singleOptionTheme' ), 
        Config:Break(""),
        Config:ColorConfigFactory('Backdrop Color', 'opt4', 'backdropColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Highlight Color', 'opt4', 'backdropColorHighlight' , 'singleOptionTheme'), 
        Config:HeaderFactory('Option 5', 'singleOptionTheme'),
        Config:RangeConfigFactory("Font Size", "opt5", "fontSize", 'singleOptionTheme', 6, 24, 1),
        Config:FontConfigFactory("Font", "opt5", "font", "singleOptionTheme"),
        Config:Break(""),
        Config:ColorConfigFactory('Font Color', 'opt5', 'fontColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Font Color Highlight', 'opt5', 'fontColorHighlight', 'singleOptionTheme' ),
        Config:Break(""),
        Config:ColorConfigFactory('Backdrop Color', 'opt5', 'backdropColor', 'singleOptionTheme' ),
        Config:ColorConfigFactory('Highlight Color', 'opt5', 'backdropColorHighlight' , 'singleOptionTheme')
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

function Config:HeaderFactory(label, lock) 
    return {
        type = 'header',
        name = label,
        hidden = function() return addon.lock[lock] end,
        disabled = function() return addon.lock[lock] end
    } 
end
function Config:DescriptionFactory(label, lock) 
    return {
        type = 'description',
        name = label,
        hidden = function() return addon.lock[lock] end,
        disabled = function() return addon.lock[lock] end,
        width = "full"
    } 
end
function Config:Break(lock) 
    return {
        type = 'description',
        name = '',
        hidden = function() return addon.lock[lock] end,
        disabled = function() return addon.lock[lock] end,
        width = "full"
    } 
end
function Config:ColorConfigFactory(label, target, property, lock)
    return {
        type = 'color',
        name = label,
        get = function() return unpack(addon.db.profile[target][property]) end,
        set = function(_, r, g, b, a) Config:UpdateDBProfile(target, property, {r, g, b, a}) end,
        hidden = function() return addon.lock[lock] end,
        disabled = function() return addon.lock[lock] end,
    }
end

function Config:ToggleFactory(label, target, property, lock)
    return {
        type = 'toggle',
        name = label,
        get = function() return addon.db.profile[target][property] end,
        set = function(self, val) Config:UpdateDBProfile(target, property, val) end,
        hidden = function() return addon.lock[lock] end,
        disabled = function() return addon.lock[lock] end
    }
end

function Config:FontConfigFactory(label, target, property, lock)
    return {
        type = 'select',
        dialogControl = 'LSM30_Font',
        name = label,
        values = Media:HashTable("font"),
        get = function() return addon.db.profile[target][property] end,
        set = function(self, val) Config:UpdateDBProfile(target, property, val) end,
        hidden = function() return addon.lock[lock] end,
        disabled = function() return addon.lock[lock] end,
        width = "double"
    };
end

function Config:RangeConfigFactory(label, target, property, lock, min, max, step)
    return 	{
		type = "range",
		name = label,
		min = min,
		max = max,
		step = step,
        get = function() return addon.db.profile[target][property] end,
        set = function(self, val) Config:UpdateDBProfile(target, property, val) end,
        hidden = function() return addon.lock[lock] end,
        disabled = function() return addon.lock[lock] end
	}
end


function Config:KeybindFactory(label, cmd)
    return {
        type = 'keybinding',
        name = label,
        get = function() return GetBindingKey(cmd) end,
        set = function(_, val) addon:SetKeybind(val, cmd) end
    }
end

function Config:UpdateDBProfile(target, property, val)
    addon.db.profile[target][property] = val;
    if target == 'opt1' and addon.lock.singleOptionTheme  then
        addon.db.profile.opt2[property] = val;
        addon.db.profile.opt3[property] = val;
        addon.db.profile.opt4[property] = val;
        addon.db.profile.opt5[property] = val;
    end
    addon:UpdateLayout(); 
end
