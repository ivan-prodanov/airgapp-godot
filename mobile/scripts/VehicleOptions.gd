class_name VehicleOptions


enum ExteriorColor{RedMulticoat, SolidBlack, SilverMetallic, MidnightSilver, DeepBlue, PearlWhite, TitaniumCopper, Red, Black, Silver, Grey, Blue, White, Titanium, Pearl, MetallicBlack, SteelGrey, Green, Brown, SigRed, SignatureBlue, MidnightCherryRed, Quicksilver, UltraRed, StealthGrey, LunarSilver, GlacierBlue, DiamondBlack, FrostBlue, SilkroadSilver, MarineBlue, GarnetRed}

enum FasciaType{
	BASE = 0, 
	POPPYSEED_BASE = 1, 
	POPPYSEED_PERF = 2, 
	BAYBERRY = 3, 
	BAYBERRY_E41 = 7, 
	BAYBERRY_PERF = 8, 
	POPPYSEED_D50 = 9}

const BASE_METALLIC = 0.3;
const BASE_ROUGHNESS = 0.04;

const ExteriorColorValue: Dictionary = {
	"RedMulticoat": {"color": Color("#0a0101"), "metallic": 0.1, "roughness": BASE_ROUGHNESS}, 
	"SolidBlack": {"color": Color("#0e0e0e"), "metallic": 1.0, "roughness": BASE_ROUGHNESS}, 
	"SilverMetallic": {"color": Color("#161616"), "metallic": 0.6, "roughness": BASE_ROUGHNESS}, 
	"MidnightSilver": {"color": Color("#131416"), "metallic": 0.8, "roughness": BASE_ROUGHNESS}, 
	"DeepBlue": {"color": Color("#000919"), "metallic": 0.7, "roughness": BASE_ROUGHNESS}, 
	"PearlWhite": {"color": Color("#181818"), "metallic": 0.25, "roughness": 0.2}, 
	"TitaniumCopper": {"color": Color("#181510"), "metallic": 0.8, "roughness": BASE_ROUGHNESS}, 
	"Red": {"color": Color("#0a0101"), "metallic": 0.1, "roughness": BASE_ROUGHNESS}, 
	"Black": {"color": Color("#0e0e0e"), "metallic": 1.0, "roughness": BASE_ROUGHNESS}, 
	"Silver": {"color": Color("#161616"), "metallic": 0.6, "roughness": BASE_ROUGHNESS}, 
	"Grey": {"color": Color("#131416"), "metallic": 0.8, "roughness": BASE_ROUGHNESS}, 
	"SignatureBlue": {"color": Color("#000206"), "metallic": 0.2, "roughness": BASE_ROUGHNESS}, 
	"White": {"color": Color("#141414"), "metallic": 0.2, "roughness": 0.3}, 
	"Titanium": {"color": Color("#181510"), "metallic": 0.8, "roughness": BASE_ROUGHNESS}, 
	"Pearl": {"color": Color("#131313"), "metallic": 0.01, "roughness": BASE_ROUGHNESS}, 
	"MetallicBlack": {"color": Color("#0e0e0e"), "metallic": 1.0, "roughness": BASE_ROUGHNESS}, 
	"SteelGrey": {"color": Color("#131416"), "metallic": 0.8, "roughness": BASE_ROUGHNESS}, 
	"Green": {"color": Color("#060a0a"), "metallic": 0.8, "roughness": BASE_ROUGHNESS}, 
	"Brown": {"color": Color("#181514"), "metallic": 0.8, "roughness": BASE_ROUGHNESS}, 
	"SigRed": {"color": Color("#110305"), "metallic": 0.7, "roughness": BASE_ROUGHNESS}, 
	"Blue": {"color": Color("#000104"), "metallic": 0.6, "roughness": BASE_ROUGHNESS}, 
	"MidnightCherryRed": {"color": Color("#200006"), "metallic": 0.8, "roughness": 0.01}, 
	"Quicksilver": {"color": Color("#2b2d35"), "metallic": 0.85, "roughness": 0.2}, 
	"UltraRed": {"color": Color("#250006"), "metallic": 0.7, "roughness": 0.05}, 
	"StealthGrey": {"color": Color("#121417"), "metallic": 0.88, "roughness": 0.1}, 
	"LunarSilver": {"color": Color("#343438"), "metallic": 0.898, "roughness": 0.28}, 
	"GlacierBlue": {"color": Color("#12161f"), "metallic": 0.7, "roughness": 0.1}, 
	"DiamondBlack": {"color": Color("#040404"), "metallic": 0.75, "roughness": 0.02}, 
	"FrostBlue": {"color": Color("#111317"), "metallic": 0.716, "roughness": 0.05}, 
	"SilkroadSilver": {"color": Color("#2d2c2d"), "metallic": 0.826, "roughness": 0.204}, 
	"MarineBlue": {"color": Color("#01050a"), "metallic": 0.85, "roughness": 0.02}, 
	"GarnetRed": {"color": Color("#1d0305"), "metallic": 0.8, "roughness": 0.05}
}

