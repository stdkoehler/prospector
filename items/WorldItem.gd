extends Node2D

var ItemScript = load("res://items/Item.gd")

var item = null
var sprite_position = null
var type = EnvironmentData.TYPE.STATIC

signal player_entered(worlditem)
signal player_exited(worlditem)


func initialize(pos_, item_):
    self.item = item_
    self.sprite_position = $Sprite.position
    
    var tx = item_.texture_path.split(".")
    self._set_texture(tx[0]+'_shadow.png')
    self.position = pos_
    EnvironmentData.nav2dtilemap.set_blocking(pos_)
    
    
func _set_texture(tex):
    var icon =  ResourceLoader.load(tex)
    var size = icon.get_size()-Vector2(32,32)
    var offset = Vector2(round(size.x/2), round(size.y/2))
    $Sprite.texture = icon
    $Sprite.position = self.sprite_position+offset



func _on_Area2D_area_entered(_area):
    emit_signal("player_entered", self)


func _on_Area2D_area_exited(_area):
    emit_signal("player_exited", self)
