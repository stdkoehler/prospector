extends KinematicBody2D

signal digging_started(value)

var Item = load("res://items/Item.gd")

const ACCELERATION = 25
const MAX_SPEED = 200
const FRICTION = 75

var velocity = Vector2.ZERO
var last_velocity = Vector2.ZERO


func _ready():
    var _c
    _c = $ActionTimer.connect("timeout", self, "_on_timeout")
    PlayerData.player = self
    self._reset_player_state()
    
func _reset_player_state():
    PlayerData.state.current = PlayerData.State.STATE.IDLE
    PlayerData.set_action_progress(100)
    $ActionTimer.stop()
    

func _digging(item):
    var nearest_bulk_storage = EnvironmentData.get_closest_bulk_storage(self.position)
    if item == null or item.type != Item.ITEMTYPE.SHOVEL or PlayerData.state.stamina<=0 or nearest_bulk_storage == null:
        self._reset_player_state()
        return null

    var res = PlayerData.state.digging_tile.dig(item)
    PlayerData.dec_stamina(1)
    var amount = res[0]
    var gold = res[1]
    var exhausted = res[2]

    nearest_bulk_storage.add(amount, gold)
    var progress = 100*(1-PlayerData.state.digging_tile.amount_dirt)
    
    return [exhausted, progress]
    
#func _start_digging(gold_tile):
#    self.velocity = Vector2.ZERO
#    var item = PlayerData.inventory.get_active_item()
#    PlayerData.state.digging_tile = gold_tile
#
#    var exhausted = false
#    var progress = 0
#
#    var res = self._digging(item)
#    if res == null:
#        return
#
#    exhausted = res[0]
#    progress = res[1]
#
#    PlayerData.state.current = PlayerData.State.STATE.DIGGING
#
#    self._post_action(exhausted, progress)
    
func _start_digging(gold_tile):
    self.velocity = Vector2.ZERO
    var item = PlayerData.inventory.get_active_item()
    var nearest_bulk_storage = EnvironmentData.get_closest_bulk_storage(self.position)
    if item == null or item.type != Item.ITEMTYPE.SHOVEL or PlayerData.state.stamina<=0 or nearest_bulk_storage == null:
        self._reset_player_state()
        return null
    
    PlayerData.state.digging_tile = gold_tile

    
    set_physics_process(false)
    print("_start_digging")
    emit_signal("digging_started", null)
    

func _return_digging(result):
    var exhausted = false
    var progress = 0
    var item = PlayerData.inventory.get_active_item()
    
    var res = self._digging(item)
    if res == null:
        return

    exhausted = res[0]
    progress = res[1]

    PlayerData.state.current = PlayerData.State.STATE.DIGGING

    self._show_interaction_options()
    print(PlayerData.state.digging_tile)
    if !exhausted:
        PlayerData.set_action_progress(progress)
        print("_return_digging")
        emit_signal("digging_started", null)
    else:
        print("Done")
        $ActionTimer.stop()
        PlayerData.set_action_progress(100)
        PlayerData.state.current = PlayerData.State.STATE.IDLE
        set_physics_process(true)
    
    
func _panning(item):
    if item == null or item.type != Item.ITEMTYPE.PAN or PlayerData.state.stamina<=0:
        self._reset_player_state()
        return null

    var res = PlayerData.state.panning_item.pan(item)
    PlayerData.dec_stamina(1)
    #var amount = res[0]
    var gold = res[1]
    var exhausted = res[2]

    PlayerData.inc_goldore(gold)
    
    var progress = 100*(1-PlayerData.state.panning_item.amount_dirt/PlayerData.state.panning_item.amount_limit)
    
    return [exhausted, progress]
    
func _start_panning(panning_item):
    self.velocity = Vector2.ZERO
    var item = PlayerData.inventory.get_active_item()
    PlayerData.state.panning_item = panning_item
    
    var exhausted = false
    var progress = 0
    
    var res = self._panning(item)
    if res == null:
        return
    
    exhausted = res[0]
    progress = res[1]
    
    PlayerData.state.current = PlayerData.State.STATE.PANNING
    
    self._post_action(exhausted, progress)
    
func _on_timeout():
    var item = PlayerData.inventory.get_active_item()
    
    var exhausted = false
    var progress = 0
    
    match PlayerData.state.current:
        PlayerData.state.STATE.DIGGING:
            var res = self._digging(item)
            if res != null:
                exhausted = res[0]
                progress = res[1]
            else:
                exhausted = true # this happens when container is full
            

        PlayerData.state.STATE.PANNING:
            var res = self._panning(item)
            if res != null:
                exhausted = res[0]
                progress = res[1]
            else:
                exhausted = true # this happens when container is full
                
            #PlayerData.inc_goldore(gold)
            
    self._post_action(exhausted, progress)
    