const FALLBACK_EXTERIOR_COLOR = {"color": Color("#161616"), "metallic": 0.6, "roughness": BASE_ROUGHNESS}



enum InteriorConfig{
	Black, 
	Black2, 
	White, 
	White2, 
	Cream, 
	BlackCarbonFiber, 
	WhiteCarbonFiber, 
	CreamCarbonFiber, 
	TacticalGrey
}


enum InteriorUpperTrimType{
	GREY = 0, 
	BLACK = 1, 
}


enum BadgingMaterialType{
	CHROME_SILVER = 0, 
	BLACK_MATTE = 1, 
}


enum SpecialBadgingType{
	NONE = 0, 
	FOUNDATION_SERIES = 1, 
	LAUNCH_SERIES = 2, 
	SIGNATURE_SERIES = 3, 
}


enum HeadlampType{
	Original = 0, 
	Premium = 1, 
	Global = 2
	}


enum RearLightType{
	Original = 0, 
	Global = 2
	}



enum WheelType{
	
	Apollo, 
	Gemini, 
	Induction, 
	Pinwheel, 
	PinwheelRefresh
	PinwheelNoCap, 
	StilettoBlack, 
	StilettoDark, 
	StilettoSilver, 
	StilettoRefresh, 
	UberTurbine, 
	ZeroG, 
	Apollo_19_Metallic_Shadow, 
	
	
	Aero, 
	Arachnid, 
	ArachnidBlack, 
	ArachnidSilver, 
	ArachnidCarbon, 
	BaseSilver, 
	Cardenio, 
	Cyberstream, 
	CycloneSilver, 
	CycloneCarbon, 
	Helix, 
	SlipstreamCarbon, 
	SlipstreamDark, 
	SlipstreamSilver, 
	TempestSilver, 
	NewTurbine22Black, 
	TurbineBlack, 
	TurbineSilver, 
	TwinTurbineCarbon, 
	TwinTurbineSilver, 

	
	Apollo19MetallicShadow, 
	
	
	SemiDefault, 

	
	CybertruckBase18, 
	CybertruckBase20, 
	CybertruckPremium, 

	
	Glider, 
	Helix19, 
	Wishbone_19, 
	Wishbone_20, 
	D50_18, 
	
	
	E41_18, 
	Crossflow_19, 
	HelixV2_20, 
	
	
	Standard_19, 
	Halo22, 
	Riptide20, 
	Cypress21, 
	HelixV2_20_Dark, 
	ArachnidV2_21, 
	MachinaV2_19, 
}

const DefaultWheelForVehicleType = {
	"models": WheelType.TempestSilver, 
	"models2": WheelType.TempestSilver, 
	"lychee": WheelType.TempestSilver, 
	"model3": WheelType.Pinwheel, 
	"modelx": WheelType.SlipstreamSilver, 
	"tamarind": WheelType.Cyberstream, 
	"modely": WheelType.Gemini, 
	"semitruck": WheelType.SemiDefault, 
	"cybertruck": WheelType.CybertruckPremium, 
	"cybercab": WheelType.StilettoSilver, 
	"unknown": WheelType.StilettoSilver, 
}

