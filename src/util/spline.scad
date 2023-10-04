//////////////////////////
//
//  util/spline.scad
//
//  Some functions for generating spline curves using
//  control points and the slope of the tangent line at
//  those points. Then generating a ribbon (sheet) that
//  follows this curve with a fixed width.
//
//  Author: Dharshan Chandramohan
//

function cubic_spline_pts(x1, y1, x2, y2, m1, m2, npts=100) =
     let ( xpts = [ for (xi = [0:npts]) x1 + xi * (x2 - x1) / npts ],
	   a = (m1 + m2 - (2 * ((y2 - y1) / (x2 - x1)))) / pow((x1 - x2), 2),
	   b = ((m2 - m1) / (2 * (x2 - x1))) - (1.5 * (x1 + x2) * a),
	   c = m1 - (3 * x1 * x1 * a) - (2 * x1 * b),
	   d = y1 - (x1 * x1 * x1 * a) - (x1 * x1 * b) - (x1 * c) )

     [ for (xi = xpts) [xi, a*pow(xi,3)+b*pow(xi,2)+c*xi+d] ];

module cubic_spline_sheet(x1, y1, x2, y2, m1, m2, thk, wid) {
    linear_extrude(height=wid) {
        let (
            a = cubic_spline_pts(x1, y1, x2, y2, m1, m2),
            b = [ for (ai = [(len(a)-1):-1:0]) [ a[ai][0], a[ai][1] + thk ] ]
        )
        polygon(points = concat(a, b), convexity = 2);
    }
}

