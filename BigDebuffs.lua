
-- BigDebuffs by Jordon (& improved / backported by Konjunktur)

BigDebuffs = LibStub("AceAddon-3.0"):NewAddon("BigDebuffs", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

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
			},
			focus = {
				enabled = true,
				anchor = "auto",
				size = 50,
			},
			target = {
				enabled = true,
				anchor = "auto",
				size = 50,
			},
			pet = {
				enabled = true,
				anchor = "auto",
				size = 50,
			},
			party = {
				enabled = true,
				anchor = "auto",
				size = 50,
			},
			arena = {
				enabled = true,
				anchor = "auto",
				size = 50,
			},
			cc = true,
			interrupts = true,
			immunities = true,
			immunities_spells = true,
			buffs_defensive = true,
			buffs_offensive = true,
			buffs_other = true,
			roots = true,
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

BigDebuffs.Spells = {

	["Dispersion"] = { type = "buffs_defensive", },  -- Dispersion
	["Frenzied Regeneration"] = { type = "buffs_defensive", },  -- Frenzied Regeneration
	["Hand of Protection"] = { type = "buffs_defensive", },  -- Blessing of Protection
	["Spirit of Redemption"] = { type = "buffs_defensive", },  -- Spirit of Redemption
	["Survival Instincts"] = { type = "buffs_defensive", },  -- Survival Instincts
	["Roar of Sacrifice"] = { type = "buffs_defensive", },  -- Roar of Sacrifice (Hunter Pet Skill)
	["Deterrence"] = { type = "buffs_defensive", },  -- Deterrence
	["Evasion"] = { type = "buffs_defensive", },  -- Evasion
	["Ardent Defender"] = { type = "buffs_defensive", },  -- Ardent Defender
	["Barkskin"] = { type = "buffs_defensive", },  -- Barkskin
	["Fear Ward"] = { type = "buffs_defensive", },  -- Fear Ward
	["Last Stand"] = { type = "buffs_defensive", },  -- Last Stand
	["Inner Focus"] = { type = "buffs_defensive", },  -- Inner Focus
	["Pain Suppression"] = { type = "buffs_defensive", },  -- Pain Suppression
	["Aura Mastery"] = { type = "buffs_defensive", },  -- Aura Mastery
	["Icebound Fortitude"] = { type = "buffs_defensive", },  -- Icebound Fortitude
	["Guardian Spirit"] = { type = "buffs_defensive", },  -- Guardian Spirit
	["Feint"] = { type = "buffs_defensive", },  -- Feint
	["Enraged Regeneration"] = { type = "buffs_defensive", },  -- Enraged Regeneration
	["Divine Hymn"] = { type = "buffs_defensive", },  -- Divine Hymn
	["Unbreakable Armor"] = { type = "buffs_defensive", },  -- Unbreakable Armor
	["Shield Wall"] = { type = "buffs_defensive", },  -- Shield Wall
	["Ice Barrier"] = { type = "buffs_defensive", },  -- Ice Barrier
	["Feign Death"] = { type = "buffs_defensive", },  -- Feign Death
	["Tranquility"] = { type = "buffs_defensive", },  -- Tranquility
	["Divine Illumination"] = { type = "buffs_defensive"},  -- Divine Illumination
	["Divine Protection"] = { type = "buffs_defensive", },  -- Divine Protection
	["Hand of Sacrifice"] = { type = "buffs_defensive", },  -- Blessing of Sacrifice
	["Hand of Freedom"] = { type = "buffs_defensive", },  -- Blessing of Freedom
	["Vampiric Blood"] = { type = "buffs_defensive", },  -- Vampiric Blood

	["Master's Call"] = { type = "buffs_defensive", },  -- Master's Call
	["Divine Favor"] = { type = "buffs_defensive", },  -- Divine Favor
	["Anti-Magic Zone"] = { type = "buffs_defensive", },  -- Anti-Magic Zone
	["Hysteria"] = { type = "buffs_defensive", },  -- Hysteria

	["Innervate"] = { type = "buffs_offensive", },  -- Innervate
	["Tiger's Fury"] = { type = "buffs_offensive", },  -- Tiger's Fury
	["Dancing Rune Weapon"] = { type = "buffs_offensive", },  -- Dancing Rune Weapon
	["Icy Veins"] = { type = "buffs_offensive", },  -- Icy Veins
	["Tree of Life"] = { type = "buffs_offensive", },  -- Tree of Life
	["Avenging Wrath"] = { type = "buffs_offensive", },  -- Avenging Wrath (Protection/Retribution)
	["Adrenaline Rush"] = { type = "buffs_offensive", },  -- Adrenaline Rush
	["Combustion"] = { type = "buffs_offensive", },  -- Combustion
	["Arcane Power"] = { type = "buffs_offensive", },  -- Arcane Power
	["Elemental Mastery"] = { type = "buffs_offensive", },  -- Elemental Mastery
	["Berserk"] = { type = "buffs_offensive", },  -- Berserk
	["Recklessness"] = { type = "buffs_offensive", },  -- Battle Cry
	["Bloodlust"] = { type = "buffs_offensive", },  -- Bloodlust
		["Heroism"] = { type = "buffs_offensive"},  -- Heroism
	["Killing Spree"] = { type = "buffs_offensive", },  -- Killing Spree
	["Power Infusion"] = { type = "buffs_offensive", },  -- Power Infusion
	["Presence of Mind"] = { type = "buffs_offensive", },  -- Presence of Mind
	["Evocation"] = { type = "buffs_offensive", },  -- Evocation
	["Invisibility"] = { type = "buffs_offensive", },  -- Invisibility
	["Bestial Wrath"] = { type = "buffs_offensive", },  -- Bestial Wrath

	["Drink"] = { type = "buffs_other", },  -- Drink
		["Refreshment"] = { type = "buffs_other"},  -- Refreshment
	["Dash"] = { type = "buffs_other", },  -- Dash
	["Sprint"] = { type = "buffs_other", },  -- Sprint
	["Viper Sting"] = { type = "buffs_other", },  -- Viper Sting
	["Fel Domination"] = { type = "buffs_other", },  -- Fel Domination
	["Berserker Rage"] = { type = "buffs_other", },  -- Berserker Rage
	["Hypothermia"] = { type = "buffs_other", },  -- Hypothermia

	["Shadowfury"] = { type = "cc", },  -- Shadowfury
	["Gouge"] = { type = "cc", },  -- Gouge
	["Disarm"] = { type = "cc", },  -- Disarm
	["Dismantle"] = {type = "cc", }, -- Dismantle
	["Hex"] = { type = "cc", },  -- Hex
	["Polymorph"] = { type = "cc", },  -- Polymorph
	["Intimidation"] = { type = "cc", },  -- Intimidation
	["Arcane Torrent"] = { type = "cc", },  -- Arcane Torrent
	["Maim"] = { type = "cc" },  -- Maim
	["Blind"] = { type = "cc", },  -- Blind
	["Bash"] = { type = "cc", },  -- Bash
	["Kidney Shot"] = { type = "cc", },  -- Kidney Shot
	["Sap"] = { type = "cc", },  -- Sap
	["Hibernate"] = {type = "cc"}, -- Hibernate
	["Wyvern Sting"] = { type = "cc", },  -- Wyvern Sting
	["Strangulate"] = { type = "cc", },  -- Strangulate 
	["Garrote - Silence"] = { type = "cc", },  -- Garrote - Silence
	["Unstable Affliction (Silence)"] = { type = "cc", },  -- Unstable Affliction (Silence)
	["Silencing Shot"] = { type = "cc", },
	["Repentance"] = { type = "cc", },  -- Repentance
	["Shockwave"] = { type = "cc", },  -- Shockwave
	["Kidney Shot"] = { type = "cc", },  -- Kidney Shot
	["Gnaw"] = { type = "cc", },  -- Gnaw
	["Psychic Scream"] = { type = "cc", },  -- Psychic Scream
	["Scatter Shot"] = { type = "cc", },  -- Scatter Shot
	["Banish"] = { type = "cc", },  -- Banish
	["Freezing Trap Effect"] = { type = "cc", },  -- Freezing Trap
	["Inferno Effect"] = { type = "cc", },  -- Infernal Awakening
	["Silence"] = { type = "cc", },  -- Silence
	["Death Coil"] = { type = "cc", },  -- Mortal Coil
	["Hammer of Justice"] = { type = "cc", },  -- Hammer of Justice
	["War Stomp"] = { type = "cc", },  -- War Stomp
	["Intimidating Shout"] = { type = "cc", },  -- Intimidating Shout
	["Mind Control"] = { type = "cc", },  -- Mind Control
	["Seduction"] = { type = "cc", },  -- Seduction
	["Fear"] = { type = "cc", },  -- Fear
	["Howl of Terror"] = { type = "cc", },  -- Howl of Terror
	["Cheap Shot"] = { type = "cc", },  -- Cheap Shot
	["Pounce"] = { type = "cc", },  -- Pounce
	["Avenger's Shield"] = { type = "cc", },  -- Avenger's Shield
	["Cyclone"] = { type = "cc" },  -- Cyclone
	["Dragon's Breath"] = { type = "cc", },  -- Dragon's Breath
	["Shackle Undead"] = { type = "cc", },  -- Shackle Undead
	["Charge"] = { type = "cc", }, -- Charge
	["Intercept"] = { type = "cc", }, -- Intercept
	["Hungering Cold"] = { type = "cc", }, -- Hungering Cold

	["Ice Block"] = { type = "immunities", },  -- Ice Block
	["Bladestorm"] = { type = "immunities", },  -- Bladestorm (Arms)
	["Divine Shield"] = { type = "immunities", },  -- Divine Shield

	["Spell Reflection"] = { type = "immunities_spells", },  -- Spell Reflection
	["Anti-Magic Shell"] = { type = "immunities_spells", },  -- Anti-Magic Shell
	["Cloak of Shadows"] = { type = "immunities_spells", },  -- Cloak of Shadows
	["Lichborne"] = { type = "immunities_spells", },  -- Lichborne

	["Pummel"] = { type = "interrupts", interruptduration = 4, },  -- Pummel (Warrior)
	["Counterspell"] = { type = "interrupts", interruptduration = 6, },  -- Counterspell (Mage)
	["Spell Lock"] = { type = "interrupts", interruptduration = 5, },  -- Spell Lock (Warlock)
	["Mind Freeze"] = { type = "interrupts", interruptduration = 3, },  -- Mind Freeze (Death Knight)
	["Feral Charge - Bear"] = { type = "interrupts", interruptduration = 4, },  -- Feral Charge - Bear
	["Wind Shear"] = { type = "interrupts", interruptduration = 3, },  -- Wind Shear (Shaman)
	["Kick"] = { type = "interrupts", interruptduration = 5, },  -- Kick (Rogue)

	["Feral Charge Effect"] = { type = "roots", },  -- Wild Charge
	["Frostbite"] = { type = "roots", },  -- Frostbite
	["Frost Nova"] = { type = "roots", },  -- Frost Nova
		["Freeze"] = { type = "roots", },  -- Freeze
	["Earthgrab"] = { type = "roots", },  -- Earthgrab Totem
	["Entangling Roots"] = { type = "roots", },  -- Entangling Roots
	["Nature's Grasp"] = { type = "roots", }, -- Nature's Grasp
}

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
	self.db = LibStub("AceDB-3.0"):New("BigDebuffsDB", defaults, true)

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
		--frame.cooldown:SetHideCountdownNumbers(not self.db.profile.unitFrames.cooldownCount)
		frame.cooldown.noCooldownCount = not self.db.profile.unitFrames.cooldownCount
		self:UNIT_AURA(nil, unit)
	end
