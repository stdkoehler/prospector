extends Control

signal open_options

# Called when the node enters the scene tree for the first time.
func _ready():
    pass



func _on_LeaveGame_pressed():
    $ConfirmationDialog.popup()
    
    
func _on_Options_pressed():
    self.visible = false
    emit_signal("open_options")
    

func _on_ConfirmationDialog_confirmed():
    PlayerData.state.stamina = 100
    GlobalManager.save_on_quit()
    GlobalManager.current_save = null
    GlobalManager.goto_scene("res://MainMenu.tscn")



