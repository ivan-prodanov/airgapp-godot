extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.LOAD, EnergySiteData.Component.VEHICLE_1], 
		[EnergySiteData.Component.GRID, EnergySiteData.Component.VEHICLE_1], 
	]
