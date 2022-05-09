CREATE TABLE IF NOT EXISTS MinorCivLeaders (
	'ID' INTEGER PRIMARY KEY AUTOINCREMENT,
	'Type' TEXT NOT NULL UNIQUE,
	'LeaderIcon' TEXT NOT NULL,
	'LeaderPlace' TEXT DEFAULT NULL,
	'LeaderName' TEXT DEFAULT NULL,
	'LeaderTitle' TEXT DEFAULT NULL,
	'LeaderArtistName' TEXT DEFAULT NULL,
	FOREIGN KEY (Type) REFERENCES MinorCivilizations(Type));

INSERT INTO MinorCivLeaders(
				Type,						LeaderIcon,						LeaderPlace,					LeaderName,					LeaderTitle,		LeaderArtistName)
		SELECT	'MINOR_CIV_ALMATY',			'almaty_leadericon.dds',		'the Kazakh Khanate',			'Janybek Khan',				'',					'knightmare13'				UNION ALL
		SELECT	'MINOR_CIV_ANTANANARIVO',	'antananarivo_leadericon.dds',	'the Kingdom of Imerina',		'Ranavalona I',				'Queen',			'Nutty'						UNION ALL
		SELECT	'MINOR_CIV_ANTWERP',		'antwerp_leadericon.dds',		'Flanders',						'Robert III',				'Count',			'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_BELGRADE',		'belgrade_leadericon.dds',		'Serbia',						'Karadorde Petrovic',		'Grand Vozd',		'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_BOGOTA',			'bogota_leadericon.dds',		'Gran Colombia',				'Simon Bolivar',			'President',		'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_BRATISLAVA',		'bratislava_leadericon.dds',	'Great Moravia',				'Svatopluk I',				'King',				'J. Kohler/Nutty'			UNION ALL
		SELECT	'MINOR_CIV_BRUSSELS',		'brussels_leadericon.dds',		'the Belgians',					'Leopold II',				'King',				'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_BUCHAREST',		'bucharest_leadericon.dds',		'Wallachia',					'Vlad III',					'Voivode',			'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_BUDAPEST',		'budapest_leadericon.dds',		'the Kingdom of Hungary',		'Stephen I',				'King Saint',		'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_BUENOS_AIRES',	'buenos_aires_leadericon.dds',	'the Argentine Republic',		'Eva Peron',				'',					'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_BYBLOS',			'byblos_leadericon.dds',		'the Kingdom of Byblos ',		'Ahiram',					'King',				'LastSword'					UNION ALL
		SELECT	'MINOR_CIV_CAHOKIA',		'cahokia_leadericon.dds',		'the Mississippians',			'Birdman',					'King',				'H. Roe/Nutty'				UNION ALL
		SELECT	'MINOR_CIV_CAPE_TOWN',		'cape_town_leadericon.dds',		'the Dutch East India Company',	'Jan van Riebeeck',			'Commander',		'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_COLOMBO',		'colombo_leadericon.dds',		'the Dominion of Ceylon',		'D.S. Senanayake',			'Prime Minister',	'knightmare13'				UNION ALL
		SELECT	'MINOR_CIV_FLORENCE',		'florence_leadericon.dds',		'the Florence Republic',		"Lorenzo de'Medici",	 	'',					'sukritact'					UNION ALL
		SELECT	'MINOR_CIV_GENEVA',			'geneva_leadericon.dds',		'the Old Swiss Confederacy',	'John Calvin',				'Pastor',			'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_GENOA',			'genoa_leadericon.dds',			'the Republic of Genoa',		'Andrea Doria',				'Condottiero',		'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_HANOI',			'hanoi_leadericon.dds',			'Dai Viet',						'Ly Thai To',				'Emperor',			'davey_henninger'			UNION ALL
		SELECT	'MINOR_CIV_HONG_KONG',		'hong_kong_leadericon.dds',		'the British Hong Kong',		'Kai Ho',					'Sir',				'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_IFE',			'ife_leadericon.dds',			'Ife-Ife',						'Akinmoyero',				'Ooni',				'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_JERUSALEM',		'jerusalem_leadericon.dds',		'the Kingdom of Israel',		'Solomon',					'King',				'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_KABUL',			'kabul_leadericon.dds',			'the Durrani Empire',			'Ahmad Shah Durrani',		'Emir',				'LastSword'					UNION ALL
		SELECT	'MINOR_CIV_KATHMANDU',		'kathmandu_leadericon.dds',		'the Kingdom of Nepal',			'Tribhuvan',				'King',				'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_KIEV',			'kiev_leadericon.dds',			"the Kievan Rus'",				'Yaroslav I',				'Grand Prince',		'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_KUALA_LUMPUR',	'kuala_lumpur_leadericon.dds',	'the Fed. Ter. of Kuala Lumpur','Yap Ah Loy',				'Kapitan Cina',		'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_KYZYL',			'kyzyl_leadericon.dds',			'the Little Khural',			'Khertek Anchimaa-Toka', 	'Chairwoman',		'Nutty'						UNION ALL
		SELECT	'MINOR_CIV_LA_VENTA',		'la_venta_leadericon.dds',		'the Olmecs',					'Po Ngbe',					'Ku',				'LastSword'					UNION ALL
		SELECT	'MINOR_CIV_LHASA',			'lhasa_leadericon.dds',			'Tibet',						'Thubten Gyatso',			'13th Dalai Lama',	'sukritact'					UNION ALL
		SELECT	'MINOR_CIV_MALACCA',		'malacca_leadericon2.dds',		'the Malacca Sultanate',		'Parameswara',				'Sultan',			'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_MANILA',			'manila_leadericon.dds',		'the Philippines Republic',		'Jose Rizal',				'',					'knightmare13'				UNION ALL
		SELECT	'MINOR_CIV_MBANZA_KONGO',	'mbanza_kongo_leadericon.dds',	'the Ambundu Kingdoms',			'Nzingha Mbande',			'Queen',			'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_MELBOURNE',		'melbourne_leadericon.dds',		'the Colony of New South Wales','John Batman',				'',					'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_MILAN',			'milan_leadericon.dds',			'the Duchy of Milan',			'Gian Galeazzo Visconti', 	'Duke',				'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_MOGADISHU',		'mogadishu_leadericon.dds',		'the Fed. Rep. of Somalia',		'Aden Adde',				'President',		'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_MOMBASA',		'mombasa_leadericon.dds',		'the Republic of Kenya',		'Jomo Kenyatta',			'President',		'knightmare13'				UNION ALL
		SELECT	'MINOR_CIV_MONACO',			'monaco_leadericon.dds',		'the Principality of Monaco',	'Rainier III',				'Prince',			'knightmare13'				UNION ALL
		SELECT	'MINOR_CIV_ORMUS',			'ormus_leadericon.dds',			'the Sultanate of Oman',		'Qaboos bin Said',			'Sultan',			'knightmare13'				UNION ALL
		SELECT	'MINOR_CIV_PANAMA_CITY',	'panama_city_leadericon.dds',	'the Republic of Panama',		'Victoriano Lorenzo',		'General',			'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_PRAGUE',			'prague_leadericon.dds',		'the Kingdom of Bohemia',		'Wenceslaus II',			'King',				'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_QUEBEC_CITY',	'quebec_city_leadericon.dds',	'Canada',						'John A. MacDonald',		'Prime Minister',	'davey_henninger'			UNION ALL
		SELECT	'MINOR_CIV_RAGUSA',			'ragusa_leadericon.dds',		'Ragusa',						'Auguste de Marmont',		'Duke',				'Nutty'						UNION ALL
		SELECT	'MINOR_CIV_RIGA',			'riga_leadericon.dds',			'the Republik of Latvia',		'Janis Cakste',				'President',		'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_SAMARKAND',		'samarkand_leadericon.dds',		'the Timurid Empire',			'Timur',					'Emir',				'M. Gerasimov/LastSword' 	UNION ALL
		SELECT	'MINOR_CIV_SIDON',			'sidon_leadericon.dds',			'the Kingdom of Sidon',			'Eshmunazar II',			'King',				'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_SINGAPORE',		'singapore_leadericon.dds',		'the Republic of Singapore',	'Lee Kuan Yew',				'Prime Minister',	'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_SOFIA',			'sofia_leadericon.dds',			'the Bulgarians and Romans',	'Simeon I',					'Tsar',				'D. Giudjenov/Nutty'		UNION ALL
		SELECT	'MINOR_CIV_SYDNEY',			'sydney_leadericon.dds',		'the Colony of New South Wales','Arthur Phillip',			'Governor',			'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_TYRE',			'tyre_leadericon.dds',			'the Kingdom of Tyre',			'Hiram I',					'King',				'LastSword'					UNION ALL
		SELECT	'MINOR_CIV_UR',				'ur_leadericon.dds',			'Sumer',						'Eannatum',					'King',				'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_VALLETTA',		'valletta_leadericon.dds',		'the Knights of Malta',			'Giovanni Paolo Lascaris', 	'Grand Master',		'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_VANCOUVER',		'vancouver_leadericon.dds',		'Canada',						'Mackenzie King',			'Prime Minister',	'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_VATICAN_CITY',	'vatican_city_leadericon.dds',	'Vatican',						'Pius IX',					'Pope',				'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_VILNIUS',		'vilnius_leadericon.dds',		'the Grand Duchy of Lithuania',	'Gediminas',				'Grand Duke',		'LastSword'					UNION ALL
		SELECT	'MINOR_CIV_WELLINGTON',		'wellington_leadericon.dds',	'New Zealand',					'Richard Seddon',			'Prime Minister',	'TPangolin'					UNION ALL
		SELECT	'MINOR_CIV_WITTENBERG',		'wittenberg_leadericon.dds',	'the Kingdom of Saxony',		'Frederick III',			'Prince Elector',	'janboruta'					UNION ALL
		SELECT	'MINOR_CIV_YEREVAN',		'yerevan_leadericon.dds',		'the Kingdom of Armenia',		'Tigranes II',				'King',				'Leugi'						UNION ALL
		SELECT	'MINOR_CIV_ZANZIBAR',		'zanzibar_leadericon.dds',		'the Sultanate of Zanzibar',	'Barghash bin Said',		'Sultan',			'TopHatPaladin'				UNION ALL
		SELECT	'MINOR_CIV_ZURICH',			'zurich_leadericon.dds',		'the Swiss Confederacy', 		'Guillaume-Henri Dufour', 	'General',			'JFD'						;
		