const WheelTypeToPathMap: Dictionary = {
	
	WheelType.Apollo: NodePath("res://Ego/Wheels/Wheel_Apollo.tscn"), 
	WheelType.Gemini: NodePath("res://Ego/Wheels/Wheel_Gemini.tscn"), 
	WheelType.Induction: NodePath("res://Ego/Wheels/Wheel_Induction.tscn"), 
	WheelType.Pinwheel: NodePath("res://Ego/Wheels/Wheel_Pinwheel.tscn"), 
	WheelType.PinwheelNoCap: NodePath("res://Ego/Wheels/Wheel_Pinwheel_No_Cap.tscn"), 
	WheelType.PinwheelRefresh: NodePath("res://Ego/Wheels/Wheel_Pinwheel_Refresh.tscn"), 
	WheelType.StilettoBlack: NodePath("res://Ego/Wheels/Wheel_Stiletto_Armor_Black.tscn"), 
	WheelType.StilettoDark: NodePath("res://Ego/Wheels/Wheel_Stiletto_Dark.tscn"), 
	WheelType.StilettoSilver: NodePath("res://Ego/Wheels/Wheel_Stiletto_Silver.tscn"), 
	WheelType.StilettoRefresh: NodePath("res://Ego/Wheels/Wheel_Stiletto_Refresh.tscn"), 
	WheelType.UberTurbine: NodePath("res://Ego/Wheels/Wheel_Uberturbine.tscn"), 
	WheelType.ZeroG: NodePath("res://Ego/Wheels/Wheel_ZeroG.tscn"), 
	WheelType.Apollo_19_Metallic_Shadow: NodePath("res://Ego/Wheels/Wheel_Apollo_19_Metallic_Shadow.tscn"), 
	
	
	WheelType.Aero: NodePath("res://Ego/Wheels_X_S/Wheel_Aero.tscn"), 
	WheelType.Arachnid: NodePath("res://Ego/Wheels_Palladium/Arachnid21.tscn"), 
	WheelType.ArachnidBlack: NodePath("res://Ego/Wheels_X_S/Wheel_Arachnid_Armor_Black.tscn"), 
	WheelType.ArachnidCarbon: NodePath("res://Ego/Wheels_X_S/Wheel_Arachnid_Sonic_Carbon.tscn"), 
	WheelType.ArachnidSilver: NodePath("res://Ego/Wheels_X_S/Wheel_Arachnid_Silver.tscn"), 
	WheelType.BaseSilver: NodePath("res://Ego/Wheels_X_S/Wheel_Base_Silver.tscn"), 
	WheelType.Cardenio: NodePath("res://Ego/Wheels_Palladium/Cardenio.tscn"), 
	WheelType.Cyberstream: NodePath("res://Ego/Wheels_Palladium/Cyberstream.tscn"), 
	WheelType.CycloneSilver: NodePath("res://Ego/Wheels_X_S/Wheel_Cyclone_Silver.tscn"), 
	WheelType.CycloneCarbon: NodePath("res://Ego/Wheels_X_S/Wheel_Cyclone_Sonic_Carbon.tscn"), 
	WheelType.Helix: NodePath("res://Ego/Wheels_X_S/Wheel_Helix_Silver.tscn"), 
	WheelType.SlipstreamCarbon: NodePath("res://Ego/Wheels_X_S/Wheel_Slipstream_Sonic_Carbon.tscn"), 
	WheelType.SlipstreamDark: NodePath("res://Ego/Wheels_X_S/Wheel_Slipstream_Two_Tone.tscn"), 
	WheelType.SlipstreamSilver: NodePath("res://Ego/Wheels_X_S/Wheel_Slipstream_Silver.tscn"), 
	WheelType.TempestSilver: NodePath("res://Ego/Wheels_X_S/Wheel_Tempest_Sonic_Silver.tscn"), 
	WheelType.NewTurbine22Black: NodePath("res://Ego/Wheels_Palladium/New_Turbine_22.tscn"), 
	WheelType.TurbineBlack: NodePath("res://Ego/Wheels_X_S/Wheel_Turbine_Onyx_Black.tscn"), 
	WheelType.TurbineSilver: NodePath("res://Ego/Wheels_X_S/Wheel_Turbine_Silver.tscn"), 
	WheelType.TwinTurbineCarbon: NodePath("res://Ego/Wheels_X_S/Wheel_Twin_Turbine_Sonic_Carbon.tscn"), 
	WheelType.TwinTurbineSilver: NodePath("res://Ego/Wheels_X_S/Wheel_Twin_Turbine_Silver.tscn"), 
	
	
	WheelType.Apollo19MetallicShadow: NodePath("res://Ego/Wheels/Wheel_Apollo_19_Metallic_Shadow.tscn"), 

	
	WheelType.SemiDefault: NodePath("res://Ego/Wheels_Semi/Wheel_F_Semi.glb"), 

	
	WheelType.CybertruckBase18: NodePath("res://Ego/Cybertruck/Wheels/Wheel_Cybertruck_RWD.tscn"), 
	WheelType.CybertruckBase20: NodePath("res://Ego/Cybertruck/Wheels/Wheel_Cybertruck_Standard.tscn"), 
	WheelType.CybertruckPremium: NodePath("res://Ego/Cybertruck/Wheels/Wheel_Cybertruck_Premium.tscn"), 

	
	WheelType.Glider: NodePath("res://Ego/v2023/Wheels/Glider.tscn"), 
	WheelType.Helix19: NodePath("res://Ego/v2023/Wheels/Helix_19.tscn"), 
	WheelType.Wishbone_19: NodePath("res://Ego/v2023/Wheels/Wishbone_19.tscn"), 
	WheelType.Wishbone_20: NodePath("res://Ego/v2023/Wheels/Wishbone_20.tscn"), 
	WheelType.D50_18: NodePath("res://Ego/Wheels/Wheel_D50.tscn"), 
	
	
	WheelType.E41_18: NodePath("res://Ego/Wheels_Bayberry/BayberryE41/Wheel_E41.tscn"), 
	WheelType.Crossflow_19: NodePath("res://Ego/Wheels_Bayberry/GeminiDark/GeminiDark.tscn"), 
	WheelType.HelixV2_20: NodePath("res://Ego/Wheels_Bayberry/Helix2/Helix2.tscn"), 
	
	
	WheelType.Standard_19: NodePath("res://Ego/Wheels_P3/Wheel_Standard.tscn"), 
	WheelType.Halo22: NodePath("res://Ego/Wheels_P3/Wheel_Halo.tscn"), 
	WheelType.Riptide20: NodePath("res://Ego/Wheels_P3/Wheel_Riptide.tscn"), 
	WheelType.Cypress21: NodePath("res://Ego/Wheels_P3/Wheel_Cypress_NoInsert.tscn"), 
	WheelType.HelixV2_20_Dark: NodePath("res://Ego/Wheels_Bayberry/Helix2_Dark/Helix2_Dark.tscn"), 
	WheelType.ArachnidV2_21: NodePath("res://Ego/Wheels_Bayberry/Arachnid_V2/Arachnid_V2_21.tscn"), 
	WheelType.MachinaV2_19: NodePath("res://Ego/Wheels_Bayberry/Machina2/Machina2.tscn"), 
}

