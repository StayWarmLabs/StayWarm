import { json } from "@sveltejs/kit"
import { randomBytes } from 'crypto'
import secp256k1 from "secp256k1"

export const GET = async ({ fetch, url }) => {
  // generate privKey
  const address = url.searchParams.get("address")

  let data = new FormData();

  if (!address) return

  let privKey
  do {
    privKey = randomBytes(32)
  } while (!secp256k1.privateKeyVerify(privKey))
  
  // get the public key in a compressed format
  const pubKey = secp256k1.publicKeyCreate(privKey)
  
  // Fetch the proof payload
  const payload = {
    action: "create",
    platform: "ethereum",
    identity: address,
    public_key: pubKey,
  }
  
  for (let key in payload) {
    data.append(key, payload[key])
    console.log(payload[key])
  }
  
  try {
    const response = await fetch("https://proof-service.next.id/v1/proof/payload", { method: "POST", body: data })
    const result = await response.json()
    console.log(result)
    return json(result)

  } catch (error) {
    console.error(error)
  }
  
  
  
}