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
end SatelliteTracking;
