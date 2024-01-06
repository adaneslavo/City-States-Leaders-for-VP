print("This is the modded CityStateDiploPopup from 'Global - City State Gifts'")

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- City State Diplo Popup
--
-- Authors: Anton Strenger
--
-- Modified for CSL: adan_eslavo
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

include( "IconSupport" )
include( "InfoTooltipInclude" )
include( "CityStateStatusHelper" )

local g_iMinorCivID = -1
local g_iMinorCivTeamID = -1
local m_PopupInfo = nil
local m_bNewQuestAvailable = false
local WordWrapOffset = 19
local WordWrapAnimOffset = 3

local kiNoAction = 0
local kiMadePeace = 1
local kiBulliedGold = 2
local kiBulliedUnit = 3
local kiGiftedGold = 4
local kiPledgedToProtect = 5
local kiDeclaredWar = 6
local kiRevokedProtection = 7
-- CBP
local kiBullyAnnexed = 8
-- END
local m_iLastAction = kiNoAction
local m_iPendingAction = kiNoAction -- For bullying dialog popups

-- adan_eslavo -->
local kiGreet = 9

local iRandomPersonalityText
local iRandomTraitText
local iRandomBonusText
local iRandomFriendshipText
local iRandomVisitText

local table_insert = table.insert
local table_concat = table.concat
local L = Locale.ConvertTextKey
-- adan_eslavo <--

--================================================================================--
-- HANDLERS AND HELPERS
--================================================================================--
function SetButtonSize(textControl, buttonControl, animControl, buttonHL)
    local sizeY = textControl:GetSizeY() + WordWrapOffset

	buttonControl:SetSizeY(sizeY)
	animControl:SetSizeY(sizeY + WordWrapAnimOffset)
	buttonHL:SetSizeY(sizeY + WordWrapAnimOffset)
end

function UpdateButtonStack()
	Controls.GiveStack:CalculateSize()
    Controls.GiveStack:ReprocessAnchoring()

	--CSD
	--Controls.GiveStackCSD:CalculateSize()
    --Controls.GiveStackCSD:ReprocessAnchoring()
    
    Controls.TakeStack:CalculateSize()
    Controls.TakeStack:ReprocessAnchoring()
    
    Controls.ButtonStack:CalculateSize()
    Controls.ButtonStack:ReprocessAnchoring()
    
	Controls.ButtonScrollPanel:CalculateInternalSize()
end

function InputHandler(uiMsg, wParam, lParam)
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
			if (Controls.BullyConfirm:IsHidden()) then
	            OnCloseButtonClicked()
			else
				m_iPendingAction = kiNoAction
				Controls.BullyConfirm:SetHide(true)
            	Controls.BGBlock:SetHide(false)
			end
			
			return true
        end
    end
end
ContextPtr:SetInputHandler(InputHandler)

function ShowHideHandler(bIsHide, bInitState)
    if not bInitState then
 	   Controls.BackgroundImage:UnloadTexture()
       
       if not bIsHide then
			-- adan_eslavo -->
        	Events.SerialEventGameDataDirty.Add(OnDisplay)
			Events.WarStateChanged.Add(OnDisplay)			-- bc1 hack to force refresh in vanilla when selecting peace / war
			
			iRandomPersonalityText = tostring(math.random(7))
			iRandomTraitText = tostring(math.random(7))
			iRandomBonusText = tostring(math.random(7))
			iRandomFriendshipText = tostring(math.random(8))
			iRandomVisitText = tostring(math.random(10))

			OnDisplay()
        	-- adan_eslavo <--
        	
        	UI.incTurnTimerSemaphore()
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo)
        else
            -- adan_eslavo -->
            Events.SerialEventGameDataDirty.Remove(OnDisplay)
			Events.WarStateChanged.Remove(OnDisplay)
            -- adan_eslavo <--
            
            UI.decTurnTimerSemaphore()
            
            if(m_PopupInfo ~= nil) then
				Events.SerialEventGameMessagePopupProcessed.CallImmediate(m_PopupInfo.Type, 0)
			end
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler )

-------------------------------------------------
-- On Event Received
-------------------------------------------------
function OnEventReceived(popupInfo)
	local bGreeting = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_GREETING
	local bMessage = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_MESSAGE
	local bDiplo = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO
	
	-- adan_eslavo -->
	if bMessage or bDiplo then
		m_iLastAction = kiNoAction
	elseif bGreeting then
		m_iLastAction = kiGreet
	else
		return
	end
	-- adan_eslavo <--
	
	m_PopupInfo = popupInfo	
	
    local iPlayer = popupInfo.Data1
    local pPlayer = Players[iPlayer]
	local iTeam = pPlayer:GetTeam()
	local pTeam = Teams[iTeam]
	
	local iQuestFlags = popupInfo.Data2
    
    g_iMinorCivID = iPlayer
    g_iMinorCivTeamID = iTeam
	
	m_iPendingAction = kiNoAction
	
	m_bNewQuestAvailable = iQuestFlags == 1
	
	UIManager:QueuePopup(ContextPtr, PopupPriority.CityStateDiplo)
end
Events.SerialEventGameMessagePopup.Add(OnEventReceived)

-------------------------------------------------
-- On Game Info Dirty
-------------------------------------------------
function OnGameDataDirty()
	if ContextPtr:IsHidden() then
		return
	end
	
	OnDisplay()
end
Events.SerialEventGameDataDirty.Add(OnGameDataDirty)

