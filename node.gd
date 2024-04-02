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
enum MPEVENT_TYPE {
	DRONE = 0,
}
enum PLAYER_EVENT_ACTION {
	FW_THRUST = 0,
	BK_THRUST,
}

# ----- constants
const PORT = 9999
const MAX_PEER_DELAY_MS = 100
const SERVER_ELAB_TIME_MS = 0

# ----- exported variables
#@export var max_server_delay_ms = 100

# ----- public variables
var peer = ENetMultiplayerPeer.new()

# ----- private variables
var _metaverese_status = {
	'tick' : 0,
	'planets': {
		'test': {
			
		}
	},
	'drones': {
	}
}
var _metaverese_last_hash = null

var _events_buffer = null

var _current_tick = 0

# max peer latency
var _max_peer_delay_ms = 0
# send status interval 
var _server_send_timer_sec = 0


var _physics_process_delta = 0
var _old_tick = 0

var _tick = 0
var _sub_tick = 0


# ----- onready variables


# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	_max_peer_delay_ms = MAX_PEER_DELAY_MS
	_server_send_timer_sec = (
			_max_peer_delay_ms + SERVER_ELAB_TIME_MS) / 1000.00
	print("_max_peer_delay_ms " + str(_max_peer_delay_ms))
	print("_server_send_timer_sec " + str(_server_send_timer_sec))

	var error = peer.create_server(PORT)
	# where can we call free ?
	_events_buffer = MapodInputBuffer.new(1000)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	var sync_timer = Timer.new()
	add_child(sync_timer)
	sync_timer.timeout.connect(func():
		var current_tick = Time.get_ticks_msec()
		var current_hash = _metaverese_status.hash()
		if _metaverese_last_hash != current_hash:
			_metaverese_last_hash = current_hash
			var metaverse_status = _metaverese_status.duplicate(true)
			metaverse_status.tick = current_tick
			send_metaverse_status.rpc(metaverse_status)
	)
	sync_timer.start(_server_send_timer_sec)
	print("READY")
	for pippo in range (0, 3):
		print(3 - pippo - 1)

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass # Replace with function body.
	
# Called every 16,6666 ms
func _physics_process(delta):
	_current_tick = Time.get_ticks_msec() - (delta + _server_send_timer_sec)
	_elab_tick(_current_tick)


# ----- public methods
## send server name
@rpc("authority", "call_remote", "unreliable")
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
	var player_node_name = "PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node(player_node_name)
	_metaverese_status.drones[str(peer_id)] = {
		"position": player_node.get_mapod_position()
	}
	player_node.mapod_position_updated.connect(_on_mapod_position_updated)
	ready_to_go.rpc_id(peer_id, peer_id)


# send ready to go
@rpc("authority", "call_remote")
func ready_to_go(peer_id):
	pass


## ticks sync request
@rpc("any_peer", "call_remote", "reliable")
func ticks_sync_request(peer_id, client_tick):
	ticks_sync.rpc_id(peer_id, client_tick, Time.get_ticks_msec())


## ticks sync answer
@rpc("authority", "call_remote", "reliable")
func ticks_sync(client_tick, server_tick):
	pass


@rpc("any_peer", "call_remote", "reliable")
func send_player_event(peer_id, event):
	print("send_event")
	# push event in the buffer
	var current_tick = _current_tick
	var last_tick = current_tick - _max_peer_delay_ms
	print(last_tick)
	if last_tick > 0:
		if event.T < last_tick:
			print("send_event discharged " + 
				" current_tick " + str(_current_tick) +
				" last_tick " + str(last_tick) +
				" event_tick " + str(event.T) +
				" diff " + str(_current_tick - event.T) +
				" lterncy_peer " +  str(event.L))
		_events_buffer.push(event, last_tick)
		_events_buffer.print()


@rpc("authority", "call_remote", "reliable")
func send_server_event(event):
	pass


@rpc("authority", "call_remote", "reliable")
func send_metaverse_status(_metaverese_status):
	pass


# ----- private methods
func _on_peer_connect(peer_id):
	print("connect " + str(peer_id))
	server_name.rpc_id(peer_id, peer_id, "MAPOD4D server")


func _on_peer_disconnect(peer_id):
	print("disconnect " + str(peer_id))
	$PlayerSpawnerArea.kill(peer_id)


func _on_mapod_position_updated(peer_id):
	print("_on_mapod_position_updated")
	var player_node_name = "PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node(player_node_name)
	_metaverese_status.drones[str(peer_id)] = {
		"position": player_node.get_mapod_position()
	}


func _old_elab_tick(current_tick):
	if current_tick > _max_peer_delay_ms:
		var result = _events_buffer.pop(current_tick - _max_peer_delay_ms)
		if result.is_empty() == false:
			for mp_event in result:
				match mp_event.type:
					MPEVENT_TYPE.DRONE:
						drone_event(mp_event)


func _elab_tick(current_tick):
	if current_tick > _max_peer_delay_ms:
		var mp_event = _events_buffer.pop_single()
		if mp_event != null:
			match mp_event.type:
				MPEVENT_TYPE.DRONE:
					drone_event(mp_event)


func drone_event(mp_event):
	print(mp_event)
	var player_node_name = (
			"PlayerSpawnerArea/" + str(mp_event.peer_id))
	var player_node = get_node(player_node_name)
	match mp_event.action:
		PLAYER_EVENT_ACTION.FW_THRUST:
			player_node.fw_thrust()
			send_server_event.rpc_id(mp_event.peer_id, mp_event)
		PLAYER_EVENT_ACTION.BK_THRUST:
			player_node.bk_thrust()
			send_server_event.rpc_id(mp_event.peer_id, mp_event)

