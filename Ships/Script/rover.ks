@lazyglobal off.

clearscreen.

local tolerance is 5.

local location is ship:geoposition.
local dest is latlng(location:lat + destLat, location:lng + destlng).


local pid is pidloop().
local runmode is 0.

local minspeed is 0.5.
local maxspeed is 8.


set pid:maxoutput to 1.
set pid:minoutput to -1.

brakes off.


function eta {
  parameter dist.
  local seconds is dist / pid:setpoint.

  return round(seconds, 1) + "s".
}

until dest:distance < tolerance {
  lock wheelthrottle to pid:update(time:seconds, groundspeed).
  lock wheelsteering to dest:heading.

  set pid:setpoint to max(minspeed, min(maxspeed, dest:distance / 5)).


  print "DEST LAT: " + round(dest:lat, 3)             + "            " at (5,2).
  print "DEST LNG: " + round(dest:lng, 3)             + "            " at (5,3).
  print "CURR LAT: " + round(ship:geoposition:lat, 3) + "            " at(5, 4).
  print "CURR LNG: " + round(ship:geoposition:lng, 3) + "            " at(5, 5).
  print "DIST:     " + round(dest:distance, 3)        + "            " at(5, 7).
  print "BEARING:  " + round(dest:heading, 3)         + "            " at(5, 8).
  print "TGT SPD:  " + round(pid:setpoint, 3)         + "            " at(5, 9).
  print "ETA:      " + eta(dest:distance)             + "            " at (5, 10).
}


unlock all.
brakes on.