end

function BigDebuffs:AttachUnitFrame(unit)
	if InCombatLockdown() then return end

	local frame = self.UnitFrames[unit]
	local frameName = "BigDebuffs" .. unit .. "UnitFrame"

	if not frame then
		frame = CreateFrame("Button", frameName, UIParent, "BigDebuffsUnitFrameTemplate")
		self.UnitFrames[unit] = frame

		frame.icon = _G[frameName.."Icon"]
		frame.icon:SetDrawLayer("BORDER")

		frame.cooldownContainer = CreateFrame("Button", frameName.."CooldownContainer", frame)
		frame.cooldownContainer:SetPoint("CENTER")
		frame.cooldown:SetParent(frame.cooldownContainer)
		frame.cooldown:SetAllPoints()
		
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

	if frame.anchor then
		if frame.blizzard then
			-- Blizzard Frame
			frame:SetParent(frame.anchor:GetParent())
			frame:SetFrameLevel(frame.anchor:GetParent():GetFrameLevel())
			frame.cooldownContainer:SetFrameLevel(frame.anchor:GetParent():GetFrameLevel()-1)
			frame.cooldownContainer:SetSize(frame.anchor:GetWidth()-10, frame.anchor:GetHeight()-8)
			frame.anchor:SetDrawLayer("BACKGROUND")
		else
			frame:SetParent(frame.parent and frame.parent or frame.anchor)
			frame:SetFrameLevel(99)
			frame.cooldownContainer:SetSize(frame.anchor:GetWidth(), frame.anchor:GetHeight())
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
		frame.cooldownContainer:SetSize(frame:GetWidth(), frame:GetHeight())

		if not self.db.profile.unitFrames[unit:gsub("%d", "")] then self.db.profile.unitFrames[unit:gsub("%d", "")] = {} end

		if self.db.profile.unitFrames[unit:gsub("%d", "")].position then
			frame:SetPoint(unpack(self.db.profile.unitFrames[unit:gsub("%d", "")].position))
		else
			-- No saved position, anchor to the blizzard position
			LoadAddOn("Blizzard_ArenaUI")
			local relativeFrame = _G[anchors.Blizzard.units[unit]] or UIParent
			frame:SetPoint("CENTER", relativeFrame, "CENTER")
		end
		
		frame:SetSize(config.size, config.size)
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
	return GetSpellInfo(debuff[1]), nil, debuff[2], 0, "Magic", 50, GetTime()+50, nil, nil, nil, debuff[1]
