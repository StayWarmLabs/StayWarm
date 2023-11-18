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
  <button on:click={burn}>
    Burn {config?.burnAmountPerRound}
  </button>
{/if}