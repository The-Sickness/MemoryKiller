local LibStub = LibStub
local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")

-- Assuming your addon's main table is named "MemoryKiller"
local MemoryKiller = MemoryKiller

-- Table to hold your addon's settings
MemoryKiller.settingsDB = AceDB:New("MemoryKillerDB", {
    profile = {
        autoRefresh = false,
        refreshInterval = 30, -- default value in seconds
    },
}, true)

function MemoryKiller:UpdateMemoryUsage()
    if self.settingsDB.profile.autoRefresh then
        self:CancelAllTimers() -- Stop any existing timer
        self:ScheduleRepeatingTimer(function() self:ActualMemoryUpdateFunction() end, self.settingsDB.profile.refreshInterval)
    else
        self:CancelAllTimers() -- Stop the timer if auto-refresh is disabled
    end
    -- Place the actual update logic in a separate function if needed or continue here
end

local options = {
    name = "MemoryKiller",
    handler = MemoryKiller,
    type = 'group',
    args = {
        autoRefresh = {
            type = "toggle",
            name = "Enable Auto Refresh",
            desc = "Automatically refresh memory usage information.",
            get = function(info) return MemoryKiller.settingsDB.profile.autoRefresh end,
            set = function(info, value)
                MemoryKiller.settingsDB.profile.autoRefresh = value
                MemoryKiller:UpdateMemoryUsage() -- Adjust based on new setting
            end,
            order = 1,
        },
        refreshInterval = {
            type = "range",
            name = "Refresh Interval",
            desc = "Interval in seconds at which the memory usage should be automatically refreshed.",
            min = 10,
            max = 120,
            step = 1,
            get = function(info) return MemoryKiller.settingsDB.profile.refreshInterval end,
            set = function(info, value)
                MemoryKiller.settingsDB.profile.refreshInterval = value
                MemoryKiller:UpdateMemoryUsage() -- Adjust based on new setting
            end,
            order = 2,
            disabled = function() return not MemoryKiller.settingsDB.profile.autoRefresh end,
        },
    },
}


-- Registering options
AceConfig:RegisterOptionsTable("MemoryKiller", options)
AceConfigDialog:AddToBlizOptions("MemoryKiller", "MemoryKiller")

-- Function to open the options panel
function MemoryKiller:ShowOptions()
    InterfaceOptionsFrame_OpenToCategory("MemoryKiller")
    
end

-- Example slash command to open the options
SLASH_MEMORYKILLER1 = "/mk"
SlashCmdList["MEMORYKILLER"] = function(msg)
    MemoryKiller:ShowOptions()
end
