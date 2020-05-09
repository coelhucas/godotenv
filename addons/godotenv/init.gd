tool
extends EditorPlugin

const AUTOLOAD_NAME: String = "GodotEnv"
const AUTOLOAD_PATH: String = "res://addons/godotenv/godotenv.gd"
const FILE_NAME: String = ".env"
const FILE_PATH: String = "res://%s" % FILE_NAME
const UNEXISTING_FILE_ERROR: String = ".env files doesn't exists at %s." % FILE_PATH

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)