-------------------------------------------------
-- On Display
-------------------------------------------------
-- adan_eslavo -->
function OnDisplay()
	local activePlayerID = Game.GetActivePlayer()
	local activePlayer = Players[activePlayerID]
	local activeTeamID = Game.GetActiveTeam()
	local activeTeam = Teams[activeTeamID]

	local minorPlayerID = g_iMinorCivID
	local minorPlayer = Players[minorPlayerID]
	local minorTeamID = g_iMinorCivTeamID
	local minorTeam = Teams[minorTeamID]
	local minorCivType = minorPlayer:GetMinorCivType()

	local strShortDescKey = minorPlayer:GetCivilizationShortDescriptionKey()

	local isAllies = minorPlayer:IsAllies(activePlayerID)
	local isFriends = minorPlayer:IsFriends(activePlayerID)

	-- At war?
	local isAtWar = activeTeam:IsAtWar(minorTeamID)

	-- Update colors
	local primaryColor, secondaryColor = minorPlayer:GetPlayerColors()
	primaryColor, secondaryColor = secondaryColor, primaryColor
	local textColor = {x = primaryColor.x, y = primaryColor.y, z = primaryColor.z, w = 1}

	-- Title
	strTitle = L("{"..strShortDescKey..":upper}")
	Controls.TitleLabel:SetText(strTitle)
	Controls.TitleLabel:SetColor(textColor, 0)

	civType = minorPlayer:GetCivilizationType()
	civInfo = GameInfo.Civilizations[civType]

	local trait = GameInfo.MinorCivilizations[minorCivType].MinorCivTrait
	local strTraitText = GetCityStateTraitText(minorPlayerID)
	local strTraitTT = GetCityStateTraitToolTip(minorPlayerID)
	local traitIcon = nil
	
	traitIcon = "CityStatePopupTopCSLBNW".. strTraitText ..".dds"

	local leaderIcon = nil
	local leaderPlace = nil
	local leaderName = nil
	local leaderNameTT = nil
	local leaderTitle = nil
	local artistName = nil

	if minorCivType ~= nil then
		local realMinorCivType = GameInfo.MinorCivilizations[minorCivType].Type
		
		if realMinorCivType ~= nil then
			local condition = "Type = '".. realMinorCivType .."'"
			
			for row in GameInfo.MinorCivLeaders(condition) do
				leaderIcon = row.LeaderIcon
				leaderPlace = row.LeaderPlace
				leaderName = row.LeaderName
				leaderTitle = row.LeaderTitle
				artistName = row.LeaderArtistName
			end
		end

		if leaderIcon ~= nil and leaderName ~= nil then
			if leaderPlace == nil then
				leaderPlace = L(strShortDescKey)
			end
			
			if leaderTitle ~= nil then
				leaderName = leaderTitle .. " " .. leaderName
			end
			
			leaderName = L("TXT_KEY_CSL_POPUP_LEADER", leaderName, leaderPlace)
			local leaderNameTag = "TXT_KEY_CSL_LEADER_SHORT_" .. realMinorCivType
			
			if L(leaderNameTag) == leaderNameTag then
				leaderNameTT = nil
			else
				leaderNameTT = L(leaderNameTag)
			end
			
			Controls.TitleIconCSLTrait:SetHide(false)
			Controls.TitleIconCSLTrait:SetTexture(traitIcon)
			Controls.TitleIconCSL:SetHide(false)
			Controls.TitleIconCSL:SetTexture(leaderIcon)
			Controls.LeaderLabel:LocalizeAndSetText(leaderName)
			if leaderNameTT then Controls.LeaderLabel:SetToolTipString(leaderNameTT) else Controls.LeaderLabel:SetToolTipString() end
			Controls.ArtistLabel:LocalizeAndSetText(artistName)
		else
			Controls.TitleIconCSLTrait:SetHide(false)
			Controls.TitleIconCSLTrait:SetTexture(traitIcon)
			Controls.TitleIconCSL:SetHide(true)
			Controls.TitleIconCSLBG:SetTexture(GameInfo.MinorCivTraits[trait].TraitTitleIcon)
			Controls.LeaderLabel:LocalizeAndSetText("")
			Controls.ArtistLabel:LocalizeAndSetText("")
		end
	end

	Controls.BackgroundImage:SetTexture(GameInfo.MinorCivTraits[trait].BackgroundImage)
	Controls.BackgroundImage:SetAlpha(0.65)

	local iconColor = textColor
	IconHookup(civInfo.PortraitIndex, 32, civInfo.AlphaIconAtlas, Controls.CivIcon)
	Controls.CivIcon:SetColor(iconColor)
	
	local isAtWar = activeTeam:IsAtWar(minorTeamID)
	local majorInfluenceWithMinor = minorPlayer:GetMinorCivFriendshipWithMajor(activePlayerID)
	
	local strStatusText = GetCityStateStatusText(activePlayerID, minorPlayerID)
	
	if not isAtWar then
		-- Influence
		strStatusText = strStatusText .. " " .. majorInfluenceWithMinor .. " [ICON_INFLUENCE]"
		
		-- Anchor
		local iCurrentAnchorLevelWithMinor = minorPlayer:GetMinorCivFriendshipAnchorWithMajor(activePlayerID)
		
		-- Merging...
		if majorInfluenceWithMinor ~= iCurrentAnchorLevelWithMinor then
			local sAnchor = ""
			
			if iCurrentAnchorLevelWithMinor < 0 then
				sAnchor = "[COLOR_NEGATIVE_TEXT]" .. iCurrentAnchorLevelWithMinor .. "[ENDCOLOR]"
			elseif iCurrentAnchorLevelWithMinor > 0 then
				sAnchor = "[COLOR_POSITIVE_TEXT]" .. iCurrentAnchorLevelWithMinor .. "[ENDCOLOR]"
			else
				sAnchor = iCurrentAnchorLevelWithMinor
			end
				
			strStatusText = strStatusText .. (" (%+2.2g [ICON_INFLUENCE] / "):format(minorPlayer:GetFriendshipChangePerTurnTimes100(activePlayerID) / 100) .. L("TXT_KEY_DO_TURN") .. ": " .. sAnchor .. " [ICON_INFLUENCE])"
		end
	end
		
	local strStatusTT = GetCityStateStatusToolTip(activePlayerID, minorPlayerID, true)
	
	UpdateCityStateStatusUI(activePlayerID, minorPlayerID, Controls.PositiveStatusMeter, Controls.NegativeStatusMeter, Controls.StatusMeterMarker, Controls.StatusIconBG)
	
	Controls.StatusInfo:SetText(strStatusText)
	Controls.StatusInfo:SetToolTipString(strStatusTT)
	Controls.StatusLabel:SetToolTipString(strStatusTT)
	Controls.StatusIconBG:SetToolTipString(strStatusTT)
	Controls.PositiveStatusMeter:SetToolTipString(strStatusTT)
	Controls.NegativeStatusMeter:SetToolTipString(strStatusTT)
	Controls.MarriedButton:SetHide(true)
	
	if minorPlayer:IsMarried(activePlayerID) then
		Controls.MarriedButton:SetHide(false)
		Controls.MarriedButton:SetText(L("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_MARRIED_SMALL"))
		Controls.MarriedButton:SetToolTipString(L("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_MARRIED_TT"))
	end

	if strTraitText == L("TXT_KEY_CITY_STATE_CULTURED_ADJECTIVE") then
		strTraitText = "[ICON_CULTURE] [COLOR_MAGENTA]".. strTraitText .."[ENDCOLOR]"
	elseif strTraitText == L("TXT_KEY_CITY_STATE_MILITARISTIC_ADJECTIVE") then
		strTraitText = "[ICON_WAR] [COLOR_YIELD_FOOD]".. strTraitText .."[ENDCOLOR]"
	elseif strTraitText == L("TXT_KEY_CITY_STATE_MARITIME_ADJECTIVE") then
		strTraitText = "[ICON_FOOD] [COLOR:105:205:0:255]".. strTraitText .."[ENDCOLOR]"
	elseif strTraitText == L("TXT_KEY_CITY_STATE_MERCANTILE_ADJECTIVE") then
		strTraitText = "[ICON_GOLD] [COLOR_YELLOW]".. strTraitText .."[ENDCOLOR]"
	elseif strTraitText == L("TXT_KEY_CITY_STATE_RELIGIOUS_ADJECTIVE") then
		strTraitText = "[ICON_PEACE] [COLOR_WHITE]".. strTraitText .."[ENDCOLOR]"
	end
	
	Controls.TraitInfo:SetText(strTraitText)
	Controls.TraitInfo:SetToolTipString(strTraitTT)
	Controls.TraitLabel:SetToolTipString(strTraitTT)

	-- Personality
	local strPersonalityText = ""
	local strPersonalityTT = ""
	local iPersonality = minorPlayer:GetPersonality()
	
	if iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY then
		strPersonalityText = "[ICON_FLOWER] [COLOR:205:255:105:255]".. L("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY") .."[ENDCOLOR]"
		strPersonalityTT = L("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY_TT")
	elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL then
		strPersonalityText = "[ICON_TEAM_1] [COLOR_WHITE]".. L("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL") .."[ENDCOLOR]"
		strPersonalityTT = L("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL_TT")
	elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE then
		strPersonalityText = "[ICON_RAZING] [COLOR_RED]".. L("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE") .."[ENDCOLOR]"
		strPersonalityTT = L("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE_TT")
	elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_IRRATIONAL then
		strPersonalityText = "[ICON_INQUISITOR] [COLOR:240:105:255:255]".. L("TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL") .."[ENDCOLOR]"
		strPersonalityTT = L("TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL_TT")
	end
	
	Controls.PersonalityInfo:SetText(strPersonalityText)
	Controls.PersonalityInfo:SetToolTipString(strPersonalityTT)
	Controls.PersonalityLabel:SetToolTipString(strPersonalityTT)

	-- Ally Status
	local iAlly = minorPlayer:GetAlly()
	local strAllyTT = ""
	local strAlly = ""
	local bHideIcon = true
	local bHideText = true
	
	if iAlly ~= nil and iAlly ~= -1 then
		local iAllyInf = minorPlayer:GetMinorCivFriendshipWithMajor(iAlly)
		local iActivePlayerInf = minorPlayer:GetMinorCivFriendshipWithMajor(activePlayerID)

		if iAlly ~= activePlayerID then
			if Teams[Players[iAlly]:GetTeam()]:IsHasMet(Game.GetActiveTeam()) then
				local iInfUntilAllied = iAllyInf - iActivePlayerInf + 1 -- needs to pass up the current ally, not just match
				
				strAllyTT = L("TXT_KEY_CITY_STATE_ALLY_TT", Players[iAlly]:GetCivilizationShortDescriptionKey(), iInfUntilAllied)
				bHideIcon = false
				
				CivIconHookup(iAlly, 32, Controls.AllyIcon, Controls.AllyIconBG, Controls.AllyIconShadow, false, true)
			else
				local iInfUntilAllied = iAllyInf - iActivePlayerInf + 1 -- needs to pass up the current ally, not just match
				
				strAllyTT = L("TXT_KEY_CITY_STATE_ALLY_UNKNOWN_TT", iInfUntilAllied)
				bHideIcon = false
				
				CivIconHookup(-1, 32, Controls.AllyIcon, Controls.AllyIconBG, Controls.AllyIconShadow, false, true)
			end
		else
			strAllyTT = L("TXT_KEY_CITY_STATE_ALLY_ACTIVE_PLAYER_TT")
			bHideText = false
			strAlly = "[COLOR_POSITIVE_TEXT]" .. L("TXT_KEY_YOU") .. "[ENDCOLOR]"
		end
	else
		local iActivePlayerInf = minorPlayer:GetMinorCivFriendshipWithMajor(activePlayerID)
		local iInfUntilAllied = GameDefines["FRIENDSHIP_THRESHOLD_ALLIES"] - iActivePlayerInf
		
		strAllyTT = L("TXT_KEY_CITY_STATE_ALLY_NOBODY_TT", iInfUntilAllied)
		bHideText = false
		strAlly = L("TXT_KEY_CITY_STATE_NOBODY")
	end
	
	if Game.IsResolutionPassed(GameInfoTypes.RESOLUTION_SPHERE_OF_INFLUENCE, minorPlayerID) then
		bHideText = false
		local sIconLocked = not bHideIcon and "      [ICON_LOCKED]" or " [ICON_LOCKED]"
		strAlly = strAlly .. sIconLocked
		strAllyTT = strAllyTT .. "[NEWLINE][NEWLINE]" .. L("TXT_KEY_CSL_POPUP_UNDER_SOI_TT")
	end

	Controls.AllyText:SetText(strAlly)
	Controls.AllyIcon:SetToolTipString(strAllyTT)
	Controls.AllyIconBG:SetToolTipString(strAllyTT)
	Controls.AllyIconShadow:SetToolTipString(strAllyTT)
	Controls.AllyText:SetToolTipString(strAllyTT)
	Controls.AllyLabel:SetToolTipString(strAllyTT)

	Controls.AllyIconContainer:SetHide(bHideIcon)
	Controls.AllyText:SetHide(bHideText)
	
	-- Protector
	local sProtectingPlayers = GetProtectingPlayers(minorPlayerID)

	if sProtectingPlayers ~= "" then
		Controls.ProtectInfo:SetText("[COLOR_POSITIVE_TEXT]" .. sProtectingPlayers .. "[ENDCOLOR]")
	else
		Controls.ProtectInfo:SetText(L("TXT_KEY_CITY_STATE_NOBODY"))
	end

	Controls.ProtectInfo:SetToolTipString(L("TXT_KEY_POP_CSTATE_PROTECTED_BY_TT"))
	Controls.ProtectLabel:SetToolTipString(L("TXT_KEY_POP_CSTATE_PROTECTED_BY_TT"))
	
	-- Contender
	Controls.ContenderInfo:SetText(GetContenderInfo(activePlayerID, minorPlayerID))
	Controls.ContenderInfo:SetToolTipString(GetContenderInfoTT(activePlayerID, minorPlayerID))
	
	-- Nearby Resources
	local pCapital = minorPlayer:GetCapitalCity()
	
	if pCapital then
		local tResourceBonus, tResourceLuxury, tResourceStrategic = {}, {}, {}
			
		for city in minorPlayer:Cities() do
			local thisX = city:GetX()
			local thisY = city:GetY()

			local bShowBonusResources = GameInfo.Community{Type="CSL-BONUS-ON"}().Value == 1
			local iRange = GameDefines.MINOR_CIV_RESOURCE_SEARCH_RADIUS or 5
			local iCloseRange = math.floor(iRange / 2)
			
			for iDX = -iRange, iRange, 1 do
				for iDY = -iRange, iRange, 1 do
					local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY)

					if pTargetPlot ~= nil then
						local iOwner = pTargetPlot:GetOwner()

						if iOwner == minorPlayerID or iOwner == -1 then
							local plotX = pTargetPlot:GetX()
							local plotY = pTargetPlot:GetY()
							local plotDistance = Map.PlotDistance(thisX, thisY, plotX, plotY)

							if plotDistance <= iRange and (plotDistance <= iCloseRange or iOwner == minorPlayerID) then
								local iResourceType = pTargetPlot:GetResourceType(Game.GetActiveTeam())

								if iResourceType ~= -1 then
									if bShowBonusResources or Game.GetResourceUsageType(iResourceType) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS then
										local sResourceClass = GameInfo.Resources[iResourceType].ResourceClassType
										local iNumResourceOnTargetPlot = pTargetPlot:GetNumResource()
										
										if sResourceClass == "RESOURCECLASS_LUXURY" then	
											if tResourceLuxury[iResourceType] == nil then
												tResourceLuxury[iResourceType] = 0
											end
											
											tResourceLuxury[iResourceType] = tResourceLuxury[iResourceType] + iNumResourceOnTargetPlot
										elseif sResourceClass == "RESOURCECLASS_BONUS" then
											if tResourceBonus[iResourceType] == nil then
												tResourceBonus[iResourceType] = 0
											end
											
											tResourceBonus[iResourceType] = tResourceBonus[iResourceType] + iNumResourceOnTargetPlot
										else
											if tResourceStrategic[iResourceType] == nil then
												tResourceStrategic[iResourceType] = 0
											end
											
											tResourceStrategic[iResourceType] = tResourceStrategic[iResourceType] + iNumResourceOnTargetPlot
										end	
									end
								end
							end
						end
					end
				end
			end
		end

		-- making a complete table
		local tResourceList = {}
		local iNumResourcesFound = 0
		local strResourceText = ""
			
		for iResourceType, iAmount in pairs(tResourceStrategic) do
			table.insert(tResourceList, {0, iResourceType, iAmount})
		end

		for iResourceType, iAmount in pairs(tResourceLuxury) do
			table.insert(tResourceList, {1, iResourceType, iAmount})
		end

		for iResourceType, iAmount in pairs(tResourceBonus) do
			table.insert(tResourceList, {2, iResourceType, iAmount})
		end
		
		-- sorting a complete table
		table.sort(tResourceList, function (a, b) 
			if a[1] ~= b[1] then
				return a[1] < b[1]
			else
				if a[3] ~= b[3] then
					return a[3] > b[3]
				else
					if a[2] ~= b[2] then
						local sNameA = L(GameInfo.Resources[a[2]].Description)
						local sNameB = L(GameInfo.Resources[b[2]].Description)
					
						return sNameA < sNameB
					end
				end
			end
		end)

		-- showing the list on display
		for i = 1, #tResourceList do
			local pResource = GameInfo.Resources[tResourceList[i][2]]
					
			if iNumResourcesFound > 0 then
				strResourceText = strResourceText .. " "
			end	
			
			if pResource.ResourceClassType == "RESOURCECLASS_LUXURY" then	
				strResourceText = strResourceText .. L("TXT_KEY_CSL_POPUP_RESOURCE_LIST", pResource.IconString, "[COLOR:205:205:0:255]", L(pResource.Description), tResourceList[i][3])
			elseif pResource.ResourceClassType == "RESOURCECLASS_BONUS" then
				strResourceText = strResourceText .. L("TXT_KEY_CSL_POPUP_RESOURCE_LIST", pResource.IconString, "[COLOR:0:205:105:255]", L(pResource.Description), tResourceList[i][3])
			else
				strResourceText = strResourceText .. L("TXT_KEY_CSL_POPUP_RESOURCE_LIST", pResource.IconString, "[COLOR:0:155:255:255]", L(pResource.Description), tResourceList[i][3])
			end			
			
			iNumResourcesFound = iNumResourcesFound + 1
		end

		Controls.ResourcesInfo:SetText(strResourceText)

		Controls.ResourcesLabel:SetHide(false)
		Controls.ResourcesInfo:SetHide(false)

		local strResourceTextTT = L("TXT_KEY_CITY_STATE_RESOURCES_TT")
		
		Controls.ResourcesInfo:SetToolTipString(strResourceTextTT)
		Controls.ResourcesLabel:SetToolTipString(strResourceTextTT)

	else
		Controls.ResourcesLabel:SetHide(true)
		Controls.ResourcesInfo:SetHide(true)
	end

	-- Body text
	local strText

	-- Active Quests
	UpdateActiveQuests()

	-- UCS Info Tab
	local sUCSInfoHide = true
	local tUCSBonuses = {}
	
	for option in GameInfo.Community{Type="CSL-UCS"} do
		if option.Value == 1 then
			sUCSInfoHide = false
			break
		end
	end

	local sUCSInfoTitle = L("TXT_KEY_CSL_POPUP_UCS_MAIN_TEXT")
	local sUCSInfoTT = L("TXT_KEY_CSL_POPUP_UCS_TOOLTIP_TITLE")
	local sNoUCSBonusesFound = L("TXT_KEY_CSL_POPUP_UCS_NO_BONUS_FOUND")
	local sTextEnableUCS = L("TXT_KEY_CSL_POPUP_UCS_NO_UCS_FOUND")
	local bBonusFound = false
	
	table_insert(tUCSBonuses, sUCSInfoTT)
	
	local pUCSActivePlayer = Players[Game.GetActivePlayer()]
	
	for eUCSPlayer, pUCSPlayer in ipairs(Players) do
		if pUCSPlayer and pUCSPlayer:IsAlive() then
			if pUCSPlayer:IsMinorCiv() then
				local sMinorType = GameInfo.MinorCivilizations[pUCSPlayer:GetMinorCivType()].Type
				
				if pUCSActivePlayer:GetEventChoiceCooldown(GameInfoTypes["PLAYER_EVENT_CHOICE_" .. GameInfo.MinorCivilizations[pUCSPlayer:GetMinorCivType()].Type]) ~= 0 then
					table_insert(tUCSBonuses, "[ICON_BULLET][COLOR_CYAN]" .. pUCSPlayer:GetName() .. ":[ENDCOLOR] " .. L("TXT_KEY_CSTRAIT_" .. sMinorType))
					bBonusFound = true
				end
			end
		end
	end

	if not bBonusFound then
		table_insert(tUCSBonuses, sNoUCSBonusesFound)
	end
	
	Controls.UCSInfo:SetHide(false)
	
	if sUCSInfoHide == false then
		Controls.UCSInfo:SetText("")
		Controls.UCSLabel:SetText(sUCSInfoTitle)
		Controls.UCSInfo:SetToolTipString(table_concat(tUCSBonuses, ""))
		Controls.UCSLabel:SetToolTipString(table_concat(tUCSBonuses, ""))
	else
		Controls.UCSInfo:SetText("")
		Controls.UCSLabel:SetText(sUCSInfoTitle)
		Controls.UCSInfo:SetToolTipString(sTextEnableUCS)
		Controls.UCSLabel:SetToolTipString(sTextEnableUCS)
	end

	-- Peace
	if not isAtWar then
		-- Gifts
		if m_iLastAction == kiGreet then
			local bFirstMajorCiv = m_PopupInfo.Option1
			local sRandPersonality1, sRandPersonality2, sRandTrait1, sRandTrait2, sRandBonus1, sRandBonus2, sRandFriendship, strGiftString = "", "", "", "", "", "", "", ""

			if iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY then
				sRandFriendship = string.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP_FRIENDLY_%s", iRandomFriendshipText)
				sRandPersonality1 = string.format("TXT_KEY_CITY_STATE_GREETING_FRIENDLY_%s", iRandomPersonalityText)
				sRandPersonality2 = Locale.Lookup(sRandPersonality1, leaderPlace)
			elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL then
				sRandFriendship = string.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP_NEUTRAL_%s", iRandomFriendshipText)
				sRandPersonality1 = string.format("TXT_KEY_CITY_STATE_GREETING_NEUTRAL_%s", iRandomPersonalityText)
				sRandPersonality2 = Locale.Lookup(sRandPersonality1, leaderPlace)
			elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE then
				sRandFriendship = string.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP_HOSTILE_%s", iRandomFriendshipText)
				sRandPersonality1 = string.format("TXT_KEY_CITY_STATE_GREETING_HOSTILE_%s", iRandomPersonalityText)
				sRandPersonality2 = Locale.Lookup(sRandPersonality1, leaderPlace)
			elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_IRRATIONAL then
				sRandFriendship = string.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP_IRRATIONAL_%s", iRandomFriendshipText)
				sRandPersonality1 = string.format("TXT_KEY_CITY_STATE_GREETING_IRRATIONAL_%s", iRandomPersonalityText)
				sRandPersonality2 = Locale.Lookup(sRandPersonality1, leaderPlace)
			end

			if m_PopupInfo.Text == "GOLD" then
				sRandTrait1 = string.format("TXT_KEY_CITY_STATE_GREETING_MERCANTILE_%s", iRandomTraitText)
				sRandTrait2 = sRandPersonality2 .. " " .. L(sRandTrait1)
			elseif m_PopupInfo.Text == "FAITH" then
				sRandTrait1 = string.format("TXT_KEY_CITY_STATE_GREETING_RELIGIOUS_%s", iRandomTraitText)
				sRandTrait2 = sRandPersonality2 .. " " .. L(sRandTrait1)
			elseif m_PopupInfo.Text == "CULTURE" then
				sRandTrait1 = string.format("TXT_KEY_CITY_STATE_GREETING_CULTURED_%s", iRandomTraitText)
				sRandTrait2 = sRandPersonality2 .. " " .. L(sRandTrait1)
			elseif m_PopupInfo.Text == "FOOD" then
				sRandTrait1 = string.format("TXT_KEY_CITY_STATE_GREETING_MARITIME_%s", iRandomTraitText)
				sRandTrait2 = sRandPersonality2 .. " " .. L(sRandTrait1)
			else
				sRandTrait1 = string.format("TXT_KEY_CITY_STATE_GREETING_MILITARISTIC_%s", iRandomTraitText)
				sRandTrait2 = sRandPersonality2 .. " " .. L(sRandTrait1)
			end
			
			local sRandBonus1 = string.format("TXT_KEY_MINOR_CIV_%sCONTACT_BONUS_%s_%s", (bFirstMajorCiv and "FIRST_" or ""), m_PopupInfo.Text, iRandomBonusText)

			if m_PopupInfo.Data3 == 0 then
				strGiftString = L("TXT_KEY_MINOR_CIV_CONTACT_BONUS_NOTHING_1")
			else
				if bFirstMajorCiv then
					if m_PopupInfo.Text == "UNIT" then
						if m_PopupInfo.Data2 ~= 0 then
							strGiftString = sRandTrait2 .. " " .. L(sRandBonus1, GameInfo.Units[m_PopupInfo.Data2].Description)
						else
							strGiftString = Locale.Lookup(sRandFriendship, leaderPlace) .. " " .. L(sRandTrait1)
						end
					else
						strGiftString = sRandTrait2 .. " " .. L(sRandBonus1, m_PopupInfo.Data2)
					end
				else
					strGiftString = Locale.Lookup(sRandFriendship, leaderPlace) .. " " .. L(sRandTrait1)
				end
			end
			
			strText = strGiftString
		
		-- Were we sent here because we clicked a notification for a new quest?
		elseif m_iLastAction == kiNoAction and m_bNewQuestAvailable then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_HELLO_QUEST_MESSAGE")

		-- Did we just make peace?
		elseif m_iLastAction == kiMadePeace then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_PEACE_JUST_MADE")

		-- Did we just bully gold?
		elseif m_iLastAction == kiBulliedGold then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_BULLIED")

		-- Did we just bully a worker?
		elseif m_iLastAction == kiBulliedUnit then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_BULLIED_WORKER")

		-- Did we just give gold?
		elseif m_iLastAction == kiGiftedGold then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_SUPPORTED")

		-- Did we just PtP?
		elseif m_iLastAction == kiPledgedToProtect then
			strText = L("TXT_KEY_CITY_STATE_PLEDGE_RESPONSE")

		-- Did we just revoke a PtP?
		elseif m_iLastAction == kiRevokedProtection then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_REVOKED_PROTECTION")

		-- Normal peaceful hello, with info about active quests
		else
			local iPersonality = minorPlayer:GetPersonality()
			
			if minorPlayer:IsProtectedByMajor(activePlayerID) then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_PROTECTED_%s", iRandomVisitText))
			elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_FRIENDLY_%s", iRandomVisitText))
			elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_NEUTRAL_%s", iRandomVisitText))
			elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_HOSTILE_%s", iRandomVisitText))
			elseif iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_IRRATIONAL then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_IRRATIONAL_%s", iRandomVisitText))
			end

			local strQuestString = ""
			local strWarString = ""

			local iNumPlayersAtWar = 0

			-- Loop through all the Majors the active player knows
			for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
				pOtherPlayer = Players[iPlayerLoop]
				iOtherTeam = pOtherPlayer:GetTeam()

				-- Don't test war with active player!
				if iPlayerLoop ~= activePlayerID then
					if pOtherPlayer:IsAlive() then
						if minorTeam:IsAtWar(iOtherTeam) then
							if minorPlayer:IsMinorWarQuestWithMajorActive(iPlayerLoop) then
								if iNumPlayersAtWar ~= 0 then
									strWarString = strWarString .. ", "
								end
								
								strWarString = strWarString .. L(pOtherPlayer:GetNameKey())

								iNumPlayersAtWar = iNumPlayersAtWar + 1
							end
						end
					end
				end
			end
		end

		-- Tell the City State to stop gifting us Units (if they are)
		if isFriends and minorPlayer:GetMinorCivTrait() == MinorCivTraitTypes.MINOR_CIV_TRAIT_MILITARISTIC then
			Controls.NoUnitSpawningButton:SetHide(false)

			-- Player has said to turn it off
			local strSpawnText
			if minorPlayer:IsMinorCivUnitSpawningDisabled(activePlayerID) then
				strSpawnText = L("TXT_KEY_CITY_STATE_TURN_SPAWNING_ON")
			else
				strSpawnText = L("TXT_KEY_CITY_STATE_TURN_SPAWNING_OFF")
			end
			
			Controls.NoUnitSpawningLabel:SetText(strSpawnText)
		else
			Controls.NoUnitSpawningButton:SetHide(true)
		end

		Controls.GiveButton:SetHide(false)
		Controls.TakeButton:SetHide(false)
		Controls.PeaceButton:SetHide(true)
		Controls.WarButton:SetHide(false)
	
	-- War
	else
		-- Warmongering player
		if minorPlayer:IsPeaceBlocked(activeTeamID) then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_HELLO_WARMONGER")
			
			Controls.PeaceButton:SetHide(true)
		-- Normal War
		else
			strText = L("TXT_KEY_CITY_STATE_DIPLO_HELLO_WAR")
			
			Controls.PeaceButton:SetHide(false)
		end

		Controls.GiveButton:SetHide(true)
		Controls.TakeButton:SetHide(true)
		Controls.WarButton:SetHide(true)
		Controls.NoUnitSpawningButton:SetHide(true)
	end

	-- Pledge to Protect
	local isShowPledgeButton = false
	local isEnablePledgeButton = false
	local isShowRevokeButton = false
	local isEnableRevokeButton = false
	local strProtectButton = Locale.Lookup("TXT_KEY_POP_CSTATE_PLEDGE_TO_PROTECT")
	local strProtectTT = Locale.Lookup("TXT_KEY_POP_CSTATE_PLEDGE_TT", GameDefines.MINOR_FRIENDSHIP_ANCHOR_MOD_PROTECTED, GameDefines.BALANCE_MINOR_PROTECTION_MINIMUM_DURATION, GameDefines.BALANCE_INFLUENCE_BOOST_PROTECTION_MINOR, GameDefines.BALANCE_CS_PLEDGE_TO_PROTECT_DEFENSE_BONUS, GameDefines.BALANCE_CS_PLEDGE_TO_PROTECT_DEFENSE_BONUS_MAX)
	local strRevokeProtectButton = Locale.Lookup("TXT_KEY_POP_CSTATE_REVOKE_PROTECTION")
	local strRevokeProtectTT = Locale.Lookup("TXT_KEY_POP_CSTATE_REVOKE_PROTECTION_TT")

	if not isAtWar then
		-- PtP in effect
		if minorPlayer:IsProtectedByMajor(activePlayerID) then
			isShowRevokeButton = true
			-- Can we revoke it?
			if minorPlayer:CanMajorWithdrawProtection(activePlayerID) then
				isEnableRevokeButton = true
			else
				strRevokeProtectButton = "[COLOR_WARNING_TEXT]" .. strRevokeProtectButton .. "[ENDCOLOR]"
				local iTurnsCommitted = (minorPlayer:GetTurnLastPledgedProtectionByMajor(activePlayerID) + GameDefines.BALANCE_MINOR_PROTECTION_MINIMUM_DURATION) - Game.GetGameTurn()
				strRevokeProtectTT = strRevokeProtectTT .. Locale.Lookup("TXT_KEY_POP_CSTATE_REVOKE_PROTECTION_DISABLED_COMMITTED_TT", iTurnsCommitted)
			end
		-- No PtP
		else
			isShowPledgeButton = true
			-- Can we pledge?
			if minorPlayer:CanMajorStartProtection(activePlayerID) then
				isEnablePledgeButton = true
			else
				strProtectButton = "[COLOR_WARNING_TEXT]" .. strProtectButton .. "[ENDCOLOR]"
				local iLastTurnPledgeBroken = minorPlayer:GetTurnLastPledgeBrokenByMajor(activePlayerID)
				
				if (iLastTurnPledgeBroken >= 0) then -- (-1) means never happened
					local iTurnsUntilRecovered = (iLastTurnPledgeBroken + 20) - Game.GetGameTurn() --antonjs: todo: xml
					if iTurnsUntilRecovered >= 1 then
						strProtectTT = strProtectTT .. Locale.Lookup("TXT_KEY_POP_CSTATE_PLEDGE_DISABLED_MISTRUST_TT", iTurnsUntilRecovered) .. minorPlayer:GetPledgeProtectionInvalidReason(activePlayerID)
					else
						strProtectTT = strProtectTT .. minorPlayer:GetPledgeProtectionInvalidReason(activePlayerID)
					end
				else
					strProtectTT = strProtectTT .. minorPlayer:GetPledgeProtectionInvalidReason(activePlayerID)
				end
			end
		end
	end
	
	Controls.PledgeAnim:SetHide(not isEnablePledgeButton)
	Controls.PledgeButton:SetHide(not isShowPledgeButton)
	
	if isShowPledgeButton then
		Controls.PledgeLabel:SetText(strProtectButton)
		Controls.PledgeButton:SetToolTipString(strProtectTT)
	end
	
	Controls.RevokePledgeAnim:SetHide(not isEnableRevokeButton)
	Controls.RevokePledgeButton:SetHide(not isShowRevokeButton)
	
	if isShowRevokeButton then
		Controls.RevokePledgeLabel:SetText(strRevokeProtectButton)
		Controls.RevokePledgeButton:SetToolTipString(strRevokeProtectTT)
	end

	if Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_WAR) then
		Controls.PeaceButton:SetHide(true)
	end
	
	if Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_PEACE) then
		Controls.WarButton:SetHide(true)
	end
	
	if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_CHANGING_WAR_PEACE) then
		Controls.PeaceButton:SetHide(true)
		Controls.WarButton:SetHide(true)
	end

	if not minorPlayer:IsMarried(activePlayerID) then
		local iBuyoutCost = minorPlayer:GetMarriageCost(activePlayerID)
		local strButtonLabel = L( "TXT_KEY_POP_CSTATE_BUYOUT")
		local strToolTip = L("TXT_KEY_POP_CSTATE_MARRIAGE_TT", iBuyoutCost)
		
		if minorPlayer:CanMajorMarry(activePlayerID) and not isAtWar then	
			Controls.MarriageButton:SetHide(false)
			Controls.MarriageAnim:SetHide(false)
		elseif activePlayer:IsDiplomaticMarriage() and not isAtWar then
			if minorPlayer:GetAlly() == activePlayerID then
				local iAllianceTurns = minorPlayer:GetAlliedTurns()
				
				strButtonLabel = "[COLOR_WARNING_TEXT]" .. strButtonLabel .. "[ENDCOLOR]"
				strToolTip = L("TXT_KEY_POP_CSTATE_MARRIAGE_DISABLED_ALLY_TT", GameDefines.MINOR_CIV_BUYOUT_TURNS, iAllianceTurns, iBuyoutCost)
			else
				strButtonLabel = "[COLOR_WARNING_TEXT]" .. strButtonLabel .. "[ENDCOLOR]"
				strToolTip = L("TXT_KEY_POP_CSTATE_MARRIAGE_DISABLED_TT", GameDefines.MINOR_CIV_BUYOUT_TURNS, iBuyoutCost)
			end
			
			Controls.MarriageButton:SetHide(false)
			Controls.MarriageAnim:SetHide(true)
		else
			Controls.MarriageButton:SetHide(true)
		end
		Controls.MarriageLabel:SetText(strButtonLabel)
		Controls.MarriageButton:SetToolTipString(strToolTip)
	else
		Controls.MarriageButton:SetHide(true)
	end
	
	Controls.DescriptionLabel:SetText(strText)

	SetButtonSize(Controls.PeaceLabel, Controls.PeaceButton, Controls.PeaceAnim, Controls.PeaceButtonHL)
	SetButtonSize(Controls.GiveLabel, Controls.GiveButton, Controls.GiveAnim, Controls.GiveButtonHL)
	SetButtonSize(Controls.TakeLabel, Controls.TakeButton, Controls.TakeAnim, Controls.TakeButtonHL)
	SetButtonSize(Controls.WarLabel, Controls.WarButton, Controls.WarAnim, Controls.WarButtonHL)
	SetButtonSize(Controls.PledgeLabel, Controls.PledgeButton, Controls.PledgeAnim, Controls.PledgeButtonHL)
	SetButtonSize(Controls.RevokePledgeLabel, Controls.RevokePledgeButton, Controls.RevokePledgeAnim, Controls.RevokePledgeButtonHL)
	SetButtonSize(Controls.NoUnitSpawningLabel, Controls.NoUnitSpawningButton, Controls.NoUnitSpawningAnim, Controls.NoUnitSpawningButtonHL)
	SetButtonSize(Controls.MarriageLabel, Controls.MarriageButton, Controls.MarriageAnim, Controls.MarriageButtonHL)
	
	Controls.GiveStack:SetHide(true)
	Controls.TakeStack:SetHide(true)
	Controls.ButtonStack:SetHide(false)

	UpdateButtonStack()
