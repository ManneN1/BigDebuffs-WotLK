local addonName = ...
local BigDebuffs = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local order = {
	immunities = 1,
	immunities_spells = 2,
	cc = 3,
	buffs_defensive = 4,
	buffs_offensive = 5,
	buffs_other = 6,
	roots = 7,
}
local SpellNames = {}
local SpellIcons = {}
local Spells = {}
for spellID, spell in pairs(BigDebuffs.Spells) do
	if not spell.parent then
		Spells[spell.type] = Spells[spell.type] or {
			name = L[spell.type],
			type = "group",
			order = order[spell.type],
			args = {},
		}
		local key = "spell"..spellID
		local raidFrames = spell.type == "cc" or spell.type == "roots" or spell.type == "special" or spell.type == "interrupts"
		Spells[spell.type].args[key] = {
			type = "group",
			get = function(info)
				local name = info[#info]
				return BigDebuffs.db.profile.spells[spellID] and BigDebuffs.db.profile.spells[spellID][name]
			end,
			set = function(info, value)
				local name = info[#info]
				BigDebuffs.db.profile.spells[spellID] = BigDebuffs.db.profile.spells[spellID] or {}
				BigDebuffs.db.profile.spells[spellID][name] = value
				BigDebuffs:Refresh()
			end,
			name = function(info) local name = SpellNames[spellID] or GetSpellInfo(spellID) or spellID SpellNames[spellID] = name return name end,
			icon = function() local icon = SpellIcons[spellID] or select(3,GetSpellInfo(spellID)) SpellIcons[spellID] = icon return icon end,
			args = {
				visibility = {
					order = 1,
					type = "group",
					name = L["Visibility"],
					inline = true,
					get = function(info)
						local name = info[#info]
						local value = (BigDebuffs.db.profile.spells[spellID] and BigDebuffs.db.profile.spells[spellID][name]) or
							(not BigDebuffs.Spells[spellID]["no"..name] and 1)
						return value and value == 1
					end,
					set = function(info, value)
						local name = info[#info]
						BigDebuffs.db.profile.spells[spellID] = BigDebuffs.db.profile.spells[spellID] or {}
						value = value and 1 or 0
						BigDebuffs.db.profile.spells[spellID][name] = value

						-- unset if default visibility
						local no = BigDebuffs.Spells[spellID]["no"..name]
						if (value == 1 and not no) or
							(value == 0 and no) then
							BigDebuffs.db.profile.spells[spellID][name] = nil
						end
						BigDebuffs:Refresh()
					end,
					args = {
						unitFrames = {
							type = "toggle",
							name = L["Unit Frames"],
							desc = L["Show this spell on the unit frames"],
							width = "full",
							order = 2
						},
					},
				},
				priority = {
					type = "group",
					inline = true,
					name = L["Priority"],
					args = {
						customPriority = {
							name = L["Custom Priority"],
							type = "toggle",
							order = 2,
							set = function(info, value)
								BigDebuffs.db.profile.spells[spellID] = BigDebuffs.db.profile.spells[spellID] or {}
								BigDebuffs.db.profile.spells[spellID].customPriority = value
								if not value then
									BigDebuffs.db.profile.spells[spellID].priority = nil
								end
								BigDebuffs:Refresh()
							end,
						},
						priority = {
							name = L["Priority"],
							desc = L["Higher priority spells will take precedence regardless of duration"],
							type = "range",
							min = 1,
							max = 100,
							step = 1,
							order = 3,
							disabled = function() return not BigDebuffs.db.profile.spells[spellID] or not BigDebuffs.db.profile.spells[spellID].customPriority end,
							get = function(info)
								-- Pull the category priority
								return BigDebuffs.db.profile.spells[spellID] and BigDebuffs.db.profile.spells[spellID].priority and
									BigDebuffs.db.profile.spells[spellID].priority or
									BigDebuffs.db.profile.priority[spell.type]
							end,
						},
					},
				},
			},
		}
	end
end

function BigDebuffs:SetupOptions()
	self.options = {
		name = "BigDebuffs",
		descStyle = "inline",
		type = "group",
		plugins = {},
		childGroups = "tab",
		args = {
			vers = {
				order = 1,
				type = "description",
				name = "|cffffd700"..L["Version"].."|r "..GetAddOnMetadata(addonName, "Version").."\n",
				cmdHidden = true
			},
			desc = {
				order = 2,
				type = "description",
				name = "|cffffd700 "..L["Author"].."|r "..GetAddOnMetadata(addonName, "Author").."\n",
				cmdHidden = true
			},
			test = {
				type = "execute",
				name = L["Toggle Test Mode"],
				order = 3,
				func = "Test",
				handler = BigDebuffs,
			},
			unitFrames = {
				name = L["Unit Frames"],
				type = "group",
				order = 20,
				disabled = function(info) return info[2] and not self.db.profile[info[1]].enabled end,
				childGroups = "tab",
				get = function(info) local name = info[#info] return self.db.profile.unitFrames[name] end,
				set = function(info, value) local name = info[#info] self.db.profile.unitFrames[name] = value self:Refresh() end,
				args = {
					general = {
						name = "General",
						type = "group",
						order = 10,
						inline = true,
						args = {
							enabled = {
								type = "toggle",
								disabled = false,
								width = "normal",
								name = L["Enabled"],
								desc = L["Enable BigDebuffs on unit frames"],
							},
							cooldownCount = {
								type = "toggle",
								width = "normal",
								name = L["Cooldown Count"],
								desc = L["Allow Blizzard and other addons to display countdown text on the icons"],
							},
						},
					},
					player = {
						type = "group",
						disabled = function(info) return not self.db.profile[info[1]].enabled or (info[3] and not self.db.profile.unitFrames[info[2]].enabled) end,
						get = function(info) local name = info[#info] return self.db.profile.unitFrames.player[name] end,
						set = function(info, value) local name = info[#info] self.db.profile.unitFrames.player[name] = value self:Refresh() self:Refresh() end,
						args = {
                            spells = {
                                order = 20,
                                name = L["Spells"],
                                type = "group",
                                inline = true,
                                args = {
                                    cc = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["cc"],
                                        desc = L["Show Crowd Control on the unit frames"],
                                        order = 1,
                                    },
                                    immunities = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities"],
                                        desc = L["Show Immunities on the unit frames"],
                                        order = 2,
                                    },
                                    interrupts = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["interrupts"],
                                        desc = L["Show Interrupts on the unit frames"],
                                        order = 3,
                                    },
                                    immunities_spells = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities_spells"],
                                        desc = L["Show Spell Immunities on the unit frames"],
                                        order = 4,
                                    },
                                    buffs_defensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_defensive"],
                                        desc = L["Show Defensive Buffs on the unit frames"],
                                        order = 5,
                                    },
                                    buffs_offensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_offensive"],
                                        desc = L["Show Offensive Buffs on the unit frames"],
                                        order = 6,
                                    },
                                    buffs_other = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_other"],
                                        desc = L["Show Other Buffs on the unit frames"],
                                        order = 7,
                                    },
                                    roots = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["roots"],
                                        desc = L["Show Roots on the unit frames"],
                                        order = 8,
                                    },
                                },
                            }, 
							enabled = {
								type = "toggle",
								disabled = function(info) return not self.db.profile[info[1]].enabled end,
								name = L["Enabled"],
								order = 1,
								width = "full",
								desc = L["Enable BigDebuffs on the player frame"],
							},
							anchor = {
								name = L["Anchor"],
								desc = L["Anchor to attach the BigDebuffs frames"],
								type = "select",
								values = {
									["auto"] = L["Automatic"],
									["manual"] = L["Manual"],
								},
								order = 2,
							},
							size = {
								type = "range",
								disabled = function(info) local name = info[2] return not self.db.profile.unitFrames[name].enabled or self.db.profile.unitFrames[name].anchor == "auto" end,
								name = L["Size"],
								desc = L["Set the size of the frame"],
								min = 8,
								max = 512,
								step = 1,
								order = 3,
							},
						},
						name = L["Player Frame"],
						order = 1,
					},
					target = {
						type = "group",
						disabled = function(info) return not self.db.profile[info[1]].enabled or (info[3] and not self.db.profile.unitFrames[info[2]].enabled) end,
						get = function(info) local name = info[#info] return self.db.profile.unitFrames.target[name] end,
						set = function(info, value) local name = info[#info] self.db.profile.unitFrames.target[name] = value self:Refresh() self:Refresh() end,
						args = {
							spells = {
                                order = 20,
                                name = L["Spells"],
                                type = "group",
                                inline = true,
                                args = {
                                    cc = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["cc"],
                                        desc = L["Show Crowd Control on the unit frames"],
                                        order = 1,
                                    },
                                    immunities = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities"],
                                        desc = L["Show Immunities on the unit frames"],
                                        order = 2,
                                    },
                                    interrupts = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["interrupts"],
                                        desc = L["Show Interrupts on the unit frames"],
                                        order = 3,
                                    },
                                    immunities_spells = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities_spells"],
                                        desc = L["Show Spell Immunities on the unit frames"],
                                        order = 4,
                                    },
                                    buffs_defensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_defensive"],
                                        desc = L["Show Defensive Buffs on the unit frames"],
                                        order = 5,
                                    },
                                    buffs_offensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_offensive"],
                                        desc = L["Show Offensive Buffs on the unit frames"],
                                        order = 6,
                                    },
                                    buffs_other = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_other"],
                                        desc = L["Show Other Buffs on the unit frames"],
                                        order = 7,
                                    },
                                    roots = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["roots"],
                                        desc = L["Show Roots on the unit frames"],
                                        order = 8,
                                    },
                                },
                            }, 
                            enabled = {
								type = "toggle",
								disabled = function(info) return not self.db.profile[info[1]].enabled end,
								name = L["Enabled"],
								order = 1,
								width = "full",
								desc = L["Enable BigDebuffs on the target frame"],
							},
							anchor = {
								name = L["Anchor"],
								desc = L["Anchor to attach the BigDebuffs frames"],
								type = "select",
								values = {
									["auto"] = L["Automatic"],
									["manual"] = L["Manual"],
								},
								order = 2,
							},
							size = {
								type = "range",
								disabled = function(info) local name = info[2] return not self.db.profile.unitFrames[name].enabled or self.db.profile.unitFrames[name].anchor == "auto" end,
								name = L["Size"],
								desc = L["Set the size of the frame"],
								min = 8,
								max = 512,
								step = 1,
								order = 3,
							},
						},
						name = L["Target Frame"],
						desc = L["Enable BigDebuffs on the target frame"],
						order = 2,
					},
					focus = {
						type = "group",
						disabled = function(info) return not self.db.profile[info[1]].enabled or (info[3] and not self.db.profile.unitFrames[info[2]].enabled) end,
						get = function(info) local name = info[#info] return self.db.profile.unitFrames.focus[name] end,
						set = function(info, value) local name = info[#info] self.db.profile.unitFrames.focus[name] = value self:Refresh() self:Refresh() end,
						args = {
                            spells = {
                                order = 20,
                                name = L["Spells"],
                                type = "group",
                                inline = true,
                                args = {
                                    cc = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["cc"],
                                        desc = L["Show Crowd Control on the unit frames"],
                                        order = 1,
                                    },
                                    immunities = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities"],
                                        desc = L["Show Immunities on the unit frames"],
                                        order = 2,
                                    },
                                    interrupts = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["interrupts"],
                                        desc = L["Show Interrupts on the unit frames"],
                                        order = 3,
                                    },
                                    immunities_spells = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities_spells"],
                                        desc = L["Show Spell Immunities on the unit frames"],
                                        order = 4,
                                    },
                                    buffs_defensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_defensive"],
                                        desc = L["Show Defensive Buffs on the unit frames"],
                                        order = 5,
                                    },
                                    buffs_offensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_offensive"],
                                        desc = L["Show Offensive Buffs on the unit frames"],
                                        order = 6,
                                    },
                                    buffs_other = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_other"],
                                        desc = L["Show Other Buffs on the unit frames"],
                                        order = 7,
                                    },
                                    roots = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["roots"],
                                        desc = L["Show Roots on the unit frames"],
                                        order = 8,
                                    },
                                },
                            }, 
                        
							enabled = {
								type = "toggle",
								disabled = function(info) return not self.db.profile[info[1]].enabled end,
								name = L["Enabled"],
								order = 1,
								width = "full",
								desc = L["Enable BigDebuffs on the focus frame"],
							},
							anchor = {
								name = L["Anchor"],
								desc = L["Anchor to attach the BigDebuffs frames"],
								type = "select",
								values = {
									["auto"] = L["Automatic"],
									["manual"] = L["Manual"],
								},
								order = 2,
							},
							size = {
								type = "range",
								disabled = function(info) local name = info[2] return not self.db.profile.unitFrames[name].enabled or self.db.profile.unitFrames[name].anchor == "auto" end,
								name = L["Size"],
								desc = L["Set the size of the frame"],
								min = 8,
								max = 512,
								step = 1,
								order = 3,
							},
						},
						name = L["Focus Frame"],
						desc = L["Enable BigDebuffs on the focus frame"],
						order = 3,
					},
					pet = {
						type = "group",
						disabled = function(info) return not self.db.profile[info[1]].enabled or (info[3] and not self.db.profile.unitFrames[info[2]].enabled) end,
						get = function(info) local name = info[#info] return self.db.profile.unitFrames.pet[name] end,
						set = function(info, value) local name = info[#info] self.db.profile.unitFrames.pet[name] = value self:Refresh() self:Refresh() end,
						args = {
							spells = {
                                order = 20,
                                name = L["Spells"],
                                type = "group",
                                inline = true,
                                args = {
                                    cc = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["cc"],
                                        desc = L["Show Crowd Control on the unit frames"],
                                        order = 1,
                                    },
                                    immunities = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities"],
                                        desc = L["Show Immunities on the unit frames"],
                                        order = 2,
                                    },
                                    interrupts = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["interrupts"],
                                        desc = L["Show Interrupts on the unit frames"],
                                        order = 3,
                                    },
                                    immunities_spells = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities_spells"],
                                        desc = L["Show Spell Immunities on the unit frames"],
                                        order = 4,
                                    },
                                    buffs_defensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_defensive"],
                                        desc = L["Show Defensive Buffs on the unit frames"],
                                        order = 5,
                                    },
                                    buffs_offensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_offensive"],
                                        desc = L["Show Offensive Buffs on the unit frames"],
                                        order = 6,
                                    },
                                    buffs_other = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_other"],
                                        desc = L["Show Other Buffs on the unit frames"],
                                        order = 7,
                                    },
                                    roots = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["roots"],
                                        desc = L["Show Roots on the unit frames"],
                                        order = 8,
                                    },
                                },
                            }, 
                            enabled = {
								type = "toggle",
								disabled = function(info) return not self.db.profile[info[1]].enabled end,
								name = L["Enabled"],
								order = 1,
								width = "full",
								desc = L["Enable BigDebuffs on the pet frame"],
							},
							anchor = {
								name = L["Anchor"],
								desc = L["Anchor to attach the BigDebuffs frames"],
								type = "select",
								values = {
									["auto"] = L["Automatic"],
									["manual"] = L["Manual"],
								},
								order = 2,
							},
							size = {
								type = "range",
								disabled = function(info) local name = info[2] return not self.db.profile.unitFrames[name].enabled or self.db.profile.unitFrames[name].anchor == "auto" end,
								name = L["Size"],
								desc = L["Set the size of the frame"],
								min = 8,
								max = 512,
								step = 1,
								order = 3,
							},
						},
						name = L["Pet Frame"],
						desc = L["Enable BigDebuffs on the pet frame"],
						order = 4,
					},
					party = {
						type = "group",
						disabled = function(info) return not self.db.profile[info[1]].enabled or (info[3] and not self.db.profile.unitFrames[info[2]].enabled) end,
						get = function(info) local name = info[#info] return self.db.profile.unitFrames.party[name] end,
						set = function(info, value) local name = info[#info] self.db.profile.unitFrames.party[name] = value self:Refresh() self:Refresh() end,
						args = {
							spells = {
                                order = 20,
                                name = L["Spells"],
                                type = "group",
                                inline = true,
                                args = {
                                    cc = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["cc"],
                                        desc = L["Show Crowd Control on the unit frames"],
                                        order = 1,
                                    },
                                    immunities = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities"],
                                        desc = L["Show Immunities on the unit frames"],
                                        order = 2,
                                    },
                                    interrupts = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["interrupts"],
                                        desc = L["Show Interrupts on the unit frames"],
                                        order = 3,
                                    },
                                    immunities_spells = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities_spells"],
                                        desc = L["Show Spell Immunities on the unit frames"],
                                        order = 4,
                                    },
                                    buffs_defensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_defensive"],
                                        desc = L["Show Defensive Buffs on the unit frames"],
                                        order = 5,
                                    },
                                    buffs_offensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_offensive"],
                                        desc = L["Show Offensive Buffs on the unit frames"],
                                        order = 6,
                                    },
                                    buffs_other = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_other"],
                                        desc = L["Show Other Buffs on the unit frames"],
                                        order = 7,
                                    },
                                    roots = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["roots"],
                                        desc = L["Show Roots on the unit frames"],
                                        order = 8,
                                    },
                                },
                            },
                            enabled = {
								type = "toggle",
								disabled = function(info) return not self.db.profile[info[1]].enabled end,
								name = L["Enabled"],
								order = 1,
								width = "full",
								desc = L["Enable BigDebuffs on the party frames"],
							},
							anchor = {
								name = L["Anchor"],
								desc = L["Anchor to attach the BigDebuffs frames"],
								type = "select",
								values = {
									["auto"] = L["Automatic"],
									["manual"] = L["Manual"],
								},
								order = 2,
							},
							size = {
								type = "range",
								disabled = function(info) local name = info[2] return not self.db.profile.unitFrames[name].enabled or self.db.profile.unitFrames[name].anchor == "auto" end,
								name = L["Size"],
								desc = L["Set the size of the frame"],
								min = 8,
								max = 512,
								step = 1,
								order = 3,
							},
						},
						name = L["Party Frames"],
						desc = L["Enable BigDebuffs on the party frames"],
						order = 5,
					},
					arena = {
						type = "group",
						disabled = function(info) return not self.db.profile[info[1]].enabled or (info[3] and not self.db.profile.unitFrames[info[2]].enabled) end,
						get = function(info) local name = info[#info] return self.db.profile.unitFrames.arena[name] end,
						set = function(info, value) local name = info[#info] self.db.profile.unitFrames.arena[name] = value self:Refresh() self:Refresh() end,
						args = {
							spells = {
                                order = 20,
                                name = L["Spells"],
                                type = "group",
                                inline = true,
                                args = {
                                    cc = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["cc"],
                                        desc = L["Show Crowd Control on the unit frames"],
                                        order = 1,
                                    },
                                    immunities = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities"],
                                        desc = L["Show Immunities on the unit frames"],
                                        order = 2,
                                    },
                                    interrupts = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["interrupts"],
                                        desc = L["Show Interrupts on the unit frames"],
                                        order = 3,
                                    },
                                    immunities_spells = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["immunities_spells"],
                                        desc = L["Show Spell Immunities on the unit frames"],
                                        order = 4,
                                    },
                                    buffs_defensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_defensive"],
                                        desc = L["Show Defensive Buffs on the unit frames"],
                                        order = 5,
                                    },
                                    buffs_offensive = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_offensive"],
                                        desc = L["Show Offensive Buffs on the unit frames"],
                                        order = 6,
                                    },
                                    buffs_other = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["buffs_other"],
                                        desc = L["Show Other Buffs on the unit frames"],
                                        order = 7,
                                    },
                                    roots = {
                                        type = "toggle",
                                        width = "normal",
                                        name = L["roots"],
                                        desc = L["Show Roots on the unit frames"],
                                        order = 8,
                                    },
                                },
                            },
                            enabled = {
								type = "toggle",
								disabled = function(info) return not self.db.profile[info[1]].enabled end,
								name = L["Enabled"],
								order = 1,
								width = "full",
								desc = L["Enable BigDebuffs on the arena frames"],
							},
							anchor = {
								name = L["Anchor"],
								desc = L["Anchor to attach the BigDebuffs frames"],
								type = "select",
								values = {
									["auto"] = L["Automatic"],
									["manual"] = L["Manual"],
								},
								order = 2,
							},
							size = {
								type = "range",
								disabled = function(info) local name = info[2] return not self.db.profile.unitFrames[name].enabled or self.db.profile.unitFrames[name].anchor == "auto" end,
								name = L["Size"],
								desc = L["Set the size of the frame"],
								min = 8,
								max = 512,
								step = 1,
								order = 3,
							},
						},
						name = L["Arena Frames"],
						desc = L["Enable BigDebuffs on the arena frames"],
						order = 6,
					},
                },
			},
			spells = {
				name = L["Spells"],
				type = "group",
				childGroups = "tab",
				order = 40,
				args = Spells,
			},
		}
	}

	self.options.args.priority = {
		name = L["Priority"],
		type = "group",
		get = function(info) local name = info[#info] return self.db.profile.priority[name] end,
		set = function(info, value) local name = info[#info] self.db.profile.priority[name] = value self:Refresh() end,
		order = 30,
		args = {
			immunities = {
				type = "range",
				width = "double",
				name = L["immunities"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 10,
			},
			immunities_spells = {
				type = "range",
				width = "double",
				name = L["immunities_spells"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 11,
			},
			cc = {
				type = "range",
				width = "double",
				name = L["cc"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 12,
			},
			interrupts = {
				type = "range",
				width = "double",
				name = L["interrupts"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 13,
			},
			buffs_defensive = {
				type = "range",
				width = "double",
				name = L["buffs_defensive"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 14,
			},
			buffs_offensive = {
				type = "range",
				width = "double",
				name = L["buffs_offensive"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 15,
			},
			buffs_other = {
				type = "range",
				width = "double",
				name = L["buffs_other"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 16,
			},
			roots = {
				type = "range",
				width = "double",
				name = L["roots"],
				desc = L["Higher priority spells will take precedence regardless of duration"],
				min = 1,
				max = 100,
				step = 1,
				order = 17,
			},
		},
	}

	self.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) }
	
	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, addonName.."DB")
	LibDualSpec:EnhanceOptions(self.options.plugins.profiles.profiles, self.db)

	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.options)
end
