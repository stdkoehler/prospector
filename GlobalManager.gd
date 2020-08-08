extends Node

var current_scene = null

## Minigame

const ACTION = {
    'DIGGING': 0,
    'PANNING': 1
   }

const ACTIONSTATE = {
    'START': 0,
    'STOP': 1,
    'ACTIVE': 2
   }

const MINIGAME = {
    'TIME': 0,
    'REACTIONGAME': 1,
    'MATHGAME': 2
   }

var minigame_digging = MINIGAME.REACTIONGAME
var minigame_panning = MINIGAME.REACTIONGAME

## end Minigame

## Tutorial

const TUTORIALPOPUP = {
    'DIGGING_BULK': 0,
    'DIGGING_TOOL': 1
   }

var show_dict = {
    self.TUTORIALPOPUP.DIGGING_BULK: true,
    self.TUTORIALPOPUP.DIGGING_TOOL: true
   }

##

func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
    # This function will usually be called from a signal callback,
    # or some other function in the current scene.
    # Deleting the current scene at this point is
    # a bad idea, because it may still be executing code.
    # This will result in a crash or unexpected behavior.

    # The solution is to defer the load to a later time, when
    # we can be sure that no code from the current scene is running:

    call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
    # It is now safe to remove the current scene
    current_scene.free()

    # Load the new scene.
    var s = ResourceLoader.load(path)

    # Instance the new scene.
    current_scene = s.instance()

    # Add it to the active scene, as child of root.
    get_tree().get_root().add_child(current_scene)

    # Optionally, to make it compatible with the SceneTree.change_scene() API.
    get_tree().set_current_scene(current_scene)
    
func _notification(event):
    if event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        self._save_on_quit()
    
func _save_on_quit():
    
    var save_game = File.new()
    save_game.open("user://savegame.save", File.WRITE)
    
    var save_data = {
        'inventory': PlayerData.inventory.store_to_savedict(),
        'show_dict': self.show_dict
       }
    save_game.store_line(to_json(save_data))
    save_game.close()
    print('save on exit')
    
func load_save():
    var save_game = File.new()
    if not save_game.file_exists("user://savegame.save"):
        return null # Error! We don't have a save to load.
    
    save_game.open("user://savegame.save", File.READ)
    var save_data = parse_json(save_game.get_line())
    
    self.show_dict = save_data['show_dict']
    PlayerData.inventory.update_from_savedict(save_data['inventory'])
