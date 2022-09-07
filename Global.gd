extends Node

var Player : Node3D

var Variables : Dictionary

func AddVar(Name : String, Value):
	Variables[Name] = Value

func GetVar(Name : String):
	return Variables.get(Name, 0)

func SetVar(Name : String, Value):
	prints(Name,Value)
	Variables[Name] = Value

func RemoveVar(Name : String):
	Variables.erase(Name)