end
----------------------------------------------------------------
----------------------------------------------------------------
-- adan_eslavo -->
-- from CityStateStatusHelper.lua
function GetContenderInfo(majorPlayerID, minorPlayerID)
	local pMinor = Players[minorPlayerID]
	if not pMinor then return "error" end
	
	local iContInfluence = 0
	local eContender = -1
	local iAllyInfluence = 0
	local eAllyID = pMinor:GetAlly()
	
	for ePlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		if ePlayer ~= eAllyID then
			local iInfluence = pMinor:GetMinorCivFriendshipWithMajor(ePlayer)

			if iInfluence > iContInfluence then
				iContInfluence = iInfluence
				eContender = ePlayer
			end
		elseif ePlayer == eAllyID then
			iAllyInfluence = pMinor:GetMinorCivFriendshipWithMajor(ePlayer)
		end
	end
	
	if iAllyInfluence == 0 then
		iAllyInfluence = GameDefines.FRIENDSHIP_THRESHOLD_ALLIES
	end

	local iMissingInfluenceForContender = iAllyInfluence - iContInfluence

	local bPlayerMet = false
	local pContenderTeam = nil
	local bMetContender = true
	
	if eContender ~= -1 then
		pContenderTeam = Teams[Players[eContender]:GetTeam()]
		bMetContender = pContenderTeam:IsHasMet(Game.GetActiveTeam())
	end
			
	if eContender == Game.GetActivePlayer() then
		bPlayerMet = true	-- active player
	else
		bPlayerMet = bMetContender	-- met players
	end 

	if eContender == -1 then
		CivIconHookup(-1, 32, Controls.ContenderIcon, Controls.ContenderIconBG, Controls.ContenderIconShadow, false, true)
	elseif eContender ~= -1 and not bPlayerMet then
		CivIconHookup(-1, 32, Controls.ContenderIcon, Controls.ContenderIconBG, Controls.ContenderIconShadow, false, true)
	else
		CivIconHookup(eContender, 32, Controls.ContenderIcon, Controls.ContenderIconBG, Controls.ContenderIconShadow, false, true)
	end

	return L("TXT_KEY_CSL_POPUP_CONTENDER_INFLUENCE", tostring(iContInfluence), iMissingInfluenceForContender)
