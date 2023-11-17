<script lang="ts">
  import { setup } from "../mud/setup"
  import { onMount } from "svelte"
  import mudConfig from "contracts/mud.config";
  import Avatar from "./Avatar.svelte"
  import { count } from "../stores"

  let incrementFunction: Function

  let open = false

  onMount(async () => {
    const {
    components,
      systemCalls: { increment },
      network,
    } = await setup();

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

      components.Game.update$.subscribe((update) => {
        // const [nextValue, prevValue] = update.value;

        // game.set(Number(nextValue?.value))
      })

      // components.Counter.update$.subscribe((update) => {
      //   const [nextValue, prevValue] = update.value;
      //   // console.log("Counter updated", update, { nextValue, prevValue });
      //   count.set(Number(nextValue?.value))
      // });
    }
  })
</script>

<div class="container">
  <div class="left" class:open>
    <button class="open-left" on:click={() => open = !open}>
      Manage
    </button>
    <div class="funds">
      <button on:click={() => incrementFunction()}>
        Buy in
      </button>
    </div>
    <div class="">
      {#if count > -1}
        {count}
      {/if}
    </div>

  </div>

  <div class="center">
    <Avatar />
  
    <button on:click={() => incrementFunction()}>
      Burn 1
    </button>
  </div>

  <div class="right" class:open>
    Rules

    <button class="open-right" on:click={() => open = !open}>
      Rules
    </button>
  </div>
</div>   


<style>
  .container {
    /* display: flex; */
    /* flex-direction: column; */
    /* gap: 2rem; */
  }

  .left {
    position: fixed;
    left: 0;
    bottom: 0;
    height: 100vh;
    width: 360px;
    background: #000;
    padding: 1rem;
    transform: translate(-100%, 0);
    transition: transform 0.4s ease;
  }

  .right {
    position: fixed;
    right: 0;
    bottom: 0;
    height: 100vh;
    width: 300px;
    background: #000;
    padding: 1rem;
    transform: translate(100%, 0);
    transition: transform 0.4s ease;
  }

  .center {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    height: 100vh;
  }

  .right.open,
  .left.open {
    transform: translate(0, 0);
  }

  .open-left {
    position: absolute;
    right: 0;
    transform: translate(100%, 0) translate(1rem, 0);
  }
  .open-right {
    position: absolute;
    left: 0;
    transform: translate(-100%, 0) translate(-1rem, 0);
  }
</style>