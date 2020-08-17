extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    $YSort/ParcelSign.connect("player_entered", $YSort/Player, "_on_parcelsign_entered")
    $YSort/ParcelSign.connect("player_exited", $YSort/Player, "_on_parcelsign_exited")
    $YSort/ShopSign.connect("player_entered", $YSort/Player, "_on_shopsign_entered")
    $YSort/ShopSign.connect("player_exited", $YSort/Player, "_on_shopsign_exited")
    
    $YSort/Player.connect("open_shop", $HubUI, "_on_shop_opened")
    $YSort/Player.connect("open_parcel", $HubUI, "_on_parcel_opened")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
