<script lang="ts">
  import type { Writable } from "svelte/store"
  import { setup } from "../mud/setup"
  import { onMount } from "svelte"
  import mudConfig from "contracts/mud.config";

  export let walletState: Writable<Record<string,string>>

  let count = -1
  let incrementFunction: Function

  onMount(async () => {
    const {
    components,
      systemCalls: { increment },
      network,
    } = await setup($walletState);

    incrementFunction = increment

    // https://vitejs.dev/guide/env-and-mode.html
    if (import.meta.env.DEV) {
      const { mount: mountDevTools } = await import("@latticexyz/dev-tools");
      mountDevTools({
        config: mudConfig,
        publicClient: network.publicClient,
        walletClient: network.walletClient,
        latestBlock$: network.latestBlock$,
        storedBlockLogs$: network.storedBlockLogs$,
        worldAddress: network.worldContract.address,
        worldAbi: network.worldContract.abi,
        write$: network.write$,
        recsWorld: network.world,
      });

      components.Counter.update$.subscribe((update) => {
        const [nextValue, prevValue] = update.value;
        // console.log("Counter updated", update, { nextValue, prevValue });
        count = Number(nextValue?.value)
      });
    }
  })
</script>

<div class="container">
  <div class="">
    {#if count > -1}
      {count}
    {/if}
  </div>


  <div class="">
    {#if incrementFunction}
      <button on:click={() => incrementFunction()}>
        Increment
      </button>
    {/if}
  </div>
</div>  


<style>
  .container {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }
</style>