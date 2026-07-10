extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.BATTERY, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.BATTERY, EnergySiteData.Component.LOAD], 
		[EnergySiteData.Component.BATTERY, EnergySiteData.Component.GRID], 
		[EnergySiteData.Component.BATTERY, EnergySiteData.Component.SOLAR], 
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.LOAD], 
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.GRID], 
	]
