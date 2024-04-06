-- BigDebuffs by Jordon
-- Backported and general improvements by Konjunktur
-- minor improvements by Apparent (initial stance logic)
-- spell list from WotlK Classic (backported by Tsoukie and fixed by Konjunktur)
local addonName, addon = ...
BigDebuffs = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0", "AceConsole-3.0")
local Masque = LibStub("Masque", true)

-- Defaults
local defaults = {
    profile = {
        unitFrames = {
            enabled = true,
            cooldownCount = true,
            player = {
                enabled = true,
                anchor = "auto",
                size = 50,
                cc = true,
                interrupts = false,
                immunities = false,
                immunities_spells = false,
                buffs_defensive = false,
                buffs_offensive = false,
                buffs_other = false,
                roots = true,
            },
            focus = {
                enabled = true,
                anchor = "auto",
                size = 50,
                cc = true,
                interrupts = true,
                immunities = true,
                immunities_spells = true,
                buffs_defensive = true,
                buffs_offensive = true,
                buffs_other = true,
                roots = true,
            },
            target = {
                enabled = true,
                anchor = "auto",
                size = 50,
                cc = true,
                interrupts = true,
                immunities = true,
                immunities_spells = true,
                buffs_defensive = true,
                buffs_offensive = true,
                buffs_other = true,
                roots = true,
            },
            pet = {
                enabled = true,
                anchor = "auto",
                size = 50,
                cc = true,
                interrupts = true,
                immunities = true,
                immunities_spells = true,
                buffs_defensive = true,
                buffs_offensive = true,
                buffs_other = true,
                roots = true,
            },
            party = {
                enabled = true,
                anchor = "auto",
                size = 50,
                cc = true,
                interrupts = true,
                immunities = true,
                immunities_spells = true,
                buffs_defensive = true,
                buffs_offensive = true,
                buffs_other = true,
                roots = true,
            },
            arena = {
                enabled = true,
                anchor = "auto",
                size = 50,
                cc = true,
                interrupts = true,
                immunities = true,
                immunities_spells = true,
                buffs_defensive = true,
                buffs_offensive = true,
                buffs_other = true,
                roots = true,
            },
        },
        priority = {
            immunities = 90,
            immunities_spells = 80,
            cc = 70,
            interrupts = 60,
            buffs_defensive = 50,
            buffs_offensive = 40,
            buffs_other = 30,
            roots = 20,
        },
        spells = {},
    }
}

BigDebuffs.Spells = addon.Spells

function BigDebuffs_SpellTest()
    for k,v in pairs(BigDebuffs.Spells) do
        if not GetSpellInfo(k) then
            print("BigDebuffs, Spell ID doesn't exist:", k)
        end
    end
end

local units = {
    "player",
    "pet",
    "target",
    "focus",
    "party1",
    "party2",
    "party3",
    "party4",
    "arena1",
    "arena2",
    "arena3",
    "arena4",
    "arena5",
}

local UnitDebuff, UnitBuff = UnitDebuff, UnitBuff

local GetAnchor = {
    ShadowedUnitFrames = function(anchor)
        local frame = _G[anchor]
        if not frame then return end
        if frame.portrait and frame.portrait:IsShown() then
            return frame.portrait, frame
        else
            return frame, frame, true
        end
    end,
    ZPerl = function(anchor)
        local frame = _G[anchor]
        if not frame then return end
        if frame:IsShown() then
            return frame, frame
        else
            frame = frame:GetParent()
            return frame, frame, true
        end
    end,
}

