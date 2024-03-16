local ldb = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local MemoryKillerBroker = ldb:NewDataObject("MemoryKiller", {
    type = "data source",
    text = "MemoryKiller",
    icon = "Interface\\AddOns\\MemoryKiller\\Icon\\MK.png",
    OnClick = function(_, button)
        if button == "LeftButton" then
            if MemoryKillerWindow:IsShown() then
                MemoryKillerWindow:Hide()
            else
                MemoryKillerWindow:Show()
            end
        elseif button == "RightButton" then
            
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cFF00FF00MemoryKiller|r")
        tooltip:AddLine("Click to toggle MemoryKiller window.")
        
    end,
})

local function InitializeMinimapIcon()
    if not MemoryKillerMinimapSettings then
        MemoryKillerMinimapSettings = {
            hide = false,
            minimapPos = 225, 
            radius = 80, 
        }
    end
    icon:Register("MemoryKillerMinimap", MemoryKillerBroker, MemoryKillerMinimapSettings)
end

-- Call InitializeMinimapIcon after ADDON_LOADED event to ensure saved variables are loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MemoryKiller" then
        InitializeMinimapIcon() 
    end
end)

local function UpdateBroker()
    
    local totalMemoryUsage = GetTotalAddonMemoryUsage() -- Use WoW API function
    MemoryKillerBroker.text = format("Mem: %.1fKB", totalMemoryUsage)
end

local settings = {
    hide = false,
    
}




