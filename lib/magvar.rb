require 'date'

module Magvar
  extend self
  M_PI = Math::PI

  def magvar(lat_rad, lon_rad, time, h)
    nmax = 12
    
    # should contain the number of Julian days
    # http://stackoverflow.com/questions/23034993
    dat = time.to_date.amjd.to_i
    
    a = 6378.137       # semi-major axis (equatorial radius) of WGS84 ellipsoid */
    b = 6356.7523142   # semi-minor axis referenced to the WGS84 ellipsoid */
    r_0 = 6371.2	      # standard Earth magnetic reference radius  */
    gnm_wmm2015 = [
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [-29438.5, -1501.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [-2445.3, 3012.5, 1676.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [1351.1, -2352.3, 1225.6, 581.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [907.2, 813.7, 120.3, -335.0, 70.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [-232.6, 360.1, 192.4, -141.0, -157.4, 4.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [69.5, 67.4, 72.8, -129.8, -29.0, 13.2, -70.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [81.6, -76.1, -6.8, 51.9, 15.0, 9.3, -2.8, 6.7, 0.0, 0.0, 0.0, 0.0, 0.0],
        [24.0, 8.6, -16.9, -3.2, -20.6, 13.3, 11.7, -16.0, -2.0, 0.0, 0.0, 0.0, 0.0],
        [5.4, 8.8, 3.1, -3.1, 0.6, -13.3, -0.1, 8.7, -9.1, -10.5, 0.0, 0.0, 0.0],
        [-1.9, -6.5, 0.2, 0.6, -0.6, 1.7, -0.7, 2.1, 2.3, -1.8, -3.6, 0.0, 0.0],
        [3.1, -1.5, -2.3, 2.1, -0.9, 0.6, -0.7, 0.2, 1.7, -0.2, 0.4, 3.5, 0.0],
        [-2.0, -0.3, 0.4, 1.3, -0.9, 0.9, 0.1, 0.5, -0.4, -0.4, 0.2, -0.9, 0.0],
    ]

    hnm_wmm2015 = [
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 4796.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -2845.6, -642.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -115.3, 245.0, -538.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 283.4, -188.6, 180.9, -329.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 47.4, 196.9, -119.4, 16.1, 100.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -20.7, 33.2, 58.8, -66.5, 7.3, 62.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -54.1, -19.4, 5.6, 24.4, 3.3, -27.5, -2.3, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 10.2, -18.1, 13.2, -14.6, 16.2, 5.7, -9.1, 2.2, 0.0, 0.0, 0.0, 0.0],
        [0.0, -21.6, 10.8, 11.7, -6.8, -6.9, 7.8, 1.0, -3.9, 8.5, 0.0, 0.0, 0.0],
        [0.0, 3.3, -0.3, 4.6, 4.4, -7.9, -0.6, -4.1, -2.8, -1.1, -8.7, 0.0, 0.0],
        [0.0, -0.1, 2.1, -0.7, -1.1, 0.7, -0.2, -2.1, -1.5, -2.5, -2.0, -2.3, 0.0],
        [0.0, -1.0, 0.5, 1.8, -2.2, 0.3, 0.7, -0.1, 0.3, 0.2, -0.9, -0.2, 0.7],
    ]

    gtnm_wmm2015 = [
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [10.7, 17.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [-8.6, -3.3, 2.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [3.1, -6.2, -0.4, -10.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [-0.4, 0.8, -9.2, 4.0, -4.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [-0.2, 0.1, -1.4, 0.0, 1.3, 3.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [-0.5, -0.2, -0.6, 2.4, -1.1, 0.3, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.2, -0.2, -0.4, 1.3, 0.2, -0.4, -0.9, 0.3, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 0.1, -0.5, 0.5, -0.2, 0.4, 0.2, -0.4, 0.3, 0.0, 0.0, 0.0, 0.0],
        [0.0, -0.1, -0.1, 0.4, -0.5, -0.2, 0.1, 0.0, -0.2, -0.1, 0.0, 0.0, 0.0],
        [0.0, 0.0, -0.1, 0.3, -0.1, -0.1, -0.1, 0.0, -0.2, -0.1, -0.2, 0.0, 0.0],
        [0.0, 0.0, -0.1, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1, -0.1, 0.0],
        [0.1, 0.0, 0.0, 0.1, -0.1, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ]

    htnm_wmm2015 = [
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -26.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -27.1, -13.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 8.4, -0.4, 2.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -0.6, 5.3, 3.0, -5.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 0.4, 1.6, -1.1, 3.3, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, -2.2, -0.7, 0.1, 1.0, 1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, 0.7, 0.5, -0.2, -0.1, -0.7, 0.1, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -0.3, 0.3, 0.3, 0.6, -0.1, -0.2, 0.3, 0.0, 0.0, 0.0, 0.0, 0.0],
        [0.0, -0.2, -0.1, -0.2, 0.1, 0.1, 0.0, -0.2, 0.4, 0.3, 0.0, 0.0, 0.0],
        [0.0, 0.1, -0.1, 0.0, 0.0, -0.2, 0.1, -0.1, -0.2, 0.1, -0.1, 0.0, 0.0],
        [0.0, 0.0, 0.1, 0.0, 0.1, 0.0, 0.0, 0.1, 0.0, -0.1, 0.0, -0.1, 0.0],
        [0.0, 0.0, 0.0, -0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ]
    
  	# Convert degree to radian
  	lat = lat_rad
  	lon = lon_rad
    
    #double SGMagVarOrig( double lat, double lon, double h, long dat, double* field )
    #{
    #    /* output field t_B_r,B_th,t_B_phi,B_x,B_y,B_z */
    #    int n,m;
    n, m = 0, 0
    #    /* reference dates */
    #    long date0_wmm2015 = yymmdd_to_julian_days(5,1,1);
    date0_wmm2015 = yymmdd_to_julian_days(5,1,1)
    #
    #    double yearfrac,sr,r,theta,c,s,psi,fn,t_B_r,t_B_theta,t_B_phi,X,Y,Z;
    
    #
    #    /* convert to geocentric coords: */
    #    sr = sqrt(pow(a*cos(lat),2.0)+pow(b*sin(lat),2.0));
    sr = sqrt(pow(a*cos(lat),2.0)+pow(b*sin(lat),2.0));
    #    /* sr is effective radius */
    theta = atan2(cos(lat) * (h * sr + a * a),
    		  sin(lat) * (h * sr + b * b));
    #    /* theta is geocentric co-latitude */
    #
    r = h * h + 2.0*h * sr +
     	(pow(a,4.0) - (pow(a,4.0) - pow(b,4.0)) * pow(sin(lat),2.0)) /
     	(a * a - (a * a - b * b) * pow(sin(lat),2.0))
    r = sqrt(r);
    #
    #    /* r is geocentric radial distance */
    c = cos(theta);
    s = sin(theta);
    
    #
    #    /* zero out arrays */
    #    for ( n = 0; n <= nmax; n++ ) {
    #	for ( m = 0; m <= n; m++ ) {
    #	    P[n][m] = 0;
    #	    DP[n][m] = 0;
    #	}
    #    }
    p_P   = [[0.0] * 13] * 13
    p_DP  = [[0.0] * 13] * 13
    gnm   = [[0.0] * 13] * 13
    hnm   = [[0.0] * 13] * 13
    sm    = [0.0] * 13
    cm    = [0.0] * 13
    
    #
    #    /* diagonal elements */
    p_P[0][0] = 1.0;
    p_P[1][1] = s;
    p_DP[0][0] = 0.0;
    p_DP[1][1] = c;
    p_P[1][0] = c;
    p_DP[1][0] = -s;
    #
    #    for ( n = 2; n <= nmax; n++ ) {
    #	P[n][n] = P[n-1][n-1] * s * sqrt((2.0*n-1) / (2.0*n));
    #	DP[n][n] = (DP[n-1][n-1] * s + P[n-1][n-1] * c) *
    #	    sqrt((2.0*n-1) / (2.0*n));
    #    }
    (2..nmax).each do |n|
      p_P[n][n] = p_P[n-1][n-1] * s * sqrt((2.0*n-1) / (2.0*n));
      p_DP[n][n] = (p_DP[n-1][n-1] * s + p_P[n-1][n-1] * c) *
        sqrt((2.0*n-1) / (2.0*n));
    end
    #    /* lower triangle */
    #    for ( m = 0; m <= nmax; m++ ) {
    #	for ( n = SG_MAX2(m + 1, 2); n <= nmax; n++ ) {
    #	    P[n][m] = (P[n-1][m] * c * (2.0*n-1) - P[n-2][m] *
    #		       sqrt(1.0*(n-1)*(n-1) - m * m)) /
    #		sqrt(1.0* n * n - m * m);
    #	    DP[n][m] = ((DP[n-1][m] * c - P[n-1][m] * s) *
    #			(2.0*n-1) - DP[n-2][m] *
    #			sqrt(1.0*(n-1) * (n-1) - m * m)) /
    #		sqrt(1.0* n * n - m * m);
    #	}
    #    }
    (0..nmax).each do |m|
      local_nmax = [m+1, 2].sort.last
      (local_nmax..nmax).each do |n|
    	  p_P[n][m] = (p_P[n-1][m] * c * (2.0*n-1) - p_P[n-2][m] *
    		  sqrt(1.0*(n-1)*(n-1) - m * m)) /
    		  sqrt(1.0* n * n - m * m);
    	  p_DP[n][m] = ((p_DP[n-1][m] * c - p_P[n-1][m] * s) *
    			(2.0*n-1) - p_DP[n-2][m] *
    			sqrt(1.0*(n-1) * (n-1) - m * m)) /
    		  sqrt(1.0* n * n - m * m);
      end
    end
    #    /* compute gnm, hnm at dat */
    #    /* WMM2015 */
    #    yearfrac = (dat - date0_wmm2015) / 365.25;
    #    for ( n = 1; n <= nmax; n++ ) {
    #	for ( m = 0; m <= nmax; m++ ) {
    #	    gnm[n][m] = gnm_wmm2015[n][m] + yearfrac * gtnm_wmm2015[n][m];
    #	    hnm[n][m] = hnm_wmm2015[n][m] + yearfrac * htnm_wmm2015[n][m];
    #	}
    #    }
    yearfrac = (dat - date0_wmm2015).to_i / 365.25;
    (1..nmax).each do |n|
      (0..nmax).each do |m|
  	    gnm[n][m] = gnm_wmm2015[n][m] + yearfrac * gtnm_wmm2015[n][m];
  	    hnm[n][m] = hnm_wmm2015[n][m] + yearfrac * htnm_wmm2015[n][m];
      end
    end

    #
    #    /* compute sm (sin(m lon) and cm (cos(m lon)) */
    #    for ( m = 0; m <= nmax; m++ ) {
    #	sm[m] = sin(m * lon);
    #	cm[m] = cos(m * lon);
    #    }
    (0..nmax).each do |m|
      sm[m] = sin(m * lon);
      cm[m] = cos(m * lon);
    end
    #
    #    /* compute B fields */
    #    t_B_r = 0.0;
    #    t_B_theta = 0.0;
    #    t_B_phi = 0.0;
    t_B_r = 0.0;
    t_B_theta = 0.0;
    t_B_phi = 0.0;
    #
    #    for ( n = 1; n <= nmax; n++ ) {
    #	double c1_n=0;
    #	double c2_n=0;
    #	double c3_n=0;
    #	for ( m = 0; m <= n; m++ ) {
    #	    c1_n=c1_n + (gnm[n][m] * cm[m] + hnm[n][m] * sm[m]) * P[n][m];
    #	    c2_n=c2_n + (gnm[n][m] * cm[m] + hnm[n][m] * sm[m]) * DP[n][m];
    #	    c3_n=c3_n + m * (gnm[n][m] * sm[m] - hnm[n][m] * cm[m]) * P[n][m];
    #	}
    #	fn=pow(r_0/r,n+2.0);
    #	t_B_r = t_B_r + (n + 1) * c1_n * fn;
    #	t_B_theta = t_B_theta - c2_n * fn;
    #	t_B_phi = t_B_phi + c3_n * fn / s;
    #    }
    
    (1..nmax).each do |n|
      c1_n = 0.0
      c2_n = 0.0
      c3_n = 0.0
      (0..n).each do |m|
        c1_n=c1_n + (gnm[n][m] * cm[m] + hnm[n][m] * sm[m]) * p_P[n][m];
        c2_n=c2_n + (gnm[n][m] * cm[m] + hnm[n][m] * sm[m]) * p_DP[n][m];
        c3_n=c3_n + m * (gnm[n][m] * sm[m] - hnm[n][m] * cm[m]) * p_P[n][m];
      end
      fn=pow(r_0/r,n+2.0);
      t_B_r = t_B_r + (n + 1) * c1_n * fn;
      t_B_theta = t_B_theta - c2_n * fn;
      t_B_phi = t_B_phi + c3_n * fn / s;
    end

    #    /* Find geodetic field components: */
    #    psi = theta - (pi / 2.0 - lat);
    #    X = -t_B_theta * cos(psi) - t_B_r * sin(psi);
    #    Y = t_B_phi;
    #    Z = t_B_theta * sin(psi) - t_B_r * cos(psi);
    psi = theta - (Math::PI / 2.0 - lat);
    p_X = -t_B_theta * cos(psi) - t_B_r * sin(psi);
    p_Y = t_B_phi;
    p_Z = t_B_theta * sin(psi) - t_B_r * cos(psi);

    #
    #    field[0]=t_B_r;
    #    field[1]=t_B_theta;
    #    field[2]=t_B_phi;
    #    field[3]=X;
    #    field[4]=Y;
    #    field[5]=Z;   /* output fields */
    #
    #    /* find variation, leave in radians! */
    #    return atan2(Y, X);  /* E is positive */
    atan2(p_Y, p_X)
  end
  
  private
  
  # Convert date to Julian day    1950-2049 */
  def yymmdd_to_julian_days(yy, mm, dd)
    yy = (yy < 50) ? (2000 + yy) : (1900 + yy);
    jd = dd - 32075 + 1461 * (yy + 4800 + (mm - 14) / 12 ) / 4;
    jd = jd + 367 * (mm - 2 - (mm - 14) / 12*12) / 12;
    jd = jd - 3 * ((yy + 4900 + (mm - 14) / 12) / 100) / 4;
    jd
  end

  def sqrt(*v)
    Math.sqrt(*v)
  end

  def cos(v)
    Math.cos(v)
  end
  
  def atan2(*a)
    Math.atan2(*a)
  end
  
  def sin(*a)
    Math.sin(*a)
  end
  
  def pow(m, exp)
    m ** exp
  end
end