local anchors = {
    ["ElvUI"] = {
        noPortrait = true,
        units = {
            player = "ElvUF_Player",
            pet = "ElvUF_Pet",
            target = "ElvUF_Target",
            focus = "ElvUF_Focus",
            party1 = "ElvUF_PartyGroup1UnitButton1",
            party2 = "ElvUF_PartyGroup1UnitButton2",
            party3 = "ElvUF_PartyGroup1UnitButton3",
            party4 = "ElvUF_PartyGroup1UnitButton4",
        },
    },
    ["bUnitFrames"] = {
        noPortrait = true,
        alignLeft = true,
        units = {
            player = "bplayerUnitFrame",
            pet = "bpetUnitFrame",
            target = "btargetUnitFrame",
            focus = "bfocusUnitFrame",
            arena1 = "barena1UnitFrame",
            arena2 = "barena2UnitFrame",
            arena3 = "barena3UnitFrame",
            arena4 = "barena4UnitFrame",
        },
    },
    ["Shadowed Unit Frames"] = {
        func = GetAnchor.ShadowedUnitFrames,
        units = {
            player = "SUFUnitplayer",
            pet = "SUFUnitpet",
            target = "SUFUnittarget",
            focus = "SUFUnitfocus",
            party1 = "SUFHeaderpartyUnitButton1",
            party2 = "SUFHeaderpartyUnitButton2",
            party3 = "SUFHeaderpartyUnitButton3",
            party4 = "SUFHeaderpartyUnitButton4",
        },
    },
    ["ZPerl"] = {
        func = GetAnchor.ZPerl,
        units = {
            player = "XPerl_PlayerportraitFrame",
            pet = "XPerl_Player_PetportraitFrame",
            target = "XPerl_TargetportraitFrame",
            focus = "XPerl_FocusportraitFrame",
            party1 = "XPerl_party1portraitFrame",
            party2 = "XPerl_party2portraitFrame",
            party3 = "XPerl_party3portraitFrame",
            party4 = "XPerl_party4portraitFrame",
        },
    },
    ["Blizzard"] = {
        units = {
            player = "PlayerPortrait",
            pet = "PetPortrait",
            target = "TargetFramePortrait",
            focus = "FocusFramePortrait",
            party1 = "PartyMemberFrame1Portrait",
            party2 = "PartyMemberFrame2Portrait",
            party3 = "PartyMemberFrame3Portrait",
            party4 = "PartyMemberFrame4Portrait",
            arena1 = "ArenaEnemyFrame1ClassPortrait",
            arena2 = "ArenaEnemyFrame2ClassPortrait",
            arena3 = "ArenaEnemyFrame3ClassPortrait",
            arena4 = "ArenaEnemyFrame4ClassPortrait",
            arena5 = "ArenaEnemyFrame5ClassPortrait",
        },
    },
}

function BigDebuffs:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults, true)

    self:RegisterChatCommand('bd', 'ParseParameters')
    self:RegisterChatCommand(addonName, 'ParseParameters')

    self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
    self.db.RegisterCallback(self, "OnProfileReset", "Refresh")
    self.frames = {}
    self.UnitFrames = {}
    self:SetupOptions()
end

local function HideBigDebuffs(frame)
    if not frame.BigDebuffs then return end
    for i = 1, #frame.BigDebuffs do
        frame.BigDebuffs[i]:Hide()
    end
end

function BigDebuffs:Refresh()
    for unit, frame in pairs(self.UnitFrames) do
        frame:Hide()
        frame.current = nil
        frame.cooldown.noCooldownCount = not self.db.profile.unitFrames.cooldownCount
        frame.cooldownCircular.noCooldownCount = not self.db.profile.unitFrames.cooldownCount
        self:AttachUnitFrame(unit)
        self:UNIT_AURA(nil, unit)
    end
end

local unitsToUpdate = {}

function BigDebuffs:PLAYER_REGEN_ENABLED()
    for unit, _ in pairs(unitsToUpdate) do
        self:AttachUnitFrame(unit)
    end
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    unitsToUpdate = {}
end

