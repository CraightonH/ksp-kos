runOncePath("0:/lib/lib_lazcalc.ks").
runOncePath("0:/lib/lib_deltav.ks").
parameter targetApoapsis is 80000.
parameter targetInclination is 0.
parameter targetOrbVelocity is 1200.
parameter targetAtmoVelocity is 600.
parameter targetOrbBody is kerbin.

runOncePath("0:/validate_orbit.ks", targetApoapsis, targetInclination).

local orbitSuccessful is false.

local shipThrottle to 1.0.
LOCK THROTTLE TO shipThrottle.

local pitch is 90.
local degrees is LAZcalc(LAZcalc_init(targetApoapsis, targetInclination)).
LOCK steering TO HEADING(degrees, pitch).

PRINT "Counting down:".
FROM {local countdown is 1.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown at (0, 2).
    WAIT 1.
}

clearScreen.

// TODO: calculate engine stages
local stagesLeft is 2.

// basic staging
WHEN maxThrust = 0 THEN {
    // PRINT "Staging".
    STAGE.
    set stagesLeft to stagesLeft - 1.
    return stagesLeft > 0.
}.
print "Liftoff".
// target cruising speed
// set speedPID to PIDLoop(0.02, 0.0015, 0.02, 0, 1).
// set speedPID:SETPOINT to targetOrbVelocity.

// TODO: tune these to take better advantage of gravity
// target pitch params
// default end of pitch function
local endAlt is targetApoapsis.
// verify this
if targetOrbBody:atm:exists {
    set endAlt to targetOrbBody:atm:height / 2.
}
local switchAlt is (endAlt * .05).

// print "endalt: " + endAlt.
// print "switchalt: " + switchAlt.

// climb to apoapsis
UNTIL ship:apoapsis > (targetApoapsis + 500) { // allow for some deceleration from gravity
    set pitch to max(0, min(90,90 - (90 / (endAlt - switchAlt)) * (ship:altitude - switchAlt))).
    // set shipThrottle to speedPID:update(time:seconds, SHIP:VELOCITY:SURFACE:MAG).
    print "Pitch " + round(pitch, 2) at (0, 0).
    // print "Throttle " + round(shipThrottle, 2) at (0, 1).
}
clearScreen.
set shipThrottle to 0.
unlock throttle.
unlock steering.
print "Coasting to apoapsis".

// // TODO: calculate this value so it's accurate for a longer manuever burn 
// local timeLeftToCalculateManeuver is 10.
// // wait til apoapsis, then calculate node to account for any changes in apoapsis during coast
// until time:seconds > (time:seconds + ship:obt:eta:apoapsis - timeLeftToCalculateManeuver) {
//     print "Waiting to calculate maneuver: " + round(ship:obt:eta:apoapsis - timeLeftToCalculateManeuver) + "s" at (0, 2).
// }

// circularize orbit
// print "eta to apoapsis: " + round(ship:obt:eta:apoapsis.
local maneuverDV is circularizeManeuverDeltaV().
// print "calculated deltaV for circularization: " + round(maneuverDV, 2).
set orbNode to node(time:seconds + ship:obt:eta:apoapsis, 0, 0, maneuverDV).
add orbNode.
// lock vessel to node vector
lock steering to orbNode:deltav.
local burnTimeMean is calc_Burn_Mean(orbNode:deltav:mag).
// print "burntimeMean: " + burnTimeMean.
local futureBurnTime is orbNode:time - burnTimeMean[0].
// print "futureBurnTime: " + (futureBurnTime - time:seconds).
// wait until time to burn
until time:seconds >= futureBurnTime {
    print "Time to execute maneuver: " + round(futureBurnTime - time:seconds) at (0, 2).
}

print "Executing orbital maneuver".

// execute node
lock throttle to 1.0.
local beginBurnTime is time:seconds. // start of burn
local endBurnTime is beginBurnTime + burnTimeMean[1].
until time:seconds >= endBurnTime { // add full burn time to begin time
    print "Time left to burn: " + round(endBurnTime - time:seconds) at (0, 4).
}
lock throttle to 0.
remove orbNode.
clearScreen.
if ship:obt:eccentricity < 0.02 {
    print "Congratulations on a successful orbit".
}
lock steering to ship:prograde.
wait 30.