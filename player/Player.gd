extends KinematicBody2D

var Item = load("res://items/Item.gd")

const ACCELERATION = 25
const MAX_SPEED = 200
const FRICTION = 75

var velocity = Vector2.ZERO
var last_velocity = Vector2.ZERO


func _ready():
    var _res = $ActionTimer.connect("timeout", self, "_on_digging_timeout")
    PlayerData.player = self
    
    
    
    
func _close_all():
    PlayerData.state.current = PlayerData.State.STATE.IDLE
    PlayerData.set_action_progress(100)
    PlayerData.close_inventory("")
    $ActionTimer.stop()
    
    
func _on_digging_timeout():
    var item = PlayerData.inventory.get_active_item()
    if item == null or item.type != Item.ITEMTYPE.SHOVEL or PlayerData.state.stamina<=0:
        self._close_all()
        return
    
    var res = PlayerData.state.digging_tile.dig(item)
    PlayerData.dec_stamina(1)
    var gold = res[0]
    var exhausted = res[1]
    
    PlayerData.inc_goldore(gold)
    self._show_interaction_options()
    
    if !exhausted:
        $ActionTimer.start()
        # calculate progress: base amount dirt = 1
        var progress = 100*(1-PlayerData.state.digging_tile.amount_dirt)
        PlayerData.set_action_progress(progress)

    else:
        print("Done")
        $ActionTimer.stop()
        PlayerData.set_action_progress(100)
        PlayerData.state.current = PlayerData.State.STATE.IDLE
    
func _start_digging(gold_tile):
    self.velocity = Vector2.ZERO
    
    var item = PlayerData.inventory.get_active_item()
    if item == null or item.type != Item.ITEMTYPE.SHOVEL or PlayerData.state.stamina<=0:
        return
    
    PlayerData.state.digging_tile = gold_tile
    PlayerData.state.current = PlayerData.State.STATE.DIGGING
    
    var res = gold_tile.dig(item)
    PlayerData.dec_stamina(1)
    var gold = res[0]
    var exhausted = res[1]
    
    PlayerData.inc_goldore(gold)

    if !exhausted:
        # calculate progress: base amount dirt = 1
        var progress = 100*(1-PlayerData.state.digging_tile.amount_dirt)
        PlayerData.set_action_progress(progress)
        $ActionTimer.set_wait_time(1)
        $ActionTimer.start()
    else:
        PlayerData.set_action_progress(100)
        PlayerData.state.current = PlayerData.State.STATE.IDLE
    
    self._show_interaction_options()

func _physics_process(delta):
    #if $RayCast2D.is_colliding():
    #    var object = $RayCast2D.get_collider()
    #    print(object)
        #if object.is_in_group("Interactable") && Input.is_action_pressed('ui_interact'):
            #object.do_something() #This would be where your inraction occurs
            
    var closed_inventory = false

    match PlayerData.state.current:
        
        PlayerData.State.STATE.INVENTORY:
            if Input.is_action_just_pressed('ui_inventory'):
                self._close_all()
                closed_inventory = true
    
        PlayerData.State.STATE.IDLE:
        
            if self._digging_possible() and Input.is_action_just_pressed("ui_interact"):
                self._start_digging(PlayerData.state.interactables[0])
                
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
        
    if Input.is_action_pressed("ui_cancel"):
        self._close_all()
        
    # we have to check if we just closed the inventory otherwise it will close in the state machine and open again here
    if Input.is_action_just_pressed('ui_inventory') and not closed_inventory:
        self._close_all()
        PlayerData.open_inventory("")
        
        
        
    
func _show_interaction_options():
    if self._digging_possible():
        var gold = PlayerData.state.interactables[0].amount_gold
        PlayerData.set_interactable_text("Dig (E) " + str(gold))
    else:
        PlayerData.set_interactable_text("")
            
func _on_gold_entered(gold):
    PlayerData.state.interactables.append(gold)
    gold.get_node("Line2D").visible = true
    self._show_interaction_options()
    
func _on_gold_exited(gold):
    gold.get_node("Line2D").visible = false
    PlayerData.state.interactables.erase(gold)
    self._show_interaction_options()
    
    
func _digging_possible():
    var item = PlayerData.inventory.get_active_item()
    if item == null:
        return false
    else:
        return len(PlayerData.state.interactables)>0 \
            and PlayerData.state.interactables[0].type == EnvironmentData.TYPE.DIGGABLE \
            and item.type == Item.ITEMTYPE.SHOVEL
#func _on_gold_clicked(gold):
#    self.player_state = STATE.MenuFreeze
#    var pos = Vector2(0,0)#gold.position-self.position-Vector2(16,16)
#    $"../CanvasLayer/UI/Panel".set_position(pos)
#    var btn = Button.new()
#    btn.text = "Test"
#    $"../CanvasLayer/UI/Panel/Options".add_child(btn)
#    $"../CanvasLayer/UI/Panel".visible = true
#    var dist = self.position.distance_to(gold.position)
#    print(dist)

