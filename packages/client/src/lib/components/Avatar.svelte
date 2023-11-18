<script lang="ts">
  import { player } from "../stores"

  // $: console.log("player", $player)

  enum states {
    UNINITIATED,
    ALIVE,
    DEAD
  }
</script>

{#if $player}
  {states[$player.Player.status]}
{/if}


