extends KinematicBody2D


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
    #if $RayCast2D.is_colliding():
    #    var object = $RayCast2D.get_collider()
    #    print(object)
        #if object.is_in_group("Interactable") && Input.is_action_pressed('ui_interact'):
            #object.do_something() #This would be where your inraction occurs
            
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
        
        
