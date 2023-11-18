<script lang="ts">
  import { onMount } from "svelte"
  export let url: string

  const gateway = url.replaceAll("ipfs://", "https://") + ".ipfs.w3s.link/"
  let string = ""

  onMount(async () => {
    const result = await fetch(gateway)
    console.log(result)

    const str = await result.text()

    string = str

  })
  // https://bafkreih4a3ag7bjv3qtegy3xgyfrwvtu7zi56ddxllti243cscodhi5hvi.ipfs.w3s.link/
</script>

{string}