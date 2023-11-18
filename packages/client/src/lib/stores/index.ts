
import { writable, derived, get } from "svelte/store"
import { walletState } from "../metamask"
import { getComponentValue } from "@latticexyz/recs";
import { singletonEntity, encodeEntity } from "@latticexyz/store-sync/recs";

export enum states {
  UNINITIATED,
  ALIVE,
  DEAD
}

export const network = writable(null)
export const blockNumber = writable(0)
export const count = writable(-1)
export const entities = writable({})
export const components = writable(null)
export const systemCalls = writable(null)

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

    entities.update(value => {
      // Create an empty entity if it does not exist
      if (value[entityID] === undefined) value[entityID] = {}

      // Set or delete
      if (newValue === undefined) {
        delete value[entityID][componentKey]
      } else {
        value[entityID][componentKey] = newValue
      }

      return value
    })
  })
}

export const player = derived([entities, components, walletState], ([$entities, $components, $walletState]) => {
  if (!$walletState.account) return false

  const address = encodeEntity({address: "address"}, { address: $walletState.account })

  if (!$components?.Player) return

  const p = getComponentValue($components?.Player, address)

  if (!p) return false

  return p
})

export const game = derived([entities, components, walletState], ([$entities, $components, $walletState]) => {
  if (!$components?.Game) return

  const g = getComponentValue($components?.Game, singletonEntity)

  if (!g) return false

  return g
})

export const config = derived([entities, components, walletState], ([$entities, $components, $walletState]) => {
  if (!$components?.Config) return

  const g = getComponentValue($components?.Config, singletonEntity)

  if (!g) return false

  return g
})

export const gameStarted = derived(([game, blockNumber]), ([$game, $blockNumber]) => {
  if (!$game) return false

  if ($blockNumber) {
    const blockTime = Math.ceil(new Date().getTime() / 1000)
    return $game.blockTime > blockTime
  }

  return false
})


export const burned = derived([game, config, player, blockNumber, network], (([$game, $config, $player, $blockNumber, $network]) => {
  if (!$game || !$player) return false

  const day = 60 * 60 * 24 * 1000 // in ms
  const lastDeadline = $game.startTime + ($game.currentRound) * day
  const deadline = $game.startTime + ($game.currentRound + 1) * day

  // console.log(lastDeadline, deadline, $player.lastCheckedTime)
  
  if ($player.status === states.ALIVE) {
    if ($player.lastCheckedTime > lastDeadline && $player.lastCheckedTime < deadline && Number($player.burnedAmount) >= Number($config.burnAmountPerRound)) {
      return true
    }
  }

  return false
}))