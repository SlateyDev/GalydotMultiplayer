extends Node3D
class_name ManualSpawn

var player_id

func _set(property, value):
	MP.print("ManualSpawn._set(%s, %s)" % [property, value])

func _enter_tree():
	MP.print("ManualSpawn._enter_tree(): player_id = %d" % [player_id])
