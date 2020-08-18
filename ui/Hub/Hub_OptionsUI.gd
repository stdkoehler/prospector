extends Control


func _ready():
    GlobalManager.minigame_digging = $Options/VBox/Minigame/DiggingOption.get_selected_id()
    GlobalManager.minigame_panning = $Options/VBox/Minigame/PanningOption.get_selected_id()




func _on_DiggingOption_item_selected(id):
    GlobalManager.minigame_digging = id


func _on_PanningOption_item_selected(id):
    GlobalManager.minigame_panning = id
    
