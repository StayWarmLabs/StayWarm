<script lang="ts">
  import { player } from "../stores"

  enum states {
    UNINITIATED,
    ALIVE,
    DEAD
  }
</script>

{#if $player}
  {states[$player.Player.status]}
{/if}