end

function BigDebuffs:OnEnable()
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self.interrupts = {}

	-- Prevent OmniCC finish animations
	if OmniCC then
		self:RawHook(OmniCC, "TriggerEffect", function(object, cooldown)
			local name = cooldown:GetName()
			if name and name:find("BigDebuffs") then return end
			self.hooks[OmniCC].TriggerEffect(object, cooldown)
		end, true)
	end

	self:InsertTestDebuff(8122) 	-- Psychic Scream
	self:InsertTestDebuff(408) 		-- Kidney Shot
	self:InsertTestDebuff(30108) 	-- Unstable Affliction
	self:InsertTestDebuff(339) 		-- Entangling Roots
end

function BigDebuffs:PLAYER_ENTERING_WORLD()
	for i = 1, #units do
		self:AttachUnitFrame(units[i])
	end
end

-- For unit frames
function BigDebuffs:GetAuraPriority(name, id)
	if not self.Spells[id] and not self.Spells[name] then return end
	
	id = self.Spells[id] and id or name
	
	-- Make sure category is enabled
	if not self.db.profile.unitFrames[self.Spells[id].type] then return end

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
	if self.interrupts[guid] == nil then
		self.interrupts[guid] = {}
		BigDebuffs:CancelTimer(self.interrupts[guid].timer)
		self.interrupts[guid].timer = BigDebuffs:ScheduleTimer(self.ClearInterruptGUID, 30, self, guid)
	end
	self.interrupts[guid].failed = GetTime()
