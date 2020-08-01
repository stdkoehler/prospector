extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func set_blocking(pixelpos):
    self.set_cellv(Vector2(floor(pixelpos.x/32), floor(pixelpos.y/32)), 1)
    self.update_bitmask_region()

func set_unblocking(pixelpos):
    self.set_cellv(Vector2(floor(pixelpos.x/32), floor(pixelpos.y/32)), 1)
    self.update_bitmask_region()