const MobileWheelTypeEnumMap: Dictionary = {
	
	"Apollo19": WheelType.Gemini, 
	"Apollo19CapKit": WheelType.Apollo, 
	"Gemini19Square": WheelType.Gemini, 
	"Gemini19Staggered": WheelType.Gemini, 
	"Induction20Black": WheelType.Induction, 
	"Pinwheel18": WheelType.Pinwheel, 
	"PinwheelRefresh18": WheelType.PinwheelRefresh, 
	"Pinwheel18CapKit": WheelType.PinwheelNoCap, 
	"PinwheelRefresh18CapKit": WheelType.PinwheelNoCap, 
	"Stiletto19": WheelType.StilettoSilver, 
	"Stiletto20": WheelType.StilettoSilver, 
	"Stiletto20DarkSquare": WheelType.StilettoDark, 
	"Stiletto20DarkStaggered": WheelType.StilettoDark, 
	"StilettoRefresh19": WheelType.StilettoRefresh, 
	"UberTurbine21Black": WheelType.UberTurbine, 
	"UberTurbine20Gunpowder": WheelType.UberTurbine, 
	"ZeroG19Gunpowder": WheelType.ZeroG, 
	"ZeroG20Gunpowder": WheelType.ZeroG, 
	"Apollo19MetallicShadow": WheelType.Apollo_19_Metallic_Shadow, 
	
	
	"Aero19": WheelType.Aero, 
	"AeroTurbine19": WheelType.SlipstreamSilver, 
	"AeroTurbine20": WheelType.SlipstreamSilver, 
	"AeroTurbine19Black": WheelType.SlipstreamCarbon, 
	"AeroTurbine20Dark": WheelType.SlipstreamDark, 
	"Arachnid21": WheelType.Arachnid, 
	"Arachnid21Silver": WheelType.ArachnidSilver, 
	"Arachnid21Black": WheelType.ArachnidBlack, 
	"Arachnid21Grey": WheelType.ArachnidCarbon, 
	"Base19": WheelType.BaseSilver, 
	"Cyberstream20": WheelType.Cyberstream, 
	"Cardenio19": WheelType.Cardenio, 
	"Charcoal21": WheelType.TurbineBlack, 
	"Charcoal21Euro": WheelType.TurbineBlack, 
	"Cyclone19Dark": WheelType.CycloneCarbon, 
	"Helix20": WheelType.Helix, 
	"TwinTurbine21Silver": WheelType.TwinTurbineSilver, 
	"TwinTurbine21Carbon": WheelType.TwinTurbineCarbon, 
	"Tempest19SonicSilver": WheelType.TempestSilver, 
	"Silver21": WheelType.TurbineSilver, 
	"Silver21Euro": WheelType.TurbineSilver, 
	"Slipstream19Carbon": WheelType.SlipstreamCarbon, 
	"Slipstream20Carbon": WheelType.SlipstreamCarbon, 
	"Slipstream20Dark": WheelType.SlipstreamDark, 
	"Super21Gray": WheelType.TurbineBlack, 
	"Super21Silver": WheelType.TurbineSilver, 
	"NewTurbine22Black": WheelType.NewTurbine22Black, 
	"Turbine19": WheelType.TurbineSilver, 
	"Turbine19Dark": WheelType.TurbineBlack, 
	"Turbine22": WheelType.TurbineSilver, 
	"Turbine22Dark": WheelType.TurbineBlack, 

	
	

	
	"CTBase18": WheelType.CybertruckBase18, 
	"CTBase20": WheelType.CybertruckBase20, 
	"CTPremium20": WheelType.CybertruckPremium, 

	
	"Glider18": WheelType.Glider, 
	"Helix19": WheelType.Helix19, 
	"Wishbone19Staggered": WheelType.Wishbone_19, 
	"Wishbone20Staggered": WheelType.Wishbone_20, 
	"D5018": WheelType.D50_18, 
	
	
	"E4118": WheelType.E41_18, 
	"Crossflow19": WheelType.Crossflow_19, 
	"HelixV220": WheelType.HelixV2_20, 
	
	
	
	"Standard19": WheelType.Standard_19, 
	"Halo22": WheelType.Halo22, 
	"Riptide20": WheelType.Riptide20, 
	"Cypress21": WheelType.Cypress21, 
	"HelixV220Dark": WheelType.HelixV2_20_Dark, 
	"ArachnidV221": WheelType.ArachnidV2_21, 
	"MachinaV219": WheelType.MachinaV2_19, 
}

