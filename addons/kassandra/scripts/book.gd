@tool
class_name KassandraBook extends Node


static func copy_and_save(copy_path: String, save_path: String):
	var read_file = FileAccess.open(copy_path, FileAccess.READ)
	if not read_file:
		return # falha
	
	var base_path: String = save_path.get_base_dir().erase(0, 6)
	var split = base_path.split("/")
	var final_path: String = "res://"
	
	for i in split.size():
		final_path += split[i]
		if not DirAccess.dir_exists_absolute(final_path):
			DirAccess.make_dir_absolute(final_path)
		final_path += "/"
	
	var white_file = FileAccess.open(final_path + save_path.get_file(), FileAccess.WRITE)
	if white_file:
		var content: String = read_file.get_as_text()
		white_file.store_string(content)
		return true # sucesso
	# falha


static func recover_procedural_resource(arquive: String, local_path: String): # content: .tscn, .scn, .res
	var split := arquive.split("\n")
	var index := 2
	while split[index].begins_with("[ext_resource"):
		var split2 := split[index].split(" ")
		for path in split2:
			if not path.begins_with("path="):
				continue
			
			path = path.replace("path=\"", "").replace("\"", "")
			print(index, " ", local_path + path.erase(0, 6), " -=- ", path)
			copy_and_save(local_path + path.erase(0, 6), path)
			
			var read_file = FileAccess.open(path, FileAccess.READ)
			if read_file:
				var new_arquive: String = read_file.get_as_text()
				
				if new_arquive.begins_with("[gd_scene") or new_arquive.begins_with("[gd_resource"):
					recover_procedural_resource(new_arquive, local_path)
		index += 1


static func uuid() -> String: return "%02x%02x-%02x%02x-%02x%02x-%02x%02x" % [
		randi() & 0b11111111, randi() & 0b11111111, randi() & 0b11111111,
		randi() & 0b11111111, randi() & 0b11111111, randi() & 0b11111111,
		((randi() & 0b11111111) & 0x0f) | 0x40, 	randi() & 0b11111111
	]
