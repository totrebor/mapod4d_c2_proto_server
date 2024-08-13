# tool

# class_name
class_name Mapod4dNet

# extends
extends Node

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:            http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals

# ----- enums

# ----- constants
const PORT = 9999
const MAX_PEER_DELAY_MS = 100
const SERVER_ELAB_TIME_MS = 0

# ----- exported variables

# ----- public variables

# ----- private variables
var _playerSpawnerArea = null

# ----- onready variables private variables
@onready var _metaverse_status = {
	'tick' : 0,
	'planets': {
		'test': {
			
		}
	},
	'drones': {
	}
}
@onready var _metaverese_last_hash = null
@onready var _current_tick = 0
# max peer latency
@onready var _max_peer_delay_ms = 0
# buffer of events received
@onready var _events_buffer = MapodEventList.new(30000)
# send status interval 
@onready var _server_send_timer_sec = 0
# server peer
@onready var _peer = ENetMultiplayerPeer.new()

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.


# Called every 16,6666 ms
func _physics_process(delta):
	_current_tick = Time.get_ticks_msec() - (delta + _server_send_timer_sec)
	_elab_tick(_current_tick)


# ----- public methods
func start(playerSpawnerArea):
	_playerSpawnerArea = playerSpawnerArea
	_max_peer_delay_ms = MAX_PEER_DELAY_MS
	_server_send_timer_sec = (
			_max_peer_delay_ms + SERVER_ELAB_TIME_MS) / 1000.00
	print("_max_peer_delay_ms " + str(_max_peer_delay_ms))
	print("_server_send_timer_sec " + str(_server_send_timer_sec))
	# PROVA DI CAMBIAMENTO
	# originale _events_buffer = MapodInputBuffer.new(1000)
	_events_buffer = MapodEventList.new(1000)
	var error = _peer.create_server(PORT)
	print(error)
	multiplayer.multiplayer_peer = _peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	var sync_timer = Timer.new()
	add_child(sync_timer)
	sync_timer.timeout.connect(func():
		var current_tick = Time.get_ticks_msec()
		var current_hash = _metaverse_status.hash()
		if _metaverese_last_hash != current_hash:
			_metaverese_last_hash = current_hash
			var metaverse_status = _metaverse_status.duplicate(true)
			metaverse_status.tick = current_tick
			send_metaverse_status.rpc(metaverse_status)
	)
	sync_timer.start(_server_send_timer_sec)
	print("READY")
	for pippo in range (0, 3):
		print(3 - pippo - 1)


## name server side
@rpc("authority", "call_remote", "unreliable")
func server_name(_peer_id_rpc, _remote_server_name_rpc):
	pass


## authentication client side
@rpc("any_peer", "call_remote")
func user_auth_request(peer_id, _login, _password):
	print("user_auth " + str(peer_id) + " " + _login + " " + _password)
	auth_confirmed.rpc_id(peer_id, peer_id, "SDWEwwW2sw")


## authentication error server side
@rpc("authority", "call_remote")
func auth_error(_peer_id_rpc):
	pass


## authentication confirmed server side
@rpc("authority", "call_remote")
func auth_confirmed(_peer_id_rpc, _auth_token_rpc):
	pass


# create player client side
# player spwan
@rpc("any_peer", "call_remote")
func start_game(peer_id, _auth_token):
	print("start_game " + str(peer_id))
	_playerSpawnerArea.spawn(peer_id)
	var player_node = _get_player_node_or_null(peer_id)
	_metaverse_status.drones[str(peer_id)] = {
		"position": player_node.get_mapod_position()
	}
	## parte da sistemare inizio
	#player_node.mapod_position_updated.connect(_on_mapod_position_updated)
	## parte da sistemare fine
	player_node.mapod_event_confirmed.connect(_on_mapod_event_confirmed)
	ready_to_go.rpc_id(peer_id, peer_id)


# send ready to go server side
@rpc("authority", "call_remote")
func ready_to_go(_peer_id_rpc):
	pass


## ticks sync request
@rpc("any_peer", "call_remote", "reliable")
func ticks_sync_request(peer_id, client_tick):
	ticks_sync.rpc_id(peer_id, client_tick, Time.get_ticks_msec())


## ticks sync answer server side
@rpc("authority", "call_remote", "reliable")
func ticks_sync(_client_tick_rpc, _server_tick_rpc):
	pass


## event received from remote player
@rpc("any_peer", "call_remote", "reliable")
func send_player_event(_peer_id, event):
	print("send_player_event")
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
				" latency_peer " +  str(event.L))
		_events_buffer.push_c(event, last_tick)
		_events_buffer.print()


## confirm an event to the remote player server side
@rpc("authority", "call_remote", "reliable")
func confirm_player_event(_mp_event):
	pass


## server event server side
@rpc("authority", "call_remote", "reliable")
func send_server_event(_event_rpc):
	pass


## metaverse status  server side
@rpc("authority", "call_remote", "reliable")
func send_metaverse_status(_metaverese_status_rpc):
	pass


# ----- private methods
func _get_player_node_or_null(peer_id):
	var player_node_name = "/root/Mapod4dMain/PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node_or_null(player_node_name)
	return player_node


func _elab_tick(current_tick):
	if current_tick > _max_peer_delay_ms:
		var mp_event = _events_buffer.get_event_rm()
		if mp_event != null:
			if MPEventBuilder.is_drone(mp_event):
				_drone_event(mp_event)


# push drone event in the correct player
func _drone_event(mp_event):
	print("drone_event " + str(mp_event))
	var peer_id = MPEventBuilder.gain_peer_id(mp_event)
	var player_node = _get_player_node_or_null(peer_id)
	if player_node != null:
		if MPEventBuilder.is_drone_thrust(mp_event):
			player_node.push_thrust_event(mp_event)


## send to remote player confirmed end of event
func _on_mapod_event_confirmed(peer_id: int, mp_event):
	print("_on_mapod_event_confirmed ", peer_id, " ", mp_event)
	confirm_player_event.rpc_id(peer_id, mp_event)


func _on_peer_connected(peer_id):
	print("connect " + str(peer_id))
	server_name.rpc_id(peer_id, peer_id, "MAPOD4D server")


func _on_peer_disconnected(peer_id):
	print("disconnect " + str(peer_id))
	_metaverse_status.erase(str(peer_id))
	_playerSpawnerArea.kill(peer_id)

