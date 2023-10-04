
include <mods.scad>

difference () {
     color([0,0,1,0.5]) bracket ();
     color([0,1,0,1]) translate ( [0, -BOLT_HEAD_HIG, 0] ) rotate ( [-90, 0, 0] ) bolt_hole ();
}