function BigDebuffs:AttachUnitFrame(unit)
    if InCombatLockdown() then
        unitsToUpdate[unit] = true
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local frame = self.UnitFrames[unit]
    local frameName = addonName .. unit .. "UnitFrame"

    if not frame then
        frame = CreateFrame("Button", frameName, UIParent, "BigDebuffsUnitFrameTemplate")
        frame.icon = _G[frameName.."Icon"]
        self.UnitFrames[unit] = frame
        frame.icon:SetDrawLayer("BORDER")
        frame.cooldown:SetParent(frame)
        frame.cooldown:SetAllPoints()
        frame.cooldown:SetAlpha(0.9)
        frame.cooldown:Hide()

        frame.cooldownCircular = CreateFrame("Frame", frameName.."CooldownCircular", frame, "CircleCooldownFrameTemplate")
        frame.cooldownCircular:SetDrawBling(false)
        frame.cooldownCircular:SetDrawSwipe(true)
        frame.cooldownCircular:SetReverse(true)
        frame.cooldownCircular:SetParent(frame)
        frame.cooldownCircular:SetAllPoints()
        frame.cooldownCircular:SetAlpha(0.9)
        frame.cooldownCircular:Hide()

        -- Needed for the circle cooldown to end up behind the unit frame level and borders
        frame.cooldownCircular:SetFrameStrata("BACKGROUND")


        frame:RegisterForDrag("LeftButton")
        frame:SetMovable(true)
        frame.unit = unit
    end

    frame:EnableMouse(self.test)

    _G[frameName.."Name"]:SetText(self.test and not frame.anchor and unit)

    frame.anchor = nil
    frame.blizzard = nil

    local config = self.db.profile.unitFrames[unit:gsub("%d", "")]

    if config.anchor == "auto" then
        -- Find a frame to attach to
        for k,v in pairs(anchors) do
            local anchor, parent, noPortrait
            if v.units[unit] then
                if v.func then
                    anchor, parent, noPortrait = v.func(v.units[unit])
                else
                    anchor = _G[v.units[unit]]
                end

                if anchor then
                    frame.anchor, frame.parent, frame.noPortrait = anchor, parent, noPortrait
                    if v.noPortrait then frame.noPortrait = true end
                    frame.alignLeft = v.alignLeft
                    frame.blizzard = k == "Blizzard"
                    if not frame.blizzard then break end
                end
            end
        end
    end

    if Masque then
        if frame.masqueGroup then
            frame.masqueGroup:RemoveButton(frame)
        end

        if not frame.anchor and not frame.blizzard then
            local group = frame.masqueGroup and frame.masqueGroup or Masque:Group(addonName, unit:gsub('%d',''))
            frame.masqueGroup = group

            frame.masqueGroup:AddButton(frame,
                {
                    Cooldown = frame.cooldown,
                    Gloss = frame.icon,
                    Icon = frame.icon,
                },
            nil, true)
        end
    end

    if frame.anchor then
        if frame.blizzard then
            -- Blizzard Frame
            frame:SetParent(frame.anchor:GetParent())
            frame:SetFrameLevel(frame.anchor:GetParent():GetFrameLevel())
            frame.anchor:SetDrawLayer("BACKGROUND")
            frame.cooldownCircular:SetFrameLevel(frame.anchor:GetParent():GetFrameLevel() + 1)
            local txtFrameName
            for preName in string.gmatch(frame.anchor:GetName(),  "(.-)Portrait") do
                txtFrameName = preName
                break
            end
            txtFrameName = txtFrameName .. "TextureFrame"
            if _G[txtFrameName] then
                local txtFrame = _G[txtFrameName]
                txtFrame:SetFrameLevel(frame.cooldownCircular:GetFrameLevel() + 2)
            end
        else
            frame:SetParent(frame.parent and frame.parent or frame.anchor)
            frame:SetFrameLevel(99)
        end

        frame:ClearAllPoints()

        if frame.noPortrait then
            -- No portrait, so attach to the side
            if frame.alignLeft then
                frame:SetPoint("TOPRIGHT", frame.anchor, "TOPLEFT")
            else
                frame:SetPoint("TOPLEFT", frame.anchor, "TOPRIGHT")
            end
            local height = frame.anchor:GetHeight()
            frame:SetSize(height, height)
        else
            frame:SetAllPoints(frame.anchor)
        end
    else
        -- Manual
        frame:SetParent(UIParent)
        frame:ClearAllPoints()

        frame:SetFrameLevel(frame:GetParent():GetFrameLevel())

        if not self.db.profile.unitFrames[unit] then self.db.profile.unitFrames[unit] = {} end

        if self.db.profile.unitFrames[unit].position then
            frame:SetPoint(unpack(self.db.profile.unitFrames[unit].position))
        else
            -- No saved position, anchor to the blizzard position
            LoadAddOn("Blizzard_ArenaUI")
            local relativeFrame = _G[anchors.Blizzard.units[unit]] or UIParent
            frame:SetPoint("CENTER", relativeFrame, "CENTER")
        end

        frame:SetSize(config.size, config.size)
    end


    if frame.anchor and frame.blizzard then
        if frame.cooldown:IsShown() then
            frame.cooldown:Hide()
        end
    elseif frame.cooldownCircular:IsShown() then
        if Masque and frame.masqueGroup then
            frame.masqueGroup:ReSkin()
        end
        frame.cooldownCircular:Hide()
    end

