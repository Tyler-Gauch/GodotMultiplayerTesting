class_name PlayerInfo

var name: String
var id: int

static func from_dict(dict) -> PlayerInfo:
	var p = PlayerInfo.new()
	p.name = dict["name"]
	p.id = dict["id"]
	return p
	
func to_dict():
	return {
		"name": name,
		"id": id
	}
