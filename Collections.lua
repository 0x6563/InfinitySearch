local addon = InfinitySearch;
local Collections = {};
local ThirdPartyCommands = {};

function addon:Populate()
    wipe(addon.list)
    wipe(addon.searchable)
    
    if addon:CollectionEnabled("mounts") then
        Collections.LoadMounts();
    end
    if addon:CollectionEnabled("pets") then 
        Collections.LoadPets();
    end
    if addon:CollectionEnabled("toys") then 
        Collections.LoadToys();
    end
    if addon:CollectionEnabled("consumables") then 
        Collections.LoadConsumables();
    end
    if addon:CollectionEnabled("characterMacros") then 
        Collections.LoadCharacterMacros();
    end
    if addon:CollectionEnabled("accountMacros") then 
        Collections.LoadAccountMacros();
    end
    if addon:CollectionEnabled("spells") then 
        Collections.LoadSpells();
    end
    if addon:CollectionEnabled("ui") then 
        Collections.LoadUIPanels();
    end

    for key, val in pairs(ThirdPartyCommands) do
        if addon:CollectionEnabled("addon:"..key) then 
            Collections.LoadAddon(key);
        end
    end
end

function addon:RegisterAddonMacrotext(addon, name, icon, command)
   Collections.RegisterThirdparty({
        addon = addon,
        name = name,
        icon = icon, 
        execute = "macrotext",
        command = command
    });
end
function addon:RegisterAddonFunction(addon, name, icon, command)
   Collections.RegisterThirdparty({
        addon = addon,
        name = name,
        icon = icon, 
        execute = "function",
        command = command
    });
end

function addon:UnregisterAddonCommand(addon, name)
    Collections.UnregisterAddonCommand(addon, name);
end

function addon:CollectionEnabled(collection)
    if type(self.db.profile.collections[collection]) ~= "boolean" then
        self.db.profile.collections[collection] = true;
        addon:RefreshCollectionsConfig();
    end
    return self.db.profile.collections[collection];
end

function Collections.RegisterThirdparty(cmd)
    ThirdPartyCommands[cmd.addon] = ThirdPartyCommands[cmd.addon] or {};
    addon:CollectionEnabled("addon:" .. cmd.addon);
    ThirdPartyCommands[cmd.addon][cmd.name] = cmd;
end

function Collections.UnregisterAddonCommand(addon, name)
    ThirdPartyCommands[addon][name] = nil;
end

function Collections.Load(execute, type, name, icon, command)
    local o = {
        execute = execute,
        icon = icon or addon.defaults.icon,
        name = name,
        type = type,
        command = command
    }
    Collections.SetSearch(o);
    table.insert(addon.list, o)
    table.insert(addon.searchable, o.search);
end

function Collections.SetSearch(cmd)
    if cmd.type == "Addon" then
        cmd.search = cmd.name;
    else
        cmd.search = cmd.type ..": ".. cmd.name;
    end
end

function Collections.LoadAddon(addon)
    for key, val in pairs(ThirdPartyCommands[addon]) do
        Collections.Load(val.execute, "Addon", addon ..": ".. val.name, val.icon, val.command)
    end
end

function Collections.LoadMounts()
    local mountIDs = C_MountJournal.GetMountIDs();
    for i, mountID in ipairs(mountIDs) do
        local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID);
        if isCollected and isUsable then
            Collections.Load("macrotext", "Mount", name, icon, SLASH_USE1 .." ".. name)
        end
    end
end

function Collections.LoadPets()
    C_PetJournal.ClearSearchFilter()
    C_PetJournal.SetAllPetSourcesChecked(true)
    C_PetJournal.SetAllPetTypesChecked(true)
    local exists = {}
    local i = 1;
    local petID, speciesID, owned, customName, level, favorite, isRevoked, name, icon = C_PetJournal.GetPetInfoByIndex(i);
    while (petID)
    do
        if owned and exists[name] == nil then
            Collections.Load("macrotext", "Pet", name, icon, "/summonpet " .. name)
            exists[name] = true;
        end
        i = i + 1;
        petID, speciesID, owned, customName, level, favorite, isRevoked, name, icon = C_PetJournal.GetPetInfoByIndex(i);
    end
