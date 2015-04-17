
appmap.createOrAugmentApp("mooshi").withScreen("meter")
    .onTarget("iphone", function () {
        try {
            mainWindow().waitForChildExistence(5, true, "Meter view", function (mw) {
                return mw.navigationBars()["MeterView"];
            });
            return true; // because we found it
        } catch (e) {
            UIALogger.logDebug("Failed to find meter screen: " + e);
            return false; // because an exception was thrown when we didn't find it
        }
    })

    .withAction("back", "Go back from meter view")
    .withImplementation(function () {
        mainWindow().navigationBars()["MeterView"].buttons()["Back"].tap();
    })

    .withAction("toggleConfigMenu", "Set the state of the configuration popup")
    .withImplementation(function(parm) {
        var gButton = mainWindow().buttons()["Switch to Graph"];
        if (parm.active != gButton.isVisible()) {
            mainWindow().navigationBars()["MeterView"].buttons()["⚙"].tap();
        }
    })
    .withParam("active", "Whether the menu is visible", true)

    .withAction("openGraph", "Open the graph view")
    .withImplementation(function () {
        mainWindow().buttons()["Switch to Graph"].tap();
    });
