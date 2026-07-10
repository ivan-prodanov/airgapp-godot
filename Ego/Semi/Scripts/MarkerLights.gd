tool 
extends VehicleNodeVisible

func should_be_visible(vehicle: Vehicle):
	if vehicle == null or not (vehicle is Semi): return
	var semi = vehicle

	return semi.markers_on
	
