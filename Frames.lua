local addon = InfinitySearch;

function addon:createFrames()
    if not InfinitySearchParent then
        local f = CreateFrame("Frame", "InfinitySearchParent", UIParent, BackdropTemplateMixin and "BackdropTemplate")
        local cInset = 8;
        f:SetPoint("CENTER")
        if self.db.profile.position then
            local position = self.db.profile.position;
            f:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y);
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
            if button == "LeftButton" then self:StartMoving() end
        end)
        f:SetScript("OnMouseUp", function(self, button)
            point, relativeTo, relativePoint, x, y = self:GetPoint();
            self.db.profile.position = {
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
        eb:SetScript("OnEscapePressed", function() addon:close() end);
        eb:SetScript("OnTabPressed", function() addon:tabCycle() end);
        eb:SetScript("OnEnterPressed", function() addon:unfocus() end);
        eb:SetScript("OnTextChanged", function() addon:filter() end);
        f:Show()
        addon:createOptions()
    end
    addon:close()
    
    if (GetBindingAction(addon.defaults.keybind) == '' and GetBindingKey('INFINITYSEARCH_TOGGLE') == nil) then
        SetBinding(addon.defaults.keybind, "INFINITYSEARCH_TOGGLE");
    end
end

function addon:createOptions()
    local f = CreateFrame("Frame", "InfinitySearchOptions", InfinitySearchParent, BackdropTemplateMixin and "BackdropTemplate")
    local cInset = 8;
    f:SetPoint("TOP", InfinitySearchParent, "BOTTOM", 12)
    f:Show()
    addon:createOption(1)
    addon:createOption(2)
    addon:createOption(3)
    addon:createOption(4)
    addon:createOption(5)
end

function addon:createOption(n)
    local parent = InfinitySearchParent
    if n > 1 then parent = addon.options[n - 1].frame end
    local f = CreateFrame("Button", "InfinitySearchOption" .. n, InfinitySearchOptions, BackdropTemplateMixin and "BackdropTemplate,SecureActionButtonTemplate")
    f:SetPoint("TOP", parent, "BOTTOM", 12)
    f:RegisterForClicks("AnyUp");
    f:SetSize(400, 40)
    f:SetBackdrop(addon.defaults.parentBackdrop)
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f:SetAttribute("type", "macro");
    f:SetScript("PostClick", function() addon:close() end)

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

    addon.options[n] = {frame = f, label = ff, icon = icn}
end