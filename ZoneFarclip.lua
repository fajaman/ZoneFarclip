---@alias ContinentName string

---@type string
local addonName = "ZoneFarclip"

---@type table
local ZFC = {}

---@type number
local maxFarclip = 1277;

-- Continent and zone data
---@type table<ContinentName, string[]>
local continents = {
    ["Eastern Kingdoms"] = {
        "Alterac Mountains", "Arathi Highlands", "Badlands", "Blasted Lands",
        "Burning Steppes", "Deadwind Pass", "Dun Morogh", "Duskwood",
        "Eastern Plaguelands", "Elwynn Forest", "Hillsbrad Foothills",
        "Ironforge", "Isle of Quel'Danas", "Loch Modan", "Redridge Mountains",
        "Searing Gorge", "Silverpine Forest", "Stormwind City", "Stranglethorn Vale",
        "Swamp of Sorrows", "The Hinterlands", "Tirisfal Glades", "Undercity",
        "Western Plaguelands", "Westfall", "Wetlands"
    },
    ["Kalimdor"] = {
        "Ashenvale", "Azshara", "Azuremyst Isle", "Bloodmyst Isle", "Darkshore",
        "Darnassus", "Desolace", "Durotar", "Dustwallow Marsh", "Felwood",
        "Feralas", "Moonglade", "Mulgore", "Orgrimmar", "Silithus",
        "Stonetalon Mountains", "Tanaris", "Teldrassil", "The Barrens",
        "The Exodar", "Thousand Needles", "Thunder Bluff", "Un'Goro Crater",
        "Winterspring"
    },
    ["Outland"] = {
        "Blade's Edge Mountains", "Hellfire Peninsula", "Nagrand", "Netherstorm",
        "Shadowmoon Valley", "Shattrath City", "Terokkar Forest", "Zangarmarsh"
    },
    ["Northrend"] = {
        "Borean Tundra", "Crystalsong Forest", "Dalaran", "Dragonblight",
        "Grizzly Hills", "Howling Fjord", "Icecrown", "Sholazar Basin",
        "The Storm Peaks", "Wintergrasp", "Zul'Drak"
    },
    ["Raids"] = {
        "Icecrown Citadel", "Ulduar", "Vault of Archavon", "The Eye of Eternity",
        "Onyxia's Lair", "Naxxramas", "Crusaders' Coliseum: Trial of the Crusader",
        "The Ruby Sanctum", "The Obsidian Sanctum"
    }
}

-- Default settings structure
---@type table
local defaults = {
    settings = {},
    version = 1,
    defaultZone = { continent = "Northrend", zone = "Dalaran" }
}

-- Current zone tracking
---@type string
local currentContinent
local currentZone
local selectedZone

-- UI Elements
local frame, zoneDropdown, slider, applyButton

