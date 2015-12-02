@lazyglobal off.

SAS off.
lock throttle to 0. //Throttle is a decimal from 0.0 to 1.0
gear off.

parameter targetAlt.

clearscreen.

local GRAVITY is (constant():G * body:mass) / body:radius^2.
local TWR is 0.
local runmode is 0.
local TVAL is 0.
local targetPitch is 0.
local maxTWR is 0.
local maxT is 0.
local finalTVAL is 0.

lock TWR to MAX( 0.001, MAXTHRUST / (MASS*GRAVITY)).

set runmode to 2. //Safety in case we start mid-flight
if ALT:RADAR < 50 { //Guess if we are waiting for take off
  set runmode to 1.
}



until runmode = 0 { //Run until we end the program

  if runmode = 1 { //Ship is on the launchpad
    lock steering to UP.  //Point the rocket straight up
    set TVAL to 1.        //Throttle up to 100%
    set runmode to 2.     //Go to the next runmode
    stage.
  }

  else if runmode = 2 { // Fly UP to 10,000m
    lock steering to heading (90,90). //Straight up.
      set TVAL to 1.
      if SHIP:ALTITUDE > 5000 {
        //Once altitude is higher than 10km, go to Gravity Turn mode
        set runmode to 3.
      }
  } //Make sure you always close out your if statements.

  else if runmode = 3 { //Gravity turn
    set targetPitch to max( 5, 90 * (1 - ALT:RADAR / 45000)).
      //Pitch over gradually until levelling out to 5 degrees at 50km
      lock steering to heading ( 90, targetPitch). //Heading 90' (East), then target pitch
      set TVAL to 1.

      if SHIP:APOAPSIS > targetAlt {
        set runmode to 4.
      }
  }

  else if runmode = 4 {
    lock throttle to 0.
    wait 1.
    stage.
    set runmode to 0.
  }

  set maxTWR to 1.5 + ALT:RADAR / 45000.


  set maxT to 1 / (TWR / maxTWR).
  set TVAL to min(maxT, TVAL).
  set finalTVAL to TVAL.

  lock throttle to finalTVAL. //Write our planned throttle to the physical throttle

  //Print data to screen.
  print "STAGE:      " + "delta_i"             + "      " at (5,3).
  print "RUNMODE:    " + runmode               + "      " at (5,4).
  print "ALTITUDE:   " + round(SHIP:ALTITUDE)  + "      " at (5,5).
  print "APOAPSIS:   " + round(SHIP:APOAPSIS)  + "      " at (5,6).
  print "PERIAPSIS:  " + round(SHIP:PERIAPSIS) + "      " at (5,7).
  print "ETA to AP:  " + round(ETA:APOAPSIS)   + "      " at (5,8).
  print "maxTWR:     " + round(maxTWR, 2)      + "      " at (5,9).
  print "TVAL:       " + round(TVAL, 2)        + "      " at (5,10).
}
