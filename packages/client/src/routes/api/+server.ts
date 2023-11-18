import { error, json } from "@sveltejs/kit"
import { W3S_KEY, W3S_PROOF } from '$env/static/private';

import * as Client from '@web3-storage/w3up-client'
import * as Signer from '@ucanto/principal/ed25519'
import { importDAG } from '@ucanto/core/delegation'
import { CarReader } from '@ipld/car'

 /** @param {string} data Base64 encoded CAR file \*/
 async function parseProof (data) {
  const blocks = []
  const reader = await CarReader.fromBytes(Buffer.from(data, 'base64'))
  for await (const block of reader.blocks()) {
    blocks.push(block)
  }
  return importDAG(blocks)
}
 
export const POST = async ({ request }) => {
  const data = await request.formData()
  const text = await data.get("text")

  if (!text) throw error(422)

  // Load client with specific private key
  const principal = Signer.parse(W3S_KEY)
  const client = await Client.create({ principal })

  // Add proof that this agent has been delegated capabilities on the space
  const proof = await parseProof(W3S_PROOF)
  const space = await client.addSpace(proof)
  await client.setCurrentSpace(space.did())
  // READY to go!

  // Now upload files

  const file = new File([text], "test.md")

  const result = await client.uploadFile(file)

  if (!result) throw error(500, "Could not upload")

  return new Response(result)
}
