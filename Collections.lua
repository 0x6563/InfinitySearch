local addon = InfinitySearch;
local Collections = {};
local ThirdPartyCommands = {};

function addon:Populate()
    wipe(addon.list)
    wipe(addon.searchable)
    
    if addon:CollectionEnabled('mounts') then
        Collections.AddMounts()
    end
    if addon:CollectionEnabled('pets') then 
        Collections.AddPets()
    end
    if addon:CollectionEnabled('toys') then 
        Collections.AddToys()
    end
    if addon:CollectionEnabled('consumables') then 
        Collections.AddConsumables()
    end
    if addon:CollectionEnabled('spells') then 
        Collections.AddSpells()
    end
    if addon:CollectionEnabled('infinitySearch') then 
        Collections.AddAddonInfinitySearch();
    end
    if addon:CollectionEnabled('ui') then 
        Collections.AddUIPanels();
    end

    for key, val in pairs(ThirdPartyCommands) do
        if addon:CollectionEnabled('addon:'..key) then 
            Collections.AddAddon(key);
        end
    end
end

function addon:RegisterAddonMacrotext(addon, name, icon, command)
   Collections.RegisterThirdparty({
        addon = addon,
        name = name,
        icon = icon, 
        execute = 'macro',
        command = command
    });
end
function addon:RegisterAddonFunction(addon, name, icon, command)
   Collections.RegisterThirdparty({
        addon = addon,
        name = name,
        icon = icon, 
        execute = 'function',
        command = command
    });
end

function addon:UnregisterAddonCommand(addon, name)
    Collections.UnregisterAddonCommand(addon, name);
end

function addon:CollectionEnabled(collection)
    if type(self.db.profile.collections[collection]) ~= 'boolean' then
        self.db.profile.collections[collection] = true;
        addon:RefreshCollectionsConfig();
    end
    return self.db.profile.collections[collection];
end

function Collections.RegisterThirdparty(cmd)
    ThirdPartyCommands[cmd.addon] = ThirdPartyCommands[cmd.addon] or {};
    addon:CollectionEnabled('addon:'..cmd.addon);
    ThirdPartyCommands[cmd.addon][cmd.name] = cmd;
end

function Collections.UnregisterAddonCommand(addon, name)
    ThirdPartyCommands[addon][name] = nil;
end

function Collections.Add(cmd)
    cmd.icon = cmd.icon or addon.defaults.icon,
    table.insert(addon.list, cmd)
    table.insert(addon.searchable, cmd.type .. ": " .. cmd.name)
end

function Collections.AddMacro(type, name, icon, command)
    local m = {
        execute = "macro",
        icon = icon,
        name = name,
        type = type,
        command = command
    }
    Collections.Add(m);
end
function Collections.AddFunction(type, name, icon, command)
    local cmd = {
        execute = 'function',
        name = name,
        icon = icon,
        type = type,
        command = command
    };
    Collections.Add(cmd);
end

function Collections.AddAddon(addon)
    for key, val in pairs(ThirdPartyCommands[addon]) do
        if val.execute == 'macro' then
            Collections.AddMacro('Addon', val.name, val.icon, val.command)
        elseif val.execute == 'function' then
            Collections.AddFunction('Addon', val.name, val.icon, val.command)
        end
    end
end

function Collections.AddMounts()
    local mountIDs = C_MountJournal.GetMountIDs();
    for i, mountID in ipairs(mountIDs) do
        local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID);
        if isCollected and isUsable then
            Collections.AddMacro("Mount", name, icon, string.format("%s %s", SLASH_USE1, name))
        end
    end
end

function Collections.AddPets()
    C_PetJournal.ClearSearchFilter()
    C_PetJournal.SetAllPetSourcesChecked(true)
    C_PetJournal.SetAllPetTypesChecked(true)
    local exists = {}
    local i = 1;
    local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon = C_PetJournal.GetPetInfoByIndex(i);
    while (petID)
    do
        if owned and exists[speciesName] == nil then
            Collections.AddMacro("Pet", speciesName, icon, string.format("%s %s", '/summonpet', speciesName))
            exists[speciesName] = true;
        end
        i = i + 1;
        petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon = C_PetJournal.GetPetInfoByIndex(i);
    end
end

