import { get } from "svelte/store";
import { network, blockNumber } from "$lib/stores";

let blockTimeout: NodeJS.Timeout;
const TIMEOUT = 10000;

export function initBlockListener() {
    get(network)?.latestBlock$.subscribe((block) => {
        clearTimeout(blockTimeout);
        blockTimeout = setTimeout(handleBlockTimeout, TIMEOUT);
        blockNumber.set(Number(block.number))
    })
}

function handleBlockTimeout() {
  console.error(new Error("Error with chain"))
}