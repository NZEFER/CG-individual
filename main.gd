extends Control

@export_category("Point")
@export var point_radius = 4
@export var point_color = Color.BLACK
@export_category("Line")
@export var line_width = 2
@export var line_color = Color.RED

var points = []
var hull = []
var selected_point = -1
const DOUBLETAP_DELAY = 0.25
var doubletap_time = DOUBLETAP_DELAY


func _draw():
	if points.size() < 2:
		for point in points:
			draw_circle(point, point_radius, point_color)
		return
	
	for i in range(hull.size()-1):
		draw_line(hull[i],hull[i + 1], line_color, line_width)
	draw_line(hull[-1], hull[0], line_color, line_width)

	for point in points:
		draw_circle(point, point_radius, point_color)
	if hull.size() > 0:
		draw_circle(hull[0], point_radius, Color.AQUA)


func add_point_to_hull(new_point):
	points.append(new_point)
	hull = calculate_incremental_hull(points)


	
	
func calculate_incremental_hull(points_array):
	var sorted_points = points_array.duplicate()
	sorted_points.sort_custom(_sort_by_x)
	
	var hull = []
	
	for point in sorted_points:
		while hull.size() >= 2 and calculate_orientation(hull[-2], hull[-1], point) <= 0:
			hull.pop_back()
		hull.append(point)
		
	var upper_hull_start = hull.size()
	for i in range(sorted_points.size() -2, -1, -1):
		var point = sorted_points[i]
		while hull.size() > upper_hull_start and calculate_orientation(hull[-2], hull[-1], point) <= 0:
			hull.pop_back()
		hull.append(point)
	
	hull.pop_back()
	return hull



func _sort_by_x(p1, p2):
	return p1.x < p2.x

func calculate_orientation(p, q, r):
	return (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x)

func _process(delta):
	doubletap_time -= delta


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = event.global_position
			if doubletap_time >= 0:
				for i in range(points.size()):
					if mouse_pos.distance_to(points[i]) <= point_radius+15:
						points.remove_at(i)
						hull = calculate_incremental_hull(points)
						queue_redraw()
						doubletap_time = DOUBLETAP_DELAY
						return
			for i in range(points.size()):
				if mouse_pos.distance_to(points[i]) <= point_radius+15:
					selected_point = i
					doubletap_time = DOUBLETAP_DELAY
					queue_redraw()
					return
			
			add_point_to_hull(mouse_pos)
			doubletap_time = DOUBLETAP_DELAY
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected_point = -1
	elif event is InputEventMouseMotion and selected_point >= 0:
		var mouse_pos = event.global_position
		points[selected_point] = mouse_pos
		hull = calculate_incremental_hull(points)
		queue_redraw()
