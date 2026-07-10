extends EnergySitePowerflowWireRemapper

func get_wire_exists_between_components():
	return [
		[EnergySiteData.Component.GENERATOR, EnergySiteData.Component.METER], 
		[EnergySiteData.Component.GENERATOR, EnergySiteData.Component.SOLAR], 
		[EnergySiteData.Component.GENERATOR, EnergySiteData.Component.BATTERY], 
		[EnergySiteData.Component.GENERATOR, EnergySiteData.Component.LOAD], 
	]
