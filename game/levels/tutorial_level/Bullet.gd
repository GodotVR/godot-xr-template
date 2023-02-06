extends RigidBody

func _on_LifeTime_timeout():
	# delete our bullet
	queue_free()
