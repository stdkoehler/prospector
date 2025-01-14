extends Node

signal goldore_changed(value)
signal goldbar_changed(value)
signal action_progress_changed(value)
signal interactable_text_changed(text)

signal stamina_changed(value)




var Item = load("res://items/Item.gd")

class State:
    signal ui_activated(value)
    signal ui_deactivated(value)
    
    const STATE = {
    'MENU': 0,
    'INVENTORY': 1,
    'DIGGING': 2,
    'PANNING': 3,
    'IDLE': 4
   }

    var current : int = STATE.IDLE setget set_state
    var digging_tile = null
    var panning_item = null
    var interactables = []
    var worlditems = []
    
    # Stamina will is a mechanic which somehow should lead to "optimization"
    # 1. day parcel costs N0 > Ni
    # 2. day parcel costs Ni
    # player can only do so much per day (stamina)
    # player must decide beforehand how long he wants to rent the parcel
    # -> player will increase yield by using better tools
    # -> there will be luck involved (rng per action but also when procedurally generating the gold deposits)
    # -> STILL OPEN: What strategic options are there?
    var stamina = 100
    
    # we use a setter here because digging_tile will automatically
    # be deleted on idle and menufreeze
    func set_state(state):
        current = state
        match state:
            STATE.IDLE:
                digging_tile = null
                emit_signal("ui_activated", null)
            STATE.INVENTORY:
                digging_tile = null
                emit_signal("ui_activated", null)
            STATE.MENU:
                digging_tile = null
                emit_signal("ui_activated", null)
            STATE.DIGGING:
                emit_signal("ui_deactivated", null)
            STATE.PANNING:
                emit_signal("ui_deactivated", null)
            
           
    func get_pannable_storage():
        var available = []
        for i in len(self.worlditems):
            var wi = self.worlditems[i]
            if wi.type==EnvironmentData.TYPE.PANNABLE and wi.amount_dirt>0:
                available.append(wi)
        return available
        


class Inventory:
    var Item = load("res://items/Item.gd")
    
    var inventory_backpack = {}
    var active_toolbelt_slot = 0
    const BACKPACKSIZE = 4*6
    
    var goldore = 0
    var goldbar = 0
    
    func exists(idx):
        return idx in self.inventory_backpack
    
    func set_active(idx):
        self.active_toolbelt_slot = idx
        
    func put_item(idx, item):
        self.inventory_backpack[idx] = item
    
    func move_item(from_idx, to_idx):
        if from_idx in inventory_backpack:
            var temp = inventory_backpack[from_idx]
            if to_idx in inventory_backpack:
                inventory_backpack[from_idx] = inventory_backpack[to_idx]
            else:
                inventory_backpack.erase(from_idx)
            inventory_backpack[to_idx] = temp
        
    func get_item(idx):
        return self.inventory_backpack[idx]
        
    func get_active_item():
        if self.active_toolbelt_slot in self.inventory_backpack:
            return self.inventory_backpack[self.active_toolbelt_slot]
        else:
            return null
            
    func get_free_slot():
        for i in range(BACKPACKSIZE):
            if !(i in self.inventory_backpack):
                return i
                
        # no free slot
        return -1
            
    func store_to_savedict():
        var inventory_backpack_save = {}
        for idx in self.inventory_backpack.keys():
            inventory_backpack_save[idx] = self.inventory_backpack[idx].id
            
        
        var inventory_dict = {
        'inventory_backpack': inventory_backpack_save,
        'active_toolbelt_slot': self.active_toolbelt_slot,
        'goldore': self.goldore,
        'goldbar': self.goldbar
        }
        return inventory_dict
        
    func update_from_savedict(inventory_dict):
        self.active_toolbelt_slot = inventory_dict['active_toolbelt_slot']
        self.goldore = inventory_dict['goldore']
        self.goldbar = inventory_dict['goldbar']
        
        var file = File.new()
        file.open("res://tools.json", file.READ)
        var text = file.get_as_text()
        var tools = JSON.parse(text).result
        file.close()
        
        self.inventory_backpack = {}
        var itemjson = null
        for idx in inventory_dict['inventory_backpack']:
            itemjson = tools[inventory_dict['inventory_backpack'][idx]]
            idx = int(idx) # json stores keys as string
            if itemjson['type'] == 'container':
                self.inventory_backpack[idx] = Item.ContainerItem.new(itemjson)
            else:
                self.inventory_backpack[idx] = Item.ToolItem.new(itemjson)
                
        
    

var player = null
var state = State.new()
var inventory = Inventory.new()





func _ready():
    var _c
    state.connect('ui_activated', self, "_ui_activated")
    state.connect('ui_deactivated', self, "_ui_deactivated")
    self.reset()
    


func reset():
    var file = File.new()
    file.open("res://tools.json", file.READ)
    var text = file.get_as_text()
    var tools = JSON.parse(text).result
    file.close()
    
    self.inventory.put_item(0, Item.ToolItem.new(tools['wood_shovel']))
    self.inventory.put_item(1, Item.ToolItem.new(tools['wood_pan']))
    self.inventory.put_item(2, Item.ContainerItem.new(tools['small_bucket']))
    
    self.inventory.goldbar = 0.1

func set_goldore(value):
    self.inventory.goldore = value
    emit_signal('goldore_changed', self.inventory.goldore)
    
func inc_goldore(value):
    self.inventory.goldore += value
    emit_signal('goldore_changed', self.inventory.goldore)
    
func dec_goldore(value):
    self.inventory.goldore -= value
    emit_signal('goldore_changed', self.inventory.goldore)
    
func set_goldbar(value):
    self.inventory.goldbar = value
    emit_signal('goldbar_changed', self.inventory.goldbar)
    
func inc_goldbar(value):
    self.inventory.goldbar += value
    emit_signal('goldbar_changed', self.inventory.goldbar)
    
func dec_goldbar(value):
    self.inventory.goldbar -= value
    emit_signal('goldbar_changed', self.inventory.goldbar)
    
func set_action_progress(value):
    emit_signal('action_progress_changed', value)
    
func set_interactable_text(text):
    emit_signal('interactable_text_changed', text)
    
func dec_stamina(stamina):
    if self.state.stamina > 0:
        self.state.stamina -= stamina
    emit_signal('stamina_changed', self.state.stamina)
    
    
func _ui_activated(value):
    self.player.set_process_input(true)
    
func _ui_deactivated(value):
    self.player.set_process_input(false)
    

func add_item(id):
    var file = File.new()
    file.open("res://tools.json", file.READ)
    var text = file.get_as_text()
    var tools = JSON.parse(text).result
    file.close()
    
    var idx = PlayerData.inventory.get_free_slot()
    
    if idx >= 0:
        if tools[id]['type'] != 'container': 
            self.inventory.put_item(idx, Item.ToolItem.new(tools[id]))
        else:
            self.inventory.put_item(idx, Item.ContainerItem.new(tools[id]))
    
    return idx
