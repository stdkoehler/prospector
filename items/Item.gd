const ITEMTYPE = {
    'SHOVEL': 0,
    'PAN': 1,
    'CONTAINER': 2
   }

class Item:
    
    var id
    var type
    var name
    var texture_path
    
    func _init(tooljson):
        self.id = tooljson["id"]
        self.type = ITEMTYPE[tooljson["type"].to_upper()]
        self.name = tooljson["name"]
        self.texture_path = tooljson["texture_path"]


class ToolItem extends Item:
    
    var power
    var efficiency
    
    func _init(tooljson).(tooljson):
        
        self.power = tooljson["power"]
        self.efficiency = tooljson["efficiency"]
        ._init(tooljson)
        
class ContainerItem extends Item:
    
    var bulk
    var items
    
    func _init(tooljson).(tooljson):
        
        self.bulk = tooljson["bulk"]
        self.items = tooljson["items"]
    
