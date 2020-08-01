extends Node2D

const tilesize = 32
const WIDTH = 75
const HEIGHT = 25

const TILES = {
    'Dirt_Dark': 0,
    'Grass_Dry': 1
   }

var dirt_patch_noise
var gold_noise

# Called when the node enters the scene tree for the first time.
func _ready():
    
    EnvironmentData.HEIGHT = HEIGHT
    EnvironmentData.WIDTH = WIDTH
    
    EnvironmentData.nav2d = $Navigation2D
    EnvironmentData.nav2dtilemap = $Navigation2D/RockNavigationMap
    EnvironmentData.rocks = $YSort/RockContainer
    EnvironmentData.camera = $Camera2D2
    EnvironmentData.worlditems = $YSort/WorldItems
    
    randomize()
    dirt_patch_noise = OpenSimplexNoise.new()
    dirt_patch_noise.seed = randi()
    
    dirt_patch_noise.octaves = 4
    dirt_patch_noise.period = 15
    dirt_patch_noise.lacunarity = 1.5
    dirt_patch_noise.persistence = 0.75
    
    gold_noise = OpenSimplexNoise.new()
    
    gold_noise.seed = randi()
    
    gold_noise.octaves = 4
    gold_noise.period = 5
    gold_noise.lacunarity = 1.5
    gold_noise.persistence = 0.75
    
    _generate_world()
    
func _generate_world():
    var goldres = load("res://environment/Gold.tscn")
    var rockres = load("res://environment/Rock.tscn")
    var W2 = floor(WIDTH/2.0)
    var H2 = floor(HEIGHT/2.0)
    for x in WIDTH:
        for y in HEIGHT:
            var pos0 = Vector2(16,16)
            var noise = dirt_patch_noise.get_noise_2d(float(x), float(y))
            if noise > -0.2:
                $GrassMap.set_cellv(Vector2(x-W2, y-H2), _get_tile_index(noise))
                
                var noiserock = randi()%300
                if noiserock == 0:
                    $Navigation2D/RockNavigationMap.set_cellv(Vector2(x-W2, y-H2), 1)
                    var ri = rockres.instance()
                    ri.initialize(pos0 + 32*Vector2(x-W2, y-H2),2)
                    $YSort/RockContainer.add_child(ri)
                elif noiserock < 5:
                    $Navigation2D/RockNavigationMap.set_cellv(Vector2(x-W2, y-H2), 1)
                    var ri = rockres.instance()
                    ri.initialize(pos0 + 32*Vector2(x-W2, y-H2),0)
                    $YSort/RockContainer.add_child(ri)
                    
                else:
                    $Navigation2D/RockNavigationMap.set_cellv(Vector2(x-W2, y-H2), 0)
                
            else:
                $Navigation2D/RockNavigationMap.set_cellv(Vector2(x-W2, y-H2), 0)
                noise = gold_noise.get_noise_2d(float(x), float(y))
                
                if noise >0.25:
                    print("Gold!")
                    var gi = goldres.instance()
                    gi.initialize(pos0 + 32*Vector2(x-W2, y-H2),noise)
                    $GoldContainer.add_child(gi)
                    gi.connect("player_entered", $YSort/Player, "_on_gold_entered")
                    gi.connect("player_exited", $YSort/Player, "_on_gold_exited")
                    gi.connect("player_clicked", $YSort/Player, "_on_gold_clicked")
                    
            
                
            $GroundMap.set_cellv(Vector2(x-W2, y-H2), TILES.Dirt_Dark)
            
    $GrassMap.update_bitmask_region()
    $GroundMap.update_bitmask_region()
    
    
func _get_tile_index(_noise_sample):
    return TILES.Grass_Dry
        


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
