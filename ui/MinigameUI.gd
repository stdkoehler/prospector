extends Control

signal minigame_action_returned(action, penalty, state)


var current_action = null
var current_game = null

# ReactionGame
const DIRECTION = {
    'LEFT': 0,
    'RIGHT': 1
   }

var direction = DIRECTION.RIGHT

const LENGTH = 64
var length = LENGTH

export var penalty_threshold = 4.5
export var velocity = 300

var random_velocity = 100
var random_angle = PI*(randi()%360)/180

var running = false
var ticks = null

# MathGame

var timer = 0
var a = 1
var b = 1
var cpos = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(false)
    self.visible = false
    
    $ReactionGame.visible = false
    $ReactionGame/Cursor.visible = false
    
    $MathGame.visible = false
    var btn = null
    var _c = null
    for i in range(1,13):
        btn = self.get_node("MathGame/Vbox/Solution/s"+str(i))
        _c = btn.connect("pressed", self, "_on_math_solution_pressed", [btn])
    
    _c = $RandomTimer.connect("timeout", self, "_on_timeout")
    
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    match self.current_game:
        
        GlobalManager.MINIGAME.REACTIONGAME:
            var vel = self.velocity + self.random_velocity
            
            if self.length > self.LENGTH:
                self.direction = self.DIRECTION.LEFT
                self.ticks+=1
            if self.length < -self.LENGTH:
                self.direction = self.DIRECTION.RIGHT
                self.ticks+=1
            
            if self.direction == self.DIRECTION.RIGHT:
                self.length += delta*vel
            if self.direction == self.DIRECTION.LEFT:
                self.length -= delta*vel
                
            $ReactionGame/Cursor.position = Vector2(LENGTH+self.length*cos(self.random_angle),
                                                    LENGTH+self.length*sin(self.random_angle))
                                                
        GlobalManager.MINIGAME.MATHGAME:
            self.timer += delta
    
    
func _start_action(action, state):
    self.current_action = action
    match action:
        GlobalManager.ACTION.DIGGING:
            self.current_game = GlobalManager.minigame_digging
            
        GlobalManager.ACTION.PANNING:
            self.current_game = GlobalManager.minigame_panning
            
    # end game if we receive stop
    if state == GlobalManager.ACTIONSTATE.STOP:
        self._clean()
        return
        
    self._start_game(state)
    
            
func _start_game(state):
    match self.current_game:
        GlobalManager.MINIGAME.REACTIONGAME:
            $ReactionGame.visible = true
            self.visible = true
            self.random_velocity = randi()%50
            self.random_angle = PI*(randi()%360)/180
            self.length = self.LENGTH
            self.direction = self.DIRECTION.LEFT
            self.ticks = 0
            $RandomTimer.set_wait_time(0.25+EnvironmentData.random_number_generator.randf())
            $RandomTimer.start()
            yield($RandomTimer, "timeout")
            self.running = true
            $ReactionGame/Cursor.visible = true
            $RandomTimer.stop()
            set_process(true)
            
        GlobalManager.MINIGAME.TIME:
            self.visible = true
            if state == GlobalManager.ACTIONSTATE.START:
                $RandomTimer.set_wait_time(0.05)
            else:
                $RandomTimer.set_wait_time(0.75)
            $RandomTimer.one_shot = true
            $RandomTimer.start()
            
        GlobalManager.MINIGAME.MATHGAME:
            self.visible = true
            $MathGame.visible = true
            self.timer = 0
            self.a = 1+randi()%10
            self.b = 1+randi()%10
            var sol = self.a*self.b
            self.cpos = 1+randi()%12
            $MathGame/Vbox/Formula.text = str(self.a) + 'x' + str(self.b)
            var btn = null
            for i in range(1,13):
                btn = self.get_node("MathGame/Vbox/Solution/s"+str(i))
                btn.set_modulate(Color('FFFFFF'))
                var candidate = 1+randi()%100
                while candidate == sol:
                    candidate = 1+randi()%100
                btn.set_text(str(candidate))
                
            btn = self.get_node("MathGame/Vbox/Solution/s"+str(self.cpos))
            
            btn.set_text(str(self.a*self.b))
            set_process(true)
            
    
    
func _input(event):
    match self.current_game:
        
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
                    print("ticks " + str(self.ticks))
                    var penalty = (1+0.5*self.ticks) * distance - self.penalty_threshold
                    self._reset()
                    emit_signal("minigame_action_returned", self.current_action, penalty, GlobalManager.ACTIONSTATE.ACTIVE)
                    
    if self.visible:
        if Input.is_action_just_pressed("ui_cancel"):
            set_process(false)
            self._reset()
            self._clean()
            emit_signal("minigame_action_returned", self.current_action, null, GlobalManager.ACTIONSTATE.STOP)


func _on_timeout():
    match self.current_game:
        GlobalManager.MINIGAME.TIME:
            self._reset()
            emit_signal("minigame_action_returned", self.current_action, 0, GlobalManager.ACTIONSTATE.ACTIVE)


func _clean():
    match self.current_game:
        GlobalManager.MINIGAME.REACTIONGAME:
            for sprite in $ReactionGame/Hits.get_children():
                sprite.queue_free()


func _reset():
    self.running = false
    self.visible = false
    $ReactionGame.visible = false
    $ReactionGame/Cursor.visible = false
    $MathGame.visible = false
    $RandomTimer.stop()
    



func _on_math_solution_pressed(btn):
    var sol = int(btn.name.split('s')[1])
    if sol == self.cpos:
        var penalty = self.timer-3
        self._reset()
        emit_signal("minigame_action_returned", self.current_action, penalty, GlobalManager.ACTIONSTATE.ACTIVE)
    else:
        self.timer += 0.5
        btn.set_modulate(Color('ac3232'))