end
-- adan_eslavo <--
----------------------------------------------------------------
----------------------------------------------------------------
-- adan_eslavo -->
function GetProtectingPlayers(iMinorCivID)
	local sProtecting = ""
	
	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local pMainPlayer = Players[iPlayerLoop]
		local iActivePlayer = Game.GetActivePlayer()
		local pActivePlayer = Players[iActivePlayer]
				
		if iPlayerLoop ~= iActivePlayer then
			if pMainPlayer:IsAlive() and Teams[Game.GetActiveTeam()]:IsHasMet(Players[iPlayerLoop]:GetTeam()) then
				if pMainPlayer:IsProtectingMinor(iMinorCivID) then
					if sProtecting ~= "" then
						sProtecting = sProtecting .. ", "
					end
					
					local iApproach = pActivePlayer:GetApproachTowardsUsGuess(iPlayerLoop)
					local sCivShortDescription = L(Players[iPlayerLoop]:GetCivilizationShortDescriptionKey())	
						
					if iApproach == -1 or iApproach == 6 then 
						sProtecting = sProtecting .. "[COLOR_FADING_POSITIVE_TEXT]" .. sCivShortDescription .. "[ENDCOLOR]"
					elseif iApproach <= 2 then
						sProtecting = sProtecting .. "[COLOR_NEGATIVE_TEXT]" .. sCivShortDescription .. "[ENDCOLOR]"
					elseif iApproach == 3 then
						sProtecting = sProtecting .. "[COLOR_PLAYER_LIGHT_ORANGE_TEXT]" .. sCivShortDescription .. "[ENDCOLOR]"
					elseif iApproach == 4 then
						sProtecting = sProtecting .. "[COLOR_MAGENTA]" .. sCivShortDescription .. "[ENDCOLOR]"
					elseif iApproach == 5 then
						sProtecting = sProtecting .. "[COLOR_POSITIVE_TEXT]" .. sCivShortDescription .. "[ENDCOLOR]"
					end
				end
			end
		else
			if pMainPlayer:IsProtectingMinor(iMinorCivID) then
				if sProtecting ~= "" then
					sProtecting = sProtecting .. ", "
				end

				sProtecting = sProtecting .. "[COLOR_POSITIVE_TEXT]" .. L("TXT_KEY_YOU") .. "[ENDCOLOR]"
			end
		end
	end

	return sProtecting
