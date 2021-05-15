local addon = {
    list = {},
    searchable = {},
    options = {},
    currentSelected = 1,
    defaults = {
        icon = "Interface\\Icons\\INV_Misc_EngGizmos_17",
        parentBackdrop = {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        },
        options = {
            backdropColor =  { .1, .83, .98, 1}
        }
    }
}
_G['BINDING_HEADER_INFINITYSEARCH_HEADER'] = 'Infinity Search';
_G['BINDING_NAME_INFINITYSEARCH_OPEN'] = 'Open Infinity Search';
_G['BINDING_NAME_CLICK InfinitySearchOption1:LeftButton'] = 'Select Option 1';
_G['BINDING_NAME_CLICK InfinitySearchOption2:LeftButton'] = 'Select Option 2';
_G['BINDING_NAME_CLICK InfinitySearchOption3:LeftButton'] = 'Select Option 3';
_G['BINDING_NAME_CLICK InfinitySearchOption4:LeftButton'] = 'Select Option 4';
_G['BINDING_NAME_CLICK InfinitySearchOption5:LeftButton'] = 'Select Option 5';

function addon.resetSettings()
    IFTYS = {
        opt1 = { backdropColor =  { .7, .91, .45, 1 } },
        opt2 = { backdropColor =  { .89, .16, .95, 1 } },
        opt3 = { backdropColor =  { .15, .43, .96, 1 } },
        opt4 = { backdropColor =  { 100, 0, .19, 1 } },
        opt5 = { backdropColor =  { 100, .55, 0, 1 } }
    }
end
function addon.show(text)
	if InCombatLockdown() then return end
    if IFTYS == nil then
        addon.resetSettings();
    end
    
    addon.create()
    addon.populate()
    if text ~= nil then
        InfinitySearchEditBox:SetText(text);
    end
    InfinitySearchParent:Show();
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    RegisterAttributeDriver(InfinitySearchParent, "state-visibility", "[combat] hide; show");
    InfinitySearchEditBox:SetFocus();

end

-- Create the secure frame to activate the macro
function addon.create()
    
    if not InfinitySearchParent then
        local f = CreateFrame("Frame", "InfinitySearchParent", UIParent, BackdropTemplateMixin and "BackdropTemplate")
        local cInset = 8;
        f:SetPoint("CENTER")
        if IFTYS and IFTYS.position then
            f:SetPoint(IFTYS.position.point, UIParent, IFTYS.position.relativePoint, IFTYS.position.x, IFTYS.position.y);
        else
            f:SetPoint("CENTER")
        end
        f:SetSize(400, 42)
        
        f:SetBackdrop(addon.defaults.parentBackdrop)
        f:SetBackdropColor(0, 0, 0, 1)
        f:SetBackdropBorderColor(0, 0, 0, 0)
        

        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", function(self, button)
            point, relativeTo, relativePoint, x, y = self:GetPoint();
            IFTYS.position = {
                point = point,
                relativePoint = relativePoint,
                x = x,
                y = y
            }
            self:StopMovingOrSizing()
        end) 

        local eb = CreateFrame("EditBox", "InfinitySearchEditBox", InfinitySearchParent, "SecureHandlerBaseTemplate")
        eb:SetPoint("LEFT", cInset, 0)
        eb:SetPoint("RIGHT", -1 * cInset, 0)
        eb:SetPoint("TOP", 0)
        eb:SetPoint("BOTTOM", 0)
        eb:SetMultiLine(false)
	    eb:SetJustifyV("MIDDLE")
        eb:SetAutoFocus(false)
        eb:SetFont("Interface\\AddOns\\InfinitySearch\\fonts\\AlegreyaSansSC-Bold.ttf", 20)
        eb:SetScript("OnEscapePressed", addon.close)
        eb:SetScript("OnTabPressed", addon.cycleSelect)
        eb:SetScript("OnEnterPressed", addon.unfocus)
        eb:SetScript("OnTextChanged", addon.filter)
        f:Show()
        addon.createOptions()
    end
