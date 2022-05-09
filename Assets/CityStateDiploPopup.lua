-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- City State Diplo Popup (modified by adan_eslavo)
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
include("IconSupport")
include("InfoTooltipInclude")
include("CityStateStatusHelper")

local g_minorCivID = -1
local g_minorCivTeamID = -1
local m_PopupInfo = nil
local m_isNewQuestAvailable = false
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
local m_lastAction = kiNoAction
local m_pendingAction = kiNoAction -- For bullying dialog popups
local kiGreet = 9
local questKillCamp = MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP

local iRandomPersonalityText
local iRandomTraitText
local iRandomBonusText
local iRandomFrienshipText
local iRandomVisitText

local table_insert = table.insert
local table_concat = table.concat
local L = Locale.ConvertTextKey
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- HANDLERS AND HELPERS
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function SetButtonSize(textControl, buttonControl, animControl, buttonHL)
	local sizeY = textControl:GetSizeY() + WordWrapOffset
	
	buttonControl:SetSizeY(sizeY)
	animControl:SetSizeY(sizeY + WordWrapAnimOffset)
	buttonHL:SetSizeY(sizeY + WordWrapAnimOffset)
end

function UpdateButtonStack()
	Controls.GiveStack:CalculateSize()
	Controls.GiveStack:ReprocessAnchoring()

	Controls.TakeStack:CalculateSize()
	Controls.TakeStack:ReprocessAnchoring()

	Controls.ButtonStack:CalculateSize()
	Controls.ButtonStack:ReprocessAnchoring()

	Controls.ButtonScrollPanel:CalculateInternalSize()
end

function InputHandler(uiMsg, wParam, lParam)
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
			if Controls.BullyConfirm:IsHidden() then
				OnCloseButtonClicked()
			else
				OnNoBully( )
			end
			
			return true
		end
	end
end
ContextPtr:SetInputHandler(InputHandler)

function ShowHideHandler(bIsHide, bInitState)
	if not bInitState then
		Controls.BackgroundImage:UnloadTexture();
		
		if not bIsHide then
			Events.SerialEventGameDataDirty.Add(OnDisplay)
			Events.WarStateChanged.Add(OnDisplay)			-- bc1 hack to force refresh in vanilla when selecting peace / war
			
			iRandomPersonalityText = tostring(math.random(7))
			iRandomTraitText = tostring(math.random(7))
			iRandomBonusText = tostring(math.random(7))
			iRandomFrienshipText = tostring(math.random(8))
			iRandomVisitText = tostring(math.random(10))

			OnDisplay()
			UI.incTurnTimerSemaphore()
			Events.SerialEventGameMessagePopupShown(m_PopupInfo)
		else
			Events.SerialEventGameDataDirty.Remove(OnDisplay)
			Events.WarStateChanged.Remove(OnDisplay)
			UI.decTurnTimerSemaphore()
			if m_PopupInfo then
				Events.SerialEventGameMessagePopupProcessed.CallImmediate( m_PopupInfo.Type, 0 )
			end
		end
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)

-------------------------------------------------
-- On Event Received
-------------------------------------------------
function OnEventReceived(popupInfo)
	local bGreeting = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_GREETING
	local bMessage = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_MESSAGE
	local bDiplo = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO

	if bMessage or bDiplo then
		-- nothing
	elseif bGreeting then
		m_lastAction = kiGreet
	else
		return
	end

	m_PopupInfo = popupInfo

	g_minorCivID = m_PopupInfo.Data1
	g_minorCivTeamID = Players[g_minorCivID]:GetTeam()

	m_pendingAction = kiNoAction

	m_isNewQuestAvailable = m_PopupInfo.Data2 == 1

	UIManager:QueuePopup(ContextPtr, PopupPriority.CityStateDiplo)
end
Events.SerialEventGameMessagePopup.Add(OnEventReceived)

