extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
    pass



func _on_LeaveParcel_pressed():
    PlayerData.state.stamina = 100
    GlobalManager.goto_scene("res://Menu.tscn")


