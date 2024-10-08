local layoutName = "|cff1784d1ElvUI|r |cff00c0faLizeUI v1|r"
local layout = {}

layout.defaultSettings = {
    posX = 632.8,
    posY = 139.4,
    scale = 1,
    classIconFontSize = 18,
    spacing = 15,
    growthDirection = 1,
    specIcon = {
        posX = -43,
        posY = 14,
        scale = 1.2,
    },
    trinket = {
        posX = 117,
        posY = 0,
        scale = 1.5,
        fontSize = 16,
    },
    racial = {
        posX = 160,
        posY = 0,
        scale = 1.5,
        fontSize = 14,
    },
    castBar = {
        posX = -140,
        posY = -12,
        scale = 1.6,
        width = 101,
    },
    dr = {
        posX = -163,
        posY = 18,
        size = 39,
        borderSize = 1,
        fontSize = 14,
        spacing = 4,
        growthDirection = 4,
    },

    -- custom layout settings
    width = 280,
    height = 71,
    powerBarHeight = 14,
    mirrored = true,
    classicBars = false,
}

local function getSetting(info)
    return layout.db[info[#info]]
end

local function setSetting(info, val)
    layout.db[info[#info]] = val

    for i = 1, 3 do
        local frame = info.handler["arena" .. i]
        frame:SetSize(layout.db.width, layout.db.height)
        frame.ClassIcon:SetSize(layout.db.height, layout.db.height)
        frame.DeathIcon:SetSize(layout.db.height * 0.8, layout.db.height * 0.8)
        frame.PowerBar:SetHeight(layout.db.powerBarHeight)
        layout:UpdateOrientation(frame)
        layout:UpdateTextures(frame)
        layout:UpdateTextures(frame)
    end
end

local function setupOptionsTable(self)
    layout.optionsTable = self:GetLayoutOptionsTable(layoutName)

    layout.optionsTable.arenaFrames.args.positioning.args.mirrored = {
        order = 5,
        name = "Mirrored Frames",
        type = "toggle",
        width = "full",
        get = getSetting,
        set = setSetting,
    }

    layout.optionsTable.arenaFrames.args.sizing.args.width = {
        order = 3,
        name = "Width",
        type = "range",
        min = 40,
        max = 400,
        step = 1,
        get = getSetting,
        set = setSetting,
    }

    layout.optionsTable.arenaFrames.args.sizing.args.height = {
        order = 4,
        name = "Height",
        type = "range",
        min = 2,
        max = 100,
        step = 1,
        get = getSetting,
        set = setSetting,
    }

    layout.optionsTable.arenaFrames.args.sizing.args.powerBarHeight = {
        order = 5,
        name = "Power Bar Height",
        type = "range",
        min = 1,
        max = 50,
        step = 1,
        get = getSetting,
        set = setSetting,
    }

    layout.optionsTable.arenaFrames.args.other = {
        order = 3,
        name = "Estilo clásico",
        type = "group",
        inline = true,
        args = {
            classicBars = {
                order = 1,
                name = "Activar para usar texturas más clasicas",
                type = "toggle",
                width = "full",
                get = getSetting,
                set = setSetting,
            }
        }
    }
end

local hpUnderlay
local ppUnderlay

function layout:Initialize(frame)
    self.db = frame.parent.db.profile.layoutSettings[layoutName]

    if (not self.optionsTable) then
        setupOptionsTable(frame.parent)
    end

    if (frame:GetID() == 3) then
        frame.parent:UpdateCastBarSettings(self.db.castBar)
        frame.parent:UpdateDRSettings(self.db.dr)
        frame.parent:UpdateFrameSettings(self.db)
        frame.parent:UpdateSpecIconSettings(self.db.specIcon)
        frame.parent:UpdateTrinketSettings(self.db.trinket)
        frame.parent:UpdateRacialSettings(self.db.racial)
    end

    self:UpdateOrientation(frame)

    frame:SetSize(self.db.width, self.db.height)
    frame.SpecIcon:SetSize(18, 18)
    frame.Trinket:SetSize(44, 44)
    frame.Racial:SetSize(44, 44)

    frame.PowerBar:SetHeight(self.db.powerBarHeight)

    frame.ClassIcon:SetSize(self.db.height, self.db.height)
    frame.ClassIcon:Show()

    local f = frame.Name
    f:SetJustifyH("LEFT")
    f:SetJustifyV("BOTTOM")
    f:SetFontObject("SystemFont_Shadow_Med3")
    f:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 0)
    f:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 0)
    f:SetHeight(12)

    f = frame.DeathIcon
    f:ClearAllPoints()
    f:SetPoint("CENTER", frame.HealthBar, "CENTER")
    f:SetSize(self.db.height * 0.8, self.db.height * 0.8)

    frame.HealthText:SetPoint("CENTER", frame.HealthBar)
    frame.HealthText:SetShadowOffset(0, 0)

    frame.PowerText:SetPoint("CENTER", frame.PowerBar)
    frame.PowerText:SetShadowOffset(0, 0)

    hpUnderlay = frame.TexturePool:Acquire()
    hpUnderlay:SetDrawLayer("BACKGROUND", 1)
    hpUnderlay:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT")
    hpUnderlay:SetPoint("BOTTOMRIGHT", frame.HealthBar, "BOTTOMRIGHT")
    hpUnderlay:SetVertexColor(0.15, 0.15, 0.15, 0.9)
    hpUnderlay:Show()

    ppUnderlay = frame.TexturePool:Acquire()
    ppUnderlay:SetDrawLayer("BACKGROUND", 1)
    ppUnderlay:SetPoint("TOPLEFT", frame.PowerBar, "TOPLEFT")
    ppUnderlay:SetPoint("BOTTOMRIGHT", frame.PowerBar, "BOTTOMRIGHT")
    ppUnderlay:SetVertexColor(0.15, 0.15, 0.15, 0.9)
    ppUnderlay:Show()

    self:UpdateTextures(frame)
end

function layout:UpdateOrientation(frame)
    local healthBar = frame.HealthBar
    local powerBar = frame.PowerBar
    local classIcon = frame.ClassIcon

    healthBar:ClearAllPoints()
    powerBar:ClearAllPoints()
    classIcon:ClearAllPoints()

    if (self.db.mirrored) then
        healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
        healthBar:SetPoint("BOTTOMLEFT", powerBar, "TOPLEFT")

        powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 2)
        powerBar:SetPoint("LEFT", classIcon, "RIGHT", 2, 0)

        classIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    else
        healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
        healthBar:SetPoint("BOTTOMRIGHT", powerBar, "TOPRIGHT")

        powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 2)
        powerBar:SetPoint("RIGHT", classIcon, "LEFT", -2, 0)

        classIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    end
end

function layout:UpdateTextures(frame)
    local texture = self.db.classicBars and "Interface\\AddOns\\sArena_LizeUI\\Media\\Textures\\pHishTex5" or
        "Interface\\AddOns\\sArena_LizeUI\\Media\\Textures\\Eltreum-PLv2"

    frame.CastBar.typeInfo = {
        filling = texture,
        full = texture,
        glow = texture
    }
    frame.CastBar:SetStatusBarTexture(texture)
    frame.HealthBar:SetStatusBarTexture(texture)
    frame.PowerBar:SetStatusBarTexture(texture)

    if self.db.classicBars then
        hpUnderlay:SetColorTexture(0, 0, 0, 0.5)
        ppUnderlay:SetColorTexture(0, 0, 0, 0.5)
    else
        hpUnderlay:SetTexture(texture)
        ppUnderlay:SetTexture(texture)
    end
end


sArenaMixin.layouts[layoutName] = layout
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings
