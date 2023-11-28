@tool
class_name BTValue
extends BTItem

@export var cache_value : bool = false

func get_value(agent : BTAgent):
	if cache_value:
		if agent.has_cached_value(self):
			return agent.get_cached_value(self)
		var value = _get_value(agent)
		agent.set_cached_value(self, value)
		return value
	return _get_value(agent)

func _get_value(agent : BTAgent):
	return


