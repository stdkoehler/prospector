extends CanvasLayer


func _input(event):
        if Input.is_action_just_pressed("ui_cancel"):
            if $ShopUI.visible == true:
                self.close_shop()
                
                
func _on_shop_opened():
    $ShopUI.reset_scroll()
    $ShopUI.visible = true
                
func close_shop():
    $ShopUI.visible = false
    
func _on_parcel_opened():
    pass
