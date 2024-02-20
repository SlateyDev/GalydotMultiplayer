extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

var players = {}
var player_info = {"name": "Name"}
var players_loaded = 0

@onready var role = "Unknown"

func mp_print(_value):
	print(role, "(for: ", multiplayer.get_unique_id(), ", from:", multiplayer.get_remote_sender_id(), ") - ", _value)

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(_address = ""):
	role = "Client"
	if _address.is_empty():
		_address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(_address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func create_game():
	role = "Host"
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(_game_scene_path : NodePath):
	get_tree().change_scene_to_file(_game_scene_path)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	Lobby.mp_print("player_loaded()")
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/World.start_game()
			players_loaded = 0

func _on_player_connected(_id):
	Lobby.mp_print("_on_player_connected(%d)" % [_id])
	_register_player.rpc_id(_id, player_info)

@rpc("any_peer", "reliable")
func _register_player(_new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = _new_player_info
	player_connected.emit(new_player_id, _new_player_info)

func _on_player_disconnected(_id):
	Lobby.mp_print("_on_player_disconnected(%d)" % [_id])
	players.erase(_id)
	player_disconnected.emit(_id)

func _on_connected_ok():
	Lobby.mp_print("_on_connected_ok()")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	Lobby.mp_print("_on_connected_fail()")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	Lobby.mp_print("_on_server_disconnected()")
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()