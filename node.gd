# tool

# class_name

# extends
extends Node

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com
# https://godotengine.org/article/enet-dtls-encryption/

# ----- signals

# ----- enums

# ----- constants
const PORT = 9999

# ----- exported variables
@export var max_server_delay_ms = 100

# ----- public variables
var peer = ENetMultiplayerPeer.new()

# ----- private variables
var _events_buffer = null
var _physics_process_delta = 0
var _old_tick = 0
var _current_tick = 0

var _tick = 0
var _sub_tick = 0


# ----- onready variables


# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	var error = peer.create_server(PORT)
	# where can we call free ?
	_events_buffer = MapodInputBuffer.new(1000)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	#var sync_timer = Timer.new()
	#add_child(sync_timer)
	#sync_timer.timeout.connect(func(): 
		#print(Time.get_ticks_msec())
	#)
	#sync_timer.start(0.1)
	print("READY")
	for pippo in range (0, 3):
		print(3 - pippo - 1)

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass # Replace with function body.
	
# Called every 16,6666 ms
func _physics_process(_delta):
	# tick in the past for a server
	var delay = 0
	_physics_process_delta = int(_delta * 1000)
	if max_server_delay_ms < _physics_process_delta:
		delay = _physics_process_delta
	else:
		delay = max_server_delay_ms
	_current_tick = Time.get_ticks_msec() - delay
	_elab_tick()


# ----- public methods
## send server name
@rpc("authority", "call_remote")
func server_name(peer_id, _remote_server_name):
	pass


## authentication
@rpc("any_peer", "call_remote")
func user_auth_request(peer_id, _login, _password):
	print("user_auth " + str(peer_id) + " " + _login + " " + _password)
	auth_confirmed.rpc_id(peer_id, peer_id, "SDWEwwW2sw")


## authentication error
@rpc("authority", "call_remote")
func auth_error(peer_id):
	pass


## authentication confirmed
@rpc("authority", "call_remote")
func auth_confirmed(peer_id, auth_token):
	pass


# create player
@rpc("any_peer", "call_remote")
func start_game(peer_id, auth_token):
	print("start_game " + str(peer_id))
	$PlayerSpawnerArea.spawn(peer_id)
	ready_to_go.rpc_id(peer_id, peer_id)


# send ready to go
@rpc("authority", "call_remote")
func ready_to_go(peer_id):
	pass


## ticks sync request
@rpc("any_peer", "call_remote")
func ticks_sync_request(peer_id):
	ticks_sync.rpc_id(peer_id, Time.get_ticks_msec())


## ticks sync answer
@rpc("authority", "call_remote")
func ticks_sync(server_ticks):
	pass


@rpc("any_peer",  "call_remote", "reliable")
func send_player_event(peer_id, event):
	print("send_event")
	# push event in the buffer
	_events_buffer.push(event, _current_tick)
	_events_buffer.print()


# ----- private methods
func _on_peer_connect(peer_id):
	print("connect " + str(peer_id))
	server_name.rpc_id(peer_id, peer_id, "MAPOD4D server")


func _on_peer_disconnect(peer_id):
	print("disconnect " + str(peer_id))
	$PlayerSpawnerArea.kill(peer_id)


func _elab_tick():
	var result = _events_buffer.pop(_current_tick)
	if result.is_empty() == false:
		print("_elab_tick")
		print(result)
