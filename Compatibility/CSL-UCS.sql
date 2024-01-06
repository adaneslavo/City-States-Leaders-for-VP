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
	INSERT INTO MinorCivLeaders
				(Type,						LeaderIcon,						LeaderPlace,									LeaderName,								LeaderTitle,			LeaderArtistName)
		SELECT	'MINOR_CIV_ADEJE',			'adeje_leadericon.dds',			'the Guanches',									'Tinerfe',								'Grand Mencey',			'DJSHenninger'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_AL_TIRABIN',		'al_tarabin_leadericon.dds',	'the Bedouins',									'Hamad Pasha as-Sufi',					'Leader',				'Grant'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_AMBRACIA',		'ambracia_leadericon.dds',		'the Epirus',									'Pyrrhus',								'King',					'Danmacsch'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_ANANGULA',		'anangula_leadericon.dds',		'the Aleuts',									'Agugux',								'Creator',				'TopHatPaladin'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_ANDORRA',		'andorra_leadericon2.dds',		'the Principality of Andorra',					'Roger-Bernard III',					'Count',				'Grant'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_ANDORRA',		'andorra_leadericon.dds',		'the Principality of Andorra',					'Roger-Bernard III',					'Count',				'Kiang'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_ANDORRA',		'tintagel_leadericon2.dds',		'the Principality of Andorra',					'Roger-Bernard III',					'Count',				'DuskJockey'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_ARMAGH',			'armagh_leadericon.dds',		'the Gaelic Ireland',							'Patrick',								'Saint',				'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_AUCKLAND',		'parihaka_leadericon.dds',		'the Ngati Toa' /*Ngāti Toa*/,					'Te Rauparaha',							'Rangatira',			'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
--[ALT]	SELECT	'MINOR_CIV_AUCKLAND',		'wellington_leadericon2.dds',	'New Zealand',									'Henry Sewell',							'Prime Minister',		'TPangolin'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
		SELECT	'MINOR_CIV_AYUTTHAYA',		'ayutthaya_leadericon.dds',		'the Kingdom of Ayutthaya',						'Naresuan',								'King',					'sukritact'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_BAGAN',			'bagan_leadericon.dds',			'the Kingdom of Pagan',							'Anawrahta Minsaw',						'King',					'Sukritact'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_BALKH',			'balkh_leadericon.dds',			'the Greco-Bactrian Kingdom',					'Demetrios I',							'King',					'tarcisiocm'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_BEDULU',			'bedulu_leadericon.dds',		'the Kingdom of Bali',							'Mahendradatta',						'Queen',				'TopHatPaladin'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_CANOSSA',		'canossa_leadericon.dds',		'the March of Tuscany',							'Matilda',								'Margravine',			'DuskJockey'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
		SELECT	'MINOR_CIV_CHEVAK',			'chevak_leadericon.dds',		"the Yup'ik",									'Apanuugpak',							'General',				'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_CLERMONT',		'clermont_leadericon.dds',		'the Duchy of Aquitaine',						'Urban II',								'Pope',					'DarthKyofu'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_CLERMONT',		'clermont_leadericon2.dds',		'the Duchy of Aquitaine',						'Urban II',								'Pope',					'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_DAKKAR',			'dakkar_leadericon.dds',		'the Adal Empire',								'Sabr ad-Din III',						'Sultan',				'Lime'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_DALI',			'dali_leadericon.dds',			'the Kingdom of Dali',							'Duan Siping',							'Commander',			'Grant'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_DANO',			'dano_leadericon.dds',			'the Kingdom of Dagara',						'Salifu Diayor',						'Naa',					'LastSword'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_DJIBOUTI',		'djibouti_leadericon.dds',		'the Republic of Djibouti',						'Hassan Gouled Aptidon',				'President',			'adan_eslavo'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_DODOMA',			'dodoma_leadericon.dds',		'the United Republic of Tanzania',				'Ali Hassan Mwinyi',					'President',			'Danmacsch'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_DOUALA',			'douala_leadericon.dds',		'the Republic of Cameroon',						'Ahmadou Ahidjo',						'President',			'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_FAYA',			'faya_leadericon.dds',			'the Republic of Chad',							'Idriss Deby',							'President',			'RawSasquatch'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_FAYA',			'faya_leadericon2.dds',			'the Republic of Chad',							'Idriss Deby',							'President',			'adan_eslavo'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_GRANADA',		'granada_leadericon.dds',		'the Emirate of Granada',						'Muhammad I ibn Yusuf',					'Emir',					'sukritact'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
