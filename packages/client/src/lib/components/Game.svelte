<script lang="ts">
  import { setup } from "../mud/setup"
  import { onMount, tick } from "svelte"
  import { initBlockListener } from "$lib/mud/blockListener"
  import { getComponentValue } from "@latticexyz/recs";
  import { singletonEntity } from "@latticexyz/store-sync/recs";
  import { fade } from "svelte/transition"
  import mudConfig from "contracts/mud.config";
  import Avatar from "./Avatar.svelte"
  import Burn from "./Burn.svelte"
  import Background from "./Background.svelte"
  import Proposals from "./Proposals.svelte"
  import Ruleset from "./Ruleset.svelte"
  import {
    count,
    components,
    network,
    player,
    burned,
    systemCalls,
    createComponentSystem
  } from "../stores"

  let open = false
  let progress = $components?.Config ? getComponentValue($components.Config, singletonEntity) : 0


  const onKeyDown = (e) => {
    if (e.key === "Escape") open = false
  }

  onMount(async () => {
    const {
      components: componentsValue,
      systemCalls: systemCallsValue,
      network: networkValue,
    } = await setup();

    progress = $components?.Config ? getComponentValue($components.Config, singletonEntity) : 0

    // https://vitejs.dev/guide/env-and-mode.html
    if (import.meta.env.DEV) {
      const { mount: mountDevTools } = await import("@latticexyz/dev-tools");
      mountDevTools({
        config: mudConfig,
        publicClient: networkValue.publicClient,
        walletClient: networkValue.walletClient,
        latestBlock$: networkValue.latestBlock$,
        storedBlockLogs$: networkValue.storedBlockLogs$,
        worldAddress: networkValue.worldContract.address,
        worldAbi: networkValue.worldContract.abi,
        write$: networkValue.write$,
        recsWorld: networkValue.world,
      });

      components.set(componentsValue)
      systemCalls.set(systemCallsValue)
      network.set(networkValue)

      // Create systems to listen to changes to components in our namespace
      for (const componentKey of Object.keys($components)) {
        createComponentSystem(componentKey)
      }

      await tick()

      $components.SyncProgress.update$.subscribe(update => {
        const [next, prev] = update.value

        progress = next.percentage || 0

      })

      initBlockListener()
    }
  })
</script>

<svelte:window on:keydown={onKeyDown} />

<Background />

{#if open}
  <div transition:fade={{ duration: 500 }} on:click={() => open = false} class="background-clicker"></div>
{/if}

{#if progress < 100}
  <div class="container">
    <div class="center">
      <p>
        Loading ... {progress}
      </p>
    </div>
  </div>
{:else}
  <div in:fade={{ duration: 2000 }} class="container">
    <div class="left" class:open>
      {#if !open}
        <button out:fade class="open-left" on:click={() => open = !open}>
          Manage
        </button>
      {/if}
      <div class="funds">
        {#if $player}
          <Ruleset />

          {#if $burned}
            You have burnt
          {/if}
        {/if}
        {#if $systemCalls?.joinGame && !$player}
          <button on:click={() => $systemCalls.joinGame()}>
            Join
          </button>
        {/if}
      </div>
      <div class="">
        {#if count > -1}
          {count}
        {/if}
      </div>

    </div>

    <div class="center">
      <Avatar />

      <Burn />
    </div>

    <div class="right" class:open>
      {#if !open}
        <button out:fade class="open-right" on:click={() => open = !open}>
          Proposals
        </button>
      {/if}
      
      {#if $player}
        <Proposals/>
      {:else}
        Add tokens to see proposals
      {/if}
    </div>
  </div>  
{/if} 


<style>
  .container {
    /* display: flex; */
    /* flex-direction: column; */
    /* gap: 2rem; */
  }

  .background-clicker {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.9);
    z-index: 0;
  }

  .left {
    position: fixed;
    left: 0;
    bottom: 0;
    height: 100vh;
    width: 46vw;
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
    width: 46vw;
    background: #000;
    padding: 1rem;
    transform: translate(100%, 0);
    transition: transform 0.4s ease;
    overflow-y: scroll;
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

  .open-left,
  .open-right {
    font-size: 40px;
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

  @media (prefers-color-scheme: light) {
    .left,
    .right {
      background: #ddd;
    }
  }
</style>