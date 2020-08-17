extends KinematicBody2D

signal open_shop()
signal open_parcel()

const ACCELERATION = 25
const MAX_SPEED = 200
const FRICTION = 75

var velocity = Vector2.ZERO
var last_velocity = Vector2.ZERO


func _ready():
    PlayerData.player = self
    self._reset_player_state()


func _reset_player_state():
    PlayerData.state.set_state(PlayerData.State.STATE.IDLE)
    PlayerData.set_action_progress(100)
    set_physics_process(true)


func _physics_process(_delta):
    
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
            
func _input(event):
#    if PlayerData.state.current != PlayerData.state.STATE.IDLE and \
#        PlayerData.state.current != PlayerData.state.STATE.DIGGING:
#        if Input.is_action_just_pressed("ui_cancel"):
#            self._reset_player_state()
    
    if Input.is_action_just_pressed("ui_interact"):
        if self._shop_possible():
            emit_signal("open_shop")
        elif self._parcel_possible():
            emit_signal("open_parcel")
        
func _show_interaction_options():
    var options_text = ""
    if self._shop_possible():
        options_text = "Shop (E) "
    elif self._parcel_possible():
        options_text = "Parcel (E)"
        
    PlayerData.set_interactable_text(options_text)
        
func _on_shopsign_entered(shopsign):
    PlayerData.state.interactables = [shopsign]
    shopsign.get_node("Line2D").visible = true
    self._show_interaction_options()
    
    
func _on_shopsign_exited(shopsign):
    shopsign.get_node("Line2D").visible = false
    PlayerData.state.interactables.erase(shopsign)
    self._show_interaction_options()
    
func _on_parcelsign_entered(parcelsign):
    PlayerData.state.interactables = [parcelsign]
    parcelsign.get_node("Line2D").visible = true
    self._show_interaction_options()
    
    
func _on_parcelsign_exited(parcelsign):
    parcelsign.get_node("Line2D").visible = false
    PlayerData.state.interactables.erase(parcelsign)
    self._show_interaction_options()
    
    
func _shop_possible():
    var shop = false
    for interi in PlayerData.state.interactables:
        if interi.get_name() == 'ShopSign':
            shop = true
    return shop


func _parcel_possible():
    var parcel = false
    for interi in PlayerData.state.interactables:
        if interi.get_name() == 'ParcelSign':
            parcel = true
    return parcel
