extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.BATTERY, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.BATTERY, EnergySiteData.Component.LOAD], 
		[EnergySiteData.Component.BATTERY, EnergySiteData.Component.GRID], 
		[EnergySiteData.Component.SOLAR, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.SOLAR, EnergySiteData.Component.LOAD], 
		[EnergySiteData.Component.SOLAR, EnergySiteData.Component.GRID], 
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.LOAD], 
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.GRID], 
	]
