extends Node2D

# If you're wondering about why it looks slightly different to the video, it's because
# I did some touchups to the code and how it looked between uploading it and pushing the repo
# to Github.

@onready var rich_text := $TextureRect/SubViewport/RichTextLabel

var ascii_path := "res://ascii_frames/"
var begin_playing: bool = false
var frames: Array[String] = []
var current_frame_index: int = 0

func _ready() -> void:
	give_me_everything()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("play") and begin_playing == false:
		begin_playing = true

func _process(delta: float) -> void:
	if begin_playing == false or frames.is_empty():
		return
	
	# Write current frame into the text of our millionaire text label
	rich_text.text = frames[current_frame_index]
	
	# This will loop it.
	current_frame_index = (current_frame_index + 1) % frames.size()

func give_me_everything():
	var dir = DirAccess.open(ascii_path)
	
	var file_paths: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	# Gather all file paths inside the directory
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".txt"):
			file_paths.append(ascii_path.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# Sort files numberically by extracting [NUMBER] from "Output_[NUMBER] yada yada"
	file_paths.sort_custom(sort_by_frame_number)
	
	# Take contents of the file into memory
	for path in file_paths:
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			frames.append(file.get_as_text())
			file.close()

# Extract integer value from filename
func sort_by_frame_number(a: String, b: String):
	var num_a = extract_number(a)
	var num_b = extract_number(b)
	return num_a < num_b

func extract_number(file_path: String):
	var file_name = file_path.get_file() # Gets the full name
	# Obliterate everything that isn't a number
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(file_name)
	if result:
		return result.get_string().to_int()
	return 0
