extends Control

signal digging_returned(value)
signal panning_returned(value)


var current_game = null

# ReactionGame
const DIRECTION = {
    'LEFT': 0,
    'RIGHT': 1
   }

var direction = DIRECTION.RIGHT

const LENGTH = 64
var length = -LENGTH

export var penalty_threshold = 4.5
export var velocity = 300

var random_velocity = 100
var random_angle = PI*(randi()%360)/180

var running = false
var ticks = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(false)
    self.visible = false
    
    $ReactionGame.visible = false
    $ReactionGame/Cursor.visible = false
    
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
            
            if self.length >= self.LENGTH:
                self.direction = self.DIRECTION.LEFT
                self.ticks+=1
            if self.length <= -self.LENGTH:
                self.direction = self.DIRECTION.RIGHT
                self.ticks+=1
            
            if self.direction == self.DIRECTION.RIGHT:
                self.length += delta*vel
            if self.direction == self.DIRECTION.LEFT:
                self.length -= delta*vel
                
            $ReactionGame/Cursor.position = Vector2(LENGTH+self.length*cos(self.random_angle),
                                                    LENGTH+self.length*sin(self.random_angle))
    
    
func start_digging_game(value):
    self.current_game = 'digging'
    if value == 'stop':
        self._clean(GlobalManager.minigame_digging)
        return
        
    self.start_game(GlobalManager.minigame_digging, value)
    
func start_panning_game(value):
    self.current_game = 'panning'
    if value == 'stop':
        self._clean(GlobalManager.minigame_panning)
        return
        
    self.start_game(GlobalManager.minigame_panning, value)
            
func start_game(type, value):
    match type:
        GlobalManager.MINIGAME.REACTIONGAME:
            $ReactionGame.visible = true
            self.visible = true
            self.random_velocity = randi()%50
            self.random_angle = PI*(randi()%360)/180
            self.length = -self.LENGTH
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
                    var distance = sqrt($ReactionGame/Cursor.position.distance_to(Vector2(self.LENGTH,self.LENGTH)))
                    var sprite = Sprite.new()
                    sprite.texture = ResourceLoader.load("res://assets/ui/crosshair_hit.png")
                    sprite.position = $ReactionGame/Cursor.position
                    $ReactionGame/Hits.add_child(sprite)
                    #print(str(self.ticks) + ' ' + str(distance))
                    var penalty = self.ticks * distance - self.penalty_threshold
                    self._reset()
                    emit_signal(sig, penalty)
                    
    if self.visible:
        if Input.is_action_just_pressed("ui_cancel"):
            set_process(false)
            self._reset()
            self._clean(type)
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

func _clean(type):
    match type:
        GlobalManager.MINIGAME.REACTIONGAME:
            for sprite in $ReactionGame/Hits.get_children():
                sprite.queue_free()

func _reset():
    self.running = false
    self.visible = false
    $ReactionGame.visible = false
    $ReactionGame/Cursor.visible = false
    $RandomTimer.stop()
    self.ticks = 0
    