-------------------------------------------------
-- On Display
-------------------------------------------------
function OnDisplay()
	local activePlayerID = Game.GetActivePlayer()
	local activePlayer = Players[activePlayerID]
	local activeTeamID = Game.GetActiveTeam()
	local activeTeam = Teams[activeTeamID]

	local minorPlayerID = g_minorCivID
	local minorPlayer = Players[minorPlayerID]
	local minorTeamID = g_minorCivTeamID
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
	local leaderTitle = nil
	local artistName = nil

	if (minorCivType ~= nil) then
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

		if (leaderIcon ~= nil and leaderName ~= nil) then
			if leaderPlace == nil then
				leaderPlace = L(strShortDescKey)
			end
			
			if (leaderTitle ~= nil) then
				leaderName = leaderTitle.." "..leaderName
			end
			
			leaderName = leaderName.." from "..leaderPlace
			
			Controls.TitleIconCSLTrait:SetHide(false)
			Controls.TitleIconCSLTrait:SetTexture(traitIcon)
			Controls.TitleIconCSL:SetHide(false)
			Controls.TitleIconCSL:SetTexture(leaderIcon)
			Controls.LeaderLabel:LocalizeAndSetText(leaderName)
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

	local strStatusText = GetCityStateStatusText(activePlayerID, minorPlayerID)
	local strStatusTT = GetCityStateStatusToolTip(activePlayerID, minorPlayerID, true)
	
	UpdateCityStateStatusUI(activePlayerID, minorPlayerID, Controls.PositiveStatusMeter, Controls.NegativeStatusMeter, Controls.StatusMeterMarker, Controls.StatusIconBG)
	Controls.StatusInfo:SetText(strStatusText)
	Controls.StatusInfo:SetToolTipString(strStatusTT)
	Controls.StatusLabel:SetToolTipString(strStatusTT)
	Controls.StatusIconBG:SetToolTipString(strStatusTT)
	Controls.PositiveStatusMeter:SetToolTipString(strStatusTT)
	Controls.NegativeStatusMeter:SetToolTipString(strStatusTT)
	Controls.MarriedButton:SetHide(true)
	
	if(minorPlayer:IsMarried(activePlayerID))then
		Controls.MarriedButton:SetHide(false)
		Controls.MarriedButton:SetText(L("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_MARRIED_SMALL"))
		Controls.MarriedButton:SetToolTipString(L("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_MARRIED_TT"))
	end

	if (strTraitText == L("TXT_KEY_CITY_STATE_CULTURED_ADJECTIVE")) then
		strTraitText = "[ICON_CULTURE] [COLOR_MAGENTA]".. strTraitText .."[ENDCOLOR]"
	elseif (strTraitText == L("TXT_KEY_CITY_STATE_MILITARISTIC_ADJECTIVE")) then
		strTraitText = "[ICON_WAR] [COLOR_RED]".. strTraitText .."[ENDCOLOR]"
	elseif (strTraitText == L("TXT_KEY_CITY_STATE_MARITIME_ADJECTIVE")) then
		strTraitText = "[ICON_FOOD] [COLOR_CYAN]".. strTraitText .."[ENDCOLOR]"
	elseif (strTraitText == L("TXT_KEY_CITY_STATE_MERCANTILE_ADJECTIVE")) then
		strTraitText = "[ICON_GOLD] [COLOR_YELLOW]".. strTraitText .."[ENDCOLOR]"
	elseif (strTraitText == L("TXT_KEY_CITY_STATE_RELIGIOUS_ADJECTIVE")) then
		strTraitText = "[ICON_PEACE] [COLOR_WHITE]".. strTraitText .."[ENDCOLOR]"
	end
	
	Controls.TraitInfo:SetText(strTraitText)
	Controls.TraitInfo:SetToolTipString(strTraitTT)
	Controls.TraitLabel:SetToolTipString(strTraitTT)

	-- Personality
	local strPersonalityText = ""
	local strPersonalityTT = ""
	local iPersonality = minorPlayer:GetPersonality()
	
	if (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY) then
		strPersonalityText = "[ICON_FLOWER] [COLOR_POSITIVE_TEXT]".. L("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY") .."[ENDCOLOR]"
		strPersonalityTT = L("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY_TT")
	elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL) then
		strPersonalityText = "[ICON_TEAM_1] [COLOR_FADING_POSITIVE_TEXT]".. L("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL") .."[ENDCOLOR]"
		strPersonalityTT = L("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL_TT")
	elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE) then
		strPersonalityText = "[ICON_RAZING] [COLOR_NEGATIVE_TEXT]".. L("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE") .."[ENDCOLOR]"
		strPersonalityTT = L("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE_TT")
	elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_IRRATIONAL) then
		strPersonalityText = "[ICON_HAPPINESS_4] [COLOR_FADING_NEGATIVE_TEXT]".. L("TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL") .."[ENDCOLOR]"
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
	
	if (iAlly ~= nil and iAlly ~= -1) then
		local iAllyInf = minorPlayer:GetMinorCivFriendshipWithMajor(iAlly)
		local iActivePlayerInf = minorPlayer:GetMinorCivFriendshipWithMajor(activePlayerID)

		if (iAlly ~= activePlayerID) then
			if (Teams[Players[iAlly]:GetTeam()]:IsHasMet(Game.GetActiveTeam())) then
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
	
	--strAlly = GetAllyText(activePlayerID, minorPlayerID)
	--strAllyTT = GetAllyToolTip(activePlayerID, minorPlayerID)

	if Game.IsResolutionPassed(GameInfoTypes.RESOLUTION_SPHERE_OF_INFLUENCE, minorPlayerID) then
		strAlly = strAlly .. " [ICON_LOCKED]"
		strAllyTT = strAllyTT .. "[NEWLINE][NEWLINE]This City-State is under the [COLOR_CYAN]Sphere of Influence[ENDCOLOR]."
	end

	Controls.AllyText:SetText(strAlly)
	Controls.AllyIcon:SetToolTipString(strAllyTT)
	Controls.AllyIconBG:SetToolTipString(strAllyTT)
	Controls.AllyIconShadow:SetToolTipString(strAllyTT)
	Controls.AllyText:SetToolTipString(strAllyTT)
	Controls.AllyLabel:SetToolTipString(strAllyTT)

	Controls.AllyIconContainer:SetHide(bHideIcon)
	Controls.AllyText:SetHide(bHideText)
	
	-- Contender
	Controls.ContenderInfo:SetText(GetContenderInfo(activePlayerID, minorPlayerID))
	
	-- Protector
	local sProtectingPlayers = getProtectingPlayers(minorPlayerID)

	if (sProtectingPlayers ~= "") then
		Controls.ProtectInfo:SetText("[COLOR_POSITIVE_TEXT]" .. sProtectingPlayers .. "[ENDCOLOR]")
	else
		Controls.ProtectInfo:SetText(L("TXT_KEY_CITY_STATE_NOBODY"))
	end

	Controls.ProtectInfo:SetToolTipString(L("TXT_KEY_POP_CSTATE_PROTECTED_BY_TT"))
	Controls.ProtectLabel:SetToolTipString(L("TXT_KEY_POP_CSTATE_PROTECTED_BY_TT"))
	
	-- Nearby Resources
	local pCapital = minorPlayer:GetCapitalCity()
	if pCapital then

		local strResourceText = ""

		local iNumResourcesFound = 0

		local thisX = pCapital:GetX()
		local thisY = pCapital:GetY()

		local iRange = GameDefines.MINOR_CIV_RESOURCE_SEARCH_RADIUS or 5 --5
		local iCloseRange = math.floor(iRange/2) --2
		local tResourceList = {}

		for iDX = -iRange, iRange, 1 do
			for iDY = -iRange, iRange, 1 do
				local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY)

				if pTargetPlot ~= nil then
					local iOwner = pTargetPlot:GetOwner()

					if (iOwner == minorPlayerID or iOwner == -1) then
						local plotX = pTargetPlot:GetX()
						local plotY = pTargetPlot:GetY()
						local plotDistance = Map.PlotDistance(thisX, thisY, plotX, plotY)

						if (plotDistance <= iRange and (plotDistance <= iCloseRange or iOwner == minorPlayerID)) then
							local iResourceType = pTargetPlot:GetResourceType(Game.GetActiveTeam())

							if (iResourceType ~= -1) then
								if (Game.GetResourceUsageType(iResourceType) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS) then
									if (tResourceList[iResourceType] == nil) then
										tResourceList[iResourceType] = 0
									end

									tResourceList[iResourceType] = tResourceList[iResourceType] + pTargetPlot:GetNumResource()
								end
							end
						end
					end
				end
			end
		end

		for iResourceType, iAmount in pairs(tResourceList) do
			if (iNumResourcesFound > 0) then
				strResourceText = strResourceText .. ", "
			end
			
			local pResource = GameInfo.Resources[iResourceType]
			
			if pResource.ResourceClassType == "RESOURCECLASS_LUXURY" then	
				strResourceText = strResourceText .. pResource.IconString .. " [COLOR_PLAYER_LIGHT_YELLOW_TEXT]" .. L(pResource.Description) .. " (" .. iAmount .. ") [ENDCOLOR]"
			else
				strResourceText = strResourceText .. pResource.IconString .. " [COLOR_YIELD_FOOD]" .. L(pResource.Description) .. " (" .. iAmount .. ") [ENDCOLOR]"
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
	local sIconText = GetActiveQuestText(activePlayerID, g_minorCivID)
	local sToolTipText = GetActiveQuestToolTip(activePlayerID, g_minorCivID)

	Controls.QuestInfo:SetText(sIconText)
	Controls.QuestInfo:SetToolTipString(sToolTipText)
	Controls.QuestLabel:SetToolTipString(sToolTipText)

	-- UCS Info Tab
	local sUCSInfoHide = true
	local tUCSBonuses = {}
	
	for option in GameInfo.Community{Type="CSL-UCS"} do
		if option.Value == 1 then
			sUCSInfoHide = false
			break
		end
	end

	local sUCSInfoTitle = L("TXT_KEY_POP_CSTATE_UCS_MAIN_TEXT")
	local sUCSInfoTT = L("TXT_KEY_POP_CSTATE_UCS_TOOLTIP_TITLE")
	local sNoUCSBonusesFound = L("TXT_KEY_POP_CSTATE_UCS_NO_BONUS_FOUND")
	local sTextEnableUCS = L("TXT_KEY_POP_CSTATE_UCS_NO_UCS_FOUND")
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
	if (not isAtWar) then
		-- Gifts
		if m_lastAction == kiGreet then
			local bFirstMajorCiv = m_PopupInfo.Option1
			local sRandPersonality1, sRandPersonality2, sRandTrait1, sRandTrait2, sRandBonus1, sRandBonus2, sRandFriendship, strGiftString = "", "", "", "", "", "", "", ""

			if (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY) then
				sRandFriendship = string.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP_FRIENDLY_%s", iRandomFrienshipText)
				sRandPersonality1 = string.format("TXT_KEY_CITY_STATE_GREETING_FRIENDLY_%s", iRandomPersonalityText)
				sRandPersonality2 = Locale.Lookup(sRandPersonality1, leaderPlace)
			elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL) then
				sRandFriendship = string.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP_NEUTRAL_%s", iRandomFrienshipText)
				sRandPersonality1 = string.format("TXT_KEY_CITY_STATE_GREETING_NEUTRAL_%s", iRandomPersonalityText)
				sRandPersonality2 = Locale.Lookup(sRandPersonality1, leaderPlace)
			elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE) then
				sRandFriendship = string.format("TXT_KEY_MINOR_CIV_CONTACT_BONUS_FRIENDSHIP_HOSTILE_%s", iRandomFrienshipText)
				sRandPersonality1 = string.format("TXT_KEY_CITY_STATE_GREETING_HOSTILE_%s", iRandomPersonalityText)
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

			if (m_PopupInfo.Data3 == 0) then
				strGiftString = L("TXT_KEY_MINOR_CIV_CONTACT_BONUS_NOTHING_1")
			else
				if bFirstMajorCiv then
					if (m_PopupInfo.Text == "UNIT") then
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
		elseif (m_lastAction == kiNoAction and m_isNewQuestAvailable) then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_HELLO_QUEST_MESSAGE")

		-- Did we just make peace?
		elseif (m_lastAction == kiMadePeace) then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_PEACE_JUST_MADE")

		-- Did we just bully gold?
		elseif (m_lastAction == kiBulliedGold) then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_BULLIED")

		-- Did we just bully a worker?
		elseif (m_lastAction == kiBulliedUnit) then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_BULLIED_WORKER")

		-- Did we just give gold?
		elseif (m_lastAction == kiGiftedGold) then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_SUPPORTED")

		-- Did we just PtP?
		elseif (m_lastAction == kiPledgedToProtect) then
			strText = L("TXT_KEY_CITY_STATE_PLEDGE_RESPONSE")

		-- Did we just revoke a PtP?
		elseif (m_lastAction == kiRevokedProtection) then
			strText = L("TXT_KEY_CITY_STATE_DIPLO_JUST_REVOKED_PROTECTION")

		-- Normal peaceful hello, with info about active quests
		else
			local iPersonality = minorPlayer:GetPersonality()
			
			if minorPlayer:IsProtectedByMajor(activePlayerID) then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_PROTECTED_%s", iRandomVisitText))
			elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY) then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_FRIENDLY_%s", iRandomVisitText))
			elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL) then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_NEUTRAL_%s", iRandomVisitText))
			elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE) then
				strText = L(string.format("TXT_KEY_CITY_STATE_DIPLO_HELLO_PEACE_HOSTILE_%s", iRandomVisitText))
			end

			local strQuestString = ""
			local strWarString = ""

			local iNumPlayersAtWar = 0

			-- Loop through all the Majors the active player knows
			for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
				pOtherPlayer = Players[iPlayerLoop]
				iOtherTeam = pOtherPlayer:GetTeam()

				-- Don't test war with active player!
				if (iPlayerLoop ~= activePlayerID) then
					if (pOtherPlayer:IsAlive()) then
						if (minorTeam:IsAtWar(iOtherTeam)) then
							if minorPlayer:IsMinorWarQuestWithMajorActive(iPlayerLoop) then
								if (iNumPlayersAtWar ~= 0) then
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
			if (minorPlayer:IsMinorCivUnitSpawningDisabled(activePlayerID)) then
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
		if (minorPlayer:IsPeaceBlocked(activeTeamID)) then
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
	
	if (isShowPledgeButton) then
		Controls.PledgeLabel:SetText(strProtectButton)
		Controls.PledgeButton:SetToolTipString(strProtectTT)
	end
	
	Controls.RevokePledgeAnim:SetHide(not isEnableRevokeButton)
	Controls.RevokePledgeButton:SetHide(not isShowRevokeButton)
	
	if (isShowRevokeButton) then
		Controls.RevokePledgeLabel:SetText(strRevokeProtectButton)
		Controls.RevokePledgeButton:SetToolTipString(strRevokeProtectTT)
	end

	if (Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_WAR)) then
		Controls.PeaceButton:SetHide(true)
	end
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_PEACE)) then
		Controls.WarButton:SetHide(true)
	end
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_CHANGING_WAR_PEACE)) then
		Controls.PeaceButton:SetHide(true)
		Controls.WarButton:SetHide(true)
	end

	if(not minorPlayer:IsMarried(activePlayerID)) then
		local iBuyoutCost = minorPlayer:GetMarriageCost(activePlayerID)
		local strButtonLabel = L( "TXT_KEY_POP_CSTATE_BUYOUT")
		local strToolTip = L( "TXT_KEY_POP_CSTATE_MARRIAGE_TT", iBuyoutCost )
		if minorPlayer:CanMajorMarry(activePlayerID) and not isAtWar then	
			Controls.MarriageButton:SetHide(false)
			Controls.MarriageAnim:SetHide(false)
		elseif (activePlayer:IsDiplomaticMarriage() and not isAtWar) then
			if (minorPlayer:GetAlly() == activePlayerID) then
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
		Controls.MarriageLabel:SetText( strButtonLabel )
		Controls.MarriageButton:SetToolTipString( strToolTip )
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

	if eContender == -1 then
		CivIconHookup(-1, 32, Controls.ContenderIcon, Controls.ContenderIconBG, Controls.ContenderIconShadow, false, true)
	else
		CivIconHookup(eContender, 32, Controls.ContenderIcon, Controls.ContenderIconBG, Controls.ContenderIconShadow, false, true)
	end

	return tostring(iContInfluence) .. " [ICON_INFLUENCE] (" .. iMissingInfluenceForContender .. " [ICON_INFLUENCE] to become an Ally)"