end
-- adan_eslavo <--

function UpdateActiveQuests()
	local pMinorPlayer = Players[g_iMinorCivID]
	local eActivePlayer = Game.GetActivePlayer()
	
	local sIconText, sToolTipText = "", ""
	local iJerkTurns = pMinorPlayer:GetJerkTurnsRemaining(eActivePlayer)
	
	if iJerkTurns > 0 then
		sIconText = L("TXT_KEY_CSL_POPUP_JERK_NO_QUESTS", iJerkTurns)
		sToolTipText = L("TXT_KEY_CSTATE_JERK_STATUS", iJerkTurns)
	else
		sIconText = GetActiveQuestText(eActivePlayer, g_iMinorCivID)
		sToolTipText = GetActiveQuestToolTip(eActivePlayer, g_iMinorCivID)
	end
		
	Controls.QuestInfo:SetText(sIconText)
	Controls.QuestInfo:SetToolTipString(sToolTipText)
	Controls.QuestLabel:SetToolTipString(sToolTipText)
end

-------------------------------------------------
-- On Quest Info Clicked
-------------------------------------------------
function OnQuestInfoClicked()
	local iActivePlayer = Game.GetActivePlayer()
	local pMinor = Players[g_iMinorCivID]

	if pMinor then
		if pMinor:IsMinorCivDisplayedQuestForPlayer(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP) then
			local iQuestData1 = pMinor:GetQuestData1(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)
			local iQuestData2 = pMinor:GetQuestData2(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)
			local pPlot = Map.GetPlot(iQuestData1, iQuestData2)
			
			if pPlot then
				UI.LookAt(pPlot, 0)
				
				local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()))
				
				Events.GameplayFX(hex.x, hex.y, -1)
			end
	    end
	
		if pMinor:IsMinorCivDisplayedQuestForPlayer(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_ARCHAEOLOGY) then
			local iQuestData1 = pMinor:GetQuestData1(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_ARCHAEOLOGY)
			local iQuestData2 = pMinor:GetQuestData2(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_ARCHAEOLOGY)
			local pPlot = Map.GetPlot(iQuestData1, iQuestData2)
			
			if pPlot then
				UI.LookAt(pPlot, 0)
				
				local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()))
				
				Events.GameplayFX(hex.x, hex.y, -1)
			end
	    end
	
		if pMinor:IsMinorCivDisplayedQuestForPlayer(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_DISCOVER_AREA) then
			local iQuestData1 = pMinor:GetQuestData1(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_DISCOVER_AREA)
			local iQuestData2 = pMinor:GetQuestData2(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_DISCOVER_AREA)
			local pPlot = Map.GetPlot(iQuestData1, iQuestData2)
			if pPlot then
				UI.LookAt(pPlot, 0)
				
				local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()))
				
				Events.GameplayFX(hex.x, hex.y, -1)
			end
	    end
	
		if pMinor:IsMinorCivDisplayedQuestForPlayer(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_ACQUIRE_CITY) then
			local iQuestData1 = pMinor:GetQuestData1(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_ACQUIRE_CITY)
			local iQuestData2 = pMinor:GetQuestData2(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_ACQUIRE_CITY)
			local pPlot = Map.GetPlot(iQuestData1, iQuestData2)
		
			if pPlot then
				UI.LookAt(pPlot, 0)
				
				local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()))
				
				Events.GameplayFX(hex.x, hex.y, -1)
			end
		end
	end
