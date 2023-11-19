<script lang="ts">
  import { components, systemCalls } from "$lib/stores"
  import { Has, runQuery, getComponentValueStrict } from "@latticexyz/recs";
  import { slice, bytesToString } from "viem"
  // import Upload from "./Upload.svelte"

  let rules = []

  function hexToUtf8(hex) {
    // Slice the hex string into pairs of two characters
    const hexPairs = hex.match(/.{1,2}/g);

    // Convert each pair from hexadecimal to decimal
    const decimalValues = hexPairs.map(pair => parseInt(pair, 16));

    // Convert decimal values to UTF-8 characters
    const utf8Array = new Uint8Array(decimalValues);
    const utf8String = new TextDecoder('utf-8').decode(utf8Array);

    return utf8String;
}
  
  // query for all named players at the center of the universe
  $: {
    if ($components && $components?.Systems) {  
      const matchingEntities = runQuery([
        Has($components.Systems)
      ])

      const syss = ["govern", "burn", "settleround", "join", "settlegame"]

      rules = [...matchingEntities].map(ent => {
        const systemAddressName = ent.slice(32, 64)
        const name = hexToUtf8(systemAddressName)

        return { name, address: getComponentValueStrict($components?.Systems, ent) }
      }).filter(({ name }) => {
        return syss.some(s => name.toLowerCase().includes(s))
      })

    }
  }
</script>

<h1>
  Rules
</h1>

{#if rules.length > 0}
  {#each rules as rule, i (i)}
    <div class="card">
      <div class="form-group">
        <p class="proposer">
          {rule.name}
          <p class="overflow">
            <a href="https://etherscan.io/address/{rule.address.system}" class="implementation">
              {rule.address.system}
            </a>
          </p>
        <p>
          <!-- <IPFSString url={rule.uri} /> -->
        </p>
        <p class="overflow">
          <!-- <a href="https://etherscan.io/address/{rule.implAddr}" class="implementation">
            {rule.implAddr}
          </a> -->
        </p>
        <p class="system">
          <!-- {rule.systemName} -->
        </p>
      </div>
    </div>
  {/each}
{:else}
  <p>
    No rules
  </p>
{/if}
