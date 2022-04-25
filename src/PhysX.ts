import PhysXModule from "./trident-physx-js-webidl.wasm";

export let PhysX = PhysXModule;

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