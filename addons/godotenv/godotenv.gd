tool
extends Node

# Constants for .env file location
const FILE_NAME: String = ".env"
const FILE_PATH: String = "res://%s" % FILE_NAME

# Prefix for error and warning messages, make easier to identify the source
const ERROR_PREFIX: String = "GodotEnv: "

# Possible warnings and errors to make it easier to re-use and add if needed
var prompt: Dictionary = {
	"unexisting_file_error": ".env file doesn't exists at %s." % FILE_PATH,
	"creating_dotenv_file": ".env file doesn't exists. Creating one at %s..." % FILE_PATH,
	"already_exists": "A variable called %s already exists, use argument override=true to override it."
}

# Every KEY=VALUE pair from .env will be parsed into this dictionary
var environment: Dictionary = {}

func _ready() -> void:
	environment = get_parsed_env()

# Custom function to prompt error and warning messages
func prompt_message(msg: String, error: bool = false) -> void:
	if error:
		push_error(ERROR_PREFIX + msg)
	else:
		push_warning(ERROR_PREFIX + msg)

func get_parsed_env() -> Dictionary:
	var env_variables: Dictionary
	var dot_env: File = File.new()
	if not dot_env.file_exists(FILE_PATH):
		prompt_message(prompt.unexisting_file_error, true)
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

func create(variable_name: String, value: String, overwrite: bool = false) -> void:
	var dot_env: File = File.new()
	if not dot_env.file_exists(FILE_PATH):
#		Create a .env file to store the new variable if file doesn't already exists
		prompt_message(prompt.creating_dotenv_file)
		dot_env.open(FILE_PATH, File.WRITE)
		dot_env.store_string("%s=%s" % [variable_name, value])
		dot_env.close()
		return
		
	if environment.has(variable_name) and not overwrite:
#		Prevent user from accidentally overwriting an env var
		prompt_message(prompt.already_exists % variable_name)
		return
	elif environment.has(variable_name) and overwrite:
#		Overwrite an already existing env variable
		environment[variable_name] = value
		overwrite_dotenv()
		return
	
	dot_env.open(FILE_PATH, File.READ_WRITE)
	dot_env.seek_end()
#	Append the new env var to the end of an existing .env file
	dot_env.store_string("\n%s=%s" % [variable_name, value])
	dot_env.close()
	environment = get_parsed_env()

func get_var(variable_name: String) -> String:
	if environment.has(variable_name):
		return environment[variable_name]
	
	push_warning("%s not found into %s. Returning ' %s ' zero value." % [variable_name, FILE_PATH, "\"\""])
	return ""