end

function addon.unfocus()
    InfinitySearchEditBox:ClearFocus()
end

function addon.createOptions()
    local f = CreateFrame("Frame", "InfinitySearchOptions", InfinitySearchParent, BackdropTemplateMixin and "BackdropTemplate")
    local cInset = 8;
    f:SetPoint("TOP", InfinitySearchParent, "BOTTOM", 12)
    f:Show()
    addon.createOption(1)
    addon.createOption(2)
    addon.createOption(3)
    addon.createOption(4)
    addon.createOption(5)
end

function addon.createOption(n)
    local parent = InfinitySearchParent
    if n > 1 then
        parent = addon.options[n - 1].frame
    end
    local f = CreateFrame("Button", "InfinitySearchOption" .. n, InfinitySearchOptions, BackdropTemplateMixin and "BackdropTemplate,SecureActionButtonTemplate")
    f:SetPoint("TOP", parent, "BOTTOM", 12)
    f:RegisterForClicks("AnyUp");
    f:SetSize(400, 40)
    f:SetBackdrop(addon.defaults.parentBackdrop)
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f:SetAttribute("type", "macro");
    f:SetScript("PostClick", addon.close)

    local ff = f:CreateFontString("InfinitySearchOption" .. n .. "Name", "HIGH")
    ff:SetFont("Interface\\AddOns\\InfinitySearch\\fonts\\AlegreyaSansSC-ExtraBold.ttf", 18)
    ff:SetPoint("TOPLEFT", f, "TOPLEFT", 42, 0)
    ff:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 42, 0)

    local icn = f:CreateTexture("InfinitySearchOption" .. n .. "Icon", "HIGH")
    icn:SetWidth(24);
    icn:SetHeight(24);	
    icn:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -8)
    icn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 4, 8)
    icn:SetTexture(addon.defaults.icon)
    SetPortraitToTexture(icn, addon.defaults.icon)

	ff:Show() 
    f:Show()

    addon.options[n] = {
        frame  = f,
        label = ff,
        icon = icn
    }
end
function addon.close()
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    
    ClearOverrideBindings(InfinitySearchOptions);
    InfinitySearchParent:Hide()

end

function addon.cycleSelect()
    addon.select(addon.currentSelected + 1)
end

function addon.select(n)
    local c = 0
    for i, o in ipairs(addon.options) do
        if o.frame:IsVisible() then
            c = c + 1
        end
    end
    if n > c then
        addon.currentSelected = 1
    else
        addon.currentSelected = n
    end
    ClearOverrideBindings(InfinitySearchOptions)
    SetOverrideBinding(InfinitySearchOptions, true, "enter", string.format("CLICK InfinitySearchOption%s:LeftButton", addon.currentSelected));

    addon.higlightRedraw()
end

function addon.higlightRedraw()
    for i, o in ipairs(addon.options) do
        if i == addon.currentSelected then
            local opt = 'opt' .. i;
            o.frame:SetBackdropColor(unpack(IFTYS[opt].backdropColor or addon.defaults.options.backdropColor));
            local r, g, b, a = o.frame:GetBackdropColor();
            IFTYS[opt].backdropColor = { r, g, b, a};
        else
            o.frame:SetBackdropColor(0, 0, 0, 1)
        end
    end
end

function addon.filter()
    local c = 1
    local s = InfinitySearchEditBox:GetText()
    
    for i, o in ipairs(addon.options) do
        o.frame:Hide()
        o.object = nil
    end
    local found = fzy.filter(s, addon.searchable)
    table.sort(found, function(a,b) return a[3] > b[3] end)
    for ii, f in ipairs(found) do
        addon.updateOption(c, addon.list[f[1]])
        c = c + 1
        if c > 5 then
            break
        end
    end
    addon.select(1);
end

