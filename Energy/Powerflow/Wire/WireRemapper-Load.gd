extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.LOAD, EnergySiteData.Component.BATTERY], 
		[EnergySiteData.Component.LOAD, EnergySiteData.Component.SOLAR], 
		[EnergySiteData.Component.LOAD, EnergySiteData.Component.GRID], 
		[EnergySiteData.Component.LOAD, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.LOAD, EnergySiteData.Component.VEHICLE_1], 
	]
