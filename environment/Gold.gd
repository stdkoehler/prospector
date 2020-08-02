extends Node2D

var Item = load("res://items/Item.gd")

const FACTOR = 2
const MED = FACTOR*0.15
const MAX = FACTOR*0.3

var amount_gold = null
var amount_dirt = 1

var type = EnvironmentData.TYPE.DIGGABLE

signal player_entered(gold)
signal player_exited(gold)
signal player_clicked(gold)


func _update_gold():
    $DiggingAnimationPlayer.play("Digging")
    var exhausted = false
    if self.amount_gold > MAX:
        var tex = load("res://assets/gold/gold_rich.png")
        $Sprite.set_texture(tex)
    elif self.amount_gold > MED:
        var tex = load("res://assets/gold/gold_medium.png")
        $Sprite.set_texture(tex)
    elif self.amount_gold > 0.001:
        var tex = load("res://assets/gold/gold_minimal.png")
        $Sprite.set_texture(tex)
    else:
        print("free")
        queue_free()
        exhausted =  true
    
    return exhausted
        


func initialize(pos, richness):
    $DiggingAnimationPlayer.play("NoDigging")
    self.amount_gold = FACTOR*richness
    self.position = pos
    
    self._update_gold()
    
    
    
func dig(item):
    
    if item.type != Item.ITEMTYPE.SHOVEL:
        return
    
    if self.amount_dirt >= 1:
        var map = self.get_parent().get_parent().get_node("GroundMap")
        var cell = map.world_to_map(self.position)
        map.set_cellv (cell, 2 )
    
    var efficiency = clamp(EnvironmentData.random_number_generator.randfn(item.efficiency, 0.1), 0, 1)
    print('Effiency ', str(efficiency))
    var gold = item.power*amount_gold/amount_dirt
    self.amount_dirt -= item.power
    self.amount_gold -= gold
    var goldyield = efficiency * gold
    var exhausted = self._update_gold()
    return [item.power, goldyield, exhausted]
    




func _on_Gold_input_event(_viewport, event, _shape_idx):
    if event is InputEventMouseButton:
        if Input.is_action_just_pressed("ui_lmb"):
            emit_signal("player_clicked", self)


func _on_Gold_area_entered(_area):
    emit_signal("player_entered", self)


func _on_Gold_area_exited(_area):
    emit_signal("player_exited", self)