end
Controls.QuestInfo:RegisterCallback(Mouse.eLClick, OnQuestInfoClicked)

--================================================================================--
--================================================================================--
-- MAIN MENU
--================================================================================--
--================================================================================--
----------------------------------------------------------------
-- Pledge
----------------------------------------------------------------
function OnPledgeButtonClicked()
	local iActivePlayer = Game.GetActivePlayer()
	local pPlayer = Players[g_iMinorCivID]
	
	if pPlayer:CanMajorStartProtection(iActivePlayer) then
		Game.DoMinorPledgeProtection(Game.GetActivePlayer(), g_iMinorCivID, true)
		
		m_iLastAction = kiPledgedToProtect
	end
end
Controls.PledgeButton:RegisterCallback(Mouse.eLClick, OnPledgeButtonClicked)

----------------------------------------------------------------
-- Revoke Pledge
----------------------------------------------------------------
function OnRevokePledgeButtonClicked()
	local iActivePlayer = Game.GetActivePlayer()
	local pPlayer = Players[g_iMinorCivID]
	
	if pPlayer:CanMajorWithdrawProtection(iActivePlayer) then
		Game.DoMinorPledgeProtection(iActivePlayer, g_iMinorCivID, false)
		
		m_iLastAction = kiRevokedProtection
	end
end
Controls.RevokePledgeButton:RegisterCallback(Mouse.eLClick, OnRevokePledgeButtonClicked)

--CBP
----------------------------------------------------------------
-- Marriage
----------------------------------------------------------------
function OnMarriageButtonClicked()
	local iActivePlayer = Game.GetActivePlayer()
	local pMinor = Players[g_iMinorCivID]

	if pMinor:CanMajorMarry(iActivePlayer) then
		UIManager:DequeuePopup(ContextPtr)
	
		Game.DoMinorBuyout(iActivePlayer, pMinor:GetID())
	end
end
Controls.MarriageButton:RegisterCallback(Mouse.eLClick, OnMarriageButtonClicked)
--END

----------------------------------------------------------------
-- War
----------------------------------------------------------------
function OnWarButtonClicked()
	UI.AddPopup{Type = ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE, Data1 = g_iMinorCivTeamID, Option1 = true}
end
Controls.WarButton:RegisterCallback(Mouse.eLClick, OnWarButtonClicked)

----------------------------------------------------------------
-- Peace
----------------------------------------------------------------
function OnPeaceButtonClicked()
	Network.SendChangeWar(g_iMinorCivTeamID, false)
	m_iLastAction = kiMadePeace
end
Controls.PeaceButton:RegisterCallback(Mouse.eLClick, OnPeaceButtonClicked)

----------------------------------------------------------------
-- Stop/Start Unit Spawning
----------------------------------------------------------------
function OnStopStartSpawning()
    local pPlayer = Players[g_iMinorCivID]
    local iActivePlayer = Game.GetActivePlayer()
	local bSpawningDisabled = pPlayer:IsMinorCivUnitSpawningDisabled(iActivePlayer)
	
	-- Update the text based on what state we're changing to
	local strSpawnText
	
	if bSpawningDisabled then
		strSpawnText = L("TXT_KEY_CITY_STATE_TURN_SPAWNING_OFF")
	else
		strSpawnText = L("TXT_KEY_CITY_STATE_TURN_SPAWNING_ON")
	end
	
	Controls.NoUnitSpawningLabel:SetText(strSpawnText)
    
	Network.SendMinorNoUnitSpawning(g_iMinorCivID, not bSpawningDisabled)
end
Controls.NoUnitSpawningButton:RegisterCallback(Mouse.eLClick, OnStopStartSpawning)

