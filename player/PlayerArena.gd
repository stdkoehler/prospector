extends KinematicBody2D


const ACCELERATION = 25
const MAX_SPEED = 200
const FRICTION = 75

var velocity = Vector2.ZERO
var last_velocity = Vector2.ZERO

var bullet = preload('res://environment/arena/Bullet.tscn')


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
            
            if Input.is_action_just_pressed('ui_lmb'):
                shoot()

func _on_Hurtbox_body_entered(body):
    if "Bullet" in body.name:
        #self.queue_free()
        var dir = body.get_linear_velocity().normalized()
        self.velocity += 350*dir
        PlayerData.dec_stamina(body.damage)
        body.queue_free()
        if PlayerData.state.stamina <= 0:
            PlayerData.state.stamina = 100
            GlobalManager.goto_scene("res://Hub.tscn")
            
func shoot():
    var bullet_instance = bullet.instance()
    var playerpos = self.get_global_position()
    var dir = playerpos.angle_to_point(get_global_mouse_position()) + PI
    bullet_instance.position = Vector2(0,0) # when the object is our own child we don't need global position
    bullet_instance.rotation_degrees = dir
    bullet_instance.apply_impulse(Vector2(), Vector2(bullet_instance.speed, 0).rotated(dir) )
    self.add_child(bullet_instance)
    #get_tree().get_root().call_deferred("add_child", bullet_instance)
    

