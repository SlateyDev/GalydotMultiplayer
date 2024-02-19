extends Node3D

@onready var player_prefab = preload("res://Player.tscn")

func _ready():
	Lobby.player_loaded.rpc_id(1)

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	for player_index in Lobby.players.size():
		var player = (Lobby.players as Dictionary).keys()[player_index]
		var new_player = player_prefab.instantiate() as Player
		Lobby.mp_print("start_game(): adding player %d" % [player])
		new_player.name = str(player)
		new_player.position = get_node("Spawn" + str(player_index + 1)).global_position
		$Players.add_child(new_player)
