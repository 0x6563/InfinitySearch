local addon = InfinitySearch;

function addon:populate()
    wipe(addon.list)
    wipe(addon.searchable)
    
    if (self.db.profile.collections.mounts) then
        addon:populateMounts()
    end
    if (self.db.profile.collections.pets) then 
        addon:populatePets()
    end
    if (self.db.profile.collections.toys) then 
        addon:populateToys()
    end
    if (self.db.profile.collections.consumables) then 
        addon:populateConsumables()
    end
    if (self.db.profile.collections.spells) then 
        addon:populateSpells()
    end
end

function addon:populateMounts()
    local mountIDs = C_MountJournal.GetMountIDs();
    for i, mountID in ipairs(mountIDs) do
        local name, spellID, icon, isActive, isUsable, sourceType, isFavorite,
              isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID =
            C_MountJournal.GetMountInfoByID(mountID);
        local o = {
            id = mountID,
            icon = icon,
            name = name,
            type = "Mount",
            macro = string.format("%s %s", SLASH_USE1, name)
        }
        if isCollected and isUsable then
            table.insert(addon.list, o)
            table.insert(addon.searchable, o.type .. ": " .. o.name)
        end
    end
end

function addon:populatePets()
    C_PetJournal.ClearSearchFilter()
    C_PetJournal.SetAllPetSourcesChecked(true)
    C_PetJournal.SetAllPetTypesChecked(true)
    local exists = {}
    local i = 1;
    local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon = C_PetJournal.GetPetInfoByIndex(i);
    while (petID)
    do
        if owned and exists[speciesName] == nil then
            local o = {
                id = petID,
                icon = icon,
                name = speciesName,
                type = "Pet",
                macro = string.format("%s %s", '/summonpet', speciesName)
            }
            table.insert(addon.list, o)
            table.insert(addon.searchable, o.type .. ": " .. o.name)
            exists[speciesName] = true;
        end
        i = i + 1;
        petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon = C_PetJournal.GetPetInfoByIndex(i);
    end
end

function addon:populateToys()
    C_ToyBox.SetAllSourceTypeFilters(true)
    C_ToyBox.SetCollectedShown(true)
    C_ToyBox.SetUncollectedShown(false)

    for i = 1, C_ToyBox.GetNumFilteredToys() do
        local id, name, icon, isFavorite, hasFanfare = C_ToyBox.GetToyInfo(C_ToyBox.GetToyFromIndex(i));
        if name and C_ToyBox.IsToyUsable(id) then
            local o = {
                id = id,
                icon = icon,
                name = name,
                type = "Toy",
                macro = string.format("%s %s", SLASH_USE_TOY1, name)
            }
            table.insert(addon.list, o)
            table.insert(addon.searchable, o.type .. ": " .. o.name)
        end
    end
end

function addon:populateConsumables()
    local exists = {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            id = GetContainerItemID(bag, slot)
            if id ~= nil and exists[id] == nil then
                local name, link, rarity, level, minLevel, type, subtype,
                      stackCount, equipLocation, icon = GetItemInfo(id);
                local o = {
                    id = id,
                    icon = icon,
                    name = name,
                    type = "Item",
                    macro = string.format("%s %s", SLASH_USE1, name)
                }
                if type == 'Consumable' then
                    table.insert(addon.list, o)
                    table.insert(addon.searchable, o.type .. ": " .. o.name)
                end
                exists[id] = true;
            end
        end
    end
end

function addon:populateSpells()
    local tabs = GetNumSpellTabs()
    for t = 1, tabs do
        local tabName, texture, offset, numSpells = GetSpellTabInfo(t);
        for i = offset + 1, offset + numSpells do
            local name, rank = GetSpellBookItemName(i, BOOKTYPE_SPELL);
            local type, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL);
            local icon = GetSpellTexture(spellID)
            local isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)
            local isUsable, _ = IsUsableSpell(i, BOOKTYPE_SPELL)
            if (rank and name and isUsable and not isPassive and type ~=
                "FUTURESPELL") then
                local o = {
                    id = spellID,
                    icon = icon,
                    name = name,
                    type = "Spell",
                    macro = string.format("%s %s", SLASH_CAST1, name)
                }
                table.insert(addon.list, o)
                table.insert(addon.searchable, o.type .. ": " .. o.name)
            end
        end
    end
end