end

function getProtectingPlayers(iMinorCivID)
	local sProtecting = ""
	
	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local pMainPlayer = Players[iPlayerLoop]
		local iActivePlayer = Game.GetActivePlayer()
		local pActivePlayer = Players[iActivePlayer]
				
		if (iPlayerLoop ~= iActivePlayer) then
			if (pMainPlayer:IsAlive() and Teams[Game.GetActiveTeam()]:IsHasMet(Players[iPlayerLoop]:GetTeam())) then
				if (pMainPlayer:IsProtectingMinor(iMinorCivID)) then
					if (sProtecting ~= "") then
						sProtecting = sProtecting .. ", "
					end
					
					local iApproach = pActivePlayer:GetApproachTowardsUsGuess(iPlayerLoop)
						
					if iApproach == -1 or iApproach == 6 then 
						sProtecting = sProtecting .. "[COLOR_FADING_POSITIVE_TEXT]" .. L(Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()) .. "[ENDCOLOR]"
					elseif iApproach <= 2 then
						sProtecting = sProtecting .. "[COLOR_NEGATIVE_TEXT]" .. L(Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()) .. "[ENDCOLOR]"
					elseif iApproach == 3 then
						sProtecting = sProtecting .. "[COLOR_PLAYER_LIGHT_ORANGE_TEXT]" .. L(Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()) .. "[ENDCOLOR]"
					elseif iApproach == 4 then
						sProtecting = sProtecting .. "[COLOR_MAGENTA]" .. L(Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()) .. "[ENDCOLOR]"
					elseif iApproach == 5 then
						sProtecting = sProtecting .. "[COLOR_POSITIVE_TEXT]" .. L(Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()) .. "[ENDCOLOR]"
					end
				end
			end
		else
			if (pMainPlayer:IsProtectingMinor(iMinorCivID)) then
				if (sProtecting ~= "") then
					sProtecting = sProtecting .. ", "
				end

				sProtecting = sProtecting .. "[COLOR_POSITIVE_TEXT]You[ENDCOLOR]"
			end
		end
	end

	return sProtecting
