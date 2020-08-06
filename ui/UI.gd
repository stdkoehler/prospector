extends CanvasLayer


func _input(event):
    
    if PlayerData.state.current == PlayerData.state.STATE.IDLE \
        or PlayerData.state.current == PlayerData.state.STATE.MENU \
        or PlayerData.state.current == PlayerData.state.STATE.INVENTORY:
        
        if Input.is_action_just_pressed('ui_inventory'):
            if $InventoryUI.visible == true:
                self.close_inventory()
            elif $MenuUI.visible == false:
                self.open_inventory()
            else:
                pass
                
    
        if Input.is_action_just_pressed("ui_cancel"):
            if $InventoryUI.visible == true:
                self.close_inventory()
            elif $MenuUI.visible == true:
                self.close_menu()
            else:
                self.open_menu()


func open_inventory():
    $InventoryUI.visible = true
    $BaseUI.hide_ui(null)
    PlayerData.state.current = PlayerData.state.STATE.INVENTORY

func close_inventory():
    $InventoryUI.visible = false
    $BaseUI.show_ui(null)
    PlayerData.state.current = PlayerData.state.STATE.IDLE
    

func open_menu():
    $MenuUI.visible = true
    $BaseUI.lock = true
    PlayerData.state.current = PlayerData.state.STATE.MENU
    
func close_menu():
    $MenuUI.visible = false
    $BaseUI.lock = false
    PlayerData.state.current = PlayerData.state.STATE.IDLE
