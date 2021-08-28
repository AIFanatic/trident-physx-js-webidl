const fs = require("fs");
const path = require("path");

PHYSX_JS_FILENAME = path.join(__dirname, "../dist/trident-physx-js-webidl.wasm.js");
fs.readFile(PHYSX_JS_FILENAME, 'utf8' , (err, data) => {
    if (err) {
        console.log("ewwfwewef")
        console.error(err)
        return
    }

    data = data.replace("function(PhysX) {", "function(PhysXInstance) {");
    data = data.replace("PhysX = PhysX || {};", "PhysXInstance = PhysX || {};");
    data = data.replace("if (Module['arguments'])", "// if (Module['arguments'])");

    fs.writeFile(PHYSX_JS_FILENAME, data, function (err) {
        if (err) return console.log(err);
        console.log("Modified PHYSX_JS_FILENAME successfully");
    });
})