----------------------------------------------------------------
-- Open Give Submenu
----------------------------------------------------------------
function OnGiveButtonClicked()
	Controls.GiveStack:SetHide(false)
	Controls.TakeStack:SetHide(true)
	Controls.ButtonStack:SetHide(true)
	
	PopulateGiftChoices()
end
Controls.GiveButton:RegisterCallback(Mouse.eLClick, OnGiveButtonClicked)

----------------------------------------------------------------
-- Open Take Submenu
----------------------------------------------------------------
function OnTakeButtonClicked()
	Controls.GiveStack:SetHide(true)
	Controls.TakeStack:SetHide(false)
	Controls.ButtonStack:SetHide(true)
	
	PopulateTakeChoices()
end
Controls.TakeButton:RegisterCallback(Mouse.eLClick, OnTakeButtonClicked)

----------------------------------------------------------------
-- Close
----------------------------------------------------------------
function OnCloseButtonClicked()
	UIManager:DequeuePopup(ContextPtr)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnCloseButtonClicked)

----------------------------------------------------------------
-- Find On Map
----------------------------------------------------------------
function OnFindOnMapButtonClicked()
	local pPlayer = Players[g_iMinorCivID]
	
	if pPlayer then
		local pCity = pPlayer:GetCapitalCity()
		
		if pCity then
			local pPlot = pCity:Plot()
			
			if pPlot then
				UI.LookAt(pPlot, 0)
			end
		end
	end
end
Controls.FindOnMapButton:RegisterCallback(Mouse.eLClick, OnFindOnMapButtonClicked)

--================================================================================--
--================================================================================--
-- GIFT MENU
--================================================================================--
--================================================================================--
local iGoldGiftLarge = GameDefines["MINOR_GOLD_GIFT_LARGE"]
local iGoldGiftMedium = GameDefines["MINOR_GOLD_GIFT_MEDIUM"]
local iGoldGiftSmall = GameDefines["MINOR_GOLD_GIFT_SMALL"]

function PopulateGiftChoices()	
	local pPlayer = Players[g_iMinorCivID]
	
	local iActivePlayer = Game.GetActivePlayer()
	local pActivePlayer = Players[iActivePlayer]
	
	-- Unit
	local iInfluence = pPlayer:GetFriendshipFromUnitGift(iActivePlayer, false, true)
	local iTravelTurns = GameDefines.MINOR_UNIT_GIFT_TRAVEL_TURNS
	local buttonText = L("TXT_KEY_POP_CSTATE_GIFT_UNIT", iInfluence)
	local tooltipText = L("TXT_KEY_POP_CSTATE_GIFT_UNIT_TT", iTravelTurns, iInfluence)

	if (pPlayer:GetIncomingUnitCountdown(iActivePlayer) >= 0) then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.UnitGiftAnim:SetHide(true)
		Controls.UnitGiftButton:ClearCallback(Mouse.eLClick)
	else
		Controls.UnitGiftAnim:SetHide(false)
		Controls.UnitGiftButton:RegisterCallback(Mouse.eLClick, OnGiftUnit)
	end
	
	Controls.UnitGift:SetText(buttonText)
	Controls.UnitGiftButton:SetToolTipString(tooltipText)
	
	SetButtonSize(Controls.UnitGift, Controls.UnitGiftButton, Controls.UnitGiftAnim, Controls.UnitGiftButtonHL)
	
	-- Tile Improvement
	-- Only allowed for allies
	iGold = pPlayer:GetGiftTileImprovementCost(iActivePlayer)

	local buttonText = L("TXT_KEY_POPUP_MINOR_GIFT_TILE_IMPROVEMENT", iGold)
	
	if not pPlayer:CanMajorGiftTileImprovement(iActivePlayer) then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.TileImprovementGiftAnim:SetHide(true)
	else
		Controls.TileImprovementGiftAnim:SetHide(false)
	end
	
	Controls.TileImprovementGift:SetText(buttonText)
	
	SetButtonSize(Controls.TileImprovementGift, Controls.TileImprovementGiftButton, Controls.TileImprovementGiftAnim, Controls.TileImprovementGiftButtonHL)

-- CBP: Deny Quest Influence Award
	if pPlayer:IsQuestInfluenceDisabled(iActivePlayer) then
		Controls.DenyInfluenceLabel:SetText(Locale.Lookup("TXT_KEY_CITY_STATE_DISABLED_QUEST_INFLUENCE_YES"))
		Controls.DenyInfluenceButton:SetToolTipString(Locale.Lookup("TXT_KEY_CITY_STATE_DISABLED_QUEST_INFLUENCE_YES_TT", pPlayer:GetName()))
	else
		Controls.DenyInfluenceLabel:SetText(Locale.Lookup("TXT_KEY_CITY_STATE_DISABLED_QUEST_INFLUENCE_NO"))
		Controls.DenyInfluenceButton:SetToolTipString(Locale.Lookup("TXT_KEY_CITY_STATE_DISABLED_QUEST_INFLUENCE_NO_TT", pPlayer:GetName()))
	end
	
	SetButtonSize(Controls.DenyInfluenceLabel, Controls.DenyInfluenceButton, Controls.DenyInfluenceAnim, Controls.DenyInfluenceButtonHL)
-- END
	
	UpdateButtonStack()
end

----------------------------------------------------------------
-- Gift Unit
----------------------------------------------------------------
function OnGiftUnit()
    UIManager:DequeuePopup(ContextPtr)

	local interfaceModeSelection = InterfaceModeTypes.INTERFACEMODE_GIFT_UNIT
	
	UI.SetInterfaceMode(interfaceModeSelection)
	UI.SetInterfaceModeValue(g_iMinorCivID)
end
Controls.UnitGiftButton:RegisterCallback(Mouse.eLClick, OnGiftUnit)

----------------------------------------------------------------
-- Gift Improvement
----------------------------------------------------------------
function OnGiftTileImprovement()
	local pMinor = Players[g_iMinorCivID]
	local iActivePlayer = Game.GetActivePlayer()
    
    if pMinor:CanMajorGiftTileImprovement(iActivePlayer) then
		UIManager:DequeuePopup(ContextPtr)

		local interfaceModeSelection = InterfaceModeTypes.INTERFACEMODE_GIFT_TILE_IMPROVEMENT
		
		UI.SetInterfaceMode(interfaceModeSelection)
		UI.SetInterfaceModeValue(g_iMinorCivID)
	end
end
Controls.TileImprovementGiftButton:RegisterCallback(Mouse.eLClick, OnGiftTileImprovement)

----------------------------------------------------------------
-- Close Give Submenu
----------------------------------------------------------------
function OnCloseGive()
--CSD
	--Controls.GiveStackCSD:SetHide(true)
	Controls.GiveStack:SetHide(true)
	Controls.TakeStack:SetHide(true)
	Controls.ButtonStack:SetHide(false)
	
	UpdateButtonStack()
end
Controls.ExitGiveButton:RegisterCallback(Mouse.eLClick, OnCloseGive)

--================================================================================--
--================================================================================--
-- TAKE MENU
--================================================================================--
--================================================================================--
local iBullyGoldInfluenceLost = (GameDefines.MINOR_FRIENDSHIP_DROP_BULLY_GOLD_SUCCESS / 100) * -1; -- Since XML value is times 100 for fidelity, and negative
local iBullyUnitInfluenceLost = (GameDefines.MINOR_FRIENDSHIP_DROP_BULLY_WORKER_SUCCESS / 100) * -1; -- Since XML value is times 100 for fidelity, and negative
local iBullyUnitMinimumPop = 4 --antonjs: todo: XML

function PopulateTakeChoices()
	local pPlayer = Players[g_iMinorCivID]
	local iActivePlayer = Game.GetActivePlayer()
	local buttonText = ""
	local ttText = ""
	
	local iRestingInfluence = pPlayer:GetRestingPointChange(iActivePlayer);
	local iCurrentInfluence = pPlayer:GetMinorCivFriendshipWithMajor(iActivePlayer);
	local iFinalBullyGoldInfluenceLost = iBullyGoldInfluenceLost;
	local iFinalBullyUnitInfluenceLost = iBullyUnitInfluenceLost;

	if iCurrentInfluence >= iRestingInfluence then
		iFinalBullyGoldInfluenceLost = iFinalBullyGoldInfluenceLost + iCurrentInfluence - iRestingInfluence;
		iFinalBullyUnitInfluenceLost = iFinalBullyUnitInfluenceLost + iCurrentInfluence - iRestingInfluence;
	end

	local iBullyGold = pPlayer:GetMinorCivBullyGoldAmount(iActivePlayer);

	buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_GOLD_AMOUNT", iBullyGold, iFinalBullyGoldInfluenceLost);

	ttText = pPlayer:GetMajorBullyGoldDetails(activePlayerID);

	if not pPlayer:CanMajorBullyGold(iActivePlayer) then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.GoldTributeAnim:SetHide(true)
	else
		Controls.GoldTributeAnim:SetHide(false)
	end
	
	Controls.GoldTributeLabel:SetText(buttonText)
	Controls.GoldTributeButton:SetToolTipString(ttText)

	SetButtonSize(Controls.GoldTributeLabel, Controls.GoldTributeButton, Controls.GoldTributeAnim, Controls.GoldTributeButtonHL)
	
