@tool
class_name BTValueExpression
extends BTValue


@export_multiline var expression : String = "":
	set(value):
		if value == expression: return

		expression = value
		_expression.text = expression


var _expression := BTExpression.new()


func _get_value(agent : BTAgent):
	return _expression.execute(agent)
