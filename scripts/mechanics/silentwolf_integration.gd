extends Node

const LEADERBOARD_ID = "voll_man_leaderboard"

func submit_score(player_name: String, score: int):
	SilentWolf.Scores.persist_score(player_name, score, LEADERBOARD_ID)
	SilentWolf.Scores.get_scores(10, LEADERBOARD_ID).sw_get_scores_complete.connect(_on_scores_received)

func _on_scores_received():
	var scores = SilentWolf.Scores.scores
	print("High scores received: ", scores)

func get_high_scores(limit: int = 10):
	SilentWolf.Scores.get_scores(limit, LEADERBOARD_ID).sw_get_scores_complete.connect(_on_scores_received)
