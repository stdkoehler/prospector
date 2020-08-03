extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    var _c = null
    _c = PlayerData.connect("menu_opened", self, "open_menu")
    _c = PlayerData.connect("menu_closed", self, "close_menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_LeaveParcel_pressed():
    GlobalManager.goto_scene("res://Menu.tscn")


func open_menu(_value):
    self.visible = true
    
func close_menu(_value):
    self.visible = false
