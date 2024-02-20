extends Control

func _on_host_pressed():
	Lobby.create_game()
	$VBoxContainer/Host.disabled = true
	$VBoxContainer/Join.disabled = true
	$VBoxContainer/Start.disabled = false

func _on_join_pressed():
	Lobby.join_game()
	$VBoxContainer/Host.disabled = true
	$VBoxContainer/Join.disabled = true
	$VBoxContainer/Start.disabled = true

func _on_start_pressed():
	Lobby.rpc("load_game", "res://World.tscn")
