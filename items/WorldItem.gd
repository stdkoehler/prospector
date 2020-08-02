extends Node2D

var ItemScript = load("res://items/Item.gd")

var item = null
var sprite_position = null
var bulk_storage = null

signal player_entered(worlditem)
signal player_exited(worlditem)

var type = EnvironmentData.TYPE.PANNABLE

func initialize(pos_, item_):
    self.item = item_
    self.sprite_position = $Sprite.position
    
    var tx = item_.texture_path.split(".")
    self._set_texture(tx[0]+'_shadow.png')
    self.position = pos_
    EnvironmentData.nav2dtilemap.set_blocking(pos_)
    
    if item_.bulk > 0:
        self.bulk_storage = ItemScript.BulkStorage.new(item_.bulk)
    
    
    
    $Panel/Filled.value = 0
    $Panel/Filled.visible = false
    
func _set_texture(tex):
    var icon =  ResourceLoader.load(tex)
    var size = icon.get_size()-Vector2(32,32)
    var offset = Vector2(round(size.x/2), round(size.y/2))
    $Sprite.texture = icon
    $Sprite.position = self.sprite_position+offset

func bulk_storage_avalaible():
    if bulk_storage != null and bulk_storage.get_percent_filled()<100:
        return true
    else:
        return false
        

func _bulk_storage_changed():
    $Panel/Filled.value = bulk_storage.get_percent_filled()
        
    print($Panel/Filled.value)
    var tx = self.item.texture_path.split(".")
    if $Panel/Filled.value > 99:
        self._set_texture(tx[0]+'_shadow_100.png')
    elif $Panel/Filled.value >= 50:
        self._set_texture(tx[0]+'_shadow_50.png')
    else:
        self._set_texture(tx[0]+'_shadow.png')
    

func bulk_storage_add(amount, gold):
    if bulk_storage != null:
        bulk_storage.add(amount, gold)
        self._bulk_storage_changed()
        


func pan(item):
    
    if item.type != ItemScript.ITEMTYPE.PAN or bulk_storage.amount <= 0:
        return [item.power, 0, true]
        
    var exhausted = false
    var efficiency = clamp(EnvironmentData.random_number_generator.randfn(item.efficiency, 0.1), 0, 1)
    var gold = item.power*bulk_storage.gold/bulk_storage.amount
    bulk_storage.amount -= item.power
    bulk_storage.gold -= gold
    var goldyield = efficiency * gold
    if bulk_storage.amount <= 0:
        bulk_storage.amount = 0
        bulk_storage.gold = 0
        exhausted = true
        
    self._bulk_storage_changed()
    return [item.power, goldyield, exhausted]


func _on_Panel_mouse_entered():
    if bulk_storage != null:
        $Panel/Filled.visible = true
    
func _on_Panel_mouse_exited():
    $Panel/Filled.visible = false


func _on_Area2D_area_entered(area):
    emit_signal("player_entered", self)


func _on_Area2D_area_exited(area):
    emit_signal("player_exited", self)
