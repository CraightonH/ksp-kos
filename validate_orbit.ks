RUNPATH("0:/lib/lib_lazcalc.ks").
parameter orbAltitude, orbInclination.

print "Starting Flight Precheck".
validateLaunchParams.
validateAzimuth.
validateDeltaV.
validateControlPart.
clearScreen.
print "Flight Precheck Successful".

function validateLaunchParams {
    if orbAltitude > 0 {
        print "Altitude and Inclination defined (" + orbAltitude + "m, " + orbInclination + " deg)".
    } else {
        abortLaunch("No altitude defined").
    }
}

function validateAzimuth {
    SET launchAzimuth TO LAZcalc(LAZcalc_init(orbAltitude,orbInclination)).
    print "Launch Azimuth set (" + ROUND(launchAzimuth,2) + " deg)".
}

function validateDeltaV {
    // TODO: Calculate required deltaV based on orbital altitude, inclination, body
    // print "ship deltav: " + ship:deltav:current.
    if round(ship:deltav:current) > 3000 { // hardcoded to kerbin
        print "Sufficient deltaV for orbital launch (" + round(ship:deltav:current) + " m/s)".
    } else {
        abortLaunch("Insufficient deltaV").
    }
}

function validateControlPart {
    // todo: ensure it is a valid control part
    // print "control part: " + ship:controlpart.
    // if ship:controlpart
}

function abortLaunch {
    parameter reason is "".
    print "Launch aborted".
    if reason:length > 0 {
        print "Reason: " + reason.
    }
    shutdown.
}
