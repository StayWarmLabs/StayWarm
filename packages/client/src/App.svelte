<script lang="ts">
  import Metamask from "../src/lib/components/Metamask.svelte"
  import Game from "./lib/components/Game.svelte"
  import Proposals from "./lib/components/Proposals.svelte"

  let walletState: any

  let game = {
    startTime: Date.now()
  }
</script>

<Metamask>
  <!-- If there is a game -->

  {#if game.startTime}
    <Game />
  {:else}
    No active game
  {/if}
</Metamask>