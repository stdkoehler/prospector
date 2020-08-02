extends Camera2D



func _process(_delta):
    var radius = 20
    var target = PlayerData.player
    if target:
        var distance = self.position.distance_to(target.position)
        if distance > radius:
            self.position += distance*self.position.direction_to(target.position)/radius