-- Initialize the addon
function ZFC:Init()
    -- Load or initialize saved variables
    ZoneFarclipDB = ZoneFarclipDB or CopyTable(defaults)

    print("|cffffd700Zone Farclip loaded!|r Type |cff00ff00/zfc|r to toggle the addon on or off.")

    -- Create main frame
    frame = CreateFrame("Frame", "ZoneFarclipFrame", UIParent)
    frame:SetSize(350, 180)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", frame.StopMovingOrSizing)

    -- Set backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 1)

    -- Title
    local titleBg = frame:CreateTexture(nil, "OVERLAY")
    titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    titleBg:SetWidth(256)
    titleBg:SetHeight(64)
    titleBg:SetPoint("TOP", 0, 12)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -2)
    title:SetText("Zone Farclip")
    title:SetFont("Fonts\\MORPHEUS.TTF", 14, "OUTLINE")

    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Two level dropdown
    zoneDropdown = CreateFrame("Button", "ZFCZoneDropdown", frame, "UIDropDownMenuTemplate")
    zoneDropdown:SetPoint("TOPLEFT", 50, -40)
    UIDropDownMenu_SetWidth(zoneDropdown, 200)


    -- Initialize the dropdown
    UIDropDownMenu_Initialize(zoneDropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        if level == 1 then
            -- First level - Continents
            for continent, zones in pairs(continents) do
                info.text = continent
                info.hasArrow = true
                info.menuList = continent
                info.notCheckable = true
                UIDropDownMenu_AddButton(info, level)
            end
        elseif level == 2 and menuList then
            -- Second level - Zones for the selected continent
            local zones = continents[string.format(menuList)]
            for _, zone in ipairs(zones) do
                info.text = zone
                info.checked = selectedZone == zone
                info.func = function()
                    UIDropDownMenu_SetSelectedValue(zoneDropdown, { continent = menuList, zone = zone })
                    UIDropDownMenu_SetText(zoneDropdown, zone)

                    -- Check if we have a saved value for this zone
                    local savedValue = ZoneFarclipDB.settings[menuList] and ZoneFarclipDB.settings[menuList][zone]

                    -- Set slider to saved value or maximum if no saved value exists
                    slider:SetValue(savedValue or maxFarclip)
                    selectedZone = zone;

                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- Slider
    slider = CreateFrame("Slider", "ZFCFarclipSlider", frame, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 75, -100)
    slider:SetWidth(200)
    slider:SetMinMaxValues(177, maxFarclip)
    slider:SetValueStep(10)
    getglobal(slider:GetName() .. "Low"):SetText("Low")
    getglobal(slider:GetName() .. "High"):SetText("High")
    slider:SetScript("OnValueChanged", function(self, value)
        getglobal(self:GetName() .. "Text"):SetText(math.floor(((value - 177) / (maxFarclip - 177)) * 100) .. "%")
    end)

    -- Apply button
    applyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    applyButton:SetSize(100, 25)
    applyButton:SetPoint("BOTTOM", 0, 20)
    applyButton:SetText("Apply")
    applyButton:SetScript("OnClick", function()
        local selected = UIDropDownMenu_GetSelectedValue(zoneDropdown)
        if not selected then
            return
        end

        local continent = selected.continent
        local zone = selected.zone
        local value = slider:GetValue()

        -- If value is unchanged return
        if value == ZoneFarclipDB.settings[continent][zone] then
            return
        end

        -- Initialize the continent table if it doesn't exist
        ZoneFarclipDB.settings[continent] = ZoneFarclipDB.settings[continent] or {}

        -- Persist the value for this zone
        ZoneFarclipDB.settings[continent][zone] = value

        -- If this is the current zone, apply immediately
        if continent == currentContinent and zone == currentZone then
            SetCVar("farclip", value)
        end

        -- Print confirmation message
        print(string.format("|cffffd700Farclip|r for |cff00ff00%s|r set to |cff00ff00%d|r", zone, value))
    end)

    -- Slash command
    SLASH_ZONEFARCLIP1 = "/zfc"
    SlashCmdList["ZONEFARCLIP"] = function()
        if frame:IsVisible() then
            frame:Hide()
        else
            frame:Show()
            -- Try to select current zone in dropdown when opening
            if currentContinent and continents[currentContinent] then
                UIDropDownMenu_SetSelectedValue(zoneDropdown, { continent = currentContinent, zone = currentZone })
                UIDropDownMenu_SetText(zoneDropdown, currentZone)

                -- Set slider to saved value or maximum
                local savedValue = ZoneFarclipDB.settings[currentContinent] and ZoneFarclipDB.settings[currentContinent][currentZone]
                slider:SetValue(savedValue or maxFarclip)
            else
                -- Fall back to Dalaran if current zone not found
                local default = ZoneFarclipDB.defaultZone or defaults.defaultZone
                UIDropDownMenu_SetSelectedValue(zoneDropdown, default)
                UIDropDownMenu_SetText(zoneDropdown, default.zone)

                local savedValue = ZoneFarclipDB.settings[default.continent] and ZoneFarclipDB.settings[default.continent][default.zone]
                slider:SetValue(savedValue or maxFarclip)
            end
        end
    end

    -- Create event frame for zone tracking
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
            ZFC:UpdateCurrentZone()
        end
    end)

    -- Initial UI update
    frame:Hide()
end

-- Update current zone information
function ZFC.UpdateCurrentZone()
    ---@type number
    local continent = GetCurrentMapContinent()
    local zone = GetRealZoneText()

    -- Convert continent index to name
    ---@type ContinentName[]
    local continentNames = { "Kalimdor", "Eastern Kingdoms", "Outland", "Northrend" }
    currentContinent = continentNames[continent] or "Unknown"
    currentZone = zone

    -- Initialize the continent table if it doesn't exist
    ZoneFarclipDB.settings[currentContinent] = ZoneFarclipDB.settings[currentContinent] or {}

    -- Check if we have saved settings for this zone
    local savedValue = ZoneFarclipDB.settings[currentContinent][currentZone]
    local defaultZone = ZoneFarclipDB.defaultZone.zone or defaults.defaultZone.zone

    local farclipValue = savedValue or maxFarclip
    if (farclipValue ~= math.floor(GetCVar("farclip"))) then
        -- Apply either the saved value or maximum if no saved value exists
        SetCVar("farclip", farclipValue)

        -- Purge the graphics context if value has increased or the zone is default
        if (farclipValue > previousFarclipValue or currentZone == defaultZone) then
            RestartGx()
        end

        -- Print current zone info
        print(string.format("|cffffd700Farclip|r for |cff00ff00%s|r: |cff00ff00%s|r set to |cff00ff00%d|r", currentContinent, currentZone, farclipValue))
    end

    -- If current zone is found set as selected, otherwise fall back to default
    if continents[currentContinent] and tContains(continents[currentContinent], currentZone) then
        selectedZone = currentZone
    else
        selectedZone = defaultZone
    end
end

-- Initialize on load
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
    if addon == addonName then
        -- Initialize saved variables
        if not ZoneFarclipDB then
            ZoneFarclipDB = CopyTable(defaults)
        elseif not ZoneFarclipDB.settings then
            ZoneFarclipDB.settings = CopyTable(defaults.settings)
        end
        if not ZoneFarclipDB.defaultZone then
            ZoneFarclipDB.defaultZone = CopyTable(defaults.defaultZone)
        end

        ZFC:Init()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
