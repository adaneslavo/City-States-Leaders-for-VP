/*
Compatibility patch for additional civilizations!
0 = Disabled disregarding if its detects Civilizaion.
1 = Enabled if it detects Civilization.
2 = Disabled until it detects something! (Default)
*/

INSERT INTO COMMUNITY	
		(Type,				Value)
VALUES	('CSL-CIV-CAN', 	2),
		('CSL-CIV-ISR', 	2),
		('CSL-CIV-SUM', 	2),
		('CSL-CIV-TIM', 	2),
		('CSL-CIV-PHI', 	2),
		('CSL-CIV-PAP', 	2),
		('CSL-CIV-TIB', 	2),
		('CSL-CIV-FLA', 	2);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-CAN' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_CANADIANVOYAGEUR') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 0);

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
WHERE Type = 'CSL-CIV-TIB' AND EXISTS (SELECT * FROM Units WHERE Type='UNIT_RTAKHRAB_KNIGHT') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIB' AND Value= 0);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-CIV-FLA' AND EXISTS (SELECT * FROM Improvements WHERE Type='IMPROVEMENT_LS_FLANDERS_COMMUNE') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-FLA' AND Value= 0);


-- Main Compatibility Code
	-- updating art for new CSs

	-- @pineappledan
	-- Canada: Quebec City ==> Honiara
	--		   Vancouver ==> St. Johns
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'honiara_leadericon.dds', LeaderPlace = 'Solomon Islands', LeaderName = 'Peter Kenilorea', LeaderTitle = 'Prime Minister sir',	LeaderArtistName = 'adan_eslavo'
	WHERE Type = 'MINOR_CIV_QUEBEC_CITY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 1);
	
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'stjohns_leadericon.dds', LeaderPlace = 'Newfoundland and Labrador', LeaderName = 'William Lyon Mackenzie King', LeaderTitle = '',	LeaderArtistName = 'adan_eslavo'
	WHERE Type = 'MINOR_CIV_VANCOUVER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 1);
	
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
	
	
	
	-- @HungryForFood
	-- Papal States: Vatican ==> Karyes
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'karyes_leadericon.dds', LeaderPlace = 'the Roman province of Athos', LeaderName = 'Constantine I', LeaderTitle = 'Emperor',	LeaderArtistName = 'janboruta'
	WHERE Type = 'MINOR_CIV_VATICAN_CITY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-PAP' AND Value= 1);
	
	
	-- @hokath
	-- Tibet: Lhasa ==> Sarnath
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'sarnath_leadericon.dds', LeaderPlace = 'Maurya', LeaderName = 'Ashoka', LeaderTitle = 'King',	LeaderArtistName = 'LastSword'
	WHERE Type = 'MINOR_CIV_LHASA' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIB' AND Value= 1);
	
	-- Flanders: Brussels ==> Luxembourg
	UPDATE MinorCivLeaders
	SET LeaderIcon = 'luxembourg_leadericon.dds', LeaderPlace = 'Luxembourg', LeaderName = 'Ermesinde II', LeaderTitle = 'Countess',	LeaderArtistName = 'DJSHenninger'
	WHERE Type = 'MINOR_CIV_BRUSELS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-FLA' AND Value= 1);


	
	-- updating UCS traits for new CSs

	-- @pineappledan
	-- Quebec City ==> Peter Kenilorea, Honiara, maritime
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Fur and Lumber', 'Forests of Guadalcanal')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_QUEBEC_CITY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);

	-- Vanocuver ==> William Lyon Mackenzie King, St. Johns, maritime
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Terminal City', 'Industry from the North')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_VANCOUVER' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-CAN' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	-- Jerusalem ==> Demetrius I, Balkh, religious
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Holy Lands', 'Religions of Amu Darya')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_JERUSALEM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-ISR' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Jerusalem', 'Balkh')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_JERUSALEM' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-ISR' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	-- Ur ==> Oengus mac Fergusa, Skara Brae, maritime
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Cradle of Civilization', 'The Heart of Neolithic Orkney')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_UR' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-SUM' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	-- Samarkand ==> Sheba, Sanaa, mercantile
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'The Sogd', 'Bab el-Mandeb Strait')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_SAMARKAND' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIM' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	

	-- @HungryForFood
	-- Vatican City ==> Constantine I, Karyes, religious
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Absolute Faith', 'The Garden of the Mother of God')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_VATICAN_CITY' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-PAP' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	

	-- @hokath
	-- Lhasa ==> Ashoka, Sarnath, religious
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'A Place Among the Gods', 'Pilgrimage to Isipatana')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_LHASA' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIB' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Lhasa', 'Sarnath')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_LHASA' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-TIB' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	-- Brussels ==> Ermesinde II, Luxembourg, cultural
	UPDATE Language_en_US
	SET Text = REPLACE(Text, 'Home of the Marsh', 'Charters of Freedom')
	WHERE Tag = 'TXT_KEY_CSTRAIT_MINOR_CIV_BRUSSELS' AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-CIV-FLA' AND Value= 1) AND EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);