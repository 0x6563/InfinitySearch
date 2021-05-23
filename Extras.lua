-- This files serves as an example of how to integrate into InfinitySearch
-- If you would like your addon to not be included or would prefer to register your own commands;
-- Please open a pull request and replace our snippets with a single comment;
-- -- Do not include NameOfMyAddon

-- There are two methods for registering and one for unregistering commands
-- InfinitySearch:RegisterAddonMacrotext(addon, name, icon, command)
--   arguments
--     addon:   string      - The name of your addon. This is prepended to the search text and used to enable/disable it in the collections config.
--     name:    string      - The name of the command
--     icon:    string      - The icon for your command
--     command: string      - The slash command to run

-- InfinitySearch:RegisterAddonFunction(addon, name, icon, command)
--   arguments
--     addon:   string      - The name of your addon. This is prepended to the search text and used to enable/disable it in the collections screen.
--     name:    string      - The name of the command
--     icon:    string      - The icon for your command
--     command: function    - The slash command to run

-- InfinitySearch:UnregisterAddonCommand(addon, name)
--   arguments
--     addon:   string      - The name of your addon
--     name:    string      - The name of the command


local Loaded = CreateFrame("FRAME");
Loaded:RegisterEvent("PLAYER_LOGIN");
Loaded:SetScript("OnEvent", function(_, e)

    if InfinitySearch then
        InfinitySearch:RegisterAddonFunction("Extras: InfinitySearch", "Options", nil, function() InfinitySearch:ShowConfig(); end);
        InfinitySearch:RegisterAddonFunction("Extras: InfinitySearch", "Drag Mode", nil,
            function()
                InfinitySearch.lock.close = true;
                InfinitySearch:ToggleEditMode();
            end
        );
        InfinitySearch:RegisterAddonFunction("Extras: InfinitySearch", "Toggle Flyout Direction", nil,
            function()
                InfinitySearch.lock.close = true;
                if InfinitySearch.db.profile.direction == "up" then
                    InfinitySearch.db.profile.direction = "down";
                else
                    InfinitySearch.db.profile.direction = "up"
                end
                InfinitySearch:UpdateLayout();
            end
        );

        if Details then
            InfinitySearch:RegisterAddonMacrotext("Extras: Details!", "Reset", nil, "/details reset");
            InfinitySearch:RegisterAddonMacrotext("Extras: Details!", "Toggle Window", nil, "/details toggle");
        end

        if RaiderIO then
            InfinitySearch:RegisterAddonMacrotext("Extras: Raider.IO", "Options", nil, "/raiderio");
        end

        if WeakAuras then
            InfinitySearch:RegisterAddonMacrotext("Extras: WeakAuras", "Options", nil, "/weakauras");
            InfinitySearch:RegisterAddonMacrotext("Extras: WeakAuras", "Toggle the minimap icon", nil, "/wa minimap");
            InfinitySearch:RegisterAddonMacrotext("Extras: WeakAuras", "Start profiling", nil, "/wa pstart");
            InfinitySearch:RegisterAddonMacrotext("Extras: WeakAuras", "Finish profiling", nil, "/wa pstop");
            InfinitySearch:RegisterAddonMacrotext("Extras: WeakAuras", "Show the results from the most recent profiling", nil, "/wa pprint");
            InfinitySearch:RegisterAddonMacrotext("Extras: WeakAuras", "Repair tool", nil, "/wa repair");
        end

        if Bartender4 then
            InfinitySearch:RegisterAddonMacrotext("Extras: Bartender4", "Options", nil, "/bt4");
            InfinitySearch:RegisterAddonMacrotext("Extras: Bartender4", "Toggle Lock", nil, "/bt4 lock");
        end
    end
end);