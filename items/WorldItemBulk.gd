extends "WorldItem.gd"


var amount_limit
var amount_dirt
var amount_gold

func initialize(position_, item_):
    
    self.type = EnvironmentData.TYPE.PANNABLE
    
    $Panel/Filled.value = 0
    $Panel/Filled.visible = false
    
    self.amount_limit = item_.bulk
    self.amount_dirt = 0
    self.amount_gold = 0
    
    .initialize(position_, item_)
    
    self._changed()

        
func get_percent_filled():
    return round(100*self.amount_dirt/self.amount_limit)
    
func add(amount_dirt_, amount_gold_):
    var amount_dirt_new = self.amount_dirt + amount_dirt_
    if amount_dirt_new > self.amount_limit:
        self.amount_dirt = self.amount_limit
        var diff = amount_dirt_new - self.amount_limit
        self.amount_gold += amount_gold_*(amount_dirt_+diff)/amount_dirt_ #only add part which fits into
    else:
        self.amount_dirt = amount_dirt_new
        self.amount_gold += amount_gold_
        
    self._changed()

func bulk_storage_avalaible():
    if self.get_percent_filled()<100:
        return true
    else:
        return false
        

func _changed():
    $Panel/Filled.value = self.get_percent_filled()
        
    print($Panel/Filled.value)
    var tx = self.item.texture_path.split(".")
    if $Panel/Filled.value > 99:
        self._set_texture(tx[0]+'_shadow_100.png')
    elif $Panel/Filled.value >= 50:
        self._set_texture(tx[0]+'_shadow_50.png')
    else:
        self._set_texture(tx[0]+'_shadow.png')


func pan(item):
    
    if item.type != ItemScript.ITEMTYPE.PAN or self.amount_dirt <= 0:
        return [item.power, 0, true]
        
    var exhausted = false
    var efficiency = clamp(EnvironmentData.random_number_generator.randfn(item.efficiency, 0.1), 0, 1)
    var gold = item.power*self.amount_gold/self.amount_dirt
    self.amount_dirt -= item.power
    self.amount_gold -= gold
    var goldyield = efficiency * gold
    if self.amount_dirt <= 0:
        self.amount_dirt = 0
        self.amount_gold = 0
        exhausted = true
        
    self._changed()
    return [item.power, goldyield, exhausted]


func _on_Panel_mouse_entered():
    $Panel/Filled.visible = true
    
func _on_Panel_mouse_exited():
    $Panel/Filled.visible = false
