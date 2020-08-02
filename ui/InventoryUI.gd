extends Control

var cursor_inside_itemlist = false

var pickup_mousepos = null

var dragged_idx = -1
var active_idx = -1

var lmb_released = true

var currently_dragging = false

var empty_slot_texture = ResourceLoader.load("res://assets/tools/icon_none.png")


func _ready():
    var _c = null
    _c = PlayerData.connect("inventory_opened", self, "open_inventory")
    _c = PlayerData.connect("inventory_closed", self, "close_inventory")
    
    
    $Panel/ItemListBackpack.set_max_columns(6)
    $Panel/ItemListBackpack.set_fixed_icon_size(Vector2(32,32))
    $Panel/ItemListBackpack.set_icon_mode($Panel/ItemListBackpack.ICON_MODE_TOP)
    $Panel/ItemListBackpack.set_select_mode($Panel/ItemListBackpack.SELECT_SINGLE)
    $Panel/ItemListBackpack.set_same_column_width(true)
    $Panel/ItemListBackpack.set_allow_rmb_select(true)
    
    $Panel/ItemListBackpack.clear()
        
    for i in range(PlayerData.inventory.BACKPACKSIZE):
        $Panel/ItemListBackpack.add_item("", null, false)
        update_slot(i)
        
    set_process(false)
    set_process_input(true)
    
    
func open_inventory(_value):
    self.visible = true
    
func close_inventory(_value):
    self.visible = false
    
    
func update_slot(idx):
    if (idx < 0):
        return
        
    if PlayerData.inventory.exists(idx):
        
        var item = PlayerData.inventory.get_item(idx)
        var icon = ResourceLoader.load(item.texture_path)
    
        $Panel/ItemListBackpack.set_item_icon(idx, icon)
        $Panel/ItemListBackpack.set_item_selectable(idx, true)
        $Panel/ItemListBackpack.set_item_metadata(idx, item)
        $Panel/ItemListBackpack.set_item_tooltip(idx, item.name)
        $Panel/ItemListBackpack.set_item_tooltip_enabled(idx, true)
    else:
        $Panel/ItemListBackpack.set_item_icon(idx, empty_slot_texture)
        $Panel/ItemListBackpack.set_item_selectable(idx, false)
        $Panel/ItemListBackpack.set_item_metadata(idx, null)
        $Panel/ItemListBackpack.set_item_tooltip(idx, "")
        $Panel/ItemListBackpack.set_item_tooltip_enabled(idx, false)
    
func _process(_delta):
    if currently_dragging:
        $Panel/SpriteDrag.global_position = get_viewport().get_mouse_position()

func _input(event) -> void:
    if self.visible:
        if (event is InputEventMouseButton):
            if (event.is_action_pressed("ui_lmb")):
                print("?")
                lmb_released = false
                pickup_mousepos = get_viewport().get_mouse_position()
            if (event.is_action_released("ui_lmb")):
                move_merge_item()
                end_drag_item()
                print("!")
    
        if (event is InputEventMouseMotion):
            if cursor_inside_itemlist:
                active_idx = $Panel/ItemListBackpack.get_item_at_position($Panel/ItemListBackpack.get_local_mouse_position(),true)
                print(active_idx)
                if (active_idx >= 0):
                    #$Panel/ItemListBackpack.select(active_idx, true)
                    if (currently_dragging or lmb_released):
                        return
                    #if (!$Panel/ItemListBackpack.is_item_selectable(active_idx)):
                    #    end_drag_item()
                    if (pickup_mousepos.distance_to(get_viewport().get_mouse_position()) > 0.0):
                        begin_drag_item(active_idx)
            else:
                active_idx = -1

func begin_drag_item(idx):
    if currently_dragging:
        return
    if (idx < 0):
        return

    set_process(true)
    $Panel/SpriteDrag.texture = $Panel/ItemListBackpack.get_item_icon(idx)
    $Panel/SpriteDrag.show()

    # Hide slot
    $Panel/ItemListBackpack.set_item_text(idx, "")
    $Panel/ItemListBackpack.set_item_icon(idx, empty_slot_texture)
    
    dragged_idx = idx
    currently_dragging = true
    lmb_released = false
    $Panel/SpriteDrag.global_translate(get_viewport().get_mouse_position())
    
    
func end_drag_item():
    set_process(false)
    dragged_idx = -1
    $Panel/SpriteDrag.hide()
    lmb_released = true
    currently_dragging = false
    active_idx = -1
    
func move_merge_item():
    if (dragged_idx < 0):
        return
    if (active_idx < 0):
        update_slot(dragged_idx)
        return

    if (active_idx == dragged_idx):
        update_slot(dragged_idx)
    else:
        PlayerData.inventory.move_item(dragged_idx, active_idx)
        update_slot(dragged_idx)
        update_slot(active_idx)
        

func _on_ItemListBackpack_mouse_entered():
    print("enter")
    cursor_inside_itemlist = true


func _on_ItemListBackpack_mouse_exited():
    print("exit")
    #for i in range(12):
    #    $Panel/ItemListBackpack.select(i, false)
    cursor_inside_itemlist = false


func _on_ItemListBackpack_item_selected(_index):
    print("selected")
