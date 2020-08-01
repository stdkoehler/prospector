extends Node2D


func initialize(pos, type):
    self.position = pos
    $Sprite.frame = type
