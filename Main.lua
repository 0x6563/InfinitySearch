local AceEvent = LibStub("AceEvent-3.0");
local addon = LibStub("AceAddon-3.0"):NewAddon("InfinitySearch");

InfinitySearch = {
    list = {},
    searchable = {},
    options = {},
    lock = {
        editMode = false,
        close = false
    },
    currentSelected = 1,
    defaults = {
        keybind = "SHIFT-`",
        icon = "Interface\\Icons\\INV_Misc_EngGizmos_17",
        parentBackdrop = {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0
            }
        }
    }
};

_G["BINDING_NAME_INFINITYSEARCH_TOGGLE"] = "Open Infinity Search";
_G["BINDING_NAME_CLICK InfinitySearchOption1:LeftButton"] = "Select Option 1";
_G["BINDING_NAME_CLICK InfinitySearchOption2:LeftButton"] = "Select Option 2";
_G["BINDING_NAME_CLICK InfinitySearchOption3:LeftButton"] = "Select Option 3";
_G["BINDING_NAME_CLICK InfinitySearchOption4:LeftButton"] = "Select Option 4";
_G["BINDING_NAME_CLICK InfinitySearchOption5:LeftButton"] = "Select Option 5";

function addon:OnInitialize()
    InfinitySearch.clientVersion = InfinitySearch:ParseVersion(select(1, GetBuildInfo()));
    InfinitySearch:LoadConfig();
    AceEvent:RegisterEvent("PLAYER_LOGIN", function(_, e)
        if (GetBindingAction(InfinitySearch.defaults.keybind) == "" and GetBindingKey("INFINITYSEARCH_TOGGLE") == nil) then
            InfinitySearch.lock.editMode = true;
            InfinitySearch:Show();
        end
    end);
end

function addon:OnEnable()
    InfinitySearch:CreateFrames();
end

function InfinitySearch:ClientVersionAtleast(version)
    local v = InfinitySearch:ParseVersion(version);
    for i, val in ipairs(InfinitySearch.clientVersion) do
        if val ~= v[i] then
            return (val > v[i]);
        end
    end
    return true;
end

function InfinitySearch:ParseVersion(version)
    local v = {}
    for token in string.gmatch(version, "[^.]+") do
        table.insert(v, tonumber(token));
    end
    return v;
end

function InfinitySearch:SetKeybind(key, cmd)
    if ((not key or key == "") and GetBindingKey(cmd)) then
        SetBinding(GetBindingKey(cmd));
    else
        SetBinding(key, cmd);
    end
    SaveBindings(GetCurrentBindingSet());
end

function InfinitySearch:Toggle()
    if InfinitySearchParent:IsVisible() then
        InfinitySearch:Close();
    else
        InfinitySearch:Show();
    end
end

function InfinitySearch:Show(text)
    if InCombatLockdown() then
        return
    end
    InfinitySearch:UpdateLayout();

    if InfinitySearch.lock.editMode then
        InfinitySearch:PopulateEditMode();
        InfinitySearchDragBox:Show();
        InfinitySearchEditBox:Hide();
        InfinitySearchEditBox:SetText(text or " ");
        InfinitySearch:Filter();
        InfinitySearchParent:Show();
        return;
    end

    InfinitySearch:Populate();
    InfinitySearchDragBox:Hide();
    InfinitySearchEditBox:Show();
    InfinitySearchEditBox:SetText(text or "");
    InfinitySearchParent:Show();
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    RegisterAttributeDriver(InfinitySearchParent, "state-visibility", "[combat] hide; show");
    InfinitySearchEditBox:SetFocus();
end

function InfinitySearch:Unfocus()
    InfinitySearchEditBox:ClearFocus();
end

function InfinitySearch:Close()
    if InfinitySearch.lock.close then
        InfinitySearch.lock.close = false;
        return;
    end
    UnregisterAttributeDriver(InfinitySearchParent, "state-visibility");
    ClearOverrideBindings(InfinitySearchOptions);
    InfinitySearchParent:Hide();
    InfinitySearch.lock.editMode = false;
end

function InfinitySearch:TabCycle()
    if (IsShiftKeyDown()) then
        InfinitySearch:Select(InfinitySearch.currentSelected - 1)
    else
        InfinitySearch:Select(InfinitySearch.currentSelected + 1)
    end
end

function InfinitySearch:CycleSelect()
    InfinitySearch:Select(InfinitySearch.currentSelected + 1)
end

function InfinitySearch:Select(n)
    local c = 0
    for i, o in ipairs(InfinitySearch.options) do
        if o.frame:IsVisible() then
            c = c + 1
        end
    end

    if n < 1 then
        InfinitySearch.currentSelected = c
    elseif n > c then
        InfinitySearch.currentSelected = 1
    else
        InfinitySearch.currentSelected = n
    end
    ClearOverrideBindings(InfinitySearchOptions);
    SetOverrideBinding(InfinitySearchOptions, true, "escape", "INFINITYSEARCH_TOGGLE");
    SetOverrideBinding(InfinitySearchOptions, true, "enter", string.format("CLICK InfinitySearchOption%s:LeftButton", InfinitySearch.currentSelected));
    InfinitySearch:UpdateLayout();
end

function InfinitySearch:Filter()
    local c = 1
    local s = InfinitySearchEditBox:GetText()
    for i, o in ipairs(InfinitySearch.options) do
        o.frame:Hide()
        o.object = nil
    end
    if (s == "" or s == nil) then
        return
    end
    local found = fzy.filter(s, InfinitySearch.searchable)
    table.sort(found, function(a, b)
        return a[3] > b[3]
    end)
    for ii, f in ipairs(found) do
        InfinitySearch:UpdateOption(c, InfinitySearch.list[f[1]])
        c = c + 1
        if c > 5 then
            break
        end
    end
    InfinitySearch:Select(1);
end

function InfinitySearch:ToggleEditMode()
    InfinitySearch.lock.editMode = not InfinitySearch.lock.editMode;
    if InfinitySearch.lock.editMode then
        InfinitySearch:Show();
    else
        InfinitySearch:Close();
    end
end

function InfinitySearch:UpdateOption(n, o)
    InfinitySearch.options[n].object = o;
    InfinitySearch.options[n].label:SetText(o.search);
    InfinitySearch.options[n].icon:SetTexture(o.icon);
    local frame = InfinitySearch.options[n].frame;
    frame:Show();
    frame:SetAttribute("type", nil);
    frame:SetAttribute("macrotext", nil);
    frame:SetAttribute("macro", nil);
    frame:SetAttribute("_function", nil);
    if o.runAs == "macrotext" then
        frame:SetAttribute("type", "macro");
        frame:SetAttribute("macrotext", o.action);
    elseif o.runAs == "macro" then
        frame:SetAttribute("type", "macro");
        frame:SetAttribute("macro", o.action);
    elseif o.runAs == "function" then
        frame:SetAttribute("type", "function");
        frame:SetAttribute("_function", o.action);
    end
end
