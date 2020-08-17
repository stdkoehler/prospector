extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    var _c
    _c = PlayerData.connect("interactable_text_changed", self, "set_interactable_text")


func set_interactable_text(text):
    $Interaction/Options/Text.bbcode_text = "[right]"+text+"[/right]"
