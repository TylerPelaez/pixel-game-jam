extends TextureRect
class_name UITrapBox

@onready var amount_label = $AmountLabel

func set_count(count: int):
	amount_label.text = str(count)
