#import "screens/AllScreens.js";

#import "NoHardwareTests.js";

target().setTimeout(0.4);

UIATarget.onAlert = function onAlert(alert) {
    UIALogger.logDebug("Caught onAlert with title " + alert.name());
    alert.elementReferenceDump("alert");
    return false; // only return true if we choose to handle this ourselves
};
