<script lang="ts">
  import * as Client from '@web3-storage/w3up-client'
  import * as Signer from '@ucanto/principal/ed25519'
  import { onMount } from "svelte"
  import { importDAG } from '@ucanto/core/delegation'
  import { CarReader } from '@ipld/car'

  let text: string
   
  async function init () {
    // Load client with specific private key
    const principal = Signer.parse(import.meta.env.W3S_KEY)
    const client = await Client.create({ principal })
    // Add proof that this agent has been delegated capabilities on the space
    const proof = await parseProof(import.meta.env.W3S_PROOF)
    const space = await client.addSpace(proof)
    await client.setCurrentSpace(space.did())
    // READY to go!

  }
   
  /** @param {string} data Base64 encoded CAR file \*/
  async function parseProof (data) {
    const blocks = []
    const reader = await CarReader.fromBytes(Buffer.from(data, 'base64'))
    for await (const block of reader.blocks()) {
      blocks.push(block)
    }
    return importDAG(blocks)
  }

  onMount(init)
</script>

<input placeholder="proposal" type="text" name="" id="" bind:value={text}>
