extends Node

const TYPE = {
    'DIGGABLE': 0,
    'PANNABLE': 1
   }

var HEIGHT = null
var WIDTH = null

var nav2d = null
var nav2dtilemap = null
var rocks = null
var camera = null
var worlditems = null


var random_number_generator = RandomNumberGenerator.new()

func _ready():
    random_number_generator.randomize()
