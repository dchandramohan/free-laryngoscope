//////////////////////////////////////////
//
//  Mac Laryngoscope Blade
//
//  Author: Dharshan Chandramohan
//  Date: 2022-09-04
//

use <../util/spline.scad>

tongue_control_pts = [
     [[18.5, 6], 0],
     [[38, 0], -5/11],
     [[82.5, 0], 5/17.5],
     [[120.5, 19.5], 2/3],
     [[128.5, 25], 2/3] ];

flange_control_pts = [
     [[0, 0], -10/19],
     [[61.5, -15], 2/97],
     [[108, 0], 4/6.5],
     [[128.5, 25], 19/15] ];

blade_len = 128.5; // max length of the blade

blade_thk = 3.2; // rounded to nearest multiple of 0.4 for printer resolution

full_width = 28.16;
tongue_width = 20.00;// full_width - flange_width; previously variable
flange_width = full_width - tongue_width; // 6.54; previously fixed...

base_blk_ht = 15;
minkowski_kernel_wid = 0.8; // in the future maybe round/smooth some edges

// vertical support width
v_sup_wid = 1.2 * blade_thk;

camera_box_wid = 10.8;
camera_box_pos = 94.29;

// cylindrical "finial" on end of blade tongue
end_finial_radius = blade_thk * 0.45;

// *** "FOOTPRINT" *** : set of control points to establish the taper of the blade
//                       when viewed from the bottom/top
end_taper = 18.82; // mm width of blade at the end
tongue_side_pts = cubic_spline_pts(0, // x1
				   -tongue_width, // z1
				   blade_len, // x2
				   -end_taper, // z2
				   0, // flat at blade base
				   (tongue_width - end_taper)/(blade_len/3.0)); // estimate slope at endpoint of taper using secant line slope (will introduce more aggressive taper, but temporary)
flange_side_pts = cubic_spline_pts(0,
				   flange_width,
				   blade_len,
				   0,
				   0,
				   -flange_width/(blade_len/4.0));
footprint_poly_pts = concat(tongue_side_pts, [ for (ai = [(len(flange_side_pts)-1):-1:0]) [flange_side_pts[ai][0], flange_side_pts[ai][1]] ]);
module footprint_volume () {
  rotate([-90, 0, 0])
    translate([0, 0, -100])
    linear_extrude(height=200) polygon(points = footprint_poly_pts, convexity = 2);
}

module piecewise_cubic_spline_sheet(ctrl_pts, thk, wid) {
     union () {
	  for (ii = [0: len(ctrl_pts) - 2]) {
	       cubic_spline_sheet(ctrl_pts[ii][0][0], ctrl_pts[ii][0][1],
				  ctrl_pts[ii+1][0][0], ctrl_pts[ii+1][0][1],
				  ctrl_pts[ii][1], ctrl_pts[ii+1][1], thk, wid);
	  }
     }
}

module blade_tongue () {
     piecewise_cubic_spline_sheet(tongue_control_pts, blade_thk, tongue_width);
}

module blade_flange () {
     piecewise_cubic_spline_sheet(flange_control_pts, blade_thk, flange_width);
}


module vertical_support (wid) {
     linear_extrude(height = wid) { // this is a bit of a heuristic/hack (fix later)
	  let ( b_ctrl_pts = flange_control_pts,
		t_ctrl_pts = [ for (ai = [(len(tongue_control_pts)-1):-1:0]) tongue_control_pts[ai] ],
		bottom = [ for (ii = [0: len(b_ctrl_pts) - 2]) each cubic_spline_pts(b_ctrl_pts[ii][0][0],
										     b_ctrl_pts[ii][0][1],
										     b_ctrl_pts[ii+1][0][0],
										     b_ctrl_pts[ii+1][0][1],
										     b_ctrl_pts[ii][1],
										     b_ctrl_pts[ii+1][1]) ],
		top = [ for (ii = [0: len(t_ctrl_pts) - 2]) each cubic_spline_pts(t_ctrl_pts[ii][0][0],
										  t_ctrl_pts[ii][0][1] + blade_thk,
										  t_ctrl_pts[ii+1][0][0],
										  t_ctrl_pts[ii+1][0][1] + blade_thk,
										  t_ctrl_pts[ii][1],
										  t_ctrl_pts[ii+1][1]) ] )
	       polygon(points = concat(bottom,top), convexity = 2);
     }
}

// channel for camera cable with angled viewport
camera_angle = 15;
camera_dia = 5;
module camera_channel () {
  difference() {
     intersection () {
	  vertical_support (camera_box_wid);
	  rotate([0, 0, camera_angle])
	    translate([0, -camera_box_pos*sin(camera_angle)-50, -50])
	      cube([camera_box_pos*cos(camera_angle), 200, 100]);
     }
     rotate([0, 90, camera_angle])
       translate([-camera_box_wid/2, -camera_box_pos*sin(camera_angle)-1, 0])
       cylinder(d=camera_dia+1, h=200, $fn=100);
  }
}

module blade () {
  union () {
    intersection () {
      union () {
	blade_tongue();
	
	translate([0, 0, -flange_width]) blade_flange();
	translate([0, 0, -blade_thk]) vertical_support(v_sup_wid);
	camera_channel();
	
	translate([0,0, -flange_width]) cube([tongue_control_pts[0][0][0], base_blk_ht, full_width]);
      }
      footprint_volume ();
    }
    
    // cylindrical "finial"
    let(ctrl_pts = tongue_control_pts)
      translate([ctrl_pts[len(ctrl_pts)-1][0][0], ctrl_pts[len(ctrl_pts)-1][0][1] + blade_thk/2.0, 0])
      minkowski () {
      sphere(r=minkowski_kernel_wid);
      cylinder(r=end_finial_radius, h=end_taper, $fn=100);
    }
  }
}

blade();
