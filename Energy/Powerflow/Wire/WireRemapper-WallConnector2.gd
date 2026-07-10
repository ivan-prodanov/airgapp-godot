extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.VEHICLE_2, EnergySiteData.Component.WALL_CONNECTOR_2], 
	]
