package SatelliteTracking
  model Satellite

    constant Real pi = Modelica.Constants.pi;
    constant Real d2r = Modelica.Constants.D2R;
    constant Real k2 = 2.2005645e4 "0.5J2Re^2 (km2)";
    constant Real Gconst = 398600.4;
    
    parameter Real M0 "Mean anomaly at Epoch (deg)";
    parameter Real N0 "Mean motion at Epoch (rev/d)";
    parameter Real eccn "Eccentricity";
    parameter Real Ndot2 "1st Der Mean Motion over 2 (rev/d2)";
    parameter Real Nddot6 "2nd Der Mean Motion over 6 (rev/d3)";

    parameter Real raan0 "Right Ascension Ascending Node at Epoch (deg)";
    parameter Real argper0 "Argument of Perigee at Epoch (deg)";
    parameter Real incl "Inclination angle (deg)";
    parameter Real tstart "Time from ref epoch to start of sim (sec)";
    
    Real M "Mean Anomaly (deg)";
    Real N "Mean Motion (rev/d)";
    Real E "Eccentric Anomaly (deg)";
    Real theta "true anomaly (deg)";
    Real a "Semi-major axis (km)";
    Real a0 = (398600.4 * 86400 ^ 2 / 4 / pi ^ 2 / N0 ^ 2) ^ (1 / 3) "Semi-major axis at Epoch";
    Real raan "Right Ascension Ascending Node (deg)";
    Real argper "Argument of Perigee (deg)";
    Real r "Satellite radial distance (km)";
    Real rotang[3] "TODO: fill in the angles here";
    Real p_sat_pf[3] "Satellite posn in pf coords (km)";
    Real v_sat_pf[3] "Satellite vel in pf coords (km/s)";
    
  initial equation
