<script lang="ts">
  import { states, player } from "../stores"
</script>

{#if $player}
  {states[$player.status]}
{/if}


