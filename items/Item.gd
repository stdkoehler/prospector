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
    
    
class BulkStorage:
    
    var bulk_limit
    var amount
    var gold
    
    func _init(bulk_limit_):
        self. bulk_limit = bulk_limit_
        self.amount = 0
        self.gold = 0
        
    func get_percent_filled():
        return round(100*self.amount/self.bulk_limit)
        
    func add(amount_, gold_):
        var amount_new = self.amount + amount_
        if amount_new > bulk_limit:
            self.amount = bulk_limit
            var diff = amount_new-bulk_limit
            self.gold += gold_*(amount+diff)/amount #only add part which fits into
        else:
            self.amount = amount_new
            self.gold += gold_
            
