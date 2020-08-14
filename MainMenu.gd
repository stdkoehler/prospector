extends Control

var time_played_slot1 = null
var time_played_slot2 = null
var time_played_slot3 = null

var save_to_delete = null
var button_to_disable = null


func _ready():
    var slotinfo = null
    slotinfo = GlobalManager.save_exists("slot1.save")
    if  slotinfo == null:
        $Panel/Grid/Delete1.disabled = true
        $Panel/Grid/Slot1.text = "Slot 1"
    else:
        $Panel/Grid/Delete1.disabled = false
        $Panel/Grid/Slot1.text = "Slot 1 " + self._timeformat(slotinfo)
        self.time_played_slot1 = slotinfo
        
    slotinfo = GlobalManager.save_exists("slot2.save")
    if  slotinfo == null:
        $Panel/Grid/Delete2.disabled = true
        $Panel/Grid/Slot2.text = "Slot 2"
    else:
        $Panel/Grid/Delete2.disabled = false
        $Panel/Grid/Slot2.text = "Slot 2 " + self._timeformat(slotinfo)
        self.time_played_slot2 = slotinfo
        
    slotinfo = GlobalManager.save_exists("slot3.save")
    if  slotinfo == null:
        $Panel/Grid/Delete3.disabled = true
        $Panel/Grid/Slot3.text = "Slot 3"
    else:
        $Panel/Grid/Delete3.disabled = false
        $Panel/Grid/Slot3.text = "Slot 3 " + self._timeformat(slotinfo)
        self.time_played_slot2 = slotinfo
        

        

func _timeformat(time):
    var hours = floor(time/3600)
    var hourminutes = (time-hours*3600)
    var minutes =floor(hourminutes/60)
    return "%02d : %02d" % [hours, minutes]

func _on_Slot1_pressed():
    GlobalManager.current_save = "slot1.save"
    if time_played_slot1 == null:
        GlobalManager.time_played = 0
    else:
        GlobalManager.time_played = time_played_slot1
    
    GlobalManager.time_start = OS.get_unix_time()
    GlobalManager.reset()
    PlayerData.reset()
    GlobalManager.load_save("slot1.save")
    GlobalManager.goto_scene("res://Hub.tscn")


func _on_Slot2_pressed():
    GlobalManager.current_save = "slot2.save"
    if time_played_slot2 == null:
        GlobalManager.time_played = 0
    else:
        GlobalManager.time_played = time_played_slot2
    
    GlobalManager.time_start = OS.get_unix_time()
    GlobalManager.reset()
    PlayerData.reset()
    GlobalManager.load_save("slot2.save")
    GlobalManager.goto_scene("res://Menu.tscn")


func _on_Slot3_pressed():
    GlobalManager.current_save = "slot3.save"
    if time_played_slot3 == null:
        GlobalManager.time_played = 0
    else:
        GlobalManager.time_played = time_played_slot3
    
    GlobalManager.time_start = OS.get_unix_time()
    GlobalManager.reset()
    PlayerData.reset()
    GlobalManager.load_save("slot3.save")
    GlobalManager.goto_scene("res://Menu.tscn")


func _on_Delete1_pressed():
    self.save_to_delete = "slot1.save"
    self.button_to_disable = $Panel/Grid/Delete1
    $Panel/ConfirmationDialog.popup()
    


func _on_Delete2_pressed():
    self.save_to_delete = "slot2.save"
    self.button_to_disable = $Panel/Grid/Delete2
    $Panel/ConfirmationDialog.popup()


func _on_Delete3_pressed():
    self.save_to_delete = "slot3.save"
    self.button_to_disable = $Panel/Grid/Delete3
    $Panel/ConfirmationDialog.popup()


func _on_ConfirmationDialog_confirmed():
    GlobalManager.delete_save(self.save_to_delete)
    self.button_to_disable.disabled = true
    self._ready()
