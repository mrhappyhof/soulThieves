extends KinematicBody2D

var stats = { 
	"speed": 100,
	"can_kick": false,
	"can_throw": false,
	"has_shield": false,
	"layable_bombs": 1,
	"bomb_blast_range": 1,
	"is_scatty": false,
	"is_restrained": false,
	"has_mirror": false,
	"has_teleport": false,
	"hyperactive": false,
	"slow": false,
	"is_dead": false,
	"fallen": false,
	"on_ice": Vector2.ZERO
}

var in_bomb = null

var used_spawn

var motion = Vector2.ZERO
var viewing_direction = Vector2.ZERO
#var speed = 100
#var can_kick = false
#var can_throw = false
#var has_shield = false
#var layable_bombs = 1
#var bomb_blast_range = 1
#var is_scatty = false
#var is_restrained = false
#var has_mirror = false
#var has_teleport = false
var has_bad_powerup = false
#var hyperactive = false
#var slow = false
#
#var is_dead = false

func _ready():
	set_physics_process(false)

func _physics_process(_delta):
	if not stats.is_dead and motion != Vector2.ZERO and not stats.fallen:
		var amplifier = 1
		if stats.has_mirror:
			amplifier = -1
		elif stats.hyperactive:
			amplifier = 4
		elif stats.slow:
			amplifier = 0.5
		if stats.on_ice != Vector2.ZERO:
			if motion == Vector2.ZERO:
				var _y = move_and_slide(stats.on_ice * stats.speed * amplifier)
			else:
				amplifier *= 2
				
		var _y = move_and_slide(motion * stats.speed * amplifier);
		motion = Vector2.ZERO
		
		if not stats.is_dead:
			var tilemap = get_parent().get_parent().get_node("TileMap")
			var coords = tilemap.world_to_map(self.position - tilemap.position)
			var cell_id = tilemap.get_cellv(coords)
			var cell_type = ""
			if cell_id != -1:
				cell_type = tilemap.tile_set.tile_get_name(cell_id)
			
			match cell_type:
				"arena_ice":
					stats.on_ice=viewing_direction
				"":
					var center_coords=get_center_coords_from_cell_in_world_coords()
					var on_cell=false;
					match viewing_direction:
						Vector2(0,0):
							on_cell=true
						Vector2.UP:
							if center_coords.y >= position.y:
								on_cell=true
						Vector2.DOWN:
							if center_coords.y <= position.y:
								on_cell=true
						Vector2.RIGHT:
							if center_coords.x <= position.x:
								on_cell=true
						Vector2.LEFT:
							if center_coords.x >= position.x:
								on_cell=true	
					if on_cell:
						stats.fallen = true
						$FallTimer.start()
			if cell_type != "arena_ice":
				stats.on_ice=Vector2.ZERO

func move(v):
	motion = v
	if v != Vector2.ZERO:
		viewing_direction = v

#Decides which Powerup was picked up and changes the attributes of the player
func pick_up_powerup(type):
	match type:
		Powerup.Types.BAD_HYPERACTIVE:
			if not has_bad_powerup:
				stats.hyperactive = true
				has_bad_powerup = true
				$Timer.start()
		Powerup.Types.BAD_MIRROR: 
			if not has_bad_powerup:
				stats.has_mirror = true
				has_bad_powerup = true
				$Timer.start()
		Powerup.Types.BAD_RESTRAIN:
			if not has_bad_powerup:
				stats.is_restrained = true
				has_bad_powerup = true
				$Timer.start()
		Powerup.Types.BAD_SCATTY: 
			if not has_bad_powerup:
				stats.is_scatty = true
				has_bad_powerup = true
				$Timer.start()
				$ScattyTimer.start()
		Powerup.Types.BAD_SLOW:
			if not has_bad_powerup:
				stats.slow = true
				has_bad_powerup = true
				$Timer.start()
		Powerup.Types.BOMB: 
			stats.layable_bombs += 1
		Powerup.Types.KICK: 
			stats.can_kick = true
		Powerup.Types.POWER: 
			stats.bomb_blast_range += 1
		Powerup.Types.SHIELD: 
			if not stats.has_shield:
				stats.has_shield = true
		Powerup.Types.SPEED: 
			stats.speed += 20
		Powerup.Types.THROW: 
			stats.can_throw = true
		Powerup.Types.NEUTRAL_TELEPORT: 
			stats.has_teleport = true
			get_node("/root/Server").teleport_player(int(name))
		Powerup.Types.NEUTRAL_PANDORA:
			var randomizer = RandomNumberGenerator.new()
			randomizer.randomize()
			var randomNumber = randomizer.randi_range(0, Powerup.Types.size() - 3) #-3 because the last two are neutral
			pick_up_powerup(randomNumber)

#Called, when the timer of the bad Powerup runs out and resets 
#some attributes of the player
func _on_bad_powerup_timer_timeout():
	stats.has_mirror = false
	stats.is_restrained = false
	stats.is_scatty = false
	stats.hyperactive = false
	stats.slow = false
	$ScattyTimer.stop()
	has_bad_powerup = false

func destroy():
	if !stats.has_shield:
		stats.is_dead = true
		get_parent().get_parent().players_alive.erase(int(name))
	else:
		stats.has_shield = false 
#TODO: If player was hit by the bomb and has_shield, has_shield = false


func _on_ScattyTimer_timeout():
	get_node("/root/Server").place_bomb(int(name))



func _on_FallTimer_timeout():
	stats.is_dead = true
	get_parent().get_parent().players_alive.erase(int(name))
	
func get_center_coords_from_cell_in_world_coords():
	var tilemap = get_parent().get_parent().get_node("TileMap")
	var map_coords=tilemap.world_to_map(self.position - tilemap.position)
	var coords=tilemap.map_to_world(map_coords)+Vector2(20,20)+tilemap.position
	return coords
