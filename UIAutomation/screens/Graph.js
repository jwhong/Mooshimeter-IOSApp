
appmap.createOrAugmentApp("mooshi").withScreen("graph")
    .onTarget("iphone", function () {
        try {
            mainWindow().waitForChildExistence(5, true, "Graph view", function (mw) {
                return mw.navigationBars()["GraphView"];
            });
            return true; // because we found it
        } catch (e) {
            UIALogger.logDebug("Failed to find graph screen: " + e);
            return false; // because an exception was thrown when we didn't find it
        }
    })

    /* don't think this works
    .withAction("back", "Go back from graph view")
    .withImplementation(function () {
        mainWindow().navigationBars()["GraphView"].buttons()["Back"].tap();
    })
    */

    .withAction("toggleConfigMenu", "Set the state of the configuration popup")
    .withImplementation(function(parm) {

        var mButton = mainWindow().buttons()["Meter Mode"];
        if (parm.active != mButton.isVisible()) {
            mainWindow().buttons()["Config"].tap();
        }
    })
    .withParam("active", "Whether the menu is visible", true)

    .withAction("openMeter", "Open the meter view")
    .withImplementation(function () {
        mainWindow().buttons()["Meter Mode"].tap();
    });
