<script lang="ts">
  import { setup } from "../mud/setup"
  import { onMount, tick } from "svelte"
  import { initBlockListener } from "$lib/mud/blockListener"
  import { getComponentValue } from "@latticexyz/recs";
  import { singletonEntity } from "@latticexyz/store-sync/recs";
  import { fade } from "svelte/transition"
  import mudConfig from "contracts/mud.config";

  import Countdown from "./Countdown.svelte"
  import Burn from "./Burn.svelte"
  import Background from "./Background.svelte"
  import Upload from "./Upload.svelte"
  import Proposals from "./Proposals.svelte"
  import Ruleset from "./Ruleset.svelte"
  import {
    count,
    components,
    network,
    player,
    burned,
    game,
    timeLeft,
    blockNumber,
    systemCalls,
    createComponentSystem
  } from "../stores"

  let adding = false
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
{/if}


<div class="game">
  <button class="settings-button" on:click={() => open = !open}>
    Manage
  </button>
  <div class="container">
    <div class="left" class:open>
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
      
      {#if $systemCalls?.joinGame && !$player}
      <!-- <button on:click={() => $systemCalls.joinGame()}>
        Join
      </button> -->
    {:else}
      <Countdown />
      {$game.currentRound}
      {#if $game.currentRound !== 0}

        <div class="balance">
          {Number($player.ftBalance)} tokens to keep me warm
        </div>
        <!-- <Avatar /> -->

    
        <Burn />
      {/if}
    {/if}
    </div>
  
    <div class="right" class:open>
      {#if !open}
        <button out:fade class="open-right" on:click={() => open = !open}>
          Proposals
        </button>
      {/if}
      
      {#if $player}
        <Proposals on:add={() => adding = true}/>
      {:else}
        Add tokens to see proposals
      {/if}
    </div>
  </div>  
</div>

{#if adding}
  <Upload on:close={() => adding = false} />
{/if}
<style>


.balance {
  color: black;
  background: white;
  padding: 0.5rem 1rem;
  border-radius: 5px;
}
.settings-button {
  position: fixed;
  top: 1rem;
  left: 1rem;
}
  .game {
    position: fixed;
    inset: 0;
    width: 100vw;
    height: 100vh;
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
    overflow-y: scroll;
    z-index: 20;
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
    z-index: 20;
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
    z-index: 1000;
  }
  .open-right {
    position: absolute;
    left: 0;
    transform: translate(-100%, 0) translate(-1rem, 0);
    z-index: 1000;
  }

  @media (prefers-color-scheme: light) {
    .left,
    .right {
      background: #ddd;
    }
  }
</style>