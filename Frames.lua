local addon = InfinitySearch;
local Media = LibStub("LibSharedMedia-3.0");

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
        f:SetBackdropBorderColor(0, 0, 0, 0)

        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if addon.lockMovement == true then
                return;
            end
            if button == "LeftButton" 
                then self:StartMoving() 
            end
        end)
        f:SetScript("OnMouseUp", function(self, button)
            if addon.lockMovement == true then
                return;
            end
            point, relativeTo, relativePoint, x, y = self:GetPoint();
            addon.db.profile.position = {
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
        eb:SetScript("OnEscapePressed", function() addon:close() end);
        eb:SetScript("OnTabPressed", function() addon:tabCycle() end);
        eb:SetScript("OnEnterPressed", function() addon:unfocus() end);
        eb:SetScript("OnTextChanged", function() addon:filter() end);
        eb:SetScript("OnEditFocusGained", function() addon:UpdateLayout() end);
        eb:SetScript("OnEditFocusLost", function() addon:UpdateLayout() end);

        local db = CreateFrame("Frame", "InfinitySearchDragBox", InfinitySearchParent, "SecureHandlerBaseTemplate")
        db:SetPoint("LEFT", cInset, 0)
        db:SetPoint("RIGHT", -1 * cInset, 0)
        db:SetPoint("TOP", 0)
        db:SetPoint("BOTTOM", 0)
        
        local ff = db:CreateFontString("InfinitySearchDragBoxText", "HIGH")
        ff:SetFont(Media:Fetch('font', self.db.profile.searchbar.font), self.db.profile.searchbar.fontSize)
        ff:SetPoint("TOPLEFT", f, "TOPLEFT", 42, 0)
        ff:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 42, 0)
        ff:SetText("Drag Me")
        db:Hide();

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
    if addon.db.profile.direction == "down" then
        f:SetPoint("TOP", InfinitySearchParent, "BOTTOM", 12)
    else
        f:SetPoint("BOTTOM", InfinitySearchParent, "TOP", 12)
    end
    f:Show()
    addon:createOption(1)
    addon:createOption(2)
    addon:createOption(3)
    addon:createOption(4)
    addon:createOption(5)
end

function addon:createOption(n)
    local parent = InfinitySearchParent
    if n > 1 then 
        parent = addon.options[n - 1].frame 
    end

    local f = CreateFrame("Button", "InfinitySearchOption" .. n, InfinitySearchOptions, BackdropTemplateMixin and "BackdropTemplate,SecureActionButtonTemplate")
    if addon.db.profile.direction == "down" then
        f:SetPoint("TOP", parent, "BOTTOM", 12)
    else
        f:SetPoint("BOTTOM", parent, "TOP", 12)
    end
    f:RegisterForClicks("AnyUp");
    f:SetSize(400, 40)
    f:SetBackdrop(addon.defaults.parentBackdrop)
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f:SetAttribute("type", "macro");
    f:SetScript("PostClick", function() addon:close() end)

    local ff = f:CreateFontString("InfinitySearchOption" .. n .. "Name", "HIGH")
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

function addon:UpdateLayout()
    InfinitySearchOptions:ClearAllPoints() 
    
    InfinitySearchEditBox:SetFont(Media:Fetch('font', self.db.profile.searchbar.font), self.db.profile.searchbar.fontSize)
    if addon.db.profile.direction == "down" then
        InfinitySearchOptions:SetPoint("TOP", InfinitySearchParent, "BOTTOM", 12)
    else
        InfinitySearchOptions:SetPoint("BOTTOM", InfinitySearchParent, "TOP", 12)
    end
    
    if InfinitySearchEditBox:HasFocus() then
        InfinitySearchEditBox:SetTextColor(unpack(self.db.profile.searchbar.fontColorHighlight))
        InfinitySearchParent:SetBackdropColor(unpack(self.db.profile.searchbar.backdropColorHighlight));
    else
        InfinitySearchDragBoxText:SetFont(Media:Fetch('font', self.db.profile.searchbar.font), self.db.profile.searchbar.fontSize)

        InfinitySearchEditBox:SetTextColor(unpack(self.db.profile.searchbar.fontColor))
        InfinitySearchParent:SetBackdropColor(unpack(self.db.profile.searchbar.backdropColor))
    end

    local parent = InfinitySearchParent
    for i, o in ipairs(addon.options) do
        local opt = 'opt' .. i;

        if i > 1 then 
            parent = addon.options[i - 1].frame 
        end
      
        o.label:SetFont(Media:Fetch('font', self.db.profile[opt].font), self.db.profile[opt].fontSize)
        o.frame:ClearAllPoints();
        if addon.db.profile.direction == "down" then
            o.frame:SetPoint("TOP", parent, "BOTTOM", 12)
        else
            o.frame:SetPoint("BOTTOM", parent, "TOP", 12)
        end

        if i == addon.currentSelected then
            o.label:SetTextColor(unpack(self.db.profile[opt].fontColorHighlight));
            o.frame:SetBackdropColor(unpack(self.db.profile[opt].backdropColorHighlight));
        else
            o.label:SetTextColor(unpack(self.db.profile[opt].fontColor));
            o.frame:SetBackdropColor(unpack(self.db.profile[opt].backdropColor))
        end
    end
end