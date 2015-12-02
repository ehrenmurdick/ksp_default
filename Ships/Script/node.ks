@lazyglobal off.

parameter nodeCount.

local node is nextnode.
sas off.

until nodeCount = 0 {

  set node to nextnode.

  wait node:eta - 30.
  lock steering to node.
  wait node:eta.

  lock throttle to node:deltav:mag / 10.
  wait until node:deltav:mag < 1.
  lock throttle to 0.

  remove node.


  set nodeCount to nodeCount - 1.
}