--[ALT]	SELECT	'MINOR_CIV_GRANADA',		'granada_leadericon2.dds',		'the Emirate of Granada',						'Muhammad I ibn Yusuf',					'Emir',					'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
		SELECT	'MINOR_CIV_GWYNEDD',		'gwynedd_leadericon.dds',		'the Kingdom of Gwynedd',						'Owain Glyndwr' /*Owain Glyndŵr*/,		'Prince',				'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_HANUABADA',		'hanuabada_leadericon.dds',		'the Motu people',								'Edai Siabo',							'Champion',				'RawSasquatch'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_HONDURAS',		'honduras_leadericon.dds',		'the Republic of Honduras',						'Manuel Bonilla Chirinos',				'President',			'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_HONIARA',		'honiara_leadericon.dds',		'the Solomon Islands',							'Peter Kenilorea',						'Prime Minister sir',	'adan_eslavo'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_IRUNEA',			'irunea_leadericon.dds',		'the Kingdom of Iruñea',						'Antso VI.a, Jakituna',					'King',					'Gwennog'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_IRUNEA',			'irunea_leadericon2.dds',		'the Kingdom of Iruñea',						'Eneko Aritza',							'King',					'Gwennog'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_ISKANWAYA',		'iskanwaya_leadericon.dds',		'the Kallawaya people',							'Mallku',								'',						'Leugi'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_JETARKTE',		'jetarkte_leadericon.dds',		'the Kawesqar' /*Kawésqar*/,					'Terwa Koyo',							'',						'HoopThrower and DarthStarKiller'	WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_JUYUBIT',		'juyubit_leadericon.dds',		'the Tongva',									'Toypurina',							'Healer',				'Rawsasquatch'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_KARASJOHKA',		'karasjohka_leadericon.dds',	'the Sami',										'Eadni',								'Mother',				'Sukritact'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_KARYES',			'karyes_leadericon.dds',		'the Roman province of Athos',					'Constantine I',						'Emperor',				'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_KATENDE',		'katende_leadericon.dds',		'the Kingdom of Luba',							'Ilunga Sungu',							'King',					'TopHatPaladin'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_KIGALI',			'kigali_leadericon.dds',		'the Kingdom of Rwanda',						'Kigeli IV Rwabugiri',					'Mwami',				'Danmacsch'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_LACONIA',		'lacedaemon_leadericon.dds',	'the Laconia',									'Leonidas I',							'King',					'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_LAHORE',			'lahore_leadericon.dds',		'the Sikh Empire',								'Ranjit Singh',							'Great Maharaja',		'RawSasquatch'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_LEVUKA',			'levuka_leadericon.dds',		'the Kingdom of Fiji',							'Seru Epenisa Cakobau',					'Ratu',					'Arilasqueto'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_LONGYAN',		'longyan_leadericon.dds',		'the Hakka',									'Chen Lanjisi',							'Rebellion Leader',		'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_LONGYAN',		'longyan_leadericon2.dds',		'the Hakka',									'Chen Lanjisi',							'Rebellion Leader',		'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_MANAGUA',		'managua_leadericon.dds',		'the Republic of Nicaragua',					'Augusto Cesar Sandino',				'',						'Senshi'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_MANAGUA',		'managua_leadericon2.dds',		'the Republic of Nicaragua',					'Anastasio Somoza Garcia',				'President',			'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_MBABANE',		'mbabane_leadericon.dds',		'the Kingdom of Eswatini',						'Labotsibeni Mdluli',					'Queen Mother',			'Danmacsch'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_MENDYARRUP',		'mendyarrup_leadericon.dds',	'the Noongar',									'Yagan',								'Warrior',				'TopHatPaladin'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_MUISCA',			'muisca_leadericon.dds',		'the Muisca Confederation',						'Nemequene',							'Zipa',					'Leugi'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_MULTAN',			'multan_leadericon.dds',		'the Ghazhnavid Empire',						'Mahmud ibn Sabuktigin',				'Sultan',				'TopHatPaladin'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_MUSCAT',			'muscat_leadericon.dds',		'the Sultanate of Oman',						'Saif bin Sultan',						'Imam',					'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_MUTITJULU',		'mutitjulu_leadericon.dds',		'the Anangu tribes',							'Robert James Randall',					'Tjilpi',				'TopHatPaladin and DarthKyofu'		WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_NAN_MADOL',		'leluh_leadericon.dds',			'the Nan Madol',								'Isokelekel',							'Conqueror',			'Jarcast'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
