extends Control

signal digging_returned(value)
signal panning_returned(value)



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var current_game = null

# ReactionGame
const DIRECTION = {
    'LEFT': 0,
    'RIGHT': 1
   }

var direction = DIRECTION.RIGHT
export var penalty_threshold = 5
export var velocity = 300
var random_velocity = 100
var running = false
var ticks = 0
var init_pos = null

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(false)
    self.visible = false
    
    $ReactionGame.visible = false
    $ReactionGame/Cursor.visible = false
    init_pos = $ReactionGame/Cursor.position
    
    
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var type = null
    if self.current_game == 'digging':
        type = GlobalManager.minigame_digging
    elif self.current_game == 'panning':
        type = GlobalManager.minigame_panning
    
    match type:
        
        GlobalManager.MINIGAME.REACTIONGAME:
            var vel = self.velocity + self.random_velocity
            var pos0 = $ReactionGame/Cursor.position
            if pos0.x >= 128:
                direction = DIRECTION.LEFT
                self.ticks+=1
            if pos0.x <= 0:
                direction = DIRECTION.RIGHT
                self.ticks+=1
                
            var pos1 = pos0
            if direction == DIRECTION.RIGHT:
                pos1 += Vector2(delta*vel, 0)
            else:
                pos1 -= Vector2(delta*vel,0)
            
            $ReactionGame/Cursor.position = pos1
    
    
func start_digging_game(value):
    self.current_game = 'digging'
    self.start_game(GlobalManager.minigame_digging, value)
    
func start_panning_game(value):
    self.current_game = 'panning'
    self.start_game(GlobalManager.minigame_panning, value)
            
func start_game(type, value):
    match type:
        GlobalManager.MINIGAME.REACTIONGAME:
            $ReactionGame.visible = true
            self.visible = true
            self.random_velocity = randi()%50
            $RandomTimer.set_wait_time(0.25+EnvironmentData.random_number_generator.randf())
            $RandomTimer.start()
            yield($RandomTimer, "timeout")
            self.running = true
            $ReactionGame/Cursor.visible = true
            $RandomTimer.stop()
            set_process(true)
            
        GlobalManager.MINIGAME.TIME:
            self.visible = true
            if value == 'start':
                $RandomTimer.set_wait_time(0.05)
            else:
                $RandomTimer.set_wait_time(0.75)
            $RandomTimer.one_shot = true
            var _c = $RandomTimer.connect("timeout", self, "_on_timeout")
            $RandomTimer.start()
    
    
func _input(event):
    var type = null
    var sig = null
    if self.current_game == 'digging':
        type = GlobalManager.minigame_digging
        sig = "digging_returned"
    elif self.current_game == 'panning':
        type = GlobalManager.minigame_panning
        sig = "panning_returned"
    
    match type:
        
        GlobalManager.MINIGAME.REACTIONGAME:
            if self.visible and self.running:
                if Input.is_action_just_pressed('ui_interact'):
                    set_process(false)
                    var distance = sqrt(abs($ReactionGame/Cursor.position.x - 128/2))
                    #print(str(self.ticks) + ' ' + str(distance))
                    var penalty = self.ticks * distance - self.penalty_threshold
                    self._reset()
                    emit_signal(sig, penalty)
                    
    if self.visible:
        if Input.is_action_just_pressed("ui_cancel"):
            set_process(false)
            self._reset()
            emit_signal(sig, null)
            
func _on_timeout():
    var type = null
    var sig = null
    if self.current_game == 'digging':
        type = GlobalManager.minigame_digging
        sig = "digging_returned"
    elif self.current_game == 'panning':
        type = GlobalManager.minigame_panning
        sig = "panning_returned"
        
    match type:
        GlobalManager.MINIGAME.TIME:
            self._reset()
            emit_signal(sig, 0)

func _reset():
    self.running = false
    self.visible = false
    $ReactionGame.visible = false
    $ReactionGame/Cursor.visible = false
    $ReactionGame/Cursor.position = init_pos
    $RandomTimer.stop()
    self.ticks = 0
    

