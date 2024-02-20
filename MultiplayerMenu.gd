extends Control

func _ready():
	Lobby.player_connected.connect(on_player_connected)
	Lobby.player_disconnected.connect(on_player_disconnected)
	Lobby.server_disconnected.connect(on_server_disconnected)

func _on_host_pressed():
	Lobby.create_game()
	$VBoxContainer/Host.disabled = true
	$VBoxContainer/Join.disabled = true
	$VBoxContainer/Start.disabled = false

func _on_join_pressed():
	Lobby.join_game($VBoxContainer/Address.text)
	$VBoxContainer/Host.disabled = true
	$VBoxContainer/Join.disabled = true
	$VBoxContainer/Start.disabled = true

func _on_start_pressed():
	Lobby.rpc("load_game", "res://World.tscn")

func on_player_connected(_peer_id: int, _player_info : Dictionary):
	Lobby.mp_print("on_player_connected(%d, %s)" % [_peer_id, _player_info])
	$VBoxContainer/PlayersConnected.text = str(Lobby.players.size()) + " Players"

func on_player_disconnected(_peer_id):
	Lobby.mp_print("on_player_disconnected(%d)" % [_peer_id])
	$VBoxContainer/PlayersConnected.text = str(Lobby.players.size()) + " Players"

func on_server_disconnected():
	Lobby.mp_print("on_server_disconnected()")
	$VBoxContainer/Host.disabled = false
	$VBoxContainer/Join.disabled = false
	$VBoxContainer/Start.disabled = true
	$VBoxContainer/PlayersConnected.text = str(Lobby.players.size()) + " Players"
