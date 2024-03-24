-- MemoryKiller
-- Made by Sharpedge_Gaming
-- v.2.3

local AceAddon = LibStub("AceAddon-3.0")
MemoryKiller = MemoryKiller or {}

local window = CreateFrame("Frame", "MemoryKillerWindow", UIParent, "BasicFrameTemplateWithInset")
window:SetSize(400, 600)
window:SetPoint("CENTER", UIParent, "CENTER")
window:SetMovable(true)
window:EnableMouse(true)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", window.StartMoving)
window:SetScript("OnDragStop", window.StopMovingOrSizing)
window:Hide()

window:SetResizable(true)
window:SetResizable(true)
window:SetResizeBounds(300, 200, 800, 1000) 

-- Correctly create a resize grip as a Button
local resizeGrip = CreateFrame("Button", nil, window)
resizeGrip:SetPoint("BOTTOMRIGHT", -6, 7)
resizeGrip:SetSize(16, 16)
resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeGrip:EnableMouse(true)

resizeGrip:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        window:StartSizing("BOTTOMRIGHT")
    end
end)

resizeGrip:SetScript("OnMouseUp", function(self)
    window:StopMovingOrSizing()
    
end)

window.title = window:CreateFontString(nil, "OVERLAY")
window.title:SetFontObject("GameFontHighlight")
window.title:SetPoint("TOP", window.TitleBg, "TOP", 0, -6)
window.title:SetText("|cFF00FF00MemoryKiller|r")

window.closeButton = CreateFrame("Button", nil, window, "UIPanelCloseButton")
window.closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT")

local scrollFrame = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", window, "TOPLEFT", 8, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -6, 8)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(380, 1500) 
scrollFrame:SetScrollChild(content)
scrollFrame:EnableMouseWheel(true)

local function UpdateMemoryUsage()
    UpdateAddOnMemoryUsage()
    local totalMemoryUsage = 0
    local memoryInfo = "\n|cFF00CCFFAddon Memory Usage:|r\n"

    for i = 1, GetNumAddOns() do
        local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(i)
        local isEnabled = GetAddOnEnableState(UnitName("player"), i) > 0
        local enabledText = isEnabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
        local memoryUsage = GetAddOnMemoryUsage(i)
        totalMemoryUsage = totalMemoryUsage + memoryUsage
        memoryInfo = memoryInfo .. format("%s (%s): |cFF99CCFF%.2f KB|r\n", title or name, enabledText, memoryUsage)
    end

    memoryInfo = memoryInfo .. format("\n|cFF00CCFFTotal Memory Usage: %.2f KB|r", totalMemoryUsage)

    if not content.text then
        content.text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        content.text:SetJustifyH("LEFT")
        content.text:SetWidth(content:GetWidth())
        content.text:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
    end

    content.text:SetText(memoryInfo)
    local textHeight = content.text:GetStringHeight()
    content:SetHeight(math.max(1500, textHeight))
end

window:SetScript("OnShow", function()
    scrollFrame:SetVerticalScroll(MemoryKillerScrollPosition or 0)
    UpdateMemoryUsage()
end)

function MemoryKiller:EnableAutoRefresh()
    if self.db.profile.autoRefresh then
        if not self.refreshTimer then
            self.refreshTimer = self:ScheduleRepeatingTimer("UpdateMemoryUsage", self.db.profile.refreshInterval)
        end
    else
        if self.refreshTimer then
            self:CancelTimer(self.refreshTimer)
            self.refreshTimer = nil
        end
    end
end

local function CollectGarbage()
    local beforeCollect = collectgarbage("count")
    collectgarbage("collect")
    local afterCollect = collectgarbage("count")
    local memoryFreed = beforeCollect - afterCollect
    print(format("|cFF00FF00Garbage collected. Memory freed: %.2f KB|r", memoryFreed / 1024))
    UpdateMemoryUsage()
end

window:SetScript("OnShow", function()
    scrollFrame:SetVerticalScroll(MemoryKillerScrollPosition or 0)
    UpdateMemoryUsage()
end)

local function CollectGarbage()
    local beforeCollect = collectgarbage("count")
    collectgarbage("collect")
    local afterCollect = collectgarbage("count")
    local memoryFreed = beforeCollect - afterCollect
    print(format("|cFF00FF00Garbage collected. Memory freed: %.2f KB|r", memoryFreed / 1024))
    UpdateMemoryUsage()
end

-- Refresh Button
local refreshButton = CreateFrame("Button", nil, window, "GameMenuButtonTemplate")
refreshButton:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", 10, 10)
refreshButton:SetSize(100, 25)
refreshButton:SetText("Refresh")
refreshButton:SetNormalFontObject("GameFontNormal")
refreshButton:SetScript("OnClick", UpdateMemoryUsage)

-- Tooltip for Refresh Button
refreshButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("|cFF00FF00Refresh", 1, 1, 1)
    GameTooltip:AddLine("Clicking this button updates the memory usage information for all addons. Use this to see current memory usage after making changes, like enabling/disabling addons or after a period of gameplay.", 1, 1, 1, true)
    GameTooltip:Show()
end)
refreshButton:SetScript("OnLeave", GameTooltip_Hide)

-- Garbage Collection Button
local gcButton = CreateFrame("Button", nil, window, "GameMenuButtonTemplate")
gcButton:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -10, 10)
gcButton:SetSize(110, 25)
gcButton:SetText("Collect Garbage")
gcButton:SetNormalFontObject("GameFontNormal")
gcButton:SetScript("OnClick", CollectGarbage)

-- Tooltip for Garbage Collection Button
gcButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cFF00FF00Collect Garbage", 1, 1, 1)
    GameTooltip:AddLine("Clicking this button updates the memory usage information for all addons. Use this to see current memory usage after making changes, like enabling/disabling addons or after a period of gameplay.", 1, 1, 1, true)
    GameTooltip:Show()
end)
gcButton:SetScript("OnLeave", GameTooltip_Hide)

-- Save scroll position
scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local newPosition = self:GetVerticalScroll() - (delta * 20)
    self:SetVerticalScroll(newPosition)
    MemoryKillerScrollPosition = newPosition
end)

SLASH_MK1 = "/mk"
SlashCmdList["MK"] = function(msg)
    if window:IsShown() then
        window:Hide()
    else
        window:Show()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MemoryKiller" then
        
        if MemoryKillerScrollPosition == nil then MemoryKillerScrollPosition = 0 end
        
        MemoryKillerMinimapSettings = MemoryKillerMinimapSettings or {}
    elseif event == "PLAYER_LOGOUT" then
                
    end
end)



