end

function BigDebuffs:SaveUnitFramePosition(frame)
    self.db.profile.unitFrames[frame.unit].position = { frame:GetPoint() }
end

function BigDebuffs:Test()
    self.test = not self.test
    self:Refresh()
end

local TestDebuffs = {}

function BigDebuffs:InsertTestDebuff(spellID)
    local texture = select(3, GetSpellInfo(spellID))
    table.insert(TestDebuffs, {spellID, texture})
end

local function UnitDebuffTest(unit, index)
    local debuff = TestDebuffs[index]
    if not debuff then return end

    local duration = random(5, 20)

    return GetSpellInfo(debuff[1]), nil, debuff[2], 0, "Magic", duration, GetTime()+duration, nil, nil, nil, debuff[1]
end

function BigDebuffs:OnEnable()
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self.interrupts = {}

    -- Prevent OmniCC finish animations
    if OmniCC then
        self:RawHook(OmniCC, "TriggerEffect", function(...)
            local _, cooldown = ...
            local name = cooldown:GetName()
            if name and name:find(addonName) then return end
            self.hooks[OmniCC].TriggerEffect(...)
        end, true)
    end

    self:InsertTestDebuff(69369) -- Predatory Strikes
    self:InsertTestDebuff(8643) -- Kidney Shot
    self:InsertTestDebuff(1766)  -- Kick
end

function BigDebuffs:PLAYER_ENTERING_WORLD()
    for i = 1, #units do
        self:AttachUnitFrame(units[i])
    end
    self.stances = {}
end

function BigDebuffs:PARTY_MEMBERS_CHANGED()
    self:Refresh()
end

-- For unit frames
function BigDebuffs:GetAuraPriority(unit, name, id)
    if not unit or (not self.Spells[id] and not self.Spells[name]) then return end

    id = self.Spells[id] and id or name

    -- Make sure category is enabled
    if not self.db.profile.unitFrames[unit:gsub("%d", "")][self.Spells[id].type] then return end

    -- Check for user set
    if self.db.profile.spells[id] then
        if self.db.profile.spells[id].unitFrames and self.db.profile.spells[id].unitFrames == 0 then return end
        if self.db.profile.spells[id].priority then return self.db.profile.spells[id].priority end
    end

    if self.Spells[id].nounitFrames and (not self.db.profile.spells[id] or not self.db.profile.spells[id].unitFrames) then
        return
    end

    return self.db.profile.priority[self.Spells[id].type] or 0
end

function BigDebuffs:GetUnitFromGUID(guid)
    for _,unit in pairs(units) do
        if UnitGUID(unit) == guid then
            return unit
        end
    end
    return nil
end

function BigDebuffs:UNIT_SPELLCAST_FAILED(_,unit, _, _, spellid)
    local guid = UnitGUID(unit)
    if not self.interrupts[guid] then
        self.interrupts[guid] = {}
        BigDebuffs:CancelTimer(self.interrupts[guid].timer)
    end
    self.interrupts[guid].timer = self:ScheduleTimer(function(...)self:ClearInterruptGUID(...)end, 30, guid)
    self.interrupts[guid].failed = GetTime()
end

