extends Area2D


signal player_entered(signs)
signal player_exited(signs)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_Sign_area_entered(_area):
    emit_signal("player_entered", self)


func _on_Sign_area_exited(_area):
    emit_signal("player_exited", self)
