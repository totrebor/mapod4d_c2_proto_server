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

# ----- exported variables

# ----- public variables

# ----- private variables


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
@onready var _current_tick = 0
# max peer latency
@onready var _max_peer_delay_ms = 0
# buffer of events received
@onready var _events_buffer = MapodEventList.new(30000)

# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.

# ----- public methods

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
	$PlayerSpawnerArea.spawn(peer_id)
	var player_node_name = "PlayerSpawnerArea/" + str(peer_id)
	var player_node = get_node(player_node_name)
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
## send to remote player confirmed end of event
func _on_mapod_event_confirmed(peer_id: int, mp_event):
	print("_on_mapod_event_confirmed ", peer_id, " ", mp_event)
	confirm_player_event.rpc_id(peer_id, mp_event)