end

-- from CityStateStatusHelper.lua
function GetCityStateStatusText( majorPlayerID, minorPlayerID )
	local majorPlayer = Players[majorPlayerID]
	local minorPlayer = Players[minorPlayerID]
	local strStatusText = ""

	if majorPlayer and minorPlayer then
		local majorTeamID = majorPlayer:GetTeam()
		local minorTeamID = minorPlayer:GetTeam()
		local majorTeam = Teams[majorTeamID]

		local isAtWar = majorTeam:IsAtWar(minorTeamID)
		local majorInfluenceWithMinor = minorPlayer:GetMinorCivFriendshipWithMajor(majorPlayerID)

		-- Status:
		-- Allies
		if minorPlayer:IsAllies(majorPlayerID) then
			strStatusText = "[COLOR_CYAN]" .. L("TXT_KEY_ALLIES")
		
		-- Friends
		elseif minorPlayer:IsFriends(majorPlayerID) then
			strStatusText = "[COLOR_POSITIVE_TEXT]" .. L("TXT_KEY_FRIENDS")
		
		-- Permanent War
		elseif minorPlayer:IsMinorPermanentWar(majorTeamID) then
			strStatusText = "[COLOR_NEGATIVE_TEXT]" .. L("TXT_KEY_PERMANENT_WAR")
		
		-- Peace blocked by being at war with ally
		elseif minorPlayer:IsPeaceBlocked(majorTeamID) then
			strStatusText = "[COLOR_FADING_NEGATIVE_TEXT]" .. L("TXT_KEY_PEACE_BLOCKED")
		
		-- War
		elseif isAtWar then
			strStatusText = "[COLOR_NEGATIVE_TEXT]" .. L("TXT_KEY_WAR")

		elseif majorInfluenceWithMinor < GameDefines.FRIENDSHIP_THRESHOLD_NEUTRAL then
			-- Afraid
			if minorPlayer:CanMajorBullyGold(majorPlayerID) then
				strStatusText = "[COLOR_PLAYER_LIGHT_ORANGE_TEXT]"..L("TXT_KEY_AFRAID").."[ENDCOLOR]"
			-- Angry
			else
				strStatusText = "[COLOR_MAGENTA]"..L("TXT_KEY_ANGRY")
			end
		
		-- Neutral
		else
			strStatusText = "[COLOR_WHITE]" .. L("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL")
		end
		
		strStatusText = strStatusText .. "[ENDCOLOR]"
		
		if not isAtWar then
			strStatusText = strStatusText .. " " .. majorInfluenceWithMinor .. " [ICON_INFLUENCE]"
			
			if majorInfluenceWithMinor ~= 0 then
				strStatusText = strStatusText .. (" (%+2.2g [ICON_INFLUENCE] / "):format(minorPlayer:GetFriendshipChangePerTurnTimes100(majorPlayerID) / 100) .. L("TXT_KEY_DO_TURN") .. ")" --"TXT_KEY_CITY_STATE_TITLE_TOOL_TIP_CURRENT"
			end
		end
	else
		print("Lua error - invalid player index")
	end

	return strStatusText
