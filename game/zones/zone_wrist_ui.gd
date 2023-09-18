extends PanelContainer


func _on_save_button_pressed():
	GameState.auto_save_game()


func _on_quit_button_pressed():
	GameState.quit_game()
