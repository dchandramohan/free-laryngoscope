///////////////////////////////////////
//
//  Mod to add an articulated phone mount to the laryngoscope
// 
//  (C) 2021-07-13, D. Chandramohan
//
//

// bolt dimensions
BOLT_SHANK_DIA = 6.35; // mm = 1/4 in
BOLT_SHANK_LEN = 6.35 * 3; // mm (3/4 in length)
BOLT_HEAD_HIG = 4; // mm
BOLT_HEAD_DIA = 6.35 * 2; // mm (~0.5 in)

// bolt hole
tol = 1; // mm overhang (so no edge issues)
module bolt_hole () {
     union () {
	  translate ( [ 0, 0, (BOLT_HEAD_HIG + tol)/2 ] ) cylinder ( h = BOLT_HEAD_HIG + tol,
								     r = (BOLT_HEAD_DIA + tol) / 2,
								     center = true);
	  translate ( [ 0, 0, -(BOLT_SHANK_LEN + tol)/2 ] ) cylinder ( h = BOLT_SHANK_LEN + 2 * tol,
								       r = (BOLT_SHANK_DIA + 0.65) / 2, // tighter tolerance
								       center = true);
     }
}

// bracket
FRAME_THK = 6.35 * 3/4; // mm (3/16 in)
PHONE_THK = 10; // mm (a bit larger than average)
module bracket () {
     linear_extrude ( height = 2 * BOLT_HEAD_DIA,
		      center = true,
		      convexity = 10,
		      twist = 0 ) polygon ( points = [
						 [ BOLT_HEAD_DIA, 0],
						 [ -BOLT_HEAD_DIA, 0],
						 [ -BOLT_HEAD_DIA, PHONE_THK],
						 [ 0, PHONE_THK + 2 *FRAME_THK],
						 [ 0, PHONE_THK + 3 * FRAME_THK],
						 [ -BOLT_HEAD_DIA - FRAME_THK, PHONE_THK + FRAME_THK],
						 [ -BOLT_HEAD_DIA - FRAME_THK, -BOLT_HEAD_HIG * 2],
						 [ BOLT_HEAD_DIA, -BOLT_HEAD_HIG * 2] ] );
}

// rail
RAIL_LENGTH = 100; // mm, 10 cm
RAIL_WIDTH = 2 * BOLT_HEAD_DIA;
module rail () {
     union () {
	  // rail body
	  difference () {
	       cube ( [RAIL_LENGTH, RAIL_WIDTH, BOLT_HEAD_HIG], center=true );
	       union () {
		    translate ( [(RAIL_LENGTH/2) - 2*BOLT_SHANK_DIA, 0, 0] )
			 cylinder ( h = BOLT_SHANK_LEN,
				    r = (BOLT_SHANK_DIA + 0.65) / 2,
				    center = true );
		    translate ( [-(RAIL_LENGTH/2) + 2*BOLT_SHANK_DIA, 0, 0] )
			 cylinder ( h = BOLT_SHANK_LEN,
				    r = (BOLT_SHANK_DIA + 0.65) / 2,
				    center = true );
		    cube ( [RAIL_LENGTH - 4*BOLT_SHANK_DIA, BOLT_SHANK_DIA + 0.65, BOLT_HEAD_HIG + 2], center = true );
	       }
	  }
	  // connector bolt hole
	  translate ( [-RAIL_LENGTH/2 - (3*BOLT_HEAD_DIA/4), RAIL_WIDTH/2 - BOLT_HEAD_HIG, 0] ) rotate ( [90, 0, 0] )
	       difference () {
	       cylinder ( r = BOLT_HEAD_DIA,
			  h = 2 * BOLT_HEAD_HIG,
			  center = true );
	       bolt_hole ();
	  }
     }
}
