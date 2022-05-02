import PhysXModule from "./trident-physx-js-webidl.wasm";

export let PhysX = PhysXModule;

// https://github.com/fabmax/physx-js-webidl/issues/5#issuecomment-1021481070
// WebIDL struggles with Enums inside namespaces, this adds _emscripten_enum_* to PhysX module.
function FixEnums(PhysX: typeof PhysXModule) {
    const enums = Object.keys(PhysX)
        .filter(key => {
            return key.includes('_emscripten_enum_');
        })
        .map(enumString => {
            const split = enumString.split('_emscripten_enum_')[1].split('();')[0].split('_e');
            return { enumName: split[0], entryName: split[1], emscript: enumString };
        });

    for (const enumEntry of enums) {
        if (!PhysX[enumEntry.enumName]) {
            PhysX[enumEntry.enumName] = {};
        }

        PhysX[enumEntry.enumName][enumEntry.entryName] = PhysX[enumEntry.emscript]();
    }
}

export function PhysXLoader(wasmLocation) {
    return new Promise<typeof PhysXModule>((resolve, reject) => {
        fetch(wasmLocation).then(response => {
            response.arrayBuffer()
            .then(bytes => {
                const PhysXModuleClone = {
                    "wasmBinary": bytes
                }
    
                PhysXModule(PhysXModuleClone)
                .then(instance => {
                    PhysX = instance;
                    FixEnums(PhysX);
                    resolve(PhysX);
                })
                .catch(error => {
                    reject(error);
                })
            })
            .catch(error => {
                reject(error);
            })
        });
    })
}