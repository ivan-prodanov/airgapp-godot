extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.SOLAR, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.SOLAR, EnergySiteData.Component.GRID], 
		[EnergySiteData.Component.SOLAR, EnergySiteData.Component.LOAD], 
		[EnergySiteData.Component.SOLAR, EnergySiteData.Component.BATTERY], 
	]