--[ALT]	SELECT	'MINOR_CIV_NAN_MADOL',		'leluh_leadericon2.dds',		'the Nan Madol',								'Olosohpa',								'',						'Gedemo'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
		SELECT	'MINOR_CIV_NYARYANA_MARQ',	'nyaryana_marq_leadericon.dds',	'the Nenets',									'Vavlyo Neniang',						'',						'TPangolin'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_OC_EO',			'oc_eo_leadericon.dds',			'the Funan Kingdom' /*Fúnán*/,					'Soma',									'Queen',				'Grant'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_ODENSO',			'odenso_leadericon.dds',		'the Republic of Finland',						'Karl Gustaf Mannerheim',				'Baron',				'Hypereon'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_OUIDAH',			'ouidah_leadericon.dds',		'the Kingdom of Whydah',						'Haffon',								'King',					'Hoop Thrower'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_PALMYRA',		'palmyra_leadericon.dds',		'the Palmyrene Empire',							'Bat-Zabbai' /*Septima Zenobia*/,		'Queen',				'TPangolin'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_PELYM',			'pelym_leadericon.dds',			'the Permians',									'Azykay',								'Grand Duke',			'Grant'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_PHANOTEUS',		'phanoteus_leadericon.dds',		'the Phocis',									'Onomarchus',							'General',				'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_PHANOTEUS',		'phanoteus_leadericon2.dds',	'the Phocis',									'Onomarchus',							'General',				'Merrick'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_POKROVKA',		'pokrovka_leadericon.dds',		'the Massagetae Confederation',					'Tomyris',								'Queen',				'TarcisioCM'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_QUELIMANE',		'quelimane_leadericon.dds',		'the Republic of Mozambique' /*Moçambique*/,	'Manuel de Araújo',						'Mayor',				'adan_eslavo'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_RISHIKESH',		'rishikesh_leadericon.dds',		'the Kingdom of Garhwal',						'Kanak Pal Paramara',					'Raja',					'EmeraldRange'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SADDARVAZEH',	'saddarvazeh_leadericon.dds',	'the Achaemenid Empire',						'Vistaspa' /*Vištāspa*/,				'Satrap',				'Gwennog'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SANAA',			'sanaa_leadericon.dds',			'the Sultanate of Yemen',						'Arwa al-Sulayhi',						'Queen',				'Urdnot '							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_SANAA',			'sanaa_leadericon2.dds',		'Sheba',										'Yahya',								'Imam',					'adan_eslavo'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SANTO_DOMINGO',	'santo_domingo_leadericon.dds',	'the Domican Republic',							'Juan Pablo Duarte',					'',						'Mosile'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SARNATH',		'sarnath_leadericon.dds',		'the Maurya Empire',							'Ashoka',								'Emperor',				'LastSword'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