func _post_action(exhausted, progress):
    self._show_interaction_options()
    
    if !exhausted:
        PlayerData.set_action_progress(progress)
        $ActionTimer.set_wait_time(1)
        $ActionTimer.start()
    else:
        print("Done")
        $ActionTimer.stop()
        PlayerData.set_action_progress(100)
        PlayerData.state.current = PlayerData.State.STATE.IDLE
    
    

    
    

func _physics_process(_delta):
    #if $RayCast2D.is_colliding():
    #    var object = $RayCast2D.get_collider()
    #    print(object)
        #if object.is_in_group("Interactable") && Input.is_action_pressed('ui_interact'):
            #object.do_something() #This would be where your inraction occurs
            
    if PlayerData.state.current != PlayerData.state.STATE.IDLE:
        if Input.is_action_just_pressed("ui_cancel"):
            self._reset_player_state()
            
    match PlayerData.state.current:
    
        PlayerData.State.STATE.IDLE:
            
            if Input.is_action_just_pressed("ui_right"):
                $RayCast2D.rotation_degrees = 0
            if Input.is_action_just_pressed("ui_down"):
                $RayCast2D.rotation_degrees = 90
            if Input.is_action_just_pressed("ui_left"):
                $RayCast2D.rotation_degrees = 180
            if Input.is_action_just_pressed("ui_up"):
                $RayCast2D.rotation_degrees = 270
        
            if Input.is_action_just_pressed("ui_interact"):
                if PlayerData.inventory.get_active_item().type == Item.ITEMTYPE.SHOVEL\
                    and self._digging_possible():
                    self._start_digging(PlayerData.state.interactables[0])
                elif PlayerData.inventory.get_active_item().type == Item.ITEMTYPE.PAN\
                    and self._panning_possible():
                    var pannables = PlayerData.state.get_pannable_storage()
                    self._start_panning(pannables[0])
                else:
                    pass
                
            var input_vector = Vector2.ZERO
            input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
            input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
            input_vector = input_vector.normalized()
            
            if input_vector != Vector2.ZERO:
                if input_vector.x > 0:
                    $AnimationPlayer.play("WalkRight")
                    last_velocity = input_vector
                elif input_vector.x < 0:
                    $AnimationPlayer.play("WalkLeft")
                    last_velocity = input_vector
                else:
                    if last_velocity.x > 0:
                        $AnimationPlayer.play("WalkRight")
                    else:
                        $AnimationPlayer.play("WalkLeft")
                        
                velocity += input_vector * ACCELERATION
                velocity = velocity.clamped(MAX_SPEED)
            else:
                $AnimationPlayer.play("IdleDown")
                velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
                #velocity = Vector2.ZERO
                
            var _collider = move_and_slide(velocity)
        
        PlayerData.state.STATE.DIGGING:
            velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
            $AnimationPlayer.play("IdleDown")
        PlayerData.state.STATE.PANNING:
            velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
            $AnimationPlayer.play("IdleDown")
        
        
        
func _show_interaction_options():
    var options_text = []
    var gold = 0
    if self._digging_possible():
        gold = PlayerData.state.interactables[0].amount_gold
        options_text.append("Dig (E) " + str(gold))
        
    if self._panning_possible():
        var pannables = PlayerData.state.get_pannable_storage()
        gold = pannables[0].amount_gold
        options_text.append("Pan (E) " + str(gold))
        
    var text = ""
    for i in range(len(options_text)):
        if i > 0:
            text += "\n"
        text += options_text[i]
        
        
    PlayerData.set_interactable_text(text)
            
func _on_gold_entered(gold):
    PlayerData.state.interactables.append(gold)
    gold.get_node("Line2D").visible = true
    self._show_interaction_options()
    
func _on_gold_exited(gold):
    gold.get_node("Line2D").visible = false
    PlayerData.state.interactables.erase(gold)
    self._show_interaction_options()
    
func _on_worlditem_entered(worlditem):
    PlayerData.state.worlditems.append(worlditem)
    worlditem.get_node("Line2D").visible = true
    self._show_interaction_options()
    
func _on_worlditem_exited(worlditem):
    worlditem.get_node("Line2D").visible = false
    PlayerData.state.worlditems.erase(worlditem)
    self._show_interaction_options()
    
func _digging_possible():
    var item = PlayerData.inventory.get_active_item()
    if item == null:
        return false
    else:
        return len(PlayerData.state.interactables)>0 \
            and PlayerData.state.interactables[0].type == EnvironmentData.TYPE.DIGGABLE \
            and item.type == Item.ITEMTYPE.SHOVEL

func _panning_possible():
    var item = PlayerData.inventory.get_active_item()
    if item == null:
        return false
    else:
        return len(PlayerData.state.get_pannable_storage())>0 and item.type == Item.ITEMTYPE.PAN

