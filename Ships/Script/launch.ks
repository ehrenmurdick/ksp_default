//first.ks
// This program launches a ship from the KSC and flies it into orbit

//Set the ship to a known configuration
SAS off.
lock throttle to 0. //Throttle is a decimal from 0.0 to 1.0
gear off.

parameter targetApoapsis.

clearscreen.

set targetPeriapsis to targetApoapsis.

set GRAVITY to (constant():G * body:mass) / body:radius^2.
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

      if SHIP:APOAPSIS > targetApoapsis {
        lock throttle to 0.
        wait 1.
        stage.
        set runmode to 4.
      }
  }

  else if runmode = 4 { //Coast to Ap
    lock steering to heading ( 90, 3). //Stay pointing 3 degrees above horizon
      set TVAL to 0. //Engines off.
      if (SHIP:ALTITUDE > 70000) and (ETA:APOAPSIS > 60) and (VERTICALSPEED > 0) {
        if WARP = 0 {        // If we are not time warping
          wait 1.         //Wait to make sure the ship is stable
            SET WARP TO 3. //Be really careful about warping
        }
      }.
      else if ETA:APOAPSIS < 60 {
        SET WARP to 0.
          set runmode to 5.
      }
  }

  else if runmode = 5 { //Burn to raise Periapsis
    if ETA:APOAPSIS < 5 or VERTICALSPEED < 0 { //If we're less 5 seconds from Ap or loosing altitude
      set TVAL to 1.
    }
    if (SHIP:PERIAPSIS > targetPeriapsis) or (SHIP:PERIAPSIS > targetApoapsis * 0.95) {
      //If the periapsis is high enough or getting close to the apoapsis
      set TVAL to 0.
        set runmode to 10.
    }
  }

  else if runmode = 10 { //Final touches
    set TVAL to 0. //Shutdown engine.
      panels on.     //Deploy solar panels
      ag1 on.
      lock throttle to 0.
      wait 1.
      stage.
      unlock steering.
      print "SHIP SHOULD NOW BE IN SPACE!".
      set runmode to 0.
  }

  if stage:liquidfuel < 1 {
    stage.
  }

  set maxTWR to 1.5 + ALT:RADAR / 45000.

  set maxT to 1 / (TWR / maxTWR).
  set TVAL to min(maxT, TVAL).
  set finalTVAL to TVAL.

  lock throttle to finalTVAL. //Write our planned throttle to the physical throttle

    //Print data to screen.
    print "RUNMODE:    " + runmode               + "      " at (5,4).
    print "ALTITUDE:   " + round(SHIP:ALTITUDE)  + "      " at (5,5).
    print "APOAPSIS:   " + round(SHIP:APOAPSIS)  + "      " at (5,6).
    print "PERIAPSIS:  " + round(SHIP:PERIAPSIS) + "      " at (5,7).
    print "ETA to AP:  " + round(ETA:APOAPSIS)   + "      " at (5,8).
    print "maxTWR:     " + round(maxTWR, 2)      + "      " at (5,9).
    print "TVAL:       " + round(TVAL, 2)        + "      " at (5,10).

}
