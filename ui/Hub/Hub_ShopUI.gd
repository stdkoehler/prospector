extends Control
var empty_slot_texture = ResourceLoader.load("res://assets/tools/icon_none.png")


onready var handle_inventory = $Panel/TextureRect/ItemListBackpack
onready var handle_shop = $Panel/ItemList

func _ready():
    # Shop
    
    var file = File.new()
    file.open("res://tools.json", file.READ)
    var text = file.get_as_text()
    var tools = JSON.parse(text).result
    file.close()
    
    handle_shop.set_max_columns(1)
    handle_shop.set_fixed_icon_size(Vector2(32,32))
    handle_shop.set_icon_mode($Panel/TextureRect/ItemListBackpack.ICON_MODE_LEFT)
    handle_shop.set_select_mode($Panel/TextureRect/ItemListBackpack.SELECT_SINGLE)
    handle_shop.set_same_column_width(true)
    handle_shop.clear()
    var idx = 0
    for ti in tools:
        ti = tools[ti]
        if ti['type'] != 'container':
            handle_shop.add_item("", null, false)
            var icon = ResourceLoader.load(ti['texture_path'])
            handle_shop.set_item_icon(idx, icon)
            handle_shop.set_item_selectable(idx, true)
            handle_shop.set_item_metadata(idx, ti)
            handle_shop.set_item_text(idx, ti['name'] + ' (' + str(ti['cost']) + ')')
            #handle_shop.set_item_tooltip(0, ti['id'])
            handle_shop.set_item_tooltip_enabled(idx, true)
            idx+=1
            
    self._update(null)
    
    #self.inventory.put_item(0, Item.ToolItem.new(tools['wood_shovel']))

    
    # Inventory
    $Panel/TextureRect/ItemListBackpack.set_max_columns(6)
    $Panel/TextureRect/ItemListBackpack.set_fixed_icon_size(Vector2(32,32))
    $Panel/TextureRect/ItemListBackpack.set_icon_mode($Panel/TextureRect/ItemListBackpack.ICON_MODE_TOP)
    $Panel/TextureRect/ItemListBackpack.set_select_mode($Panel/TextureRect/ItemListBackpack.SELECT_SINGLE)
    $Panel/TextureRect/ItemListBackpack.set_same_column_width(true)
    
    $Panel/TextureRect/ItemListBackpack.clear()
        
    for i in range(PlayerData.inventory.BACKPACKSIZE):
        $Panel/TextureRect/ItemListBackpack.add_item("", null, false)
        update_slot(i)

func update_slot(idx):
    if (idx < 0):
        return
        
    if PlayerData.inventory.exists(idx):
        
        var item = PlayerData.inventory.get_item(idx)
        var icon = ResourceLoader.load(item.texture_path)
    
        $Panel/TextureRect/ItemListBackpack.set_item_icon(idx, icon)
        $Panel/TextureRect/ItemListBackpack.set_item_selectable(idx, true)
        $Panel/TextureRect/ItemListBackpack.set_item_metadata(idx, item)
        $Panel/TextureRect/ItemListBackpack.set_item_tooltip(idx, item.name)
        $Panel/TextureRect/ItemListBackpack.set_item_tooltip_enabled(idx, true)
    else:
        $Panel/TextureRect/ItemListBackpack.set_item_icon(idx, empty_slot_texture)
        $Panel/TextureRect/ItemListBackpack.set_item_selectable(idx, false)
        $Panel/TextureRect/ItemListBackpack.set_item_metadata(idx, null)
        $Panel/TextureRect/ItemListBackpack.set_item_tooltip(idx, "")
        $Panel/TextureRect/ItemListBackpack.set_item_tooltip_enabled(idx, false)


func _set_price(price):
    $Panel/GridContainer/Cost.text = str(stepify(price,0.1)) + ' / ' + str(stepify(PlayerData.inventory.goldbar,0.1))
    if price > PlayerData.inventory.goldbar:
        $Panel/BuyButton.disabled = true
    else:
        $Panel/BuyButton.disabled = false


func _on_ItemList_item_selected(index):
    self._update(null)


func _on_BuyButton_pressed():
    var sel = handle_shop.get_selected_items()[0]
    var meta = self.handle_shop.get_item_metadata(sel)
    
    var idx = PlayerData.add_item(meta['id'])
    if idx > 0: 
        PlayerData.dec_goldbar(meta['cost'])
        self._update(idx)
    else:
        $Panel/BuyButton.disabled = true
        
func _update(idx):
    if idx != null:
        self.update_slot(idx)
        
    var cost = null
    var sel = handle_shop.get_selected_items()
    if len(sel) > 0:
        cost = self.handle_shop.get_item_metadata(sel[0])['cost']
        self._set_price(cost)
    else:
        self._set_price(0)
        
    idx = PlayerData.inventory.get_free_slot()
    # check if there is a free slot and we can afford (owned gold-0.1 to make sure
    # we can still rent a parcel after buying)
    if idx > 0 && cost != null && cost <= (PlayerData.inventory.goldbar-0.1):
        $Panel/BuyButton.disabled = false
    else:
        $Panel/BuyButton.disabled = true
        
func reset_scroll():
    $Panel/ItemList.get_v_scroll().value = 0
        

