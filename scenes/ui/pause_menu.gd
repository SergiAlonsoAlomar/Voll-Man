extends Control

@onready var resume_button = $Panel/CenterContainer/VBoxContainer/ResumeButton
@onready var menu_button = $Panel/CenterContainer/VBoxContainer/MenuButton

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

	resume_button.pressed.connect(_on_resume_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_resume_pressed():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_menu_pressed():
	get_tree().paused = false  # Despausa antes de cambiar
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
