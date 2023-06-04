
enum Direction {
	North_West,
	North_East,
	South_West,
	South_East, 
	
}

// Struct to hold data between a grid and array. 
function world_gen_cell(_x, _y, _id) constructor {
	x			= _x;
	y			= _y;
	region_id	= _id;
}

// Preps data holders to be used. Also resets generation.
function prep_world_map() {
	active_cells	= [];
	
	region_data		= [];
	locked_regions	= [];
	
	for(var _y = 0; _y < world_height; ++_y) {
		for(var _x = 0; _x < world_width; ++_x) {
			working_grid[# _x, _y] = new world_gen_cell(_x, _y, -1);
			array_push(active_cells, working_grid[# _x, _y]);
		}	
	}
}

// Used to find free space for a cell to expand into. 
function try_expand_cell(_cell) {

	var _region_id		= _cell.region_id;
	var _region_data	= region_data[_region_id];
	var _left = true, _right = true, _up = true, _down = true;
	
	// Check if cell is touching side and setting false if so.
	if (_region_data.x_start == 0) {
		_left = false;
	}
	if (_region_data.y_start == 0) {
		_up = false;
	}
	
	if (_region_data.x_start + _region_data.x_length >= world_width -1) {
		_right = false;
	}
	if (_region_data.y_start + _region_data.y_length >= world_height -1) {
		_down = false;
	}

	
	/*
	For loops checking if the space is clear in set direction if safe. (pre checks above). 
	Then adding that direction to a array to randomly select from if it can expand.
	One set for each directions just makes it easier to edit and debug. 
	*/
	
	var _choose_dir = [];
	
	if (_up and _left) {
		var _valid_direction = true;
		for (var i = 0; i < _region_data.x_length + 1; ++i) {
			var _x = _region_data.x_start-1+i, _y = _region_data.y_start-1;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
			var _x = _region_data.x_start-1, _y = _region_data.y_start-1+i;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
		}
		
		if (_valid_direction) {
			array_push(_choose_dir, Direction.North_West);
		}
	}
	
	if (_up and _right) {
		var _valid_direction = true;
		for (var i = 0; i < _region_data.x_length + 1; ++i) {
			var _x = _region_data.x_start+i, _y = _region_data.y_start-1;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
			var _x = _region_data.x_start + _region_data.x_length, _y = _region_data.y_start-1+i;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
		}
		
		if (_valid_direction) {
			array_push(_choose_dir, Direction.North_East);
		}
	}
	
	if (_down and _left) {	
		var _valid_direction = true;
		for (var i = 0; i < _region_data.x_length + 1; ++i) {
			var _x = _region_data.x_start-1, _y = _region_data.y_start+i;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
			var _x = _region_data.x_start-1+i, _y = _region_data.y_start+_region_data.y_length;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
		}
		
		if (_valid_direction) {
			array_push(_choose_dir, Direction.South_West);
		}
	}
	
	if (_down and _right) {	
		var _valid_direction = true;
		for (var i = 0; i < _region_data.x_length + 1; ++i) {
			var _x = _region_data.x_start + _region_data.x_length, _y = _region_data.y_start+i;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
			var _x = _region_data.x_start+i, _y =  _region_data.y_start+_region_data.y_length;
			if (working_grid[# _x, _y].region_id != -1) {
				_valid_direction = false;
				break;
			}
		}
		
		if (_valid_direction) {
			array_push(_choose_dir, Direction.South_East);
		}
	}
		
	
	// Exit if no directions to expand into
	if (array_length(_choose_dir) == 0) {
		return(false);
	}

	var _found_direction = _choose_dir[irandom(array_length(_choose_dir)-1)];
	var _old_start_x = _region_data.x_start;
	var _old_start_y = _region_data.y_start;
	
	// Changing region x,y and size based on expanding direction.
	if (_found_direction == Direction.North_West) { 
		_region_data.x_length ++;
		_region_data.y_length ++;
		_region_data.x_start --;
		_region_data.y_start --;
	}
	
	if (_found_direction == Direction.North_East) { 
		_region_data.x_length ++;
		_region_data.y_length ++;
		_region_data.y_start --;
	}
		
	if (_found_direction == Direction.South_West) { 
		_region_data.x_length ++;
		_region_data.y_length ++;
		_region_data.x_start --;
	}
	
	if (_found_direction == Direction.South_East) { 
		_region_data.x_length ++;
		_region_data.y_length ++;
	}
	
	// Updating structs that are held between the array and grids. 
	for(var _y = _region_data.y_start; _y < _region_data.y_start + _region_data.y_length; ++_y) {
		for(var _x = _region_data.x_start; _x < _region_data.x_start + _region_data.x_length; ++_x) {
			working_grid[# _x, _y].region_id = _region_id;
		}	
	}
	
	
	return(true);
	
	
}


/*
Starts the generation.
Basics are that it chooses a grid cell struct stored in an array. 
Checks if it has a region id and goes from there. 
Regions created are held in region_data. This is the main export as it has the x , y and size of a region all in one place. 
If try_expand_cell -> false. It means that region cant be expanded, locking it. 

NOTE: the grid/array structs are just used as a refrence to the region they are in, 
selected cells are only used for there 'region_id', then the region is expanded and grid edited based on that 'region_id'

*/
function generate_world_map() {
	var _generation_done = false;
	
	while(!_generation_done) {
		var _array	= active_cells;
		
		if (array_length(_array) == 0) {
			_generation_done = true;
			show_debug_message("Generation Done");
			continue;
		}
		
		var _pos	= irandom(array_length(_array)-1);
		var _cell	= _array[_pos];

		if (_cell.region_id == -1) {
			
			array_push(region_data, {
				x_start		: _cell.x,
				y_start		: _cell.y,
				x_length	: 1,
				y_length	: 1,
				locked		: false,
			});
			
			_cell.region_id = array_length(region_data)-1;
		}
		
		if (region_data[_cell.region_id].locked) {
			array_delete(_array, _pos, 1);
			continue;	
		}
		

		var _expanded = try_expand_cell(_cell);
		
		if (!_expanded) {
			region_data[_cell.region_id].locked = true;
		}
	}
}



// Basic struct to hold all the data. 
function world_map(_w, _h) constructor {
	world_width 	= _w;
	world_height	= _h;
	working_grid	= ds_grid_create(_w, _h);
	active_cells	= [];
	
	region_data		= [];
	locked_regions	= [];
	
	static run_generation = function() {
		prep_world_map();
		generate_world_map()
	}
	
	static draw_map_gizmo = function(_cell_size = 10) {
		draw_rectangle(49, 49, 50 + (world_width*_cell_size), 50 + (world_height*_cell_size), true)
		for (var i = 0; i < array_length(global.testing.region_data); ++i) {
		    draw_rectangle(
			50+(global.testing.region_data[i].x_start)*_cell_size, 
			50+(global.testing.region_data[i].y_start)*_cell_size, 
			50+(global.testing.region_data[i].x_start+global.testing.region_data[i].x_length)*_cell_size - 1, 
			50+(global.testing.region_data[i].y_start+global.testing.region_data[i].y_length)*_cell_size - 1, 
			true
			)
		}
	}
	
}