const InteriorMap: Dictionary = {
	
	"Black": InteriorConfig.Black, 
	"White": InteriorConfig.White, 

	
	"AllBlack": InteriorConfig.Black, 
	"BlackAndWhite": InteriorConfig.White, 
	"Cream": InteriorConfig.Cream, 

	
	"CarbonCream": InteriorConfig.CreamCarbonFiber, 
	"CarbonBlack": InteriorConfig.BlackCarbonFiber, 
	"CarbonWhite": InteriorConfig.WhiteCarbonFiber, 
	"EbonyBlack": InteriorConfig.Black, 
	"WalnutCream": InteriorConfig.Cream, 
	"WalnutWhite": InteriorConfig.White, 

	
	"Black2": InteriorConfig.Black2, 
	"White2": InteriorConfig.White2, 

	
	"TacticalGrey": InteriorConfig.TacticalGrey, 
}

const VizInteriorMap: Dictionary = {
	"UNKNOWN": InteriorConfig.Black, 
	"BLACK_DEFAULT": InteriorConfig.Black, 
	"WHITE_DEFAULT": InteriorConfig.White, 
	"CREAM_DEFAULT": InteriorConfig.Cream, 
	"BLACK_CARBON_FIBER": InteriorConfig.BlackCarbonFiber, 
	"WHITE_CARBON_FIBER": InteriorConfig.WhiteCarbonFiber, 
	"CREAM_CARBON_FIBER": InteriorConfig.CreamCarbonFiber, 
	"TAN_DEFAULT": InteriorConfig.Black, 
	"BLACK_BLACK_TRIM": InteriorConfig.Black, 
	"WHITE_BLACK_TRIM": InteriorConfig.White, 
	"TACTICAL_GREY": InteriorConfig.TacticalGrey, 
}

