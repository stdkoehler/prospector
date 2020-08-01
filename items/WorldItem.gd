extends Node2D

var ItemScript = load("res://items/Item.gd")

var item

func initialize(pos_, item_):
    self.item = item_
    var tx = item_.texture_path.split(".")
    var icon =  ResourceLoader.load(tx[0]+'_shadow.png')
    var size = icon.get_size()-Vector2(32,32)
    var offset = Vector2(round(size.x/2), round(size.y/2))
    $Sprite.texture = icon
    $Sprite.position = $Sprite.position+offset
    self.position = pos_
    EnvironmentData.nav2dtilemap.set_blocking(pos_)
    


