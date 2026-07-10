extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.GRID, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.GRID, EnergySiteData.Component.SOLAR], 
		[EnergySiteData.Component.GRID, EnergySiteData.Component.BATTERY], 
		[EnergySiteData.Component.GRID, EnergySiteData.Component.LOAD], 
		[EnergySiteData.Component.GRID, EnergySiteData.Component.VEHICLE_1]
	]
