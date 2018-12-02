/*
UCS compatibility patch!
0 = Disabled disregarding if its detects UCS by Enginseer.
1 = Enabled if it detects the UCS by Enginseer.
2 = Disabled until it detects something! (Default)
*/

INSERT INTO COMMUNITY	
		(Type,			Value)
VALUES	('CSL-UCS', 	2);

UPDATE COMMUNITY
SET Value = '1'
WHERE Type = 'CSL-UCS' AND EXISTS (SELECT * FROM MinorCivilizations WHERE Type='MINOR_CIV_HONDURAS') AND NOT EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 0);

-- Main Compatibility Code
	-- adding art for new CSs
	-- 1st part
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_AUCKLAND',		'wellington_leadericon2.dds',	'New Zealand',			'Henry Sewell',				'Premier',		'TPangolin'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_GRANADA',		'granada_leadericon.dds',		'Granada',				'Muhammad I ibn Yusuf',		'Emir',			'Mosile'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_NANMANDOL',		'leluh_leadericon.dds',			'Nan Madol',			'Olosohpa',					'',				'Gedemo'
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_MUSCAT',			'muscat_leadericon.dds',		'Oman',					'Saif bin Sultan',			'Imam',			'janboruta'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_CLERMONT',		'clermont_leadericon.dds',		'Clermont-Ferrand',		'Urban II',					'Pope',			'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_HONDURAS',		'honduras_leadericon.dds',		'Honduras',				'Manuel Bonilla Chirinos',	'President',	'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_ARMAGH',			'armagh_leadericon.dds',		'Ireland',				'Saint Patrick',			'',				'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	--2nd part
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_GWYNEDD',		'gwynedd_leadericon.dds',		'Wales',				'Owain Glyndwr',			'Prince',		'janboruta'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_LACONIA',		'lacedaemon_leadericon.dds',	'Lacedaemon',			'Leonidas',					'King',			'janboruta'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_MUISCA',			'muisca_leadericon.dds',		'Muisca',				'Nemequene',				'Zipa',			'Leugi'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_YANGCHENG',		'yangcheng_leadericon.dds',		'Xia',					'Yu',						'Emperor',		'janboruta'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_PHANOTEUS',		'phanoteus_leadericon.dds',		'Phocia',				'Onomarchus',				'General',		'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_MANAGUA',		'managua_leadericon.dds',		'Nicaragua',			'Anastasio Somoza Garcia',	'President',	'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_SANTO_DOMINGO',	'santo_domingo_leadericon.dds',	'Domican Republic',		'Juan Pablo Duarte',		'',				'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_CHEVAK',			'chevak_leadericon.dds',		"Yup'ik",				'Apanuugpak',				'General',		'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_DOUALA',			'douala_leadericon.dds',		'Cameroon',				'Ahmadou Ahidjo',			'President',	'Mosile'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
	
	INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,			LeaderName,					LeaderTitle,	LeaderArtistName)
	SELECT		'MINOR_CIV_ODENSO',			'odenso_leadericon.dds',		'Finland',				'Karl Gustaf Mannerheim',	'Baron',		'Hypereon'	
	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);