end

function BigDebuffs:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
	_, subEvent, _, _, _, destGUID, destName, _, spellid, name = ...

	if subEvent ~= "SPELL_CAST_SUCCESS" and subEvent ~= "SPELL_INTERRUPT" then
		return
	end
		
	local unit = self:GetUnitFromGUID(destGUID)
	if not unit then return end
	
	
	-- UnitChannelingInfo and event orders are not the same in WotLK as later expansions, UnitChannelingInfo will always return
	-- nil @ the time of this event (independent of whether something was kicked or not).
	-- We have to track UNIT_SPELLCAST_FAILED for spell failure of the target at the (approx.) same time as we interrupted
	-- this "could" be wrong if the interrupt misses with a <0.01 sec failure window (which depending on server tickrate might
	-- not even be possible)
	if not (subEvent == "SPELL_CAST_SUCCESS" and self.interrupts[destGUID] and 
			self.interrupts[destGUID].failed and GetTime() - self.interrupts[destGUID].failed < 0.01) then
		return
	end
	
	local spelldata = self.Spells[name] and self.Spells[name] or self.Spells[spellid]
	if spelldata == nil or spelldata.type ~= "interrupts" then return end
	local duration = spelldata.interruptduration
   	if not duration then return end
	
	self:UpdateInterrupt(unit, destGUID, spellid, duration)
