extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
    pass



func _on_LeaveParcel_pressed():
    GlobalManager.goto_scene("res://Menu.tscn")


