extends Control


func _ready():
    $Options/VBox/Minigame/DiggingOption.select(GlobalManager.minigame_digging)
    $Options/VBox/Minigame/PanningOption.select(GlobalManager.minigame_panning)




func _on_DiggingOption_item_selected(id):
    GlobalManager.minigame_digging = id


func _on_PanningOption_item_selected(id):
    GlobalManager.minigame_panning = id
    
