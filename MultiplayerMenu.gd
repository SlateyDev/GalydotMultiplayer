extends Control

func _ready():
	MP.player_connected.connect(on_player_connected)
	MP.player_disconnected.connect(on_player_disconnected)
	MP.server_disconnected.connect(on_server_disconnected)

func _on_host_pressed():
	MP.create_game()
	$VBoxContainer/Host.disabled = true
	$VBoxContainer/Join.disabled = true
	$VBoxContainer/Start.disabled = false

func _on_join_pressed():
	MP.join_game($VBoxContainer/Address.text)
	$VBoxContainer/Host.disabled = true
	$VBoxContainer/Join.disabled = true
	$VBoxContainer/Start.disabled = true

func _on_start_pressed():
	MP.rpc("load_game", "res://World.tscn")

func on_player_connected(_peer_id: int, _player_info : Dictionary):
	MP.print("on_player_connected(%d, %s)" % [_peer_id, _player_info])
	$VBoxContainer/PlayersConnected.text = str(MP.players.size()) + " Players"

func on_player_disconnected(_peer_id):
	MP.print("on_player_disconnected(%d)" % [_peer_id])
	$VBoxContainer/PlayersConnected.text = str(MP.players.size()) + " Players"

func on_server_disconnected():
	MP.print("on_server_disconnected()")
	$VBoxContainer/Host.disabled = false
	$VBoxContainer/Join.disabled = false
	$VBoxContainer/Start.disabled = true
	$VBoxContainer/PlayersConnected.text = str(MP.players.size()) + " Players"
