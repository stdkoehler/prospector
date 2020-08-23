extends RigidBody2D



func _ready():
    $Autodestruct.wait_time = 2
    $Autodestruct.one_shot = true
    var _c = $Autodestruct.connect("timeout", self, "_autodestruct")
    $Autodestruct.start()
    
    
func _autodestruct():
    self.queue_free()
