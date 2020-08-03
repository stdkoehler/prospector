extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    self.set_goldore(PlayerData.inventory.goldore)
    self.set_goldbar(PlayerData.inventory.goldbar)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_RentParcel_pressed():
    PlayerData.dec_goldbar(0.1)
    GlobalManager.goto_scene("res://Autoparcel.tscn")
    
func _on_SmeltOre_pressed():
    PlayerData.inc_goldbar(0.5*PlayerData.inventory.goldore)
    PlayerData.inventory.goldore = 0
    self.set_goldore(PlayerData.inventory.goldore)
    self.set_goldbar(PlayerData.inventory.goldbar)


func _display_round(value):
    return floor(value*10)/10

func set_goldore(value):
    $Currency/Currency/margin_goldore/value_goldore.bbcode_text = str(_display_round(value)) + " oz"

func set_goldbar(value):
    $Currency/Currency/margin_goldbar/value_goldbar.bbcode_text = str(_display_round(value)) + " oz"



