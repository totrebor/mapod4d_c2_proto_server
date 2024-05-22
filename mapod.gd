# tool

# class_name

# extends
extends CharacterBody3D

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals
signal position_updated()

# ----- enums

# ----- constants

# ----- exported variables
@export var acceleration = 20.0
@export var mouse_sensitivity = 0.01

# ----- public variables

# ----- private variables
var _velocity = null


# ----- onready variables
#@onready var _camera = $Camera3D

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


func _physics_process(delta):
	if _velocity != null:
		var local_velocity = _velocity
		_velocity = null
		var collision = move_and_collide(local_velocity * delta)
		if collision:
			print("I collided with ", collision.get_collider().name)
		call_deferred("emit_signal", "position_updated")


# ----- public methods
func mapod_rotate(_rotate_vector: Vector2):
	#rotate_y(-event.relative.x * mouse_sensitivity)
	#_camera.rotate_x(-rotate_vector.x * mouse_sensitivity)
	pass


func fw_thrust():
	print("fw_thrust")
	#var delta = get_physics_process_delta_time()
	#linear_velocity.z += (acceleration * delta)
	_velocity = transform.basis * Vector3(0, 0, 1)


func bk_thrust():
	#var delta = get_physics_process_delta_time()
	#linear_velocity.z += (-acceleration * delta)
	_velocity = Vector3(0, 0, -1)


func lf_thrust():
	#var delta = get_physics_process_delta_time()
	#linear_velocity.x += (acceleration * delta)
	pass


func rg_thrust():
	#var delta = get_physics_process_delta_time()
	#linear_velocity.x += (-acceleration * delta)
	pass


func up_thrust():
	#var delta = get_physics_process_delta_time()
	#linear_velocity.y += (acceleration * delta)
	pass


func dw_thrust():
	#var delta = get_physics_process_delta_time()
	#linear_velocity.y += (-acceleration * delta)
	pass


# ----- private methods





