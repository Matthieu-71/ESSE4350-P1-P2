import numpy
import datetime
#import keyboard
import winsound
#import msvcrt
from collections import namedtuple

def banner():
  print("Team members: Matthieu Durand, Naufal Rafi Antares, Yuri Davydov\nProgram name: SatTrack\nRevision date: 2/28/2019\nVersion: 1.00\n\nYou can check out anytime you want, but you can never leave!")
 
  return None 

def anykey():
    #msvcrt.getch()    #msvcrt module function, prompts for user input in the form of any key
    #keyboard.sleep()    #special module function, prompts for user input in the form of any key
    input("Press Enter to continue...")
    return None

def errmsg():
  frequency = 2500  # Set Frequency To 2500 Hertz
  duration = 1000  # Set Duration To 1000 ms == 1 second
  winsound.Beep(frequency, duration)
  print("ERROR DETECTED")
  
  return None

def ReadStationFile(filename):
  f = open(filename, 'r')
  name = str(f.readline())    #read first line, register string  NAME OF STN
  stnlat = float(f.readline())  #read next line, register float  LATITUDE OF STN (DEGREES)
  stnlong = float(f.readline()) #read next line, register float  LONGITUDE OF STN (DEGREES)
  stnalt = float(f.readline())  #read next line, register float  ALTITUDE OF STN (METRES)
  utc_offset = float(f.readline())  #read next line, register float  UTC OFFSET
  az_el_nlim = int(f.readline())  #read next line, register integer  NUMBER OF AZ-EL LIMITS
  azellim = namedtuple('azellim',['az','elmin','elmax']) #setting up namedtuple for the azimuthal elevation limits
  az_el_lim = [[]*3]*az_el_nlim

  for i in range(0, az_el_nlim):
        l = f.readline()
        az = float(l.split(", ")[0])
        elmin = float(l.split(", ")[1])
        elmax = float(l.split(", ")[2])
        az_el_lim[i] = azellim(az, elmin, elmax)
        i+=1
  
  az_speed_max = float(f.readline())  #read next line, register float  MAX AZIMUTH SPEED (M/S)
  el_speed_max = float(f.readline())  #read next line, register float  MAX ELEVATION SPEED (M/S)

  stntup = namedtuple('stntup', ['name', 'stnlat', 'stnlong', 'stnalt', 'utc_offset', 'az_el_nlim', 'az_el_lim', 'az_speed_max', 'el_speed_max'])  # SETTING UP STN NAMED TUPLE
  Station = stntup(name, stnlat, stnlong, stnalt, utc_offset, az_el_nlim, az_el_lim, az_speed_max, el_speed_max)
  
  return Station
  

def ReadNoradTLE(filename):
  
  nlines = 0
  ff = open(filename, 'r')
  for line in ff:
      nlines += 1
      
  
  nsat = int(nlines/3)
  Satellite = [[]*12]*nsat
  
  ff = open(filename, 'r')
  for j in range(0, nsat):
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
      Satellite[j] = nrdtup(name, refepoch, incl, raan, eccn, argper, meanan, meanmo, ndot, nddot6, bstar, orbitnum)
      j+=1
  
  return Satellite

 
def STKout(filename, EphemSyst, time, position, velocity):
    #filename = name of .e file to be created
    #EphemSyst = name of .txt file containing header/settings of .e file to be created
    #time = n-sized array
    #position = n-by-3-sized matrix
    #velocity = n-by-3-sized matrix
  
    fff = open(EphemSyst,'r')
    #-------extracting data of header, might be needed----------
    stkver = fff.readline().split("v.")[1]
    nEphemPts = int(fff.readline().split(" ",1)[1])
    Epoch = str(fff.readline().split("  ",1)[1])
    IntMethod = str(fff.readline().split("  ",1)[1])
    IntOrder = int(fff.readline().split(" ",1)[1])
    CentBody = str(fff.readline().split("  ",1)[1])
    CoordSyst = str(fff.readline().split("  ",1)[1])
    #------------------------------------------------------------
    
    headr = open(EphemSyst,'r')
    headc = headr.read() #extracting the whole content of header file as str
    
    #-----------------writing output file------------------------
    ffff= open(filename,'w+')
    
    ffff.write(str(headc) + '\n')
    
    for k in range(nEphemPts):
        ffff.write(str(time[k]) + " " + str(position[k][0]) + " " + str(position[k][1]) + " " + str(position[k][2]) + " " + str(velocity[k][0]) + " " + str(velocity[k][1]) + " " + str(velocity[k][2]) + "\n")
        k+=1
    #-------------------------------------------------------------
    
    return None
