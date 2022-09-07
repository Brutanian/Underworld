extends Control

@export var ReadSpeed : float = 1
var Tick : float
var Reading : bool = false
var Text : String = ""

signal LineRead()
signal Selected(Index : int)

func _process(delta):
	if Reading:
		Tick += delta * ReadSpeed
		if Tick >= 1:
			Tick = 0
			$Panel/Text.visible_characters += 1
			if $Panel/Text.visible_characters == len(Text):
				Reading = false
				LineRead.emit()

func SetSelections(Selections : PackedStringArray):
	for c in $Panel/Text/VBox.get_children():
		c.queue_free()
	
	var Ind : int = 0
	for s in Selections:
		var NewButton := Button.new()
		$Panel/Text/VBox.add_child(NewButton)
		NewButton.text = s
		NewButton.pressed.connect(Select.bind(Ind))
		NewButton.size_flags_vertical = 3
		Ind += 1

func Select(Index : int):
	Selected.emit(Index)

func ResetText():
	$Panel/Text.visible_characters = 0
	Reading = false
	SetSelections([])

func SetText(Str : String):
	Text = Str
	$Panel/Text.text = Text
	Reading = true

func Hide():
	$Panel/Text.visible_characters = 0
	Reading = false
