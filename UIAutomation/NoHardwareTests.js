#import "screens/AllScreens.js";

var ia = appmap.apps["Illuminator"];
var mm = appmap.apps["mooshi"];

automator.createScenario("Home screen tests", ["home", "nohardware"])
    .withStep(ia.do.delay, {seconds: 2}) // prevent a boot-time issue
    .withStep(mm.home.openSimulatedMeter)
    .withStep(mm.meter.back)
    .withStep(mm.home.openMeter, {name: "SIMULATED METER, RSSI: n/a        FW Build: n/a"})
    .withStep(mm.meter.toggleConfigMenu, {active: true})
    .withStep(mm.meter.openGraph)
    .withStep(mm.graph.toggleConfigMenu, {active: true})
    .withStep(mm.graph.toggleConfigMenu, {active: false})
    .withStep(mm.graph.toggleConfigMenu, {active: true})
    .withStep(mm.graph.openMeter)
    .withStep(mm.meter.toggleConfigMenu, {active: false})
    .withStep(mm.meter.back)
    .withStep(mm.home.verifyIsActive);