function Collections.AddToys()
    C_ToyBox.SetAllSourceTypeFilters(true)
    C_ToyBox.SetCollectedShown(true)
    C_ToyBox.SetUncollectedShown(false)

    for i = 1, C_ToyBox.GetNumFilteredToys() do
        local id, name, icon, isFavorite, hasFanfare = C_ToyBox.GetToyInfo(C_ToyBox.GetToyFromIndex(i));
        if name and C_ToyBox.IsToyUsable(id) then
            Collections.AddMacro("Toy", name, icon, string.format("%s %s", SLASH_USE_TOY1, name));
        end
    end
end

function Collections.AddConsumables()
    local exists = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            id = GetContainerItemID(bag, slot)
            if id ~= nil and exists[id] == nil then
                local name, link, rarity, level, minLevel, type, subtype, stackCount, equipLocation, icon = GetItemInfo(id);
                if type == 'Consumable' then
                    Collections.AddMacro("Item", name, icon, string.format("%s %s", SLASH_USE1, name));
                end
                exists[id] = true;
            end
        end
    end
end

function Collections.AddSpells()
    local tabs = GetNumSpellTabs()
    for t = 1, tabs do
        local tabName, texture, offset, numSpells = GetSpellTabInfo(t);
        for i = offset + 1, offset + numSpells do
            local name, rank = GetSpellBookItemName(i, BOOKTYPE_SPELL);
            local type, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL);
            local icon = GetSpellTexture(spellID)
            local isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)
            local isUsable, _ = IsUsableSpell(i, BOOKTYPE_SPELL)
            if (rank and name and isUsable and not isPassive and type ~= "FUTURESPELL") then
                Collections.AddMacro("Spell", name, icon, string.format("%s %s", SLASH_CAST1, name));
            end
        end
    end
end

function Collections.AddAddonInfinitySearch()
    Collections.AddFunction("Addon", "InfinitySearch Drag Mode", nil,
        function()
            addon.lock.close = true;
            addon:ToggleEditMode();
        end
    );
    Collections.AddFunction("Addon", "InfinitySearch Toggle Flyout", nil,
        function()
            addon.lock.close = true;
            if addon.db.profile.direction == 'up' then
                addon.db.profile.direction = 'down';
            else
                addon.db.profile.direction = 'up'
            end
            addon:UpdateLayout();
        end
    );
end

function Collections.AddUIPanels()
    Collections.AddFunction("UI", "Open Character Tab", nil, function() ToggleCharacter("PaperDollFrame"); end);
    Collections.AddFunction("UI", "Open Pet Tab", nil, function() ToggleCharacter("PetPaperDollFrame"); end);
    Collections.AddFunction("UI", "Open Reputation Tab", nil, function() ToggleCharacter("ReputationFrame"); end);
    Collections.AddFunction("UI", "Open Currency Tab", nil, function() ToggleCharacter("TokenFrame"); end);
    Collections.AddFunction("UI", "Open Adventure Guide", nil, function()  ToggleEncounterJournal(); end);
    Collections.AddFunction("UI", "Open Talents", nil, function() ToggleTalentFrame(); end);
    Collections.AddFunction("UI", "Open Achievements", nil, function()  ToggleAchievementFrame(); end);
    Collections.AddFunction("UI", "Open Dungeon Finder",  nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", LFDParentFrame) end);
    Collections.AddFunction("UI", "Open Raid Finder",  nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", RaidFinderFrame) end);
    Collections.AddFunction("UI", "Open Premade Groups window",  nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", LFGListPVEStub) end);
    Collections.AddFunction("UI", "Open PVP window",  nil, function() TogglePVPUI() end);
    Collections.AddFunction("UI", "Open Mounts Journal",  nil, function() ToggleCollectionsJournal(1) end);
    Collections.AddFunction("UI", "Open Pet Journal",  nil, function() ToggleCollectionsJournal(2) end);
    Collections.AddFunction("UI", "Open Toybox Journal",  nil, function() ToggleCollectionsJournal(3) end);
    Collections.AddFunction("UI", "Open Heirlooms Journal",  nil, function() ToggleCollectionsJournal(4) end);
    Collections.AddFunction("UI", "Open Appearances Journal",  nil, function() ToggleCollectionsJournal(5) end);
    Collections.AddFunction("UI", "Open Weekly Rewards",  nil, function() WeeklyRewards_ShowUI() end);
end

