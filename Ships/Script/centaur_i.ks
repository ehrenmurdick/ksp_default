@lazyglobal off.

parameter targetAlt.

clearscreen.

local runmode is 1.
local TVAL is 0.
local targetPitch is 0.
local finalTVAL is 0.

wait 1.
stage.

until runmode = 0 { //Run until we end the program

  if runmode = 1 { //Coast to Ap
    lock steering to prograde.
      set TVAL to 0. //Engines off.
      if (SHIP:ALTITUDE > 70000) and (ETA:APOAPSIS > 60) and (VERTICALSPEED > 0) {
        if WARP = 0 {        // If we are not time warping
          wait 1.         //Wait to make sure the ship is stable
            SET WARP TO 3. //Be really careful about warping
        }
      }.
      else if ETA:APOAPSIS < 60 {
        SET WARP to 0.
          set runmode to 2.
      }
  }

  else if runmode = 2 { //Burn to raise Periapsis
    if ETA:APOAPSIS < 5 or VERTICALSPEED < 0 { //If we're less 5 seconds from Ap or loosing altitude
      set TVAL to 1.
    }
    if SHIP:PERIAPSIS > targetAlt * 0.95 {
      //If the periapsis is high enough or getting close to the apoapsis
      set TVAL to 0.
        set runmode to 10.
    }
  }

  else if runmode = 10 { //Final touches
    set TVAL to 0. //Shutdown engine.
      lock throttle to 0.
      unlock steering.
      print "SHIP SHOULD NOW BE IN SPACE!".
      set runmode to 0.
  }

  set finalTVAL to TVAL.
  lock throttle to finalTVAL. //Write our planned throttle to the physical throttle

    //Print data to screen.
  print "STAGE:      " + "centaur_i"           + "      " at (5,3).
  print "RUNMODE:    " + runmode               + "      " at (5,4).
  print "ALTITUDE:   " + round(SHIP:ALTITUDE)  + "      " at (5,5).
  print "APOAPSIS:   " + round(SHIP:APOAPSIS)  + "      " at (5,6).
  print "PERIAPSIS:  " + round(SHIP:PERIAPSIS) + "      " at (5,7).
  print "ETA to AP:  " + round(ETA:APOAPSIS)   + "      " at (5,8).
  print "TVAL:       " + round(TVAL, 2)        + "      " at (5,10).

}
