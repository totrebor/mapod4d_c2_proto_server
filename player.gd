# tool

# class_name

# extends
extends Node3D

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals
signal mapod_position_updated(_peer_id)

# ----- enums

# ----- constants

# ----- exported variables

# ----- public variables

# ----- private variables
#var _position_updated = false
#var _velocity = null

# ----- onready variables
@onready var _mapod = $Mapod

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	_mapod.position_updated.connect(_on_position_updated)
	pass # Replace with function body.
	

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


func _physics_process(_delta):
	pass
	#if Input.is_action_pressed("mapod_w"):
		#mapod.fw_thrust()
	#if Input.is_action_pressed("mapod_s"):
		#mapod.bk_thrust()
	#if Input.is_action_pressed("mapod_a"):
		#mapod.lf_thrust()
	#if Input.is_action_pressed("mapod_d"):
		#mapod.rg_thrust()
	#if Input.is_action_pressed("mapod_q"):
		#mapod.up_thrust()
	#if Input.is_action_pressed("mapod_space"):
		#mapod.dw_thrust()



# ----- public methods
@rpc("any_peer", "call_local")
func setup_multiplayer(_player_id_rpc):
	pass


func fw_thrust():
	_mapod.fw_thrust()
	#await get_tree().create_timer(1).timeout
	#_position_updated = true
	pass


func bk_thrust():
	_mapod.bk_thrust()
	#await get_tree().create_timer(1).timeout
	#_position_updated = true
	pass


func get_mapod_position():
	return _mapod.position

# ----- private methods

func _on_position_updated():
	print("position_updated")
	emit_signal("mapod_position_updated", self.name)


