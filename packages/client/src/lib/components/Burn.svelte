<script lang="ts">
  import { components, player, burned, game, systemCalls } from "$lib/stores"
  import { getComponentValue } from "@latticexyz/recs";
  import { singletonEntity } from "@latticexyz/store-sync/recs";

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
      await $systemCalls.burn()
      console.log("You burned")
    } catch (error) {
      console.error(error)
    }

  }
</script>

{#if $player && !$burned && config}
  <!-- Based on tokens, value = Math.sqrt of the amount of tokens you wanna burn -->
  <select>
  </select>
  <button on:click={burn}>
    Burn
  </button>
{/if}