extends Control

signal digging_returned(value)



# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const DIRECTION = {
    'LEFT': 0,
    'RIGHT': 1
   }

var direction = DIRECTION.RIGHT
export var velocity = 200

var init_pos = null

# Called when the node enters the scene tree for the first time.
func _ready():
    self.visible = false
    set_process(false)
    init_pos = $Panel/Cursor.position
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    
    var pos0 = $Panel/Cursor.position
    if pos0.x >= 100:
        direction = DIRECTION.LEFT
    if pos0.x <= 0:
        direction = DIRECTION.RIGHT
        
    var pos1 = pos0
    if direction == DIRECTION.RIGHT:
        pos1 += Vector2(delta*velocity, 0)
    else:
        pos1 -= Vector2(delta*velocity,0)
    
    $Panel/Cursor.position = pos1
    
    
func start_digging_game(value):
    print("got_signal")
    self.visible = true
    set_process(true)
    
func _input(event):
    if self.visible:
        if Input.is_action_just_pressed('ui_interact'):
            self.visible = false
            $Panel/Cursor.position = init_pos
            set_process(false)
            emit_signal("digging_returned", null)
    

