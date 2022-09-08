extends StaticBody3D

const MAX_LINES : int = 5

@export_group("NPC Interaction")
@export var Prompt : String
@export_multiline var Chatter : String = "Hello"

@export_subgroup("Animation")
@export_node_path(AnimationTree) var AnimatorPath : NodePath
@export var IdleName : String = "Idle"
@export var TalkingName : String = "Talking"

var AnimPlayer : AnimationNodeStateMachinePlayback

var CurrentLine : int = 0
var Lines : Array
var DisplayedLines : int = 0

var Text : String
var Selections : PackedStringArray
var SelectLinks : PackedStringArray

var WaitingForInput : bool = false
var Talking : bool = true

signal NPCSignal(SignalName : String)

func _ready():
	AnimPlayer = get_node(AnimatorPath).get("parameters/playback")
	for i in Chatter.split("\n"):
		if i != "":
			Lines.append_array(i.split(" | "))
	for i in Lines:
		print(i)

func _process(delta):
	if Talking:
		if Input.is_action_just_pressed("ui_accept") && len(Selections) == 0 && WaitingForInput:
			Text = ""
			WaitingForInput = false
			$ReadText.ResetText()
			ResetSelection()
			ReadLine()
			$ReadText.SetText(Text)
	var Angle := Vector3(0,0,1).signed_angle_to(global_position.direction_to(Global.Player.position), Vector3.UP)
	rotation.y = lerp_angle(rotation.y, Angle, 0.1)

func Select(Index : int = -1):
	Text = ""
	WaitingForInput = false
	$ReadText.ResetText()
	ParseCom(SelectLinks[Index], ":")
	ResetSelection()
	ReadLine()
	$ReadText.SetText(Text)

func GetPrompt():
	return Prompt

func Interact():
	ReadAt("Begin")
	ResetSelection()
	$ReadText.ResetText()
	ReadLine()
	Global.Player.SetPaused(true)
	Global.Player.SetMouseLock(false)
	$ReadText.visible = true
	Talking = true

func Exit():
	Global.Player.SetPaused(false)
	Global.Player.SetMouseLock(true)
	$ReadText.visible = false
	Talking = false

func LineRead():
	AnimPlayer.travel(IdleName)
	DisplayedLines += 1
	if DisplayedLines == MAX_LINES:
		WaitingForInput = true
	elif !WaitingForInput:
		ReadLine()

func ReadLine():
	CurrentLine += 1
	if len(Lines) > CurrentLine:
		var Line : String = Lines[CurrentLine]
		if Line.begins_with("@"):
			ParseCom(Line.substr(1), ",")
		elif Line.begins_with("#"):
			ReadLine()
		else:
			AnimPlayer.travel(TalkingName)
			Text += Line
			DisplayedLines += 1
			$ReadText.SetText(Text)
	else:
		print("Force Quit")
		Exit()

func ParseCom(CommandStr : String, Splitter : String):
	var Command = CommandStr.split(Splitter)
	print(Command)
	match Command[0]:
		"WAIT": #Wait for a Timer or Player Input
			if len(Command) == 2:
				get_tree().create_timer(Command[1].to_float()).connect("timeout",ReadLine)
			else:
				WaitingForInput = true
		"GOTO": #Goto a Tag
			ReadAt(Command[1])
			ReadLine()
		"END": #End Conversation
			Exit()
		"?": #Add a Selection Option
			AddSelection(Command[1],Command[2])
			ReadLine()
		"CHECK": #Uses an Internal sub-function to decide if should Trigger other Commands
			if Check(Command[1]):
				ParseCom(Command[2],"-")
			elif len(Command) == 4:
				ParseCom(Command[3],"-")
			else:
				ReadLine()
		"EMIT": #Emits NPCSignal with Identification
			NPCSignal.emit(Command[1])
		"VAR": #Performs Actions with Globally Stored Variables (Floats / Bools)
			GlobalAction(Command)
			ReadLine()

func ReadAt(Identity : String):
	CurrentLine = Lines.find("#"+Identity)

func ResetSelection():
	Selections.clear()
	SelectLinks.clear()
	$ReadText.SetSelections([])

func AddSelection(Title : String, Command : String):
	Selections.append(Title)
	SelectLinks.append(Command)
	$ReadText.SetSelections(Selections)

func GlobalAction(Command : Array):
	var GlobVar = Global.GetVar(Command[1])
	var OthrVar
	if Command[3] == "True":
		OthrVar = true
	elif Command[3] == "False":
		OthrVar = false
	elif Command[3].is_valid_float():
		OthrVar = Command[3].to_float()
	
	match Command[2]:
		"+":
			Global.SetVar(Command[1], GlobVar + OthrVar)
		"-":
			Global.SetVar(Command[1], GlobVar - OthrVar)
		"*":
			Global.SetVar(Command[1], GlobVar * OthrVar)
		"/":
			Global.SetVar(Command[1], GlobVar / OthrVar)
		">":
			if GlobVar > OthrVar:
				ParseCom(Command[4], "-")
		"<":
			if GlobVar < OthrVar:
				ParseCom(Command[4], "-")
		"==":
			if GlobVar == OthrVar:
				ParseCom(Command[4], "-")
		"?":
			if GlobVar:
				ParseCom(Command[3], "-")
		"!":
			if !GlobVar:
				ParseCom(Command[3], "-")
		"=":
			Global.SetVar(Command[1], OthrVar)

func Check(ID : String = "") -> bool:
	return false

func get_aabb(): #Return Useable AABB for Scale Follow
	return AABB()
