extends Control


var lock = false

signal new_action_item_selected()
signal placement_enabled(flag)


func _ready():
    var _c = null
    _c = PlayerData.connect("goldore_changed", self, "set_goldore")
    _c = PlayerData.connect("goldbar_changed", self, "set_goldbar")
    _c = PlayerData.connect("action_progress_changed", self, "set_action_progress")
    _c = PlayerData.connect("interactable_text_changed", self, "set_interactable_text")
    _c = PlayerData.connect("stamina_changed", self, "update_stamina")
    
    $Toolbelt/ItemList.set_max_columns(6)
    $Toolbelt/ItemList.set_fixed_icon_size(Vector2(32,32))
    $Toolbelt/ItemList.set_icon_mode($Toolbelt/ItemList.ICON_MODE_TOP)
    $Toolbelt/ItemList.set_select_mode($Toolbelt/ItemList.SELECT_SINGLE)
    $Toolbelt/ItemList.set_same_column_width(true)
    $Toolbelt/ItemList.set_allow_rmb_select(true)
    
    for _idx in range(6):
        $Toolbelt/ItemList.add_item("", null, false)
        
    self.set_goldore(PlayerData.inventory.goldore)
    self.set_goldbar(PlayerData.inventory.goldbar)
        
    self._update_toolbelt()
    self._set_active_toolbelt_slot(1)
    emit_signal('new_action_item_selected')
    


func _display_round(value):
    return floor(value*10)/10

func set_goldore(value):
    $Currency/Currency/margin_goldore/value_goldore.bbcode_text = str(_display_round(value)) + " oz"

func set_goldbar(value):
    $Currency/Currency/margin_goldbar/value_goldbar.bbcode_text = str(_display_round(value)) + " oz"
    
func set_action_progress(value):
    $ActionItem/Progress.value = value
    $ActionItem/ProgressBackground.value = value
    
func set_interactable_text(text):
    $Interaction/Options/Text.bbcode_text = "[right]"+text+"[/right]"
    
func hide_ui(_value):
    self.visible = false
    emit_signal('placement_enabled', false)
    
func show_ui(_value):
    self.visible = true
    self._update_toolbelt()
    self._update_action_item_texture()
    emit_signal('placement_enabled', true)
    emit_signal('new_action_item_selected')
    
func _hide_toolbelt_selection():
    $Toolbelt/s0.visible = false
    $Toolbelt/s1.visible = false
    $Toolbelt/s2.visible = false
    $Toolbelt/s3.visible = false
    $Toolbelt/s4.visible = false
    $Toolbelt/s5.visible = false
    


func _input(event):
    if self.lock == false:
        if event is InputEventKey:
            if PlayerData.state.current == PlayerData.state.STATE.IDLE:
                if event.pressed and event.scancode == KEY_1:
                    self._set_active_toolbelt_slot(0)
                if event.pressed and event.scancode == KEY_2:
                    self._set_active_toolbelt_slot(1)
                if event.pressed and event.scancode == KEY_3:
                    self._set_active_toolbelt_slot(2)
                if event.pressed and event.scancode == KEY_4:
                    self._set_active_toolbelt_slot(3)
                if event.pressed and event.scancode == KEY_5:
                    self._set_active_toolbelt_slot(4)
                if event.pressed and event.scancode == KEY_6:
                    self._set_active_toolbelt_slot(5)
                

    
func _set_active_toolbelt_slot(idx):
    self._hide_toolbelt_selection()
    var a = get_node("Toolbelt/s"+str(idx))
    a.visible = true
    $Toolbelt/ItemList.select(idx)
    PlayerData.inventory.active_toolbelt_slot = idx
    self._update_action_item_texture()
    emit_signal('new_action_item_selected')
    
    
func _update_action_item_texture():
    var empty_slot_texture = ResourceLoader.load("res://assets/tools/icon_none.png")
    var active_item = PlayerData.inventory.get_active_item()
    var icon = null
    if active_item != null:
        icon = ResourceLoader.load(active_item.texture_path)
    else:
        icon = empty_slot_texture
    $ActionItem/Progress.texture_over = icon
    $ActionItem/Progress.texture_progress = icon
    
func _update_toolbelt():
    var icon = null
    var empty_slot_texture = ResourceLoader.load("res://assets/tools/icon_none.png")
    for idx in range(6):
        if PlayerData.inventory.exists(idx):
            var item = PlayerData.inventory.get_item(idx)
            icon = ResourceLoader.load(item.texture_path)
        
            $Toolbelt/ItemList.set_item_icon(idx, icon)
            $Toolbelt/ItemList.set_item_selectable(idx, true)
            $Toolbelt/ItemList.set_item_metadata(idx, item)
            $Toolbelt/ItemList.set_item_tooltip(idx, item.name)
            $Toolbelt/ItemList.set_item_tooltip_enabled(idx, true)
        else:
            $Toolbelt/ItemList.set_item_icon(idx, empty_slot_texture)
            $Toolbelt/ItemList.set_item_selectable(idx, false)
            $Toolbelt/ItemList.set_item_metadata(idx, null)
            $Toolbelt/ItemList.set_item_tooltip(idx, "")
            $Toolbelt/ItemList.set_item_tooltip_enabled(idx, false)
            
func update_stamina(value):
    $PlayerStats/Grid/StaminaBar.value = value