end

-------------------------------------------------
-- On Quest Info Clicked
-------------------------------------------------
function OnQuestInfoClicked()
	local activePlayerID = Game.GetActivePlayer()
	local minorPlayer = Players[ g_minorCivID ]
	if minorPlayer then
		if minorPlayer:IsMinorCivDisplayedQuestForPlayer( activePlayerID, questKillCamp ) then
			local questData1 = minorPlayer:GetQuestData1( activePlayerID, questKillCamp )
			local questData2 = minorPlayer:GetQuestData2( activePlayerID, questKillCamp )
			local plot = Map.GetPlot( questData1, questData2 )
			
			if plot then
				UI.LookAt( plot, 0 )
				local hex = ToHexFromGrid{ x=plot:GetX(), y=plot:GetY() }
				Events.GameplayFX( hex.x, hex.y, -1 )
			end
		end
	elseif (minorPlayer:IsMinorCivDisplayedQuestForPlayer(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_ARCHAEOLOGY)) then
		local iQuestData1 = minorPlayer:GetQuestData1(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_ARCHAEOLOGY)
		local iQuestData2 = minorPlayer:GetQuestData2(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_ARCHAEOLOGY)
		local plot = Map.GetPlot( questData1, questData2 )
		
		if plot then
			UI.LookAt( plot, 0 )
			local hex = ToHexFromGrid{ x=plot:GetX(), y=plot:GetY() }
			Events.GameplayFX( hex.x, hex.y, -1 )
		end
	elseif (minorPlayer:IsMinorCivDisplayedQuestForPlayer(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_DISCOVER_PLOT)) then
		local iQuestData1 = minorPlayer:GetQuestData1(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_DISCOVER_PLOT)
		local iQuestData2 = minorPlayer:GetQuestData2(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_DISCOVER_PLOT)
		local plot = Map.GetPlot( iQuestData1, iQuestData2 )
		
		if plot then
			UI.LookAt( plot, 0 )
			local hex = ToHexFromGrid{ x=plot:GetX(), y=plot:GetY() }
			Events.GameplayFX( hex.x, hex.y, -1 )
		end
	elseif (minorPlayer:IsMinorCivDisplayedQuestForPlayer(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_UNIT_GET_CITY)) then
		local iQuestData1 = minorPlayer:GetQuestData1(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_UNIT_GET_CITY)
		local iQuestData2 = minorPlayer:GetQuestData2(activePlayerID, MinorCivQuestTypes.MINOR_CIV_QUEST_UNIT_GET_CITY)
		local plot = Map.GetPlot( iQuestData1, iQuestData2 )
		
		if plot then
			UI.LookAt( plot, 0 )
			local hex = ToHexFromGrid{ x=plot:GetX(), y=plot:GetY() }
			Events.GameplayFX( hex.x, hex.y, -1 )
		end
	end
end
Controls.QuestInfo:RegisterCallback( Mouse.eLClick, OnQuestInfoClicked )

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- MAIN MENU
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------------------------------------
-- Pledge
----------------------------------------------------------------
function OnPledgeButtonClicked ()
	local activePlayerID = Game.GetActivePlayer()
	local minorPlayer = Players[g_minorCivID]

	if minorPlayer:CanMajorStartProtection( activePlayerID ) then
		Game.DoMinorPledgeProtection( Game.GetActivePlayer(), g_minorCivID, true )
		m_lastAction = kiPledgedToProtect
	end
end
Controls.PledgeButton:RegisterCallback( Mouse.eLClick, OnPledgeButtonClicked )

