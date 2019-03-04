import numpy as np
import datetime as dt
import winsound
from collections import namedtuple

def banner():
  print("Team members: Matthieu Durand, Naufal Rafi Antares, Yuri LASTNAME\nProgram name: PROGRAM NAME\nRevision date: 2/28/2019\nVersion: 1.00\n\nYou can check out anytime you want, but you can never leave!")
return none 

#def anykey()

def errmsg()
  frequency = 2500  # Set Frequency To 2500 Hertz
  duration = 1000  # Set Duration To 1000 ms == 1 second
  winsound.Beep(frequency, duration)
  return none 

def ReadStationFile(filename)
  f = open(filename, 'r')

  name = str(f.readline().split(" = ")[1])    #read first line, register sting read after " = " NAME OF STN
  stnlat = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " LATITUDE OF STN (DEGREES)
  stnlong = float(f.readline().split(" = ")[1]) #read next line, register float read after " = " LONGITUDE OF STN (DEGREES)
  stnalt = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " ALTITUDE OF STN (METRES)
  utc_offset = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " UTC OFFSET
  az_el_nlim = int(f.readline().split(" = ")[1])  #read next line, register integer read after " = " IDK
  azmin = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " MIN AZIMUTH (DEGREES)
  azmax = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " MAX AZIMUTH (DEGREES)
  elmin = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " MIN ELEVATION (DEGREES)
  elmax = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " MAX ELEVATION (DEGREES)
  az_speed_max = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " MAX AZIMUTH SPEED (M/S)
  el_speed_max = float(f.readline().split(" = ")[1])  #read next line, register float read after " = " MAX ELEVATION SPEED (M/S)

  stntup = namedtuple('stntup', ['name', 'stnlat', 'stnlong', 'stnalt', 'utc_offset', 'az_el_nlim', 'azmin', 'azmax', 'elmin', 'elmax', 'az_speed_max', 'el_speed_max'])  # SETTING UP STN NAMED TUPLE
  Station = stntup(name, stnlat, stnlong, stnalt, utc_offset, az_el_nlim, azmin, azmax, elmin, elmax, az_speed_max, el_speed_max)
  return Station
  

def ReadNoradTLE(filename)
  ff = open(filename, 'r')
  line0 = str(ff.readline())
  line1 = str(ff.readline())
  line2 = str(ff.readline())

  name = str(line0.split("    ")[0]) #NAME OF SAT
  refepoch = float(line1[18:32]) #REFERENCE EPOCH, LAST 2 DIGITS OF YEAR FOLLOWED BY NUMBER OF DAYS PASSED IN THE YEAR
  incl = float(line2[8:16]) # INCLINATION (DEGREES)
  raan = float(line2[17:25]) # RAAN (DEGREES)
  eccn = float(line2[26:33]) # ECCENTRICITY (DEGREES W/ DEC. POINTS)
  argper = float(line2[34:42]) # ARGUMENT OF PERIGEE (DEGREES)
  meanan = float(line2[43:51]) # MEAN ANOMALY (DEGREES)
  meanmo = float(line2[52:63]) # MEAN MOTION (REVS PER DAY)
  ndot = float(line1[33:43]) # FIRST TIME DERIVATIVE OF THE MEAN MOTION
  nddot6 = line1[44:52] # SECOND TIME DERIVATIVE OF THE MEAN MOTION, ASSUMED DECIMAL PLACE REMOVED
  bstar = line1[53:61] # BSTAR DRAG TERM 
  orbitnum = int(line1[2:7]) # SATELLITE NUMBER = ORBIT NUMBER ??
  
  nrdtup = namedtuple('nrdtup', ['name', 'refepoch', 'incl', 'raan', 'eccn', 'argper', 'meanan', 'meanmo', 'ndot', 'nddot6', 'bstar', 'orbitnum']) # SETTING UP NORAD TLE NAMED TUPLE
  Station = nrdtup(name, refepoch, incl, raan, eccn, argper, meanan, meanmo, ndot, nddot6, bstar, orbitnum)
  return Station  

 
  