function BigDebuffs:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
    local _, subEvent, sourceGUID, _, _, destGUID, destName, _, spellid, name = ...

    -- Stance logic
    if subEvent == "SPELL_CAST_SUCCESS" and self.Spells[spellid] then
        if spellid == 2457 or spellid == 2458 or spellid == 71 then -- Defensive/Berserker/Battle
            self:UpdateStance(sourceGUID, spellid)
        end
    end

    if subEvent ~= "SPELL_CAST_SUCCESS" and subEvent ~= "SPELL_INTERRUPT" then
        return
    end

    -- UnitChannelingInfo and event orders are not the same in WotLK as later expansions, UnitChannelingInfo will always return
    -- nil @ the time of this event (independent of whether something was kicked or not).
    -- We have to track UNIT_SPELLCAST_FAILED for spell failure of the target at the (approx.) same time as we interrupted
    -- this "could" be wrong if the interrupt misses with a <0.01 sec failure window (which depending on server tickrate might
    -- not even be possible)
    if subEvent == "SPELL_CAST_SUCCESS" and not (self.interrupts[destGUID] and
            self.interrupts[destGUID].failed and GetTime() - self.interrupts[destGUID].failed < 0.01) then
        return
    end

    local spelldata = self.Spells[name] and self.Spells[name] or self.Spells[spellid]
    if spelldata == nil or spelldata.type ~= "interrupts" then return end
    local duration = spelldata.duration
    if not duration then return end

    self:UpdateInterrupt(nil, destGUID, spellid, duration)
end

function BigDebuffs:UpdateStance(guid, spellid)
    if self.stances[guid] == nil then
        self.stances[guid] = {}
    else
        self:CancelTimer(self.stances[guid].timer)
    end

    self.stances[guid].stance = spellid
    self.stances[guid].timer = self:ScheduleTimer(function(...)self:ClearStanceGUID(...)end, 180, guid)

    local unit = self:GetUnitFromGUID(guid)

    if unit then
        self:UNIT_AURA(nil, unit)
    end
end

function BigDebuffs:ClearStanceGUID(guid)
    local unit = self:GetUnitFromGUID(guid)
    if not unit or not self.stances[guid] then
        self.stances[guid] = nil
    else
        self.stances[guid].timer = self:ScheduleTimer(function(...)self:ClearStanceGUID(...)end, 180, guid)
    end
end

function BigDebuffs:UpdateInterrupt(unit, guid, spellid, duration)
    local t = GetTime()
    -- new interrupt
    if spellid and duration ~= nil then
        if self.interrupts[guid] == nil then self.interrupts[guid] = {} end
        BigDebuffs:CancelTimer(self.interrupts[guid].timer)
        self.interrupts[guid].timer = BigDebuffs:ScheduleTimer(function(...)self:ClearInterruptGUID(...)end, 30, guid)
        self.interrupts[guid][spellid] = {started = t, duration = duration}
    -- old interrupt expiring
    elseif spellid and duration == nil then
        if self.interrupts[guid] and self.interrupts[guid][spellid] and
                t > self.interrupts[guid][spellid].started + self.interrupts[guid][spellid].duration then
            self.interrupts[guid][spellid] = nil
        end
    end

    unit = unit and unit or self:GetUnitFromGUID(guid)

    if unit then
        self:UNIT_AURA(nil, unit)
    end
    -- clears the interrupt after end of duration
    if duration then
        self:ScheduleTimer(function(arg1) self:UpdateInterrupt(unpack(arg1)) end, duration+0.1, {unit, guid, spellid})
    end
end

function BigDebuffs:ClearInterruptGUID(guid)
    self.interrupts[guid] = nil
end

function BigDebuffs:GetInterruptFor(unit)
    local guid = UnitGUID(unit)
    interrupts = self.interrupts[guid]
    if interrupts == nil then return end

    local name, spellid, icon, duration, endsAt

    -- iterate over all interrupt spellids to find the one of highest duration
    for ispellid, intdata in pairs(interrupts) do
        if type(ispellid) == "number" then
            local tmpstartedAt = intdata.started
            local dur = intdata.duration
            local tmpendsAt = tmpstartedAt + dur
            if GetTime() > tmpendsAt then
                self.interrupts[guid][ispellid] = nil
            elseif endsAt == nil or tmpendsAt > endsAt then
                endsAt = tmpendsAt
                duration = dur
                name, _, icon = GetSpellInfo(ispellid)
                spellid = ispellid
            end
        end
    end

    if name then
        return name, spellid, icon, duration, endsAt
    end
end

