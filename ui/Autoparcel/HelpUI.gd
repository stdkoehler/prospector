extends Control


func _popup(message):
    match message:
        GlobalManager.TUTORIALPOPUP.DIGGING_BULK:
            self._popup_digging_bulk(message)
        GlobalManager.TUTORIALPOPUP.DIGGING_TOOL:
            self._popup_digging_tool(message)
        

func _popup_digging_bulk(message):
    if GlobalManager.show_dict[message]:
        $DiggingBulk.popup()
        
func _popup_digging_tool(message):
    if GlobalManager.show_dict[message]:
        $DiggingTool.popup()


func _on_DiggingBulk_popup_hide():
    GlobalManager.show_dict[GlobalManager.TUTORIALPOPUP.DIGGING_BULK] = !$DiggingBulk/CheckBox.is_pressed()


func _on_DiggingTool_popup_hide():
    GlobalManager.show_dict[GlobalManager.TUTORIALPOPUP.DIGGING_TOOL] = !$DiggingTool/CheckBox.is_pressed()
