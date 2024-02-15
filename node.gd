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

# ----- public variables
var peer = ENetMultiplayerPeer.new()

# ----- private variables

# ----- onready variables


# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	var error = peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	print("READY")

# ----- remaining built-in virtual methods

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass # Replace with function body.

# ----- public methods
@rpc("unreliable","authority")
func server_name():
	pass


# ----- private methods
func _on_peer_connect(peer_id):
	print("connect " + str(peer_id))
	$PlayerSpawnerArea.spawn(peer_id)
	rpc_id(peer_id, "server_name", "sono il server MAPOD4D")


func _on_peer_disconnect(peer_id):
	print("disconnect " + str(peer_id))
	$PlayerSpawnerArea.kill(peer_id)

