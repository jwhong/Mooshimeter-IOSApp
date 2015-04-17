

function actionOpenSim(parm) {
    mainWindow().tableViews()[0].cells()[parm.name].tap();
}

appmap.createOrAugmentApp("mooshi").withScreen("home")
    .onTarget("iphone", function () {
        try {
            mainWindow().waitForChildExistence(15, true, "Main nav bar", function (mw) {
                return mw.navigationBars()["Swipe down to scan"];
            });
            return true; // because we found it
        } catch (e) {
            UIALogger.logDebug("Failed to find home screen: " + e);
            return false; // because an exception was thrown when we didn't find it
        }
    })

    .withAction("openMeter", "Open a detected meter")
    .withImplementation(actionOpenSim)
    .withParam("name", "The (full) name of the meter")

    .withAction("openSimulatedMeter", "Open the fake meter")
    .withImplementation(actionOpenSim.bind(undefined, {name: "SIMULATED METER, RSSI: n/a        FW Build: n/a"}));
