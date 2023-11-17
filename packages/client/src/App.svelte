<script lang="ts">
  import Metamask from "../src/lib/components/Metamask.svelte"
  import Main from "../src/lib/components/Main.svelte"

  let walletState: any
</script>

<Metamask bind:walletState>
  <Main wallet={walletState} />
</Metamask>