--[ALT]	SELECT	'MINOR_CIV_ANTANANARIVO',	'antananarivo_leadericon2.dds',	'the Kingdom of Imerina',		'Andrianampoinimerina',		'King',				'TPangolin'					UNION ALL
--[ALT]	SELECT	'MINOR_CIV_BUENOS_AIRES',	'buenos_aires_leadericon2.dds',	'Cuyo, United Provinces', 		'Jose de San Martin',		'General Don',		'Leugi'						UNION ALL
--[ALT]	SELECT	'MINOR_CIV_CAHOKIA',		'cahokia_leadericon2.dds',		'the Mississippians',			'Birdman',					'King',				'H. Roe/TPangolin'			UNION ALL
--[ALT]	SELECT	'MINOR_CIV_HANOI',			'hanoi_leadericon2.dds',		'Vietnam',						'Ho Chi Minh',				'President',		'knightmare13'				UNION ALL
--[ALT]	SELECT	'MINOR_CIV_KABUL',			'kabul_leadericon2.dds',		'Afghanistan',					'Ahmad Shah Durrani',		'Emir',				'TPangolin'					UNION ALL
--[ALT]	SELECT	'MINOR_CIV_LA_VENTA',		'la_venta_leadericon2.dds',		'the Olmecs',					'Po Ngbe',					'Ku',				'Leugi'						UNION ALL
--[ALT]	SELECT	'MINOR_CIV_MALACCA',		'malacca_leadericon.dds',		'Kedah',						'Abdul Halim',				'Sultan',			'Nutty'						UNION ALL
--[ALT]	SELECT	'MINOR_CIV_SAMARKAND',		'samarkand_leadericon2.dds',	'the Timurid Empire',			'Timur',					'Emir',				'Tomatekh'					UNION ALL
--[ALT]	SELECT	'MINOR_CIV_SINGAPORE',		'singapore_leadericon2.dds',	'Singapore',					'Thomas Stamford Raffles',	'Sir',				'adan_eslavo'				UNION ALL
--[ALT]	SELECT	'MINOR_CIV_SOFIA',			'sofia_leadericon2.dds',		'the Bulgarians',				'Simeon I',					'Tsar',				'D. Giudjenov/TPangolin'	UNION ALL
--[ALT]	SELECT	'MINOR_CIV_SYDNEY',			'sydney_leadericon2.dds',		'New South Wales',				'Sir Henry Parkes',			'Premier',			'TPangolin'					UNION ALL
--[ALT]	SELECT	'MINOR_CIV_WELLINGTON',		'wellington_leadericon2.dds',	'New Zealand',					'Henry Sewell',				'Premier',			'TPangolin'					UNION ALL
--[ALT]	SELECT	'MINOR_CIV_ZANZIBAR',		'zanzibar_leadericon2.dds',		'the Sultanate of Zanzibar',	'Majid bin Said',			'Sultan',			'sukritact'					UNION ALL
--[ALT]	SELECT	'MINOR_CIV_ZURICH', 		'zurich_leadericon2.dds', 		'the Swiss Confederacy', 		'Matthaus Schiner', 		'Cardinal', 		'Krateng' 					UNION ALL
--[ALT]	SELECT	'MINOR_CIV_ZURICH',			'zurich_leadericon3.dds',		'Zurich',						'Rudolf Brun',				'Mayor',			'G. Closs/TPangolin' 		UNION ALL
--[ALT]	SELECT	'MINOR_CIV_MOMBASA',		'nairobi_leadericon.dds',		'the Republic of Kenya',		'Jomo Kenyatta',			'President',		'Danmacsch'					UNION ALL	
	
--[OLD] SELECT	'MINOR_CIV_DUBLIN',			'dublin_leadericon.dds',		'Dublin',				 		"Daniel O'Connell",			'Lord Mayor',		'B. Mulrenin/Nutty'			UNION ALL
--[OLD] SELECT	'MINOR_CIV_EDINBURGH',		'edinburgh_leadericon.dds',		'the Scots',					'James VI',					'King',				'LastSword'					UNION ALL
--[OLD] SELECT	'MINOR_CIV_HELSINKI',		'helsinki_leadericon.dds',		'Finland',						'Gustaf Mannerheim',		'President',		'Hypereon'					UNION ALL
--[OLD] SELECT	'MINOR_CIV_LISBON',			'lisbon_leadericon2.dds',		'Portugal',						'Joao II',					'King',				'janboruta'					UNION ALL
