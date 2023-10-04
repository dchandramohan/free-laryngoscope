/////////////////////////////////
//
//  Full Laryngoscope Model with Mac Blade
//
//  Author: Dharshan Chandramohan
//  Date: 2022-09-04
//

include <../blade/mac3_blade.scad>
include <../mods/mods.scad>

handle_axis_ctr = [
     tongue_control_pts[0][0][0]/2,
     -(full_width/2) + flange_width, 0];

module handle () {
     union () {
	  cylinder(d=15, h=120, $fn=100); // connecting cylinder
	  translate([0, 0, 20]) cylinder(d=30, h=5, $fn=100);
	  translate([0, 0, 20]) cylinder(d=20, h=100, $fn=100);
	  translate([0, 0, 115]) cylinder(d=30, h=5, $fn=100);

	  // bolt hole for rail attachment
	  translate([0, -2.4, 115])
	    rotate([0,-30,0])
	    difference () {
	    union () {
	      translate([0,0,10])cube([20, 5, 20], center=true);
	      rotate([90,0,0]) translate([0,20,0]) cylinder(r=10, h=5, $fn=100, center=true);
	    }
	    rotate([90,0,0]) translate([0,20,0]) cylinder(d=BOLT_SHANK_DIA, h=100, $fn=100, center=true);
	  }
     }
}

rotate([-90, 0, 0])
translate(handle_axis_ctr)
handle();
