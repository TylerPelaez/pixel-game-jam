extends Node
class_name WaveData

enum WaveType {
	LEFT,
	BOTTOM,
	RIGHT,
	ALL
}

enum EnemyDistribution {
	MIXED,
	VARIANT_FIRST,
	VARIANT_LAST
}

class WaveMakeup:
	var type: WaveType
	var regular_enemy_count: int
	var variant_enemy_count: int
	var distribution: EnemyDistribution
	var core_health_reward: int
	var player_health_reward: int
	var spawn_duration_seconds: float
	
	func _init(_type: WaveType, _regular_enemy_count: int, _variant_enemy_count: int, _distribution: EnemyDistribution = EnemyDistribution.MIXED, _core_health_reward: int = 5, _player_health_reward: int = 3, _spawn_duration_seconds: float = 30.0):
		type = _type
		regular_enemy_count = _regular_enemy_count
		variant_enemy_count = _variant_enemy_count
		distribution = _distribution
		core_health_reward = _core_health_reward
		player_health_reward = _player_health_reward
		spawn_duration_seconds = _spawn_duration_seconds
	
	
	func duplicate() -> WaveMakeup:
		return WaveMakeup.new(type, regular_enemy_count, variant_enemy_count, distribution, core_health_reward, player_health_reward, spawn_duration_seconds)
	
var db: Array[WaveMakeup] = [
	WaveMakeup.new(WaveType.LEFT, 10, 0),
	WaveMakeup.new(WaveType.RIGHT, 15, 0),
	WaveMakeup.new(WaveType.BOTTOM, 30, 0),
	WaveMakeup.new(WaveType.RIGHT, 30, 5, EnemyDistribution.VARIANT_FIRST),
	WaveMakeup.new(WaveType.ALL, 0, 50, EnemyDistribution.MIXED, 20, 10),
	
	WaveMakeup.new(WaveType.LEFT, 40, 20),
	WaveMakeup.new(WaveType.BOTTOM, 55, 20),
	WaveMakeup.new(WaveType.RIGHT, 60, 25),
	WaveMakeup.new(WaveType.LEFT, 70, 20),
	WaveMakeup.new(WaveType.ALL, 80, 30)
]

func get_wave_makeup(wave_number: int) -> WaveMakeup:
	var max_wave_number_in_db = db.size()
	var index = wave_number - 1

	var makeup: WaveMakeup = db[index % max_wave_number_in_db]
	makeup = makeup.duplicate()
	
	var extra_enemies_base = (index / max_wave_number_in_db) * max_wave_number_in_db
	var total_enemies = float(makeup.regular_enemy_count + makeup.variant_enemy_count)
	var regular_enemies_pct = float(makeup.regular_enemy_count) / total_enemies
	var variant_enemies_pct = float(makeup.variant_enemy_count) / total_enemies
	
	
	makeup.regular_enemy_count += extra_enemies_base * regular_enemies_pct * max_wave_number_in_db
	makeup.variant_enemy_count += extra_enemies_base * variant_enemies_pct * max_wave_number_in_db
	return makeup