end

function BigDebuffs:UpdateInterrupt(unit, guid, spellid, duration)
	local t = GetTime()
	-- new interrupt
	if spellid and duration ~= nil then
		if self.interrupts[guid] == nil then self.interrupts[guid] = {} end
		BigDebuffs:CancelTimer(self.interrupts[guid].timer)
		self.interrupts[guid].timer = BigDebuffs:ScheduleTimer(self.ClearInterruptGUID, 30, self, guid)
		self.interrupts[guid][spellid] = {started = t, duration = duration}
	-- old interrupt expiring
	elseif spellid and duration == nil then
		if self.interrupts[guid] and self.interrupts[guid][spellid] and
				t > self.interrupts[guid][spellid].started + self.interrupts[guid][spellid].duration then
			self.interrupts[guid][spellid] = nil
		end
	end
	
	self:UNIT_AURA(nil, unit)
	
	-- clears the interrupt after end of duration
	if duration then
		print("Schedluing removal")
		BigDebuffs:ScheduleTimer(self.UpdateInterrupt, duration+0.1, self, unit, guid, spellid)
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
	if not self.db.profile.unitFrames[unit:gsub("%d", "")] or 
			not self.db.profile.unitFrames[unit:gsub("%d", "")].enabled then 
		return 
	end
	self:AttachUnitFrame(unit)
	
	local frame = self.UnitFrames[unit]
	if not frame then return end
	
	local UnitDebuff = BigDebuffs.test and UnitDebuffTest or UnitDebuff
	
	local now = GetTime()
	local left, priority, duration, expires, icon, debuff, buff, interrupt = 0, 0
	
	for i = 1, 40 do
		-- Check debuffs
		local n,_, ico, _,_, d, e, caster, _,_, id = UnitDebuff(unit, i)
		
		if id then
			if self.Spells[n] or self.Spells[id] then
				local p = self:GetAuraPriority(n, id)
				if p and (p > priority or (p == prio and expires and e < expires)) then
					left = e - now
					duration = d
					debuff = i
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
				local p = self:GetAuraPriority(n, id)
				if p and p >= priority then
					if p and (p > priority or (p == prio and expires and e < expires)) then
						left = e - now
						duration = d
						debuff = i
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
		local p = self:GetAuraPriority(n, id)
		if p and (p > priority or (p == prio and expires and e < expires)) then
			left = e - now
			duration = d
			debuff = 0
			priority = p
			expires = e
			icon = ico
		end
	end
	
	if debuff then
		if duration < 1 then duration = 1 end -- auras like Solar Beam don't have a duration

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
		
		frame.cooldown:SetCooldown(expires - duration, duration)
		frame.cooldownContainer:Show()
		frame:Show()

		frame.current = icon
	else
		-- Adapt
		if frame.anchor and frame.blizzard and Adapt and Adapt.portraits[frame.anchor] then
			Adapt.portraits[frame.anchor].modelLayer:SetFrameStrata("LOW")
		end

		frame:Hide()
		frame.current = nil
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

SLASH_BigDebuffs1 = "/bd"
SLASH_BigDebuffs2 = "/bigdebuffs"
SlashCmdList.BigDebuffs = function(msg)
	LibStub("AceConfigDialog-3.0"):Open("BigDebuffs")
end
