extends Node3D

@onready var player_prefab = preload("res://Player.tscn")

func _ready():
	Lobby.player_disconnected.connect(on_player_disconnected)
	Lobby.player_loaded.rpc_id(1)

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	for player_index in Lobby.players.size():
		var player = (Lobby.players as Dictionary).keys()[player_index]
		var new_player = player_prefab.instantiate() as Player
		Lobby.mp_print("start_game(): adding player %d" % [player])
		new_player.name = Lobby.get_node_name_for_player(player)
		new_player.position = get_node("Spawn" + str(player_index + 1)).global_position
		$Players.add_child(new_player)

func on_player_disconnected(_peer_id : int):
	Lobby.mp_print("on_player_disconnected(%d)" % [_peer_id])
	if multiplayer.is_server():
		if $Players.has_node(Lobby.get_node_name_for_player(_peer_id)):
			$Players.get_node(Lobby.get_node_name_for_player(_peer_id)).queue_free()
