import {configs} from "@front-utils/linter";

export default [
    ...configs.ts,
    {
        languageOptions: {
            globals: {
                Module: true,
            },
        },
    }
];