end

function Collections.LoadToys()
    C_ToyBox.SetAllSourceTypeFilters(true)
    C_ToyBox.SetCollectedShown(true)
    C_ToyBox.SetUncollectedShown(false)

    for i = 1, C_ToyBox.GetNumFilteredToys() do
        local id, name, icon, isFavorite, hasFanfare = C_ToyBox.GetToyInfo(C_ToyBox.GetToyFromIndex(i));
        if name and C_ToyBox.IsToyUsable(id) then
            Collections.Load("macrotext", "Toy", name, icon, SLASH_USE_TOY1 .. " " .. name);
        end
    end
end

function Collections.LoadConsumables()
    local exists = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            id = GetContainerItemID(bag, slot)
            if id ~= nil and exists[id] == nil then
                local name, link, rarity, level, minLevel, type, subtype, stackCount, equipLocation, icon = GetItemInfo(id);
                if type == "Consumable" then
                    Collections.Load("macrotext", "Item", name, icon, SLASH_USE1 .. " " .. name);
                end
                exists[id] = true;
            end
        end
    end
end

function Collections.LoadSpells()
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
                Collections.Load("macrotext", "Spell", name, icon, SLASH_CAST1 .. " " .. name);
            end
        end
    end
end

function Collections.LoadCharacterMacros()
    local numMacros = select(2, GetNumMacros());
    for id = 121, 120 + numMacros do
        local name, icon, body, isLocal = GetMacroInfo(id);
        if name then
            Collections.Load("macro", "Macro", name, icon, id);
        end
    end
end

function Collections.LoadAccountMacros()
    local numMacros = select(1, GetNumMacros());
    for id = 1, numMacros do
        local name, icon, body, isLocal = GetMacroInfo(id);
        if name then
            Collections.Load("macro", "Macro", name, icon, id);
        end
    end
end

function Collections.LoadUIPanels()
    Collections.Load("function", "UI", "Open Character Tab", nil, function() ToggleCharacter("PaperDollFrame"); end);
    Collections.Load("function", "UI", "Open Pet Tab", nil, function() ToggleCharacter("PetPaperDollFrame"); end);
    Collections.Load("function", "UI", "Open Reputation Tab", nil, function() ToggleCharacter("ReputationFrame"); end);
    Collections.Load("function", "UI", "Open Currency Tab", nil, function() ToggleCharacter("TokenFrame"); end);
    Collections.Load("function", "UI", "Open Adventure Guide", nil, function()  ToggleEncounterJournal(); end);
    Collections.Load("function", "UI", "Open Talents", nil, function() ToggleTalentFrame(); end);
    Collections.Load("function", "UI", "Open Achievements", nil, function()  ToggleAchievementFrame(); end);
    Collections.Load("function", "UI", "Open Dungeon Finder",  nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", LFDParentFrame) end);
    Collections.Load("function", "UI", "Open Raid Finder",  nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", RaidFinderFrame) end);
    Collections.Load("function", "UI", "Open Premade Groups window",  nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", LFGListPVEStub) end);
    Collections.Load("function", "UI", "Open PVP window",  nil, function() TogglePVPUI() end);
    Collections.Load("function", "UI", "Open Mounts Journal",  nil, function() ToggleCollectionsJournal(1) end);
    Collections.Load("function", "UI", "Open Pet Journal",  nil, function() ToggleCollectionsJournal(2) end);
    Collections.Load("function", "UI", "Open Toybox Journal",  nil, function() ToggleCollectionsJournal(3) end);
    Collections.Load("function", "UI", "Open Heirlooms Journal",  nil, function() ToggleCollectionsJournal(4) end);
    Collections.Load("function", "UI", "Open Appearances Journal",  nil, function() ToggleCollectionsJournal(5) end);
    Collections.Load("function", "UI", "Open Weekly Rewards",  nil, function() WeeklyRewards_ShowUI() end);
end

