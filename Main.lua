InfinitySearch = LibStub("AceAddon-3.0"):NewAddon("InfinitySearch");
local addon = InfinitySearch;
addon.list = {};
addon.searchable = {};
addon.options = {};
addon.currentSelected = 1;
addon.lockMovement = true;
addon.defaults = {
    keybind = 'SHIFT-`',
    icon = "Interface\\Icons\\INV_Misc_EngGizmos_17",
    parentBackdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
};

_G['BINDING_NAME_INFINITYSEARCH_TOGGLE'] = 'Open Infinity Search';
_G['BINDING_NAME_CLICK InfinitySearchOption1:LeftButton'] = 'Select Option 1';
_G['BINDING_NAME_CLICK InfinitySearchOption2:LeftButton'] = 'Select Option 2';
_G['BINDING_NAME_CLICK InfinitySearchOption3:LeftButton'] = 'Select Option 3';
_G['BINDING_NAME_CLICK InfinitySearchOption4:LeftButton'] = 'Select Option 4';
_G['BINDING_NAME_CLICK InfinitySearchOption5:LeftButton'] = 'Select Option 5';

function addon:OnInitialize()
    addon:loadConfig();
end

function addon:OnEnable()
    addon:createFrames();  
end

function addon:setKeybind(key, cmd)
    if(not key or key == "") then
        SetBinding(GetBindingKey(cmd));
    else
        SetBinding(key, cmd);
    end
    SaveBindings(GetCurrentBindingSet());
end

function addon:toggle()
    if InfinitySearchParent:IsVisible() then
        addon:close();
    else
        addon:show();
    end
end

function addon:show(text)
    if InCombatLockdown() then return end
    if addon.lockMovement == false then
        InfinitySearchDragBox:Show();
        InfinitySearchEditBox:Hide();
        InfinitySearchParent:Show();
        return;
    end
    
    InfinitySearchDragBox:Hide();
    InfinitySearchEditBox:Show();
    addon:populate()    
    InfinitySearchEditBox:SetText(text or ""); 
    InfinitySearchParent:Show();
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    RegisterAttributeDriver(InfinitySearchParent, "state-visibility", "[combat] hide; show");
    InfinitySearchEditBox:SetFocus();

end
function addon:unfocus() InfinitySearchEditBox:ClearFocus(); end

function addon:close()
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    ClearOverrideBindings(InfinitySearchOptions);
    InfinitySearchParent:Hide()
end
function addon:tabCycle()
    if (IsShiftKeyDown())  then
        addon:select(addon.currentSelected - 1) 
    else    
        addon:select(addon.currentSelected + 1) 
    end
end
function addon:cycleSelect() 
    addon:select(addon.currentSelected + 1) 
end

function addon:select(n)
    local c = 0
    for i, o in ipairs(addon.options) do
        if o.frame:IsVisible() then c = c + 1 end
    end

    if n < 1 then
        addon.currentSelected = c
    elseif n > c then
        addon.currentSelected = 1
    else
        addon.currentSelected = n
    end
    ClearOverrideBindings(InfinitySearchOptions)
    SetOverrideBinding(InfinitySearchOptions, true, "enter", string.format("CLICK InfinitySearchOption%s:LeftButton",  addon.currentSelected));
    addon:higlightRedraw()
end

function addon:higlightRedraw()
    for i, o in ipairs(addon.options) do
        if i == addon.currentSelected then
            local opt = 'opt' .. i;
            o.frame:SetBackdropColor(unpack(self.db.profile[opt].backdropColor));
        else
            o.frame:SetBackdropColor(0, 0, 0, 1)
        end
    end
end

function addon:filter()
    local c = 1
    local s = InfinitySearchEditBox:GetText()

    for i, o in ipairs(addon.options) do
        o.frame:Hide()
        o.object = nil
    end
    if (s == '' or s == nil) then
        return
    end
    local found = fzy.filter(s, addon.searchable)
    table.sort(found, function(a, b) return a[3] > b[3] end)
    for ii, f in ipairs(found) do
        addon:updateOption(c, addon.list[f[1]])
        c = c + 1
        if c > 5 then break end
    end
    addon:select(1);
end

function addon:updateOption(n, o)
    addon.options[n].object = o
    addon.options[n].label:SetText(o.name)
    addon.options[n].icon:SetTexture(o.icon)
    addon.options[n].frame:Show()
    addon.options[n].frame:SetAttribute("macrotext", o.macro);
end

function addon:updateFlyout(direction)
    addon.db.profile.direction = direction;
    
    InfinitySearchOptions:ClearAllPoints() 
    if addon.db.profile.direction == "down" then
        InfinitySearchOptions:SetPoint("TOP", InfinitySearchParent, "BOTTOM", 12)
    else
        InfinitySearchOptions:SetPoint("BOTTOM", InfinitySearchParent, "TOP", 12)
    end
    local parent = InfinitySearchParent
    for i, o in ipairs(addon.options) do
        if i > 1 then 
            parent = addon.options[i - 1].frame 
        end
            o.frame:ClearAllPoints() 
        if addon.db.profile.direction == "down" then
            o.frame:SetPoint("TOP", parent, "BOTTOM", 12)
        else
            o.frame:SetPoint("BOTTOM", parent, "TOP", 12)
        end
    end
end