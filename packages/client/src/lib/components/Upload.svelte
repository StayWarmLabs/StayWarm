<script lang="ts">
  import { components } from "$lib/stores"
  let form: HTMLFormElement

  const submit = async () => {
    const data = new FormData(form)
    const cid = await fetch("/api", { method: "POST", body: data })

    const str = await cid.text()

    const file = `https://${str}.ipfs.w3s.link/`
  }
</script>

<div class="">
  New proposal
  <form bind:this={form} on:submit|preventDefault={submit}>
    <input placeholder="contract address" type="text" name="address" id="">
    <input placeholder="proposal" type="text" name="text" id="">
    <input type="submit" value="Submit proposal">
  </form>
</div>

<div class="">
  Current proposals
  
</div>