function BigDebuffs:UNIT_AURA(event, unit)
    if not unit or not self.db.profile.unitFrames[unit:gsub("%d", "")] or
            not self.db.profile.unitFrames[unit:gsub("%d", "")].enabled then
        return
    end

    local frame = self.UnitFrames[unit]
    if not frame then return end

    local UnitDebuff = BigDebuffs.test and UnitDebuffTest or UnitDebuff

    local now = GetTime()
    local left, priority, duration, expires, icon, isAura, interrupt = 0, 0

    for i = 1, 40 do
        -- Check debuffs
        local n,_, ico, _,_, d, e, caster, _,_, id = UnitDebuff(unit, i)

        if id then
            if self.Spells[n] or self.Spells[id] then
                local p = self:GetAuraPriority(unit, n, id)
                if p and (p > priority or (p == priority and expires and e > expires)) then
                    left = e - now
                    duration = d
                    isAura = true
                    priority = p
                    expires = e
                    icon = ico
                end
            end
        else
            break
        end
    end

    for i = 1, 40 do
        -- Check buffs
        local n,_, ico, _,_, d, e, _,_,_, id = UnitBuff(unit, i)
        if id then
            if self.Spells[id] then
                local p = self:GetAuraPriority(unit, n, id)
                if p and p >= priority then
                    if p and (p > priority or (p == priority and expires and e > expires)) then
                        left = e - now
                        duration = d
                        isAura = true
                        priority = p
                        expires = e
                        icon = ico
                    end
                end
            end
        else
            break
        end
    end

    local n, id, ico, d, e = self:GetInterruptFor(unit)
    if n then
        local p = self:GetAuraPriority(unit, n, id)
        if p and (p > priority or (p == priority and expires and e > expires)) then
            left = e - now
            duration = d
            isAura = true
            priority = p
            expires = e
            icon = ico
        end
    end

    -- need to always look for a stance (if we only look for it once a player
    -- changes stance we will never get back to it again once other auras fade)
    local guid = UnitGUID(unit)
    if self.stances[guid] then
        local stanceId = self.stances[guid].stance
        if stanceId and self.Spells[stanceId] then
            n, _, ico = GetSpellInfo(stanceId)
            local p = self:GetAuraPriority(unit, n, stanceId)
            if p and p >= priority then
                left = 0
                duration = 0
                isAura = true
                priority = p
                expires = 0
                icon = ico
            end
        end
    end

    if isAura then
        if frame.current ~= icon then
            if frame.blizzard then
                -- Blizzard Frame
                SetPortraitToTexture(frame.icon, icon)
                -- Adapt
                if frame.anchor and Adapt and Adapt.portraits[frame.anchor] then
                    Adapt.portraits[frame.anchor].modelLayer:SetFrameStrata("BACKGROUND")
                end
            else
                frame.icon:SetTexture(icon)
            end
        end

        if duration then
            if frame.anchor and frame.blizzard then
                frame.cooldownCircular:SetCooldown(expires - duration, duration)
            else
                frame.cooldown:SetCooldown(expires - duration, duration)
            end
        else
            if frame.anchor and frame.blizzard then
                frame.cooldownCircular:SetCooldown(0, 0)
                frame.cooldownCircular:Hide()
            else
                frame.cooldown:SetCooldown(0, 0)
                frame.cooldown:Hide()
            end
        end

        if not frame:IsShown() then
            frame:Show()
        end
        frame.current = icon
    else
        -- Adapt
        if frame.anchor and frame.blizzard and Adapt and Adapt.portraits[frame.anchor] then
            Adapt.portraits[frame.anchor].modelLayer:SetFrameStrata("LOW")
        else
            frame:Hide()
            frame.current = nil
        end
    end
end

function BigDebuffs:PLAYER_FOCUS_CHANGED()
    self:UNIT_AURA(nil, "focus")
end

function BigDebuffs:PLAYER_TARGET_CHANGED()
    self:UNIT_AURA(nil, "target")
end

function BigDebuffs:UNIT_PET()
    self:UNIT_AURA(nil, "pet")
end

function BigDebuffs:ParseParameters()
    LibStub("AceConfigDialog-3.0"):Open(addonName)
end