function addon.updateOption(n, o) 
    addon.options[n].object = o
    addon.options[n].label:SetText(o.name)
    addon.options[n].icon:SetTexture(o.icon)
    addon.options[n].frame:Show()
    addon.options[n].frame:SetAttribute("macrotext", o.macro);
end

function addon.populate()
    wipe(addon.list)
    wipe(addon.searchable)
    addon.populateMounts()
    addon.populateToys()
    addon.populateConsumables()
    addon.populateSpells()
    addon.populatePets()
end

function addon.populateMounts()
	local mountIDs = C_MountJournal.GetMountIDs();
    for i, mountID in ipairs(mountIDs) do
        local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID);
        local o = {
            id = mountID,
            icon = icon, 
            name = name,
            type = "Mount",
            macro = string.format("%s %s", SLASH_USE1, name)
        }
        if isCollected and isUsable then
            table.insert(addon.list,  o)
            table.insert(addon.searchable, o.type .. ": " .. o.name)
        end
    end
end

function addon.populatePets()
    C_PetJournal.ClearSearchFilter() 
    C_PetJournal.SetAllPetSourcesChecked(true)
    C_PetJournal.SetAllPetTypesChecked(true)
    local exists = {}
    for i =1, C_PetJournal.GetNumMaxPets() do
        local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i);
        if owned and exists[speciesName] == nil then
            local o = {
                id = petID,
                icon = icon, 
                name = speciesName,
                type = "Pet",
                macro = string.format("%s %s", '/summonpet', speciesName)
            }
            table.insert(addon.list,  o)
            table.insert(addon.searchable, o.type .. ": " .. o.name)
            exists[speciesName] = true;
        end
    end
end


function addon.populateToys()
    C_ToyBox.SetAllSourceTypeFilters(true)
    C_ToyBox.SetCollectedShown(true)
    C_ToyBox.SetUncollectedShown(false)

    for i = 1, C_ToyBox.GetNumFilteredToys() do
	    local id, name, icon, isFavorite, hasFanfare = C_ToyBox.GetToyInfo(C_ToyBox.GetToyFromIndex(i));
        local o = {
            id = id,
            icon = icon, 
            name = name,
            type = "Toy",
            macro = string.format("%s %s", SLASH_USE_TOY1, name)
        }
        if C_ToyBox.IsToyUsable(o.id) then
            table.insert(addon.list,  o)
            table.insert(addon.searchable, o.type .. ": " .. o.name)
        end
	end
end

function addon.populateConsumables()
    local exists = {}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do
            id = GetContainerItemID(bag,slot) 
            if id ~= nil and exists[id] == nil then
                local name, link, rarity, level, minLevel, type, subtype, stackCount, equipLocation, icon = GetItemInfo(id);
                local o = {
                    id = id,
                    icon = icon, 
                    name = name,
                    type = "Item",
                    macro = string.format("%s %s", SLASH_USE1, name)
                }
                if type == 'Consumable' then
                    table.insert(addon.list,  o)
                    table.insert(addon.searchable, o.type .. ": " .. o.name)
                end
                exists[id] = true;
            end
        end
    end
end

function addon.populateSpells()
    local tabs = GetNumSpellTabs()
    for t = 1, tabs do
        local tabName, texture, offset, numSpells = GetSpellTabInfo(t);
        for i = offset + 1, offset + numSpells do 
            local name, rank = GetSpellBookItemName(i, BOOKTYPE_SPELL) ;
            local type, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL);
            local icon = GetSpellTexture(spellID)
            local isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)
            local isUsable, _ = IsUsableSpell(i, BOOKTYPE_SPELL)
            if (rank and name and isUsable and not isPassive and type ~= "FUTURESPELL") then
                local o = {
                    id = spellID,
                    icon = icon, 
                    name = name,
                    type = "Spell",
                    macro = string.format("%s %s", SLASH_CAST1, name)
                }
                table.insert(addon.list,  o)
                table.insert(addon.searchable, o.type .. ": " .. o.name)
            end
        end
    end
end

INFINITYSEARCH = addon;