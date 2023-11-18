import { writable, derived, get } from "svelte/store"
import { walletState } from "../metamask"
import { encodeEntity } from "@latticexyz/store-sync/recs";

export const count = writable(-1)
export const entities = writable({})
export const components = writable(null)

export function createComponentSystem(componentKey: string) {
  get(components)[componentKey].update$.subscribe(update => {
    // console.log("==>", componentKey, update);
    const [nextValue] = update.value

    // Single-value components have a "value" property, structs do not
    const newValue =
      nextValue && Object.prototype.hasOwnProperty.call(nextValue, "value")
        ? nextValue.value
        : nextValue

    const entityID = update.entity
    const propertyName = componentKey

    entities.update(value => {
      // Create an empty entity if it does not exist
      if (value[entityID] === undefined) value[entityID] = {}

      // Set or delete
      if (newValue === undefined) {
        delete value[entityID][propertyName]
      } else {
        value[entityID][propertyName] = newValue
      }

      return value
    })
  })
}

export const player = derived([entities, walletState], ([$entities, $walletState]) => {
  if (!$walletState.account) return false

  const address = encodeEntity({address: "address"}, { address: $walletState.account })

  const p = $entities[address]

  if (!p) return false

  return p
})

export const config = derived(entities, ($entities) => {
  console.log($entities)

  return {}
})