-- CBP
	local iGoldTribute = pPlayer:GetMinorCivBullyGoldAmount(iActivePlayer, true)
	local pMajor = Players[iActivePlayer]
	
	buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_UNIT_AMOUNT", iGoldTribute, iFinalBullyUnitInfluenceLost)
-- END
	ttText = pPlayer:GetMajorBullyUnitDetails(iActivePlayer)
	
	if not pPlayer:CanMajorBullyUnit(iActivePlayer) or not HasActivePersonalQuestText(iActivePlayer, g_iMinorCivID) then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.UnitTributeAnim:SetHide(true)
	else
		Controls.UnitTributeAnim:SetHide(false)
	end
	
	Controls.UnitTributeLabel:SetText(buttonText)
	Controls.UnitTributeButton:SetToolTipString(ttText)

	SetButtonSize(Controls.UnitTributeLabel, Controls.UnitTributeButton, Controls.UnitTributeAnim, Controls.UnitTributeButtonHL)
	
-- CBP: Forced Annex
	if pMajor:IsBullyAnnex() then
		ttText = pPlayer:GetMajorBullyAnnexDetails(iActivePlayer)
		buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_UNIT_AMOUNT_ANNEX")
		
		Controls.BullyAnnexButton:SetHide(false)
		
		if not pPlayer:CanMajorBullyUnit(activePlayerID) then
			buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
			Controls.BullyAnnexAnim:SetHide(true)
		else
			Controls.BullyAnnexAnim:SetHide(false)
		end
		
		Controls.BullyAnnexLabel:SetText(buttonText)
		Controls.BullyAnnexButton:SetToolTipString(ttText)
		
		SetButtonSize(Controls.BullyAnnexLabel, Controls.BullyAnnexButton, Controls.BullyAnnexAnim, Controls.BullyAnnexButtonHL)
	else
		Controls.BullyAnnexButton:SetHide(true)
	end
-- END
	UpdateButtonStack()
end

----------------------------------------------------------------
-- Bully confirmation
----------------------------------------------------------------
function OnBullyButtonClicked ()
	local listofProtectingCivs = {}

	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
			
		pOtherPlayer = Players[iPlayerLoop]
			
		-- Don't test protection status with active player!
		if iPlayerLoop ~= Game.GetActivePlayer() then
			if pOtherPlayer:IsAlive() then
				if Teams[Game.GetActiveTeam()]:IsHasMet(pOtherPlayer:GetTeam()) then
					if  pOtherPlayer:IsProtectingMinor(g_iMinorCivID)  then
						table_insert(listofProtectingCivs, Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()) 
					end
				end
			end
		end
	end
	
	local pMinor = Players[g_iMinorCivID]
	local cityStateName = Locale.Lookup(pMinor:GetCivilizationShortDescriptionKey())
	
	local bullyConfirmString = L("TXT_KEY_CONFIRM_BULLY", cityStateName)
	local numProtectingCivs = #listofProtectingCivs
	
	if numProtectingCivs > 0 then
		if numProtectingCivs == 1 then
			bullyConfirmString = L("TXT_KEY_CONFIRM_BULLY_PROTECTED_CITY_STATE", cityStateName, listofProtectingCivs[1])
		else
			local translatedCivs = {}
			
			for i, v in ipairs(listofProtectingCivs) do
				translatedCivs[i] = Locale.Lookup(v)
			end
		
			bullyConfirmString = L("TXT_KEY_CONFIRM_BULLY_PROTECTED_CITY_STATE_MULTIPLE", cityStateName, table_concat(translatedCivs, ", "))
		end
	end
	
	Controls.BullyConfirmLabel:SetText(bullyConfirmString)
	Controls.BullyConfirm:SetHide(false)
	Controls.BGBlock:SetHide(true)
end

----------------------------------------------------------------
-- CBP: Forced Annex confirmation
----------------------------------------------------------------
function OnForcedAnnexButtonClicked()
    local pMinor = Players[g_iMinorCivID]
	local cityStateName = Locale.Lookup(pMinor:GetCivilizationShortDescriptionKey())
	local bullyConfirmString = L("TXT_KEY_CONFIRM_BULLYANNEX", cityStateName)

	Controls.BullyConfirmLabel:SetText(bullyConfirmString)
	Controls.BullyConfirm:SetHide(false)
	Controls.BGBlock:SetHide(true)
end

----------------------------------------------------------------
-- Take Gold
----------------------------------------------------------------
function OnGoldTributeButtonClicked()
	local pPlayer = Players[g_iMinorCivID]
	local iActivePlayer = Game.GetActivePlayer()
	
	if pPlayer:CanMajorBullyGold(iActivePlayer) then
		m_iPendingAction = kiBulliedGold
	
		OnBullyButtonClicked()
		OnCloseTake()
	end
end
Controls.GoldTributeButton:RegisterCallback(Mouse.eLClick, OnGoldTributeButtonClicked)

----------------------------------------------------------------
-- Take Unit
----------------------------------------------------------------
function OnUnitTributeButtonClicked()
	local pPlayer = Players[g_iMinorCivID]
	local iActivePlayer = Game.GetActivePlayer()
	
	if pPlayer:CanMajorBullyUnit(iActivePlayer) and HasActivePersonalQuestText(iActivePlayer, g_iMinorCivID) then
		m_iPendingAction = kiBulliedUnit
		
		OnBullyButtonClicked()
		OnCloseTake()
	end
end
Controls.UnitTributeButton:RegisterCallback(Mouse.eLClick, OnUnitTributeButtonClicked)

----------------------------------------------------------------
-- CBP: Forced Annex (Rome UA)
----------------------------------------------------------------
function OnBullyAnnexButtonClicked()
	local pPlayer = Players[g_iMinorCivID]
	local iActivePlayer = Game.GetActivePlayer()
	
	if pPlayer:CanMajorBullyUnit(iActivePlayer) then
		m_iPendingAction = kiBullyAnnexed
		
		OnForcedAnnexButtonClicked()
		OnCloseTake()
	end
end
Controls.BullyAnnexButton:RegisterCallback(Mouse.eLClick, OnBullyAnnexButtonClicked)

----------------------------------------------------------------
-- CBP: Deny Quest Influence
----------------------------------------------------------------
function OnNoQuestInfluenceButtonClicked()
	local pPlayer = Players[g_iMinorCivID]
	local iActivePlayer = Game.GetActivePlayer()
	
	if pPlayer:IsQuestInfluenceDisabled(iActivePlayer) then
		pPlayer:SetQuestInfluenceDisabled(iActivePlayer, false)
		
		OnCloseTake()
	else
		pPlayer:SetQuestInfluenceDisabled(iActivePlayer, true)
		
		OnCloseTake()
	end
end
Controls.DenyInfluenceButton:RegisterCallback(Mouse.eLClick, OnNoQuestInfluenceButtonClicked)

----------------------------------------------------------------
-- Close Take Submenu
----------------------------------------------------------------
function OnCloseTake()
--CSD
	--Controls.GiveStackCSD:SetHide(true)
	Controls.GiveStack:SetHide(true)
	Controls.TakeStack:SetHide(true)
	Controls.ButtonStack:SetHide(false)
	
	UpdateButtonStack()
end
Controls.ExitTakeButton:RegisterCallback(Mouse.eLClick, OnCloseTake)

--================================================================================--
--================================================================================--
-- BULLY CONFIRMATION POPUP
--================================================================================--
--================================================================================--
function OnYesBully()
	local iActivePlayer = Game.GetActivePlayer()
	
	if m_iPendingAction == kiBulliedGold then
		Game.DoMinorBullyGold(iActivePlayer, g_iMinorCivID)
		
		m_iPendingAction = kiNoAction
		m_iLastAction = kiBulliedGold
	elseif m_iPendingAction == kiBulliedUnit then
-- CBP
		OnCloseButtonClicked()
		
		m_iPendingAction = kiNoAction
		m_iLastAction = kiBulliedUnit
-- END
		Game.DoMinorBullyUnit(iActivePlayer, g_iMinorCivID)
-- CBP
	elseif m_iPendingAction == kiBullyAnnexed then
		OnCloseButtonClicked()
	
		m_iPendingAction = kiNoAction
		m_iLastAction = kiBullyAnnexed
	
		Game.DoMinorBullyAnnex(iActivePlayer, g_iMinorCivID)
-- END
	else
		print("Scripting error - Selected Yes for bully confirmation dialog, but invalid PendingAction type")
	end

	Controls.BullyConfirm:SetHide(true)
	Controls.BGBlock:SetHide(false)
	
    UIManager:DequeuePopup(ContextPtr)
end
Controls.YesBully:RegisterCallback(Mouse.eLClick, OnYesBully)

function OnNoBully()
	Controls.BullyConfirm:SetHide(true)
	Controls.BGBlock:SetHide(false)
end
Controls.NoBully:RegisterCallback(Mouse.eLClick, OnNoBully)

--================================================================================--
--================================================================================--
-- 'Active' (local human) player has changed
--================================================================================--
--================================================================================--
Events.GameplaySetActivePlayer.Add(OnCloseButtonClicked)