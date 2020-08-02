extends Node

var Item = load("res://items/Item.gd")

class State:
    const STATE = {
    'INVENTORY': 0,
    'DIGGING': 1,
    'PANNING': 2,
    'IDLE': 3
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
        if state == STATE.IDLE:
            digging_tile = null
        if state == STATE.INVENTORY:
            digging_tile = null
           
    func get_pannable_storage():
        var available = []
        for i in len(self.worlditems):
            var wi = self.worlditems[i]
            if wi.type==EnvironmentData.TYPE.PANNABLE and wi.amount_dirt>0:
                available.append(wi)
        return available


class Inventory:
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
    

var player = null
var state = State.new()
var inventory = Inventory.new()



signal goldore_changed(value)
signal goldbar_changed(value)
signal action_progress_changed(value)
signal interactable_text_changed(text)

signal inventory_opened(value)
signal inventory_closed(value)

signal stamina_changed(value)



func _ready():
    var file = File.new()
    file.open("res://tools.json", file.READ)
    var text = file.get_as_text()
    var tools = JSON.parse(text).result
    file.close()
    
    self.inventory.put_item(0, Item.ToolItem.new(tools['wood_shovel']))
    self.inventory.put_item(1, Item.ToolItem.new(tools['iron_studded_wood_shovel']))
    self.inventory.put_item(2, Item.ToolItem.new(tools['iron_shovel']))
    self.inventory.put_item(3, Item.ToolItem.new(tools['steel_shovel']))
    self.inventory.put_item(4, Item.ToolItem.new(tools['full_steel_shovel']))
    
    self.inventory.put_item(5, Item.ToolItem.new(tools['wood_pan']))
    self.inventory.put_item(6, Item.ToolItem.new(tools['iron_sheet_pan']))
    self.inventory.put_item(7, Item.ToolItem.new(tools['iron_pan']))
    self.inventory.put_item(8, Item.ToolItem.new(tools['blackcast_steel_pan']))
    self.inventory.put_item(9, Item.ToolItem.new(tools['blackcast_steel_riffled_pan']))
    
    self.inventory.put_item(10, Item.ContainerItem.new(tools['small_bucket']))
    self.inventory.put_item(11, Item.ContainerItem.new(tools['chest']))
    


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
    
func open_inventory(value):
    self.state.set_state(self.State.STATE.INVENTORY)
    emit_signal('inventory_opened', value)
    
func close_inventory(value):
    self.state.set_state(self.State.STATE.IDLE)
    emit_signal('inventory_closed', value)
    
func dec_stamina(_value):
    if self.state.stamina > 0:
        self.state.stamina -= 1
    emit_signal('stamina_changed', self.state.stamina)
    
    

