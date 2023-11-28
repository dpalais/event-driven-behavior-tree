@tool
class_name BTValueBlackboard
extends BTValue

@export var key : String = ""

func _get_bt_type_name() -> String:
	return "Blackboard Value"

func _get_value(agent : BTAgent) -> Variant:
	return agent.blackboard.get_value(key)
