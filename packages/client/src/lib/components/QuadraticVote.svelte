<script lang="ts">
  import { systemCalls } from "$lib/stores"

  export let proposal: any

  let value = 1
</script>

<div class="votes">
  <button on:click={() => $systemCalls.vote(value)}>
    +
  </button>
  <p>
    {proposal.support}🔥
  </p>
</div>
<div class="votes">
  <p>
    {proposal.reject}❄️
  </p>
  <button on:click={() => $systemCalls.vote(value)}>
    -
  </button>
</div>