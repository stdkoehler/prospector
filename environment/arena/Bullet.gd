extends RigidBody2D

export var damage = 20
export var speed = 300


func _ready():
    self.set_continuous_collision_detection_mode(1)
    $Autodestruct.wait_time = 2
    $Autodestruct.one_shot = true
    var _c = $Autodestruct.connect("timeout", self, "_autodestruct")
    $Autodestruct.start()
    if 'Shooting' in $AnimationPlayer.get_animation_list():
        $AnimationPlayer.play('Shooting')
    
    
func _autodestruct():
    self.queue_free()
