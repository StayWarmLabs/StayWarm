<script lang="ts">
  import { states, player } from "../stores"
</script>

{#if $player}
  <div class="">
    {states[$player.status]}
  </div>
{/if}


