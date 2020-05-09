tool
extends Node

const AUTOLOAD_NAME: String = "GodotEnv"
const AUTOLOAD_PATH: String = "res://addons/godotenv/godotenv_funcs.gd"
const FILE_NAME: String = ".env"
const FILE_PATH: String = "res://%s" % FILE_NAME
const UNEXISTING_FILE_ERROR: String = ".env files doesn't exists at %s." % FILE_PATH
const CREATING_DOTENV_WARNING: String = ".env files doesn't exists. Creating one inside %s..." % FILE_PATH
const ALREADY_EXISTS_WARNING: String = "A variable called %s already exists, use argument override=true to override it."

var environment: Dictionary = {}

func _ready() -> void:
	environment = get_parsed_env()

func get_parsed_env() -> Dictionary:
	var env_variables: Dictionary
	var dot_env: File = File.new()
	if not dot_env.file_exists(FILE_PATH):
		push_error(UNEXISTING_FILE_ERROR)
		return env_variables
	
	dot_env.open(FILE_PATH, File.READ)
	while !dot_env.eof_reached():
		var line: String = dot_env.get_line()
		var env_var: Array = line.split("=")
		env_variables[env_var[0]] = env_var[1]
		
	dot_env.close()
	return env_variables

func overwrite_dotenv() -> void:
	var dot_env: File = File.new()
	var new_content: String
	for key in environment.keys():
		new_content += "%s=%s" % [key, environment[key]]
		var last_key: String = environment.keys()[len(environment) - 1]
		if key != last_key:
			new_content += "\n"
	dot_env.open(FILE_PATH, File.WRITE)
	dot_env.store_string(new_content)

func create(variable_name: String, value: String, override: bool = false) -> void:
	var dot_env: File = File.new()
	if not dot_env.file_exists(FILE_PATH):
		push_warning(CREATING_DOTENV_WARNING)
		dot_env.open(FILE_PATH, File.WRITE)
		dot_env.store_string("%s=%s" % [variable_name, value])
		dot_env.close()
		
	
	if environment.has(variable_name) and not override:
		push_warning(ALREADY_EXISTS_WARNING % variable_name)
		return
	elif environment.has(variable_name) and override:
		environment[variable_name] = value
		overwrite_dotenv()
		return
	
	dot_env.open(FILE_PATH, File.READ_WRITE)
	dot_env.seek_end()
	dot_env.store_string("\n%s=%s" % [variable_name, value])
	dot_env.close()
	environment = get_parsed_env()

func get_var(variable_name: String) -> String:
	if environment.has(variable_name):
		return environment[variable_name]
	
	push_warning("%s not found into %s. Returning ' %s ' zero value." % [variable_name, FILE_PATH, "\"\""])
	return ""
