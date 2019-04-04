use <MCAD/2Dshapes.scad>

IN = 25.4;
tile_unit = 1 * IN;
tile_radius = tile_unit / 2;
tile_tolerance = IN * 1/16;
tile_edge_width = IN * 1/16;
board_tolerance = IN * 1/16;

tile_outer_radius = tile_radius + tile_edge_width * 2;

layer_height = 0.2;

board_ridge_base_height = 7;
board_ridge_starting_height = board_ridge_base_height + 1;
board_ridge_inner_rim_height = board_ridge_base_height + layer_height;
board_ridge_outer_rim_height = board_ridge_base_height + 2*layer_height;
board_base_height=5;
board_radius = 215;

start_symbol_radius = 7.5;
start_symbol_disc_inner_radius = 4.5;
start_symbol_6star_inner_radius = 4;
start_symbol_12star_inner_radius = 4.5;
start_symbol_24star_inner_radius = 6.4;

start_circle_height=4;
start_disc_height=4;
start_hex_height=5;
start_6star_height=4;
start_12star_height=5;
start_24star_height=4;

tile_spacing = tile_unit + tile_tolerance + tile_edge_width*2;

segment_clearance = 0.1;

segment_key_height = 3;
segment_key_length = 10;
segment_key_radius = 5;
segment_key_clearance = 0.3;

module board_ridge(row, col, height=board_ridge_base_height, radius=tile_radius) {
    translate([tile_spacing*col*cos(60), tile_spacing*col*sin(60),0])
    translate([tile_spacing*row,0,0])
    linear_extrude(height)
    ngon(6, radius);
}

module board_locked_tile(row, col) {
    board_ridge(row, col, board_ridge_starting_height, tile_outer_radius);
}

module board_base() {
    rotate([0,0,30])
    linear_extrude(board_base_height)
    ngon(6, board_radius);
}

module start_circle(row, col) {
    translate([tile_spacing*col*cos(60), tile_spacing*col*sin(60),0])
    translate([tile_spacing*row,0,0])
    translate([0,0,board_ridge_starting_height-start_circle_height])
    linear_extrude(start_circle_height)
    circle(r=start_symbol_radius);
}

module start_disc(row, col) {
    translate([tile_spacing*col*cos(60), tile_spacing*col*sin(60),0])
    translate([tile_spacing*row,0,0])
    translate([0,0,board_ridge_starting_height-start_disc_height])
    linear_extrude(start_disc_height)
    difference() {
        circle(r=start_symbol_radius);
        circle(r=start_symbol_disc_inner_radius);
    }
}

module start_hex(row, col) {
    translate([tile_spacing*col*cos(60), tile_spacing*col*sin(60),0])
    translate([tile_spacing*row,0,0])
    translate([0,0,board_ridge_starting_height-start_hex_height])
    linear_extrude(start_hex_height)
    ngon(6, start_symbol_radius);
}

module nstar(n, inner, outer) {
    union() {
        for (p = [1:n]) {
            rotate([0, 0, p*360/n])
            polygon([
                [inner*cos(180/n), inner*sin(180/n)],
                [inner*cos(-180/n), inner*sin(-180/n)],
                [outer*cos(0), outer*sin(0)]
            ]);
        }
        
        ngon(n, inner, outer);
    }
}

module start_6star(row, col) {
    translate([tile_spacing*col*cos(60), tile_spacing*col*sin(60),0])
    translate([tile_spacing*row,0,0])
    translate([0,0,board_ridge_starting_height-start_6star_height])
    linear_extrude(start_6star_height)
    nstar(6, start_symbol_6star_inner_radius, start_symbol_radius);
}

module start_12star(row, col) {
    translate([tile_spacing*col*cos(60), tile_spacing*col*sin(60),0])
    translate([tile_spacing*row,0,0])
    translate([0,0,board_ridge_starting_height-start_12star_height])
    linear_extrude(start_12star_height)
    nstar(12, start_symbol_12star_inner_radius, start_symbol_radius);
}

module start_24star(row, col) {
    translate([tile_spacing*col*cos(60), tile_spacing*col*sin(60),0])
    translate([tile_spacing*row,0,0])
    translate([0,0,board_ridge_starting_height-start_24star_height])
    linear_extrude(start_24star_height+1)
    nstar(24, start_symbol_24star_inner_radius, start_symbol_radius);
}

