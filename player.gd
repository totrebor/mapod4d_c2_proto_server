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
var _position_updated = false

# ----- onready variables
@onready var _mapod = $Mapod

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass # Replace with function body.


func _unhandled_input(event):
	pass
	#if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		##rotate_y(-event.relative.x * mouse_sensitivity)
		##$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		##$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
		#var rotate_vector: Vector2
		#if event.relative.y > 0:
			#rotate_vector.x = 1
		#else:
			#rotate_vector.x = -1
		#mapod.mapod_rotate(rotate_vector)


func _physics_process(_delta):
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
	if _position_updated:
		emit_signal("mapod_position_updated", self.name)
		_position_updated = false


# ----- public methods
@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	pass


func fw_thrust():
	_mapod.fw_thrust()
	await get_tree().create_timer(get_physics_process_delta_time()).timeout
	_position_updated = true

func bk_thrust():
	_mapod.bk_thrust()
	await get_tree().create_timer(get_physics_process_delta_time()).timeout
	_position_updated = true

func get_mapod_position():
	return _mapod.position

# ----- private methods





