local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");

local addon = InfinitySearch;
local Collections = {};
local ThirdPartyCommands = {};
local Cache = {};
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
    if addon:CollectionEnabled("experimental") then
        Collections.LoadExperiemental();
    end
    if addon:CollectionEnabled("libDataBrokerLaunchers") then
        Collections.LoadLibDataBrokerLaunchers();
    end

    for key, val in pairs(ThirdPartyCommands) do
        if addon:CollectionEnabled("addon:" .. key) then
            Collections.LoadAddon(key);
        end
    end
end

function addon:PopulateEditMode()
    wipe(addon.list);
    wipe(addon.searchable);

    Collections.Load("function", "Addon", "InfinitySearch: Open Options", nil, function()
        InfinitySearch.lock.close = true;
        AceConfigDialog:Open("InfinitySearch");
    end);
    Collections.Load("function", "Addon", "InfinitySearch: Set Keybinding", nil, function()
        InfinitySearch.lock.close = true;
        AceConfigDialog:Open("InfinitySearch", "general");
    end);
    Collections.Load("function", "Addon", "InfinitySearch: Toggle Flyout Direction", nil, function()
        InfinitySearch.lock.close = true;
        if InfinitySearch.db.profile.direction == "up" then
            InfinitySearch.db.profile.direction = "down";
        else
            InfinitySearch.db.profile.direction = "up"
        end
        InfinitySearch:UpdateLayout();
    end);
    Collections.Load("function", "Addon", "InfinitySearch: Emote Dance", nil, function()
        InfinitySearch.lock.close = true;
        DoEmote("DANCE");
    end);
    Collections.Load("function", "Addon", "InfinitySearch: Emote Happy", nil, function()
        InfinitySearch.lock.close = true;
        DoEmote("HAPPY");
    end);
end

function addon:RegisterAddonMacrotext(addon, command, icon, action)
    Collections.RegisterThirdparty({ addon = addon, command = command, icon = icon, action = action, runAs = "macrotext" });
end

function addon:RegisterAddonFunction(addon, command, icon, action)
    Collections.RegisterThirdparty({ addon = addon, command = command, icon = icon, action = action, runAs = "function" });
end

function addon:UnregisterAddonCommand(addon, command)
    Collections.UnregisterAddonCommand(addon, command);
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
    ThirdPartyCommands[cmd.addon][cmd.command] = cmd;
end

function Collections.UnregisterAddonCommand(addon, command)
    ThirdPartyCommands[addon][command] = nil;
end

function Collections.Load(runAs, type, command, icon, action)
    local o = { runAs = runAs, icon = icon or addon.defaults.icon, command = command, type = type, action = action };
    Collections.SetSearch(o);
    table.insert(addon.list, o)
    table.insert(addon.searchable, o.search);
end

function Collections.SetSearch(cmd)
    if cmd.type == "Addon" then
        cmd.search = cmd.command;
    else
        cmd.search = cmd.type .. ": " .. cmd.command;
    end
end

function Collections.LoadAddon(addon)
    for key, val in pairs(ThirdPartyCommands[addon]) do
        Collections.Load(val.runAs, "Addon", addon .. ": " .. val.command, val.icon, val.action)
    end
end

function Collections.LoadMounts()
    if (addon:ClientVersionAtleast("3.0.0")) then
        Collections.LoadMountsRetail();
    else
        Collections.LoadMountsClassic();
    end
end

function Collections.LoadMountsClassic()
    local exists = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local id = C_Container.GetContainerItemID(bag, slot)
            if id ~= nil and exists[id] == nil then
                local name, link, rarity, level, minLevel, type, subtype, stackCount, equipLocation, icon = GetItemInfo(
                    id);
                if subtype == "Mount" then
                    Collections.Load("macrotext", "Mount", name, icon, SLASH_USE1 .. " " .. name);
                end
                exists[id] = true;
            end
        end
    end
end

function Collections.LoadMountsRetail()
    local mountIDs = C_MountJournal.GetMountIDs();
    for i, mountID in ipairs(mountIDs) do
        local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID);
        if isCollected and isUsable then
            Collections.Load("macrotext", "Mount", name, icon, SLASH_USE1 .. " " .. name)
        end
    end
end

function Collections.LoadPets()
    if (addon:ClientVersionAtleast("3.0.0")) then
        Collections.LoadPetsRetail();
    else
        Collections.LoadPetsClassic();
    end
end

function Collections.LoadPetsRetail()
    C_PetJournal.ClearSearchFilter()
    C_PetJournal.SetAllPetSourcesChecked(true)
    C_PetJournal.SetAllPetTypesChecked(true)
    local exists = {}
    local i = 1;
    local petID, speciesID, owned, customName, level, favorite, isRevoked, name, icon = C_PetJournal.GetPetInfoByIndex(i);
    while (petID)
    do
        if name and owned and exists[name] == nil then
            Collections.Load("macrotext", "Pet", name, icon, "/summonpet " .. name)
            exists[name] = true;
        end
        i = i + 1;
        petID, speciesID, owned, customName, level, favorite, isRevoked, name, icon = C_PetJournal.GetPetInfoByIndex(i);
    end
end

