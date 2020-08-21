extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
    pass



func _on_LeaveParcel_pressed():
    $ConfirmationDialog.popup()
    

func _on_ConfirmationDialog_confirmed():
    PlayerData.state.stamina = 100
    # always make sure we don't go bankrupt
    if PlayerData.inventory.goldbar < 0.1 and PlayerData.inventory.goldore < 0.3:
        PlayerData.inventory.goldbar = 0.1
    GlobalManager.goto_scene("res://Hub.tscn")