module board() {
    difference() {
        union() {
            board_base();
            
            board_ridge();
            
            for (row = [-7:7]) {
                for (col = [-7:7]) {
                    if (abs(row + col) > 7) {
                        //#board_ridge(row, col);
                    }
                    
                    else if (abs(row + col) == 7 || abs(row) == 7 || abs(col) == 7) {
                        board_ridge(row, col, board_ridge_outer_rim_height);
                    }
                    
                    else if (abs(row + col) == 6 || abs(row) == 6 || abs(col) == 6) {
                        board_ridge(row, col, board_ridge_inner_rim_height);
                    }
                    
                    else if (row == 5 && col == 0) {
                        difference() {
                            board_locked_tile(row, col);
                        }
                    }
                    
                    else if (row == 0 && col == 5) {
                        difference() {
                            board_locked_tile(row, col);
                        }
                    }
                    
                    else if (row == -5 && col == 5) {
                        difference() {
                            board_locked_tile(row, col);
                        }
                    }
                    
                    else if (row == -5 && col == 0) {
                        difference() {
                            board_locked_tile(row, col);
                        }
                    }
                    
                    else if (row == 0 && col == -5) {
                        difference() {
                            board_locked_tile(row, col);
                        }
                    }
                    
                    else if (row == 5 && col == -5) {
                        difference() {
                            board_locked_tile(row, col);
                        }
                    }
                    
                    else {
                        board_ridge(row, col);
                    }
                }
            }
        }
        
        start_circle(5, 0);
        start_12star(0, 5);
        start_disc(-5, 5);
        start_24star(-5, 0);
        start_hex(0, -5);
        start_6star(5, -5);
    }
}

module segment_key(rot, pos, mirror=false) {
    rotate([0,0,rot])
    translate([0,-segment_key_radius/2 + pos,0])
    mirror([mirror?1:0,0,0])
    union() {
        translate([-0.1,0,0])
        cube([segment_key_length+0.1,segment_key_radius,segment_key_height]);
        
        translate([segment_key_length,segment_key_radius/2,0])
        cylinder(segment_key_height, r=segment_key_radius);
    }
}

module segment_socket(rot, pos, mirror=false) {
    rotate([0,0,rot])
    translate([0,-segment_key_radius/2 + pos,0])
    mirror([mirror?1:0,0,0])
    union() {
        cube([segment_key_length,segment_key_radius+segment_key_clearance,segment_key_height+segment_key_clearance]);
        
        translate([segment_key_length,segment_key_radius/2,0])
        cylinder(segment_key_height+segment_key_clearance, r=segment_key_radius+segment_key_clearance);
    }
}

module ne_board() {
    union() {
        difference() {
            intersection() {
                board();
                rotate([0,0,45])
                translate([segment_clearance,segment_clearance,0])
                cube(300);
            }
        
            segment_socket(45, 55);
            segment_socket(45, 155);
            segment_socket(-45, 50, true);
            segment_socket(-45, 150, true);
        }
    }
}

module se_board() {
    union() {
        difference() {
            intersection() {
                board();
                rotate([0,0,45])
                translate([segment_clearance,-300-segment_clearance,0])
                cube(300);
            }
        }
                
        segment_key(-45, 50, true);
        segment_key(-45, 150, true);
        segment_key(225, 45);
        segment_key(225, 145);
    }
}

module sw_board() {
    union() {
        difference() {
            intersection() {
                board();
                rotate([0,0,45])
                translate([-300-segment_clearance,-300-segment_clearance,0])
                cube(300);
            }
        
            segment_socket(225, 45);
            segment_socket(225, 145);
            segment_socket(135, 40, true);
            segment_socket(135, 140, true);
        }
    }
}

module nw_board() {
    union() {
        difference() {
            intersection() {
                board();
                rotate([0,0,45])
                translate([-300-segment_clearance,segment_clearance,0])
                cube(300);
            }
        }
            
        segment_key(90, 40, true);
        segment_key(90, 140, true);
        segment_key(0, 55);
        segment_key(0, 155);
    }
}

module segmentn_board(segments=4, off=0, show=[1:4]) {
    rotate_by = 360 / segments;
    for (segment = show) {
        union() {
            difference() {
                intersection() {
                    board();
                    rotate([0,0,off+segment*rotate_by])
                    translate([segment_clearance,segment_clearance,0])
                    linear_extrude(board_radius*2)
                    polygon([
                        [0,0],
                        [0,board_radius*2],
                        [sin(rotate_by)*board_radius*2,cos(rotate_by)*board_radius*2]
                    ]);
                }
                
                if (segment % 2 == 1) {
                    segment_socket(off+segment*rotate_by, 50 + (segment-1)*5);
                    segment_socket(off+segment*rotate_by, 150);
                    segment_socket(off+(segment-1)*rotate_by, 50, true);
                    segment_socket(off+(segment-1)*rotate_by, 150, true);
                }
            }
            
            if (segment % 2 == 0) {
                segment_key(off+segment*rotate_by, 50, true);
                segment_key(off+segment*rotate_by, 150, true);
                segment_key(off+(segment-1)*rotate_by, 50+(segment-2)*5);
                segment_key(off+(segment-1)*rotate_by, 150);
            }
        }
    }
}

module test_print1() {
    intersection() {
        board();
        translate([100,-60,0])
        cube(120, 120, 120);
    }
}

module test_print2() {
    intersection() {
        ne_board();
        translate([100,-60,0])
        cube(120, 120, 120);
    }
}

module test_print3() {
    intersection() {
        se_board();
        translate([100,-60,0])
        cube(120, 120, 120);
    }
}

//test_print1();
//test_print2();
//test_print3();
//board();
//ne_board();
//se_board();
//sw_board();
//nw_board();
segmentn_board(6, 0, [1:6]);