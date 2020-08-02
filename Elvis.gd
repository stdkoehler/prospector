extends KinematicBody2D


const ACCELERATION = 25
const MAX_SPEED = 300
const FRICTION = 75

var velocity = Vector2.ZERO
var last_velocity = Vector2.ZERO

const STATE = {
    "WAITING": 0,
    "APPROACH": 1,
    "SLACK": 2
   }

onready var state = STATE.WAITING

func _walk_to(pos):
    var path = EnvironmentData.nav2d.get_simple_path(self.global_position, pos)
    if path.size()>1:
        return self.global_position.direction_to(path[1]) * ACCELERATION
    else:
        return Vector2.ZERO

func _physics_process(_delta):
    
    var player_pos = PlayerData.player.global_position
    var dist = self.position.distance_to(player_pos)
    
    match state:
        
        STATE.WAITING:
            if dist > 200:
                state = STATE.APPROACH
                velocity += _walk_to(player_pos)
            else:
                velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
            
        STATE.APPROACH:
            if dist <= 100 and PlayerData.player.velocity.length()==0:
                velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
                state = STATE.WAITING
            else:
                velocity += _walk_to(player_pos)
                if dist <= 100:
                    state = STATE.SLACK
                    
        STATE.SLACK:
            velocity = velocity.clamped(0.8*PlayerData.player.MAX_SPEED)
            if dist >= 150:
                state = STATE.APPROACH
            elif dist <= 100 and PlayerData.player.velocity.length()==0:
                state = STATE.WAITING
            
            
    velocity = velocity.clamped(MAX_SPEED)
    if velocity != Vector2.ZERO:
        if velocity.x > 0:
            $AnimationPlayer.play("WalkRight")
            last_velocity = velocity
        elif velocity.x < 0:
            $AnimationPlayer.play("WalkLeft")
            last_velocity = velocity
        else:
            if last_velocity.x > 0:
                $AnimationPlayer.play("WalkRight")
            else:
                $AnimationPlayer.play("WalkLeft")
                
    else:
        if last_velocity.x > 0:
            $AnimationPlayer.play("IdleRight")
        else:
            $AnimationPlayer.play("IdleLeft")
    
    var _collider = move_and_slide(velocity)
