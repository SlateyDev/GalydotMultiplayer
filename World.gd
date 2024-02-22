extends Node3D

@onready var player_prefab = preload("res://Player.tscn")
@onready var manual_spawn_prefab = preload("res://ManualSpawn.tscn")

var players = {}
var names : Array[String] = [
	"Galy",
	"Tucker",
	"Fred",
	"Homer",
	"Carl",
	"Boris",
	"Borat",
	"Mephisto",
	"Carly",
	"Melissa",
	"Lily",
	"Brit",
	"Jess",
	"Luffy",
	"Noname",
	"Bish",
	"STFU",
	"NSFW",
	"ROFLCopter",
	"LastName"
]

func pick_unused_player_name() -> String:
	var picknames = names.filter(func(name): return players.values().all(func(n): return n.name != name))
	return picknames.pick_random()

func _ready():
	MP.player_disconnected.connect(on_player_disconnected)
	MP.player_loaded.rpc_id(1)

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	for player_index in MP.players.size():
		# Spawn using MultiplayerSpawner
		var player = (MP.players as Dictionary).keys()[player_index]
		var new_player = player_prefab.instantiate() as Player
		MP.print("start_game(): adding player %d" % [player])
		new_player.name = MP.get_node_name_for_player(player)
		new_player.position = $SpawnPoints.get_node("Spawn" + str(player_index + 1)).global_position
		$Players.add_child(new_player)
		
		# Spawn using manual method. This is useful if you need properties set before
		# the node enters the tree for things like setting the authority of the node
		# without having to set the node name to the peer_id
		players[player] = { "name": pick_unused_player_name() }
		do_manual_spawn.rpc(player, Vector3(randf_range(-5, 5), 0, randf_range(-5, 5)), players[player])

@rpc("call_local", "reliable")
func do_manual_spawn(_peer_id : int, _position : Vector3, player_info : Dictionary):
	var new_manual_spawn = manual_spawn_prefab.instantiate() as ManualSpawn
	new_manual_spawn.name = player_info.name
	new_manual_spawn.position = _position
	new_manual_spawn.player_id = _peer_id
	$ManualSpawns.add_child(new_manual_spawn)

func on_player_disconnected(_peer_id : int):
	MP.print("on_player_disconnected(%d)" % [_peer_id])
	if multiplayer.is_server():
		if $Players.has_node(MP.get_node_name_for_player(_peer_id)):
			$Players.get_node(MP.get_node_name_for_player(_peer_id)).queue_free()
