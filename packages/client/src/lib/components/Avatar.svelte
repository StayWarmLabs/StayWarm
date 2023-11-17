<script lang="ts">
  import { count } from "../stores"

  console.log($count)

  enum states {
    UNINITIATED,
    ALIVE,
    DEAD
  }

  $: state = states[Math.abs($count % 3)]
</script>

{state}