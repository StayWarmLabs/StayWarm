<script lang="ts">
  import { components, player, burned, game, systemCalls } from "$lib/stores"
  import { getComponentValue } from "@latticexyz/recs";
  import { singletonEntity } from "@latticexyz/store-sync/recs";
	import { parseEther } from "viem";

  let config

  $: {
    if ($components?.Config) {
      $components?.Config.update$.subscribe(() => {
        config = getComponentValue($components.Config, singletonEntity)
      })
    }
  }

  const burn = async () => {
    try {
      await $systemCalls.burn(parseEther("100"))
    } catch (error) {
      console.error(error)
    }

  }
</script>

{#if $player}
  <button class="burn" on:click={burn}>
    Burn
  </button>
{/if}

<style>
  .burn {
    padding: 0.5rem 1rem;
    background: orangered;
    border: transparent;
    font-size: 16px;
    border-radius: 5px;
    margin-top: .5rem;
    cursor: pointer;
  }

  .burn:hover {
    background: white;
    color: orangered;
  }
</style>