----------------------------------------------------------------
-- Revoke Pledge
----------------------------------------------------------------
function OnRevokePledgeButtonClicked ()
	local activePlayerID = Game.GetActivePlayer()
	local minorPlayer = Players[g_minorCivID]

	if minorPlayer:CanMajorWithdrawProtection(activePlayerID) then
		Game.DoMinorPledgeProtection(activePlayerID, g_minorCivID, false)
		m_lastAction = kiRevokedProtection
	end
end
Controls.RevokePledgeButton:RegisterCallback( Mouse.eLClick, OnRevokePledgeButtonClicked )

----------------------------------------------------------------
-- Marriage
----------------------------------------------------------------
function OnMarriageButtonClicked()
	local activePlayerID = Game.GetActivePlayer()
	local minorPlayer = Players[g_minorCivID]

	if minorPlayer:CanMajorMarry(activePlayerID) then
		OnCloseButtonClicked()
		Game.DoMinorBuyout(activePlayerID, g_minorCivID)
	end
end
Controls.MarriageButton:RegisterCallback( Mouse.eLClick, OnMarriageButtonClicked )

----------------------------------------------------------------
-- War
----------------------------------------------------------------
function OnWarButtonClicked ()
	UI.AddPopup{ Type = ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE, Data1 = g_minorCivTeamID, Option1 = true}
end
Controls.WarButton:RegisterCallback( Mouse.eLClick, OnWarButtonClicked )

----------------------------------------------------------------
-- Peace
----------------------------------------------------------------
function OnPeaceButtonClicked ()

	Network.SendChangeWar(g_minorCivTeamID, false)
	m_lastAction = kiMadePeace

end
Controls.PeaceButton:RegisterCallback( Mouse.eLClick, OnPeaceButtonClicked )

----------------------------------------------------------------
-- Stop/Start Unit Spawning
----------------------------------------------------------------
function OnStopStartSpawning()
	local minorPlayer = Players[g_minorCivID]
	local activePlayerID = Game.GetActivePlayer()

	local bSpawningDisabled = minorPlayer:IsMinorCivUnitSpawningDisabled(activePlayerID)

	-- Update the text based on what state we're changing to
	local strSpawnText
	if (bSpawningDisabled) then
		strSpawnText = L("TXT_KEY_CITY_STATE_TURN_SPAWNING_OFF")
	else
		strSpawnText = L("TXT_KEY_CITY_STATE_TURN_SPAWNING_ON")
	end

	Controls.NoUnitSpawningLabel:SetText(strSpawnText)

	Network.SendMinorNoUnitSpawning(g_minorCivID, not bSpawningDisabled)
end
Controls.NoUnitSpawningButton:RegisterCallback( Mouse.eLClick, OnStopStartSpawning )

----------------------------------------------------------------
-- Open Give Submenu
----------------------------------------------------------------
function OnGiveButtonClicked ()
	Controls.GiveStack:SetHide(false)
	Controls.TakeStack:SetHide(true)
	Controls.ButtonStack:SetHide(true)
	PopulateGiftChoices()
end
Controls.GiveButton:RegisterCallback( Mouse.eLClick, OnGiveButtonClicked )

----------------------------------------------------------------
-- Open Take Submenu
----------------------------------------------------------------
function OnTakeButtonClicked ()
	Controls.GiveStack:SetHide(true)
	Controls.TakeStack:SetHide(false)
	Controls.ButtonStack:SetHide(true)
	PopulateTakeChoices()
end
Controls.TakeButton:RegisterCallback( Mouse.eLClick, OnTakeButtonClicked )

----------------------------------------------------------------
-- Close or 'Active' (local human) player has changed
----------------------------------------------------------------
function OnCloseButtonClicked ()
	m_lastAction = kiNoAction
	m_pendingAction = kiNoAction
	UIManager:DequeuePopup( ContextPtr )
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnCloseButtonClicked )
Events.GameplaySetActivePlayer.Add( OnCloseButtonClicked )

----------------------------------------------------------------
-- Find On Map
----------------------------------------------------------------
function OnFindOnMapButtonClicked ()
	local minorPlayer = Players[g_minorCivID]
	
	if minorPlayer then
		local city = minorPlayer:GetCapitalCity()
		if city then
			local plot = city:Plot()
			if plot then
				UI.LookAt(plot, 0)
			end
		end
	end
end
Controls.FindOnMapButton:RegisterCallback( Mouse.eLClick, OnFindOnMapButtonClicked )

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- GIFT MENU
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function PopulateGiftChoices()
	local minorPlayer = Players[g_minorCivID]
	local activePlayerID = Game.GetActivePlayer()
	
	-- Unit
	local iInfluence = minorPlayer:GetFriendshipFromUnitGift(activePlayerID, false, true)
	local iTravelTurns = GameDefines.MINOR_UNIT_GIFT_TRAVEL_TURNS
	local buttonText = L("TXT_KEY_POP_CSTATE_GIFT_UNIT", iInfluence)
	local tooltipText = L("TXT_KEY_POP_CSTATE_GIFT_UNIT_TT", iTravelTurns, iInfluence)
	
	if minorPlayer:GetIncomingUnitCountdown(activePlayerID) >= 0 then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.UnitGiftAnim:SetHide(true)
		Controls.UnitGiftButton:ClearCallback( Mouse.eLClick )
	else
		Controls.UnitGiftAnim:SetHide(false)
		Controls.UnitGiftButton:RegisterCallback( Mouse.eLClick, OnGiftUnit )
	end
	
	Controls.UnitGift:SetText(buttonText)
	Controls.UnitGiftButton:SetToolTipString(tooltipText)
	
	SetButtonSize(Controls.UnitGift, Controls.UnitGiftButton, Controls.UnitGiftAnim, Controls.UnitGiftButtonHL)

	-- Tile Improvement
	-- Only allowed for allies
	iGold = minorPlayer:GetGiftTileImprovementCost(activePlayerID)
	local buttonText = L("TXT_KEY_POPUP_MINOR_GIFT_TILE_IMPROVEMENT", iGold)
	
	if not minorPlayer:CanMajorGiftTileImprovement(activePlayerID) then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.TileImprovementGiftAnim:SetHide(true)
	else
		Controls.TileImprovementGiftAnim:SetHide(false)
	end
	
	Controls.TileImprovementGift:SetText(buttonText)
	SetButtonSize(Controls.TileImprovementGift, Controls.TileImprovementGiftButton, Controls.TileImprovementGiftAnim, Controls.TileImprovementGiftButtonHL)
	
	UpdateButtonStack()
