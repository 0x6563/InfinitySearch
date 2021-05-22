InfinitySearch = LibStub("AceAddon-3.0"):NewAddon("InfinitySearch");
local addon = InfinitySearch;
addon.list = {};
addon.searchable = {};
addon.options = {};
addon.lock = {
    movement = true
};
addon.currentSelected = 1;
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
    addon:LoadConfig();
end

function addon:OnEnable()
    addon:CreateFrames();  
end

function addon:SetKeybind(key, cmd)
    if(not key or key == "") then
        SetBinding(GetBindingKey(cmd));
    else
        SetBinding(key, cmd);
    end
    SaveBindings(GetCurrentBindingSet());
end

function addon:Toggle()
    if InfinitySearchParent:IsVisible() then
        addon:Close();
    else
        addon:Show();
    end
end

function addon:Show(text)
    if InCombatLockdown() then return end
    addon:Populate()
    if addon.lock.movement == false then
        InfinitySearchEditBox:SetText(text or " "); 
        addon:Filter();
        InfinitySearchDragBox:Show();
        InfinitySearchEditBox:Hide();
        InfinitySearchParent:Show();
        return;
    end
    
    InfinitySearchDragBox:Hide();
    InfinitySearchEditBox:Show();
    InfinitySearchEditBox:SetText(text or ""); 
    InfinitySearchParent:Show();
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    RegisterAttributeDriver(InfinitySearchParent, "state-visibility", "[combat] hide; show");
    InfinitySearchEditBox:SetFocus();

end
function addon:Unfocus() InfinitySearchEditBox:ClearFocus(); end

function addon:Close()
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    ClearOverrideBindings(InfinitySearchOptions);
    InfinitySearchParent:Hide()
end
function addon:TabCycle()
    if (IsShiftKeyDown())  then
        addon:Select(addon.currentSelected - 1) 
    else    
        addon:Select(addon.currentSelected + 1) 
    end
end
function addon:CycleSelect() 
    addon:Select(addon.currentSelected + 1) 
end

function addon:Select(n)
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
    addon:UpdateLayout()
end

function addon:Filter()
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
        addon:UpdateOption(c, addon.list[f[1]])
        c = c + 1
        if c > 5 then break end
    end
    addon:Select(1);
end

function addon:UpdateOption(n, o)
    addon.options[n].object = o
    addon.options[n].label:SetText( o.type .. ": " .. o.name)
    addon.options[n].icon:SetTexture(o.icon)
    addon.options[n].frame:Show()
    addon.options[n].frame:SetAttribute("macrotext", o.macro);
end