function Collections.LoadPetsClassic()
    local exists = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local id = C_Container.GetContainerItemID(bag, slot)
            if id ~= nil and exists[id] == nil then
                local name, link, rarity, level, minLevel, type, subtype, stackCount, equipLocation, icon = GetItemInfo(
                    id);
                if subtype == "Pet" then
                    Collections.Load("macrotext", "Pet", name, icon, SLASH_USE1 .. " " .. name);
                end
                exists[id] = true;
            end
        end
    end
end

function Collections.LoadToys()
    if (addon:ClientVersionAtleast("3.0.0")) then
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
end

function Collections.LoadExperiemental()
    if (addon:ClientVersionAtleast("7.0.0")) then
        for tradeSkillID, tradeSkill in pairs(Cache) do
            for _, recipe in pairs(tradeSkill) do
                Collections.Load("function", "Profession", recipe.name, recipe.icon,
                    function()
                        C_TradeSkillUI.OpenRecipe(recipe.recipeID);
                        C_TradeSkillUI.CraftRecipe(recipe.recipeID);
                        C_TradeSkillUI.CloseTradeSkill();
                    end);
            end
        end
    end

    if (addon:ClientVersionAtleast("10.0.0")) then
        for i = 1, GetNumSpecializations() do
            local id, name, description, icon, role, primaryStat = GetSpecializationInfo(i);
            Collections.Load("function", "Specialization", name, icon, function() SetSpecialization(i); end);
        end

        local configIDs = C_ClassTalents.GetConfigIDsBySpecID();
        for i in pairs(configIDs) do
            local configInfo = C_Traits.GetConfigInfo(configIDs[i]);
            Collections.Load("function", "Specialization Loadout", configInfo.name, nil,
                function() C_ClassTalents.LoadConfig(configIDs[i], true); end);
        end
        local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
        for i in pairs(equipmentSetIDs) do
            local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored =
                C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[i])
            Collections.Load("function", "Equipment Set", name, iconFileID,
                function() C_EquipmentSet.UseEquipmentSet(equipmentSetIDs[i]); end);
        end
    end
end

function Collections.LoadConsumables()
    local exists = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local id = C_Container.GetContainerItemID(bag, slot)
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
    -- local tabs = GetNumSpellTabs()
    -- for t = 1, tabs do
    --     local tabName, texture, offset, numSpells = GetSpellTabInfo(t);
    --     for i = offset + 1, offset + numSpells do
    --         local name, rank = GetSpellBookItemName(i, Enum.SpellBookSpellBank.Player);
    --         local spell = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player);
    --         local icon = C_Spell.GetSpellTexture(spell["spellID"]);
    --         local isPassive = C_Spell.IsSpellPassive(i, Enum.SpellBookSpellBank.Player);
    --         local isUsable, _ = C_Spell.IsSpellUsable(i, Enum.SpellBookSpellBank.Player);
    --         if (rank and name and isUsable and not isPassive and spell["type"] ~= "FUTURESPELL") then
    --             Collections.Load("macrotext", "Spell", name, icon, SLASH_CAST1 .. " " .. name);
    --         end
    --     end
    -- end
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
    Collections.Load("function", "UI", "Open Adventure Guide", nil, function() ToggleEncounterJournal(); end);
    Collections.Load("function", "UI", "Open Talents", nil, function() ToggleTalentFrame(); end);
    Collections.Load("function", "UI", "Open Achievements", nil, function() ToggleAchievementFrame(); end);
    Collections.Load("function", "UI", "Open Dungeon Finder", nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", LFDParentFrame) end);
    Collections.Load("function", "UI", "Open Raid Finder", nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", RaidFinderFrame) end);
    Collections.Load("function", "UI", "Open Premade Groups window", nil, function() PVEFrame_ToggleFrame("GroupFinderFrame", LFGListPVEStub) end);
    Collections.Load("function", "UI", "Open PVP window", nil, function() TogglePVPUI() end);
    Collections.Load("function", "UI", "Open Mounts Journal", nil, function() ToggleCollectionsJournal(1) end);
    Collections.Load("function", "UI", "Open Pet Journal", nil, function() ToggleCollectionsJournal(2) end);
    Collections.Load("function", "UI", "Open Toybox Journal", nil, function() ToggleCollectionsJournal(3) end);
    Collections.Load("function", "UI", "Open Heirlooms Journal", nil, function() ToggleCollectionsJournal(4) end);
    Collections.Load("function", "UI", "Open Appearances Journal", nil, function() ToggleCollectionsJournal(5) end);
    Collections.Load("function", "UI", "Open Weekly Rewards", nil, function() WeeklyRewards_ShowUI() end);
end

function Collections.LoadLibDataBrokerLaunchers()
    for name, dataobj in ldb:DataObjectIterator() do
        if dataobj.type == 'launcher' then
            Collections.Load("function", "DataBroker Launcher", dataobj.label or name, dataobj.icon, function(s, btn) dataobj.OnClick(s, btn) end);
        end
    end
end

local TRADE_SKILL_SHOW = CreateFrame("FRAME");
TRADE_SKILL_SHOW:RegisterEvent("TRADE_SKILL_SHOW");
TRADE_SKILL_SHOW:SetScript("OnEvent", function(_, e)
    local info = C_TradeSkillUI.GetBaseProfessionInfo();
    Cache[info.professionID] = {}
    for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
        if recipeInfo and recipeInfo.name and recipeInfo.craftable then
            table.insert(Cache[info.professionID], recipeInfo);
        end
    end
end);