// Keplerian Orbital Elements
    a = a0;
    incl = incl;
    M = (M0 + N0*(360/86400)*tstart + 360*Ndot2*(tstart/86400)^2 + 360*(Nddot6)*(tstart/86400)^3)+1.09;
    N = N0 + 2 * Ndot2 * (time / 86400. ^ 2) + 3 * Nddot6 * (time ^ 2 / 86400. ^ 3);
    argper = argper0 + (3. * k2 * (5. * cos(incl  * d2r)^2 - 1.) * (N0 * 360. / 86400.)/ tstart * (a^2 * (1. - eccn^2)^2));
    raan = raan0 +  (3. * k2 * cos(incl  * d2r) * (N0 * 360. / 86400.) / tstart * (a^2 * (1. - eccn^2)^2));
    
  equation
    M * d2r = E * d2r - eccn * sin(E * d2r);
    der(M) = N0 * 360. * (360. / 86400.) + 2 * Ndot2 * (time / 86400. ^ 2) + 3 * 360. * Nddot6 * (time ^ 2 / 86400. ^ 3);
    tan(theta * d2r / 2.) = sqrt((1. + eccn) / (1. - eccn)) * tan(E * d2r / 2.);
    r = a * (1. - eccn ^ 2) / (1. + eccn * cos(theta * d2r));
    N = 86400 / (2. * pi) * sqrt(Gconst / a ^ 3);
    der(N) = 2 * 360. * Ndot2 * (1 / 86400. ^ 2) + 6 * 360. * Nddot6 * (time / 86400. ^ 3);  
       
    p_sat_pf[1] = r * cos(theta * d2r);
    p_sat_pf[2] = r * sin(theta * d2r);
    p_sat_pf[3] = 0.;
    
    der(p_sat_pf[1]) = v_sat_pf[1];
    der(p_sat_pf[2]) = v_sat_pf[2];
    der(p_sat_pf[3]) = v_sat_pf[3];
    
    der(raan) = (N * 360. / 86400.) * (3. * k2 * cos(incl  * d2r) / (a^2 * (1 - eccn^2)^2));
    der(argper) = (N * 360. / 86400.) * (3. * k2 * (5. * cos(incl  * d2r)^2 - 1) / (a^2 * (1 - eccn^2)^2));
    rotang[1] = -argper / d2r;
    rotang[2] = -incl / d2r;
    rotang[3] = -raan / d2r;
   
    
  end Satellite;

  model Station
      import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.axesRotations;
      import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
      constant Real Re = 6378.137 "Earth radius (km)";
      constant Real f = 1 / 298.257223563 "Earth ref ellipsoid flattening";
      constant Real ecc_e_sq = 2 * f - f ^ 2 "Square of earth eccentricity";
      constant Real d2r = Modelica.Constants.D2R;
      
      parameter Real stn_long "Station longitude (degE)";
      parameter Real stn_lat "Station latitude (degN)";
      parameter Real stn_elev "Station elevation (m)";
      
      
      Real p_stn_topo[3] "Station coordinates in TOPO";
      Real p_stn_ECF[3] "Station coordinates in ECF (km)";
      Real N_phi;
      Real TM[3, 3] "Transform matrix from ECF to topo";
      
      Integer seq[3] = {3, 1, 3};
      Real ang[3] = {-(stn_long * d2r), -(stn_lat * d2r), -(90 * d2r)};
  
    equation
      N_phi = Re / sqrt(1. - sin(stn_lat * d2r) ^ 2 * ecc_e_sq);
      p_stn_ECF[1] = (cos(stn_lat * d2r * N_phi + stn_elev * 10. ^ (-3)) ) * cos(stn_long * d2r);
      p_stn_ECF[2] = (cos(stn_lat * d2r) * N_phi + stn_elev * 10. ^ (-3)) * sin(stn_long * d2r);
      p_stn_ECF[3] = (1. - ecc_e_sq) * sin(stn_lat * d2r) * N_phi;
      TM = axesRotations(seq, ang);
      p_stn_topo = resolve2(TM, p_stn_ECF);
  
  end Station;

  model Testing
  //TEST CASE
    //COSMOS 2485 (747)
    //TLE parameters
    //1 39155U 13019A   19061.75354861 -.00000038  00000-0  00000+0 0  9994
    //2 39155  64.6665 163.3110 0018561 233.7464  42.2514  2.1310183745523
  SatelliteTracking.Satellite PlotTest(M0=42.2514,N0=2.1310183745523,eccn=0.0018561,
                                Ndot2=-0.00000038,Nddot6=0.,raan0=163.3110,
                                argper0=233.7464,incl=64.6665,tstart = 0.000001);
  
   Real M;
   Real N;
   Real E;
   Real r;
   Real theta;
   Real px;
   Real py;
   Real vx;
   Real vy;
   Real raan;
   Real argper;
  
  equation
   M = mod(PlotTest.M,360);
   N = PlotTest.N;
   E = PlotTest.E;
   r = PlotTest.r;
   theta = PlotTest.theta;
   px = PlotTest.p_sat_pf[1];
   py = PlotTest.p_sat_pf[2];
   vx = PlotTest.v_sat_pf[1];
   vy = PlotTest.v_sat_pf[2];
   raan = PlotTest.raan;
   argper = PlotTest.argper;
  
  end Testing;

  function sat_ECI "Converts Peri-focal coordinates to ECI"
    // Function to calculate the current satellite trajectory in ECI coordinates.
    // Author : Matthieu
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.axesRotations;
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
  
    input Real ang[3] "-argper, -inc, -raan (rad)";
    input Real p_pf[3] "Posn vector in Perifocal coords (km)";
    input Real v_pf[3] "Velocity vector in Perifocal coords (km/s)";
    
    output Real p_ECI[3] "Posn vector in ECI coords (km)";
    output Real v_ECI[3] "Velocity vector in ECI coords (km/s)";
    
    protected
      Integer seq[3] = {3,1,3} "Angle sequence from pf to ECI";
      Real TM[3, 3]= axesRotations(sequence=seq, angles=ang);
    
    algorithm
      p_ECI := resolve2(TM, p_pf);
      v_ECI := resolve2(TM, v_pf);
  
  end sat_ECI;

  function theta_d "Calculates GMST angle"
    // Function to calculate the Greenwich Mean Sidereal Time in degrees
    // Author : Matthieu
    input Real days "Number of days from J2000 to start of day in question";
    input Real hours "hours from midnight of the day in question to time in question";
  
    output Real GMST "GMST angle (deg)";
  
    protected
      Real Tuu = days/36525;
      Real d2r = Modelica.Constants.D2R;
  
    algorithm
      D_0 := days;
      GMST_h := 6.697374558 + 0.06570982441906*D_0 + 1.00273790935*hours + 0.000026*T_u^2;
      GMST_d := GMST_h * 15;
      GMST := mod(GMST_d, 360);

  end theta_d;
  
  function sat_ECF "Converts ECI to ECF coordinates"
    // Function to calculate the current satellite position and velocity in ECF coordinates
    // Author : Matthieu Durand
    // Can test using the dcmeci2ecef in MATLAB Aerospace Toolbox
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.axisRotation;
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
  
    input Real ang "GMST angle (deg)";
    input Real p_ECI[3] "Position vector in ECI coordinates (km)";
    input Real v_ECI[3] "Velocity vector in ECI coordinates (km/s)";
    
    output Real p_ECF[3] "Position vector in ECF coordinates (km)";
    output Real v_ECF[3] "Relative Velocity vector in ECF coordinates (km/s)";

    protected
      Real d2r = Modelica.Constants.D2R;
      Real theta_dot[3] = {0., 0., 360/86154.091} "Relative motion in the constant sidereal motion of the Earth";
      Integer ax = 3;
      Real wcross[3,3] = skew({0., 0., 360./86164.*d2r});
      Real TM[3,3] = axisRotation(axis=ax, angle=ang*d2r);
      
    algorithm
      p_ECF := resolve2(TM, p_ECI);
      v_ECF := resolve2(TM, v_ECI - theta_dot*p_ECI);
      
  end sat_ECF;

  function station_ECF
    // Function to calculate the current station position and velocity in ECF coordinates
    // Author : Matthieu Durand
    // Can test using the dcmeci2ecef in MATLAB Aerospace Toolbox
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.axisRotation;
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
  
    input Real ang "GMST angle (deg)";
    input Real p_ECI[3] "Position vector in ECI coordinates (km)";
    input Real v_ECI[3] "Velocity vector in ECI coordinates (km/s)";
    
    output Real p_ECF[3] "Position vector in ECF coordinates (km)";
    output Real v_ECF[3] "Relative Velocity vector in ECF coordinates (km/s)";
  
    protected
      Real d2r = Modelica.Constants.D2R;
      Integer ax = 3;
      Real wcross[3,3] = skew({0., 0., 360./86164.*d2r});
      Real TM[3,3] = axisRotation(axis=ax, angle=ang*d2r);
      
    algorithm
      p_ECF := resolve2(TM, p_ECI);

  end station_ECF;

  function range_ECF2topo
    // Function to find the current satellite position and velocity in the topocentric system coordinates.
    // Author : Matthieu Durand
    import Modelica.Mechanics.MultiBody.Frames.TransformationMatrices.resolve2;
    
    input Real p_stn_ECF[3] "Position of station in ECF coords";
    input Real p_sat_ECF[3] "Position of satellite in ECF coords";
    input Real v_sat_ECF[3] "Relative Velocity of satellite in ECF coords";
    input Real TM[3, 3] "Transform matrix from ECF to topo";
    
    output Real p_sat_topo[3] "Position of satellite relative to station, topo coords (km)";
    output Real v_sat_topo[3] "Velocity of satellite relative to station, topo coords (km/s)";
    
    algorithm 
      p_sat_topo := resolve2(TM, p_sat_ECF - p_stn_ECF);
      v_sat_topo := resolve2(TM, v_sat_ECF);

  end range_ECF2topo;

  function range_topo2look_angles
    input Real p_sat_topo[3] "Position of satellite in topo coords (km)";
    input Real v_sat_topo[3] "Velocity of satellite in topo coords (km)";
  
    output Real az "Azimuth look angle (deg)";
    output Real el "Elevation look angle (deg)";
    output Real dazdt "Azimuth rate (deg/s)";
    output Real deldt "Elevation rate (deg/s)";
    
    protected
      Real d2r = Modelica.Constants.D2R;
    
    algorithm
      az := atan(p_sat_topo[1]/p_sat_topo[2]);
      el := atan(p_sat_topo[3]/sqrt((p_sat_topo[1]^2)+(p_sat_topo[2]^2)));
      dazdt := ((v_sat_topo[1]*p_sat_topo[2])-(v_sat_topo[2]*p_sat_topo[1]))/(p_sat_topo[1:2]*p_sat_topo[1:2]);
      deldt := ((sqrt(p_sat_topo[1:2]*p_sat_topo[1:2])*v_sat_topo[3])-(p_sat_topo[3]*(p_sat_topo[1:2]*v_sat_topo[1:2])/sqrt(p_sat_topo[1:2]*p_sat_topo[1:2])))/(p_sat_topo*p_sat_topo);
    
  end range_topo2look_angles;

end SatelliteTracking;
