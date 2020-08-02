extends Node

const TYPE = {
    'STATIC': 0,
    'DIGGABLE': 1,
    'PANNABLE': 2
   }

var HEIGHT = null
var WIDTH = null

var nav2d = null
var nav2dtilemap = null
var rocks = null
var camera = null
var worlditems = null


var random_number_generator = RandomNumberGenerator.new()

func _ready():
    random_number_generator.randomize()
    
    
func get_closest_bulk_storage(pos_):
    var nearest_idx = null
    var shortest_dist = 3.402823e+38
    var worlditems_ = worlditems.get_children()
    for i in len(worlditems_):
        var wi = worlditems_[i]
        var dist = pos_.distance_to(wi.position)
        if dist < shortest_dist and wi.type==EnvironmentData.TYPE.PANNABLE and wi.bulk_storage_avalaible():
            shortest_dist = dist
            nearest_idx = i
    if nearest_idx != null and shortest_dist < 100:
        return worlditems_[nearest_idx]
    else:
        return null
