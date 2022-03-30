/*
Compatibility patch for additional civilizations!
0 = Disabled disregarding if its detects Civilizaion.
1 = Enabled if it detects Civilization.
2 = Disabled until it detects something! (Default)
*/

INSERT INTO COMMUNITY	
		(Type,				Value)
VALUES	('CSL-CIV-ISR', 	2),
		('CSL-CIV-SUM', 	2),
		('CSL-CIV-TIM', 	2),
		('CSL-CIV-PAP', 	2),
		('CSL-CIV-CAN', 	2),
		('CSL-CIV-TIB', 	2),
		('CSL-CIV-FLA', 	2),
		('CSL-CIV-DUR', 	2);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-ISR' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_ISRAEL_MACCABEE') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-ISR' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-SUM' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_AKKADIAN_MOD_VULTURE') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-SUM' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-TIM' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_TIMURID_GHAZI_MOD') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIM' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-PAP' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_JFD_DISCIPLE') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-PAP' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-CAN' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_CANADIANVOYAGEUR') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-TIB' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_RTAKHRAB_KNIGHT') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIB' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-FLA' AND EXISTS (SELECT * FROM Improvements WHERE Type='IMPROVEMENT_LS_FLANDERS_COMMUNE') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-FLA' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-DUR' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_LS_JEZAIL_RIFLEMAN') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-DUR' AND Value= 0);

-- Main Compatibility Code
	-- updating art for new CSs
	-- Israel: Jerusalem ==> Balkh
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'balkh_leadericon.dds', LeaderPlace = 'Bactria', LeaderName = 'Demetrius I', LeaderTitle = 'King',	LeaderArtistName = 'tarcisiocm'
	WHERE Type = 'MINOR_CIV_JERUSALEM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-ISR' AND Value= 1);
	
	-- Sumer: Ur ==> Skara Brae
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'skara_brae_leadericon.dds', LeaderPlace = 'the Pictish Confederation', LeaderName = 'Oengus mac Fergusa', LeaderTitle = 'King',	LeaderArtistName = 'Firebug'
	WHERE Type = 'MINOR_CIV_UR' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-SUM' AND Value= 1);
	
	-- Timurids: Samarkand ==> Sanaa
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'sanaa_leadericon.dds', LeaderPlace = 'Sheba', LeaderName = 'Yahya', LeaderTitle = 'Imam',	LeaderArtistName = 'adan_eslavo'
	WHERE Type = 'MINOR_CIV_SAMARKAND' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIM' AND Value= 1);
	
	-- Papal States: Vatican ==> Karyes
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'karyes_leadericon.dds', LeaderPlace = 'the Roman province of Athos', LeaderName = 'Constantine I', LeaderTitle = 'Emperor',	LeaderArtistName = 'janboruta'
	WHERE Type = 'MINOR_CIV_VATICAN_CITY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-PAP' AND Value= 1);
	
	-- Canada: Quebec City ==> Honiara
	--		   Vancouver ==> St. Johns
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'honiara_leadericon.dds', LeaderPlace = 'Solomon Islands', LeaderName = 'Peter Kenilorea', LeaderTitle = 'Prime Minister sir',	LeaderArtistName = 'adan_eslavo'
	WHERE Type = 'MINOR_CIV_QUEBEC_CITY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 1);
	
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'stjohns_leadericon.dds', LeaderPlace = 'Newfoundland and Labrador', LeaderName = 'William Lyon Mackenzie King', LeaderTitle = '',	LeaderArtistName = 'adan_eslavo'
	WHERE Type = 'MINOR_CIV_VANCOUVER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 1);
	
	-- Tibet: Lhasa ==> Sarnath
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'sarnath_leadericon.dds', LeaderPlace = 'Maurya', LeaderName = 'Ashoka', LeaderTitle = 'King',	LeaderArtistName = 'LastSword'
	WHERE Type = 'MINOR_CIV_LHASA' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIB' AND Value= 1);
	
	-- Flanders: Brussels ==> Luxembourg
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'luxembourg_leadericon.dds', LeaderPlace = 'Luxembourg', LeaderName = 'Ermesinde II', LeaderTitle = 'Countess',	LeaderArtistName = 'DJSHenninger'
	WHERE Type = 'MINOR_CIV_BRUSELS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-FLA' AND Value= 1);
	
	-- Durrani: Kabul ==> Thimphu
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'thimphu_leadericon.dds', LeaderPlace = 'Bhutan', LeaderName = 'Jigme Dorji Wangchuck', LeaderTitle = 'Druk Gyalpo',	LeaderArtistName = 'janboruta'
	WHERE Type = 'MINOR_CIV_KABUL' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-DUR' AND Value= 1);