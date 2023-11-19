import { json } from "@sveltejs/kit"
import { randomBytes } from 'crypto'
import { bytesToHex } from "viem"
import secp256k1 from "secp256k1"

export const GET = async ({ fetch, url }) => {
  // generate privKey
  const address = url.searchParams.get("address")

  if (!address) return

  let privKey
  do {
    privKey = randomBytes(32)
  } while (!secp256k1.privateKeyVerify(privKey))
  
  // get the public key in a compressed format
  const pubKey = secp256k1.publicKeyCreate(privKey)
  
  const stringKey = bytesToHex(pubKey);

  // Fetch the proof payload
  const payload = {
    action: "create",
    platform: "ethereum",
    identity: address,
    public_key: stringKey,
  }
  
  try {
    const response = await fetch("https://proof-service.next.id/v1/proof/payload", { method: "POST", body: JSON.stringify(payload) })
    const result = await response.json()
    return json(result)

  } catch (error) {
    // console.error(error)
  }
}