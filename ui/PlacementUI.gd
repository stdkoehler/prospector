extends Control

var Item = load("res://items/Item.gd")

var currently_placing = false

func _ready():
    set_process(false)
    

func _process(delta) -> void:
    if currently_placing:
        var global_pos = self._adjust_mouse_place(EnvironmentData.camera.get_global_mouse_position())
        var view_pos = self._adjust_mouse_place(get_viewport().get_mouse_position())
        var offset = view_pos-global_pos
        var position = self._to_tilepos(global_pos)
        $SpritePlace.position = position+offset
        
func _input(event):
    if (event is InputEventMouseButton):
        if event.is_action_pressed("ui_lmb") and self.visible:
            if currently_placing:
                var mouse_pos = self._adjust_mouse_place(EnvironmentData.camera.get_global_mouse_position())
                var position = self._to_tilepos(mouse_pos)
                var obj = self._get_object_under_position(position)
                if len(obj)==0:
                    var wi = load("res://items/WorldItem.tscn").instance()
                    wi.initialize(position, PlayerData.inventory.get_active_item())
                    EnvironmentData.worlditems.add_child(wi)
                    wi.connect("player_entered", PlayerData.player, "_on_worlditem_entered")
                    wi.connect("player_exited", PlayerData.player, "_on_worlditem_exited")
        
        
    
    
func _to_tilepos(position):
    return Vector2(round(position.x/32)*32, round(position.y/32)*32)+Vector2(16,16)
    
func _adjust_mouse_place(position):
    return position-Vector2(16,16)
    
    
func _get_object_under_position(position):
    var space_state = get_world_2d().get_direct_space_state()
    var selection = space_state.intersect_ray(position-Vector2(16,16), position+Vector2(16,16), [], 0xFFFFFFFF)
    #var selection = space_state.intersect_point(mouse_pos, 32, [], 0xFFFFFFFF, true, true)
    return selection
    
func _enable_placement(flag):
    if flag:
        self.visible = true
    else:
        self.visible = false
    
func _check_placable_selected():
    if self.visible:
        if PlayerData.inventory.get_active_item().type == Item.ITEMTYPE.CONTAINER:
            currently_placing = true
            $SpritePlace.visible = true
            var icon = ResourceLoader.load(PlayerData.inventory.get_active_item().texture_path)
            $SpritePlace.texture = icon
            #self.visible = true
            set_process(true)
        else:
            currently_placing = false
            $SpritePlace.visible = false
            #self.visible = false
            set_process(false)
        

