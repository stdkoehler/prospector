extends KinematicBody2D


var velocity = Vector2.ZERO

const FRICTION = 75 
const ACCELERATION = 10
const MAX_SPEED = 210

var player = null


var canshoot = true
var canmove = true
export var bullet = preload('res://environment/arena/Bullet.tscn')
export var max_health = 100

onready var health = max_health

export var SHOOTFRAME = 3
export var MOVEFRAME = 4

# Called when the node enters the scene tree for the first time.
func _ready():
    self.player = PlayerData.player


func _physics_process(delta):
    
    
    if canmove == true:
        #$AnimationPlayer.play("Idle")
    
        var playerdistance = self.get_global_position().distance_to(self.player.get_global_position())
        
        if playerdistance < 500 and playerdistance > 175:
            var acc = ACCELERATION*self.get_global_position().direction_to(self.player.get_global_position())
            velocity += acc
            velocity = velocity.clamped(MAX_SPEED)
        else:
            velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
            
        if playerdistance <= 200:
            self.shoot()
        
        var _collider = move_and_slide(velocity)


func _on_Hitbox_body_entered(body):
    if "Bullet" in body.name:
        #self.queue_free()
        var dir = body.get_linear_velocity().normalized()
        self.velocity += 350*dir
        body.queue_free()
        self.health -= body.damage
        print(self.health)
        if self.health <= 0:
            self.queue_free()


func shoot():
    if self.canshoot:
        $AnimationPlayer.play("Shoot")
        self.canshoot = false
        self.canmove = false
        
        

func _on_Sprite_frame_changed():
    if $Sprite.frame == SHOOTFRAME:
        var bullet_instance = bullet.instance()
        bullet_instance.collision_layer = 8
        bullet_instance.collision_mask = 8
        var dir = self.get_global_position().angle_to_point(self.player.get_global_position())+PI
        bullet_instance.position = Vector2(0,0) # when the object is our own child we don't need global position
        bullet_instance.rotation_degrees = 180*(dir-PI/4)/PI
        bullet_instance.apply_impulse(Vector2(), Vector2(bullet_instance.speed, 0).rotated(dir) )
        self.add_child(bullet_instance)
        $Timer.start()
        #get_tree().get_root().call_deferred("add_child", bullet_instance)
    if $Sprite.frame == MOVEFRAME:
        self.canmove = true
    


func _on_Timer_timeout():
    self.canshoot = true