end

----------------------------------------------------------------
-- Gift Unit
----------------------------------------------------------------
function OnGiftUnit()
	OnCloseButtonClicked()
	UI.SetInterfaceMode( InterfaceModeTypes.INTERFACEMODE_GIFT_UNIT )
	UI.SetInterfaceModeValue( g_minorCivID )
end
Controls.UnitGiftButton:RegisterCallback( Mouse.eLClick, OnGiftUnit )

----------------------------------------------------------------
-- Gift Improvement
----------------------------------------------------------------
function OnGiftTileImprovement()
	local minorPlayer = Players[g_minorCivID]
	local activePlayerID = Game.GetActivePlayer()

	if minorPlayer:CanMajorGiftTileImprovement(activePlayerID) then
		OnCloseButtonClicked()
		UI.SetInterfaceMode( InterfaceModeTypes.INTERFACEMODE_GIFT_TILE_IMPROVEMENT )
		UI.SetInterfaceModeValue( g_minorCivID )
	end
end
Controls.TileImprovementGiftButton:RegisterCallback( Mouse.eLClick, OnGiftTileImprovement )

----------------------------------------------------------------
-- Close Give Submenu
----------------------------------------------------------------
function OnCloseGive()
	Controls.GiveStack:SetHide(true)
	Controls.TakeStack:SetHide(true)
	Controls.ButtonStack:SetHide(false)
	UpdateButtonStack()
end
Controls.ExitGiveButton:RegisterCallback( Mouse.eLClick, OnCloseGive )

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TAKE MENU
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function PopulateTakeChoices()
	local minorPlayer = Players[g_minorCivID]
	local activePlayerID = Game.GetActivePlayer()
	local buttonText = ""
	local ttText = ""

	buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_GOLD_AMOUNT",
			minorPlayer:GetMinorCivBullyGoldAmount(activePlayerID),
			(-GameDefines.MINOR_FRIENDSHIP_DROP_BULLY_GOLD_SUCCESS / 100) or 0 )
	
	if minorPlayer.GetMajorBullyGoldDetails then
		ttText = minorPlayer:GetMajorBullyGoldDetails(activePlayerID)
	else
		ttText = Locale.Lookup("TXT_KEY_POP_CSTATE_BULLY_GOLD_TT")
	end
	
	if (not minorPlayer:CanMajorBullyGold(activePlayerID)) then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.GoldTributeAnim:SetHide(true)
	else
		Controls.GoldTributeAnim:SetHide(false)
	end
	
	Controls.GoldTributeLabel:SetText(buttonText)
	Controls.GoldTributeButton:SetToolTipString(ttText)
	SetButtonSize(Controls.GoldTributeLabel, Controls.GoldTributeButton, Controls.GoldTributeAnim, Controls.GoldTributeButtonHL)

	local iTheftValue = 0
	local iBullyUnitInfluenceLost = (-GameDefines.MINOR_FRIENDSHIP_DROP_BULLY_WORKER_SUCCESS / 100)
	local pMajor = Players[activePlayerID]
	local sBullyUnit = GameInfo.Units[minorPlayer:GetBullyUnit()].Description --antonjs: todo: XML or fn
	
	if(pMajor:IsBullyAnnex()) then
		buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_UNIT_AMOUNT_ANNEX")
	else
		if(minorPlayer:GetMinorCivTrait() == MinorCivTraitTypes.MINOR_CIV_TRAIT_MARITIME) then
			iTheftValue = minorPlayer:GetYieldTheftAmount(activePlayerID, YieldTypes.YIELD_FOOD)
			buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_FOOD_AMOUNT", iTheftValue, iBullyUnitInfluenceLost)
		elseif(minorPlayer:GetMinorCivTrait() == MinorCivTraitTypes.MINOR_CIV_TRAIT_CULTURED) then
			iTheftValue = minorPlayer:GetYieldTheftAmount(activePlayerID, YieldTypes.YIELD_CULTURE)
			buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_CULTURE_AMOUNT", iTheftValue, iBullyUnitInfluenceLost)
		elseif(minorPlayer:GetMinorCivTrait() == MinorCivTraitTypes.MINOR_CIV_TRAIT_MILITARISTIC) then
			iTheftValue = minorPlayer:GetYieldTheftAmount(activePlayerID, YieldTypes.YIELD_SCIENCE)
			buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_SCIENCE_AMOUNT", iTheftValue, iBullyUnitInfluenceLost)
		elseif(minorPlayer:GetMinorCivTrait() == MinorCivTraitTypes.MINOR_CIV_TRAIT_MERCANTILE) then
			iTheftValue = minorPlayer:GetYieldTheftAmount(activePlayerID, YieldTypes.YIELD_PRODUCTION)
			buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_PRODUCTION_AMOUNT", iTheftValue, iBullyUnitInfluenceLost)
		elseif(minorPlayer:GetMinorCivTrait() == MinorCivTraitTypes.MINOR_CIV_TRAIT_RELIGIOUS) then
			iTheftValue = minorPlayer:GetYieldTheftAmount(activePlayerID, YieldTypes.YIELD_FAITH)
			buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_FAITH_AMOUNT", iTheftValue, iBullyUnitInfluenceLost)
		else
			buttonText = Locale.Lookup("TXT_KEY_POPUP_MINOR_BULLY_UNIT_AMOUNT", sBullyUnit, iBullyUnitInfluenceLost)
		end	
	end
	
	if minorPlayer.GetMajorBullyUnitDetails then
		ttText = minorPlayer:GetMajorBullyUnitDetails(activePlayerID)
	else
		ttText = Locale.Lookup("TXT_KEY_POP_CSTATE_BULLY_UNIT_TT", sBullyUnit, 4 ) --antonjs: todo: BullyUnitMinimumPop XML
	end
	
	if (not minorPlayer:CanMajorBullyUnit(activePlayerID)) then
		buttonText = "[COLOR_WARNING_TEXT]" .. buttonText .. "[ENDCOLOR]"
		Controls.UnitTributeAnim:SetHide(true)
	else
		Controls.UnitTributeAnim:SetHide(false)
	end
	
	Controls.UnitTributeLabel:SetText(buttonText)
	Controls.UnitTributeButton:SetToolTipString(ttText)
	SetButtonSize(Controls.UnitTributeLabel, Controls.UnitTributeButton, Controls.UnitTributeAnim, Controls.UnitTributeButtonHL)

	UpdateButtonStack()