const GTWWheelTypeEnumMap: Dictionary = {
	
	"BASE_19": WheelType.BaseSilver, 
	"SILVER_21": WheelType.TurbineSilver, 
	"CHARCOAL_21": WheelType.TurbineBlack, 
	"SILVER_21_EURO": WheelType.TurbineSilver, 
	"AERO_19": WheelType.Aero, 
	"CHARCOAL_21_EURO": WheelType.TurbineBlack, 
	"SUPER_21_GRAY": WheelType.TurbineBlack, 
	"SUPER_21_SILVER": WheelType.TurbineSilver, 
	"TURBINE_19": WheelType.TurbineSilver, 
	"TURBINE_19_CHARCOAL": WheelType.TurbineBlack, 
	"AERO_TURBINE_19_METAL": WheelType.SlipstreamSilver, 
	"AERO_TURBINE_19_BLACK": WheelType.SlipstreamDark, 
	"HELIX_20_SILVER": WheelType.Helix, 
	"AERO_TURBINE_20_SILVER": WheelType.SlipstreamSilver, 
	"TURBINE_22_SILVER": WheelType.TurbineSilver, 
	"CYCLONE_19_GREY": WheelType.CycloneSilver, 
	"AERO_TURBINE_20_SLVRBLK": WheelType.SlipstreamCarbon, 
	"TURBINE_22_BLACK": WheelType.TurbineBlack, 
	"ARACHNID_21": WheelType.Arachnid, 
	"ARACHNID_21_SILVER": WheelType.ArachnidSilver, 
	"ARACHNID_21_BLACK": WheelType.ArachnidBlack, 
	"ARACHNID_21_GREY": WheelType.ArachnidCarbon, 
	"CYBERSTREAM_20": WheelType.Cyberstream, 
	"SLIPSTREAM_20_CARBON": WheelType.SlipstreamCarbon, 
	"SLIPSTREAM_20_SLVRBLK": WheelType.SlipstreamDark, 
	"SLIPSTREAM_19_SONICSILVER": WheelType.SlipstreamSilver, 
	"SLIPSTREAM_19_CARBON": WheelType.SlipstreamCarbon, 
	"TWINTURBINE_21_SILVER": WheelType.TwinTurbineSilver, 
	"TWINTURBINE_21_CARBON": WheelType.TwinTurbineCarbon, 
	"TEMPEST_19_SONICSILVER": WheelType.TempestSilver, 
	"NEW_TURBINE_22_BLACK": WheelType.NewTurbine22Black, 
	"TURBINE_21_SILVER": WheelType.TurbineSilver, 
	"PINWHEEL_18": WheelType.Pinwheel, 
	"STILETTO_19": WheelType.StilettoSilver, 
	"STILETTO_20": WheelType.StilettoSilver, 
	"CARDENIO_19": WheelType.Cardenio, 
	
	"STILETTO_20_DARK_STAGGERED": WheelType.StilettoDark, 
	"GEMINI_19_SQUARE": WheelType.Gemini, 
	"GEMINI_19_STAGGERED": WheelType.Gemini, 
	"STILETTO_20_DARK_SQUARE": WheelType.StilettoDark, 
	"INDUCTION_20_BLACK": WheelType.Induction, 
	"UBERTURBINE_21_BLACK": WheelType.UberTurbine, 
	"APOLLO_19_SILVER": WheelType.Apollo, 
	"PINWHEEL_18_CAP_KIT": WheelType.PinwheelNoCap, 
	"APOLLO_19_SILVER_CAP_KIT": WheelType.Apollo, 
	"ZEROG_19_GUNPOWDER": WheelType.ZeroG, 
	"ZEROG_20_GUNPOWDER": WheelType.ZeroG, 
	"STILETTO_REFRESH_19": WheelType.StilettoSilver, 
	"PINWHEEL_REFRESH_18": WheelType.Pinwheel, 
	"UBERTURBINE_20_GUNPOWDER": WheelType.UberTurbine, 
	
	"GLIDER_18": WheelType.Glider, 
	"HELIX_19": WheelType.Helix19, 
	"WISHBONE_19_STAGGERED": WheelType.Wishbone_19, 
	"WISHBONE_20_STAGGERED": WheelType.Wishbone_20, 
	"D50_18": WheelType.D50_18, 
	
	"APOLLO_19_METALLIC_SHADOW": WheelType.Apollo19MetallicShadow, 
	
	"E41_18": WheelType.E41_18, 
	"CROSSFLOW_19": WheelType.Crossflow_19, 
	"HELIX_V2_20": WheelType.HelixV2_20, 
	"HELIX_V2_20_DARK": WheelType.HelixV2_20_Dark, 
	"ARACHNID_V2_21": WheelType.ArachnidV2_21, 
	"MACHINA_V2_19": WheelType.MachinaV2_19, 
	
	"CT_BASE_18": WheelType.CybertruckBase18, 
	"CT_BASE_20": WheelType.CybertruckBase20, 
	"CT_PREMIUM_20": WheelType.CybertruckPremium, 
	
	"UNKNOWN": WheelType.StilettoSilver, 
}



const ChargePortTypeToCableMap = {
	"US": NodePath("res://mobile/geometry/Charging_Cable/Charging_Cable.tscn"), 
	"EU": NodePath("res://mobile/geometry/Charging_Cable/Charging_Cable_IEC.tscn"), 
	"GB": NodePath("res://mobile/geometry/Charging_Cable/Charging_Cable_IEC.tscn"), 
	"GB_AC": NodePath("res://mobile/geometry/Charging_Cable/Charging_Cable_IEC.tscn"), 
	"GB_DC": NodePath("res://mobile/geometry/Charging_Cable/Charging_Cable_IEC.tscn"), 
	"CCS": NodePath("res://mobile/geometry/Charging_Cable/Charging_Cable_CCS2_V3.tscn")
}