--[ALT]	SELECT	'MINOR_CIV_SARNATH',		'sarnath_leadericon2.dds',		'the Maurya Empire',							'Ashoka',								'Emperor',				'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
		SELECT	'MINOR_CIV_SGANG_GWAAY',	'sgang_leadericon.dds',			'the Haida',									'Koyah',								'Chief',				'RawSasquatch'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_SGANG_GWAAY',	'sgang_leadericon2.dds',		'the Haida',									'Koyah',								'Chief',				'LastSword'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SIERRA_LEONE',	'sierra_leone_leadericon.dds',	'the Republic of Sierra Leone',					'Sir Milton Margai',					'Prime Minister',		'adan_eslavo'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SUCEAVA',		'suceava_leadericon.dds',		'the Moldavian Empire',							'Stephen III',							'King',					'DJSHenninger'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SURREY',			'surrey_leadericon.dds',		'the Kingdom of Great Britain',					'George V',								'King',					'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_SURREY',			'surrey_leadericon2.dds',		'the Kingdom of West Saxons',					'Aethelwulf',							'King',					'adan_eslavo'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_TAIWAN',			'taipei_leadericon.dds',		'the Republic of China',						'Sun Yat-sen',							'President',			'DJSHenninger'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
--[ALT]	SELECT	'MINOR_CIV_TAIWAN',			'taipei_leadericon2.dds',		'the Republic of China',						'Sun Yat-sen',							'President',			'JakeWalrusWhale'					WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_TBILISI',		'tbilisi_leadericon.dds',		'the Kingdom of Georgia',						'Tamar',								'Queen',				'Urdnot'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
--[ALT]	SELECT	'MINOR_CIV_TBILISI',		'tbilisi_leadericon2.dds',		'the Kingdom of Georgia',						'Tamar',								'Queen',				'Urdnot'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL
		SELECT	'MINOR_CIV_THIMPHU',		'thimphu_leadericon.dds',		'the Kingdom of Bhutan',						'Jigme Dorji Wangchuck',				'Druk Gyalpo',			'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_TIWANAKU',		'tiwanaku_leadericon.dds',		'the Tiwanaku-Wari Empire',						'Huyustus',								'Cacique',				'Leugi'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_TUNIS',			'tunis_leadericon.dds',			'the Hafsid Sultanate',							'Abu Zakariya Yahya',					'Sultan',				'Regalman'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_WOOTEI_NIICIE',	'wootei_niicie_leadericon.dds',	'the Arapaho',									'Pretty Nose',							'War Chief',			'Arilasqueto'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_YANGCHENG',		'yangcheng_leadericon.dds',		'the Xia Dynasty',								'Yu',									'Emperor',				'janboruta'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1);
		
		/*
		SELECT	'MINOR_CIV_ISHIYAMA',		'ishiyama_leadericon.dds',		'the Ikko-ikki' Ikkō-ikki,						'Kosa',	Kōsa							'Chief Abbot',			'PorkBean'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_SHAHRAZUR',		'shahrazur_leadericon.dds',		'the Principality of Ardalan',					'Bani Ardalan',							'King',					'Darth'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_YAIUWA',			'yaiuwa_leadericon.dds',		'the Haush',									'Tenenisk',								'Shaman',				'Grant'								WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		*/
		
		/*
		SELECT	'MINOR_CIV_SKARA_BRAE',		'skara_brae_leadericon.dds',	'the Pictish Confederation',					'Oengus mac Fergusa',					'King',					'Firebug'							WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		SELECT	'MINOR_CIV_LUXEMBOURG',		'luxembourg_leadericon.dds',	'the Grand Duchy of Luxembourg',				'Ermesinde II',							'Countess',				'DJSHenninger'						WHERE EXISTS (SELECT * FROM COMMUNITY WHERE Type='CSL-UCS' AND Value= 1) UNION ALL	
		*/