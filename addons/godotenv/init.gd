tool
extends EditorPlugin

const AUTOLOAD_NAME: String = "GodotEnv"
const AUTOLOAD_PATH: String = "res://addons/godotenv/godotenv.gd"

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)

