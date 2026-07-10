extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.WALL_CONNECTOR_1], 
		[EnergySiteData.Component.VEHICLE_1, EnergySiteData.Component.LOAD], 
	]
