extends Control

onready var handle_parcel = $Panel/ItemList

func _ready():
    handle_parcel.set_max_columns(1)
    handle_parcel.set_fixed_icon_size(Vector2(32,32))
    handle_parcel.set_icon_mode(handle_parcel.ICON_MODE_LEFT)
    handle_parcel.set_select_mode(handle_parcel.SELECT_SINGLE)
    handle_parcel.set_same_column_width(true)
    handle_parcel.clear()
    
    var parcels = [{'name': 'Standard', 'cost_0': 0.1, 'cost_1': 0.1}]
    var idx = 0
    for ti in parcels:
        handle_parcel.add_item("", null, false)
        handle_parcel.set_item_selectable(idx, true)
        handle_parcel.set_item_metadata(idx, ti)
        handle_parcel.set_item_text(idx, ti['name'] + ' (' + str(ti['cost_0']) + '/' + str(ti['cost_1']) + ')')
        handle_parcel.set_item_tooltip_enabled(idx, true)
        idx+=1
        
    self._update(null)
        
        
func _update(idx):
    #if idx != null:
    #    self.update_slot(idx)
    
        
    var cost = null
    var sel = self.handle_parcel.get_selected_items()
    if len(sel) > 0:
        var meta = self.handle_parcel.get_item_metadata(sel[0])
        cost = meta['cost_0'] + ($Panel/GridContainer2/SpinBox.value-1)*meta['cost_1']
        self._set_price(cost)
        $Panel/GridContainer2/SpinBox.editable = true
    else:
        $Panel/GridContainer2/SpinBox.editable = false
        self._set_price(0)
        
    idx = PlayerData.inventory.get_free_slot()
    if idx > 0 && cost != null && cost <= PlayerData.inventory.goldbar:
        $Panel/GridContainer2/LeaseButton.disabled = false
    else:
        $Panel/GridContainer2/LeaseButton.disabled = true
        
func _on_ItemList_item_selected(index):
    self._update(null)
    
func _on_SpinBox_value_changed(value):
    print($Panel/GridContainer2/SpinBox.value)
    self._update(null)
    
func _set_price(price):
    $Panel/GridContainer/Cost.text = str(stepify(price,0.1)) + ' / ' + str(stepify(PlayerData.inventory.goldbar,0.1))
    if price > PlayerData.inventory.goldbar:
        $Panel/GridContainer2/LeaseButton.disabled = true
    else:
        $Panel/GridContainer2/LeaseButton.disabled = false

func reset_scroll():
    $Panel/ItemList.get_v_scroll().value = 0
    
func _on_LeaseButton_pressed():
    var cost = null
    var sel = self.handle_parcel.get_selected_items()
    if len(sel) > 0:
        var meta = self.handle_parcel.get_item_metadata(sel[0])
        cost = meta['cost_0'] + ($Panel/GridContainer2/SpinBox.value-1)*meta['cost_1']
        PlayerData.dec_goldbar(cost)
        GlobalManager.goto_scene("res://Autoparcel.tscn")
        
        
func _on_SmeltOre_pressed():
    PlayerData.inc_goldbar(0.5*PlayerData.inventory.goldore)
    PlayerData.inventory.goldore = 0
    self._update(null)




