declare global {
    interface WasmModule {
        onRuntimeInitialized: () => Promise<void>;
        cwrap: <T>(name: string, type: string | null, args: unknown[]) => T;
        HEAP8: {
            set: (data: Uint8ClampedArray, number) => void;
            buffer: ArrayBufferLike;
        }
    }
    const Module: WasmModule;
  }
  
export {};