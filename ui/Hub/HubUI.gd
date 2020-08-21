extends CanvasLayer


func _input(event):
        if Input.is_action_just_pressed("ui_cancel"):
            if $ShopUI.visible == true:
                self.close_shop()
            elif $ParcelUI.visible == true:
                self.close_parcel()
            elif $MenuUI.visible == true:
                self.close_menu()
            elif $OptionsUI.visible == true:
                self.close_options()
            else:
                self.open_menu()
                
                
func _on_shop_opened():
    $ShopUI.reset_scroll()
    $ShopUI.visible = true
                
func close_shop():
    $ShopUI.visible = false
    
func _on_parcel_opened():
    $ParcelUI.reset_scroll()
    $ParcelUI._update(null)
    $ParcelUI.visible = true
    
func close_parcel():
    $ParcelUI.visible = false
    
func open_menu():
    $MenuUI.visible = true
    
func close_menu():
    $MenuUI.visible = false
    
func _on_options_opened():
    $OptionsUI.visible = true
    
func close_options():
    $OptionsUI.visible = false
