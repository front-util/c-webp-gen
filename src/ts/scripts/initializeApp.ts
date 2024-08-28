Module.onRuntimeInitialized = async () => {
    const api = {
        version         : Module.cwrap<() => number>("version", "number", []),
        createBuffer    : Module.cwrap<(width: number, height: number) => number>('create_buffer', 'number', ['number', 'number']),
        destroyBuffer   : Module.cwrap<(pointer: number) => void>('destroy_buffer', null, ['number']),
        encode          : Module.cwrap<(buffer: number, width: number, height: number, quality: number) => void>('encode', null, ['number', 'number', 'number', 'number']),
        freeResult      : Module.cwrap<(res: number) => void>('free_result', null, ['number']),
        getResultPointer: Module.cwrap<() => number>('get_result_pointer', null, []),
        getResultSize   : Module.cwrap<() => number>('get_result_size', null, []),
    };
    const loadImage = async (src: string) => {
        const imgBlob = await fetch(src, {
            mode: 'no-cors',
        }).then((resp) => resp.blob());
        const img = await createImageBitmap(imgBlob);
        const canvas = document.createElement('canvas');
    
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
    
        ctx?.drawImage(img, 0, 0);
        return ctx?.getImageData(0, 0, img.width, img.height);
    };

    const encodeImage = (imageBuffer: number, image: ImageData) => {
        api.encode(imageBuffer, image.width, image.height, 100);
        const resultPointer = api.getResultPointer();
        const resultSize = api.getResultSize();
        const resultView = new Uint8Array(Module.HEAP8.buffer, resultPointer, resultSize);
        const result = new Uint8Array(resultView);

        api.freeResult(resultPointer);

        return result;
    };

    const renderEncodedImage = (result: Uint8Array) => {
        const blob = new Blob([result], { type: 'image/webp', });
        const blobURL = URL.createObjectURL(blob);
        const img = document.createElement('img');

        img.src = blobURL;
        document.body.appendChild(img);
    };

    console.log(api.version());
    const image = await loadImage('test.png');

    if(!image) {
        return;
    }
    const p = api.createBuffer(image.width, image.height);

    Module.HEAP8.set(image.data, p);
    const encodedImage = encodeImage(p, image);

    renderEncodedImage(encodedImage);
    api.destroyBuffer(p);
};