end

----------------------------------------------------------------
-- Bully Action
----------------------------------------------------------------
function BullyAction(action)
	local minorPlayer = Players[g_minorCivID]
	
	if not minorPlayer then
		return
	end
	
	m_pendingAction = action
	local listofProtectingCivs = {}
	
	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		pOtherPlayer = Players[iPlayerLoop]

		-- Don't test protection status with active player!
		if iPlayerLoop ~= Game.GetActivePlayer() and pOtherPlayer:IsAlive() and pOtherPlayer:IsProtectingMinor(g_minorCivID) then
			table.insert(listofProtectingCivs, Locale.Lookup(Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()))
		end
	end

	local cityStateName = Locale.Lookup(minorPlayer:GetCivilizationShortDescriptionKey())

	local bullyConfirmString
	
	if action == kiDeclaredWar then
		if #listofProtectingCivs >= 1 then
			bullyConfirmString = L("TXT_KEY_CONFIRM_WAR_PROTECTED_CITY_STATE", cityStateName ) .. " " .. table.concat(listofProtectingCivs, ", ")
		else
			bullyConfirmString = cityStateName .. ": " .. L("TXT_KEY_CONFIRM_WAR")
		end
	else
		if #listofProtectingCivs == 1 then
			bullyConfirmString = L("TXT_KEY_CONFIRM_BULLY_PROTECTED_CITY_STATE", cityStateName, listofProtectingCivs[1])
		elseif #listofProtectingCivs > 1 then
			bullyConfirmString = L("TXT_KEY_CONFIRM_BULLY_PROTECTED_CITY_STATE_MULTIPLE", cityStateName, table.concat(listofProtectingCivs, ", "))
		else
			bullyConfirmString = L("TXT_KEY_CONFIRM_BULLY", cityStateName)
		end
	end

	Controls.BullyConfirmLabel:SetText( bullyConfirmString )
	Controls.BullyConfirm:SetHide(false)
	Controls.BGBlock:SetHide(true)
end

----------------------------------------------------------------
-- Take Gold
----------------------------------------------------------------
function OnGoldTributeButtonClicked()
	local minorPlayer = Players[g_minorCivID]
	local activePlayerID = Game.GetActivePlayer()

	if minorPlayer:CanMajorBullyGold(activePlayerID) then
		BullyAction( kiBulliedGold )
		OnCloseTake()
	end
end
Controls.GoldTributeButton:RegisterCallback( Mouse.eLClick, OnGoldTributeButtonClicked )

----------------------------------------------------------------
-- Take Unit
----------------------------------------------------------------
function OnUnitTributeButtonClicked()
	local minorPlayer = Players[g_minorCivID]
	local activePlayerID = Game.GetActivePlayer()

	if minorPlayer:CanMajorBullyUnit(activePlayerID) then
		BullyAction( kiBulliedUnit )
		OnCloseTake()
	end
end
Controls.UnitTributeButton:RegisterCallback( Mouse.eLClick, OnUnitTributeButtonClicked )

----------------------------------------------------------------
-- Close Take Submenu
----------------------------------------------------------------
function OnCloseTake()
	Controls.GiveStack:SetHide(true)
	Controls.TakeStack:SetHide(true)
	Controls.ButtonStack:SetHide(false)
	UpdateButtonStack()
end
Controls.ExitTakeButton:RegisterCallback( Mouse.eLClick, OnCloseTake )

-------------------------------------------------------------------------------
-- Bully Action Confirmation
-------------------------------------------------------------------------------
function OnYesBully( )
	local activePlayerID = Game.GetActivePlayer()
	
	if m_pendingAction == kiBulliedGold then
		Game.DoMinorBullyGold(activePlayerID, g_minorCivID)

	elseif m_pendingAction == kiBulliedUnit then
		--[VP]
		OnCloseButtonClicked()
		--[END]
		
		Game.DoMinorBullyUnit(activePlayerID, g_minorCivID)

	elseif m_pendingAction == kiDeclaredWar then
		Network.SendChangeWar(g_minorCivTeamID, true)
	else
		print("Scripting error - Selected Yes for bully confrirmation dialog, but invalid PendingAction type")
	end
	
	m_lastAction = m_pendingAction
	m_pendingAction = kiNoAction

	Controls.BullyConfirm:SetHide(true)
	Controls.BGBlock:SetHide(false)
end
Controls.YesBully:RegisterCallback( Mouse.eLClick, OnYesBully )

function OnNoBully( )
	m_lastAction = kiNoAction
	m_pendingAction = kiNoAction
	Controls.BullyConfirm:SetHide(true)
	Controls.BGBlock:SetHide(false)
end
Controls.NoBully:RegisterCallback( Mouse.eLClick, OnNoBully )
