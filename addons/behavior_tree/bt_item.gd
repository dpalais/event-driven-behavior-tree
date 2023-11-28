@tool
class_name BTItem
extends Resource



enum BTState {
	FAILURE,
	SUCCESS,
	RUNNING,
}

enum BTMonitorType {
	NONE,
	BOTH,
	SELF,
	LOWER_PRIORITY,
}

enum BTUtilityCompoundMode{
	MULTIPLY,
	AVERAGE,
	MIN,
	MAX,
}


@export var name : String = "":
	set(value):
		name = value
		emit_changed()

var graph_position : Vector2:
	set = _set_graph_position


func _init() -> void:
	name = get_bt_type_name()



func get_bt_type_name() -> String:
	return _get_bt_type_name()



func _get_bt_type_name() -> String:
	return ""


func _set_graph_position(value : Vector2) -> void:
	graph_position = value

	if self is BTNode:
		if self.parent != null:
			self.parent.reorder_children()
		else:
			self.sibling_index = -1

	emit_changed()

