extends Control
var Item = load("res://items/Item.gd")

var currently_placing = false


func _ready():
    var _c = null
    _c = PlayerData.connect("goldore_changed", self, "set_goldore")
    _c = PlayerData.connect("goldbar_changed", self, "set_goldbar")
    _c = PlayerData.connect("action_progress_changed", self, "set_action_progress")
    _c = PlayerData.connect("interactable_text_changed", self, "set_interactable_text")
    _c = PlayerData.connect("inventory_opened", self, "hide_ui")
    _c = PlayerData.connect("inventory_closed", self, "show_ui")
    _c = PlayerData.connect("stamina_changed", self, "update_stamina")
    
    $Toolbelt/ItemList.set_max_columns(6)
    $Toolbelt/ItemList.set_fixed_icon_size(Vector2(32,32))
    $Toolbelt/ItemList.set_icon_mode($Toolbelt/ItemList.ICON_MODE_TOP)
    $Toolbelt/ItemList.set_select_mode($Toolbelt/ItemList.SELECT_SINGLE)
    $Toolbelt/ItemList.set_same_column_width(true)
    $Toolbelt/ItemList.set_allow_rmb_select(true)
    
    for idx in range(6):
        $Toolbelt/ItemList.add_item("", null, false)
        
        
    self._update_toolbelt()
    self._set_active_toolbelt_slot(1)
    set_process(false)


func _process(delta) -> void:
    if currently_placing:
        var global_pos = self._adjust_mouse_place(EnvironmentData.camera.get_global_mouse_position())
        var view_pos = self._adjust_mouse_place(get_viewport().get_mouse_position())
        var offset = view_pos-global_pos
        var position = self._to_tilepos(global_pos)
        $SpritePlace.position = position+offset


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
    
func hide_ui(value):
    self.visible = false
    
func show_ui(value):
    self.visible = true
    self._update_toolbelt()
    self._set_action_item(PlayerData.inventory.active_toolbelt_slot)
    self._check_placable_selected()
    
    
func _hide_toolbelt_selection():
    $Toolbelt/s0.visible = false
    $Toolbelt/s1.visible = false
    $Toolbelt/s2.visible = false
    $Toolbelt/s3.visible = false
    $Toolbelt/s4.visible = false
    $Toolbelt/s5.visible = false
    
func _to_tilepos(position):
    return Vector2(round(position.x/32)*32, round(position.y/32)*32)+Vector2(16,16)
    
func _adjust_mouse_place(position):
    return position-Vector2(16,16)


func _get_object_under_position(position):
    var space_state = get_world_2d().get_direct_space_state()
    var selection = space_state.intersect_ray(position-Vector2(16,16), position+Vector2(16,16), [], 0xFFFFFFFF)
    #var selection = space_state.intersect_point(mouse_pos, 32, [], 0xFFFFFFFF, true, true)
    return selection

func _input(event):
    var just_pressed = event.is_pressed() and not event.is_echo()
    if just_pressed:
        if PlayerData.state.current == PlayerData.state.STATE.IDLE:
            if Input.is_key_pressed(KEY_1):
                self._set_active_toolbelt_slot(0)
            if Input.is_key_pressed(KEY_2):
                self._set_active_toolbelt_slot(1)
            if Input.is_key_pressed(KEY_3):
                self._set_active_toolbelt_slot(2)
            if Input.is_key_pressed(KEY_4):
                self._set_active_toolbelt_slot(3)
            if Input.is_key_pressed(KEY_5):
                self._set_active_toolbelt_slot(4)
            if Input.is_key_pressed(KEY_6):
                self._set_active_toolbelt_slot(5)
                
    if (event is InputEventMouseButton):
        if event.is_action_pressed("ui_lmb"):
            if currently_placing:
                var mouse_pos = self._adjust_mouse_place(EnvironmentData.camera.get_global_mouse_position())
                var position = self._to_tilepos(mouse_pos)
                var obj = _get_object_under_position(position)
                if len(obj)==0:
                    var wi = load("res://items/WorldItem.tscn").instance()
                    wi.initialize(position, PlayerData.inventory.get_active_item())
                    EnvironmentData.worlditems.add_child(wi)

    
func _set_active_toolbelt_slot(idx):
    self._hide_toolbelt_selection()
    var a = get_node("Toolbelt/s"+str(idx))
    a.visible = true
    $Toolbelt/ItemList.select(idx)
    PlayerData.inventory.active_toolbelt_slot = idx
    self._set_action_item(idx)
    self._check_placable_selected()
    
func _check_placable_selected():
    if PlayerData.inventory.get_active_item().type == Item.ITEMTYPE.CONTAINER:
        print("container")
        currently_placing = true
        $SpritePlace.visible = true
        var icon = ResourceLoader.load(PlayerData.inventory.get_active_item().texture_path)
        $SpritePlace.texture = icon
        set_process(true)
    else:
        currently_placing = false
        $SpritePlace.visible = false
        set_process(false)
    
func _set_action_item(idx):
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
    $PlayerStats/StaminaBar.value = value
