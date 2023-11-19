import { writable, derived, get, type Writable, type Readable } from 'svelte/store';
import { walletState } from '../metamask';
import { getComponentValue, type ComponentValue } from '@latticexyz/recs';
import { singletonEntity, encodeEntity } from '@latticexyz/store-sync/recs';
import type { SystemCalls } from '$lib/mud/createSystemCalls';
import type { ClientComponents } from '$lib/mud/createClientComponents';
import type { SetupNetworkResult } from '$lib/mud/setupNetwork';

export enum states {
	UNINITIATED,
	ALIVE,
	DEAD
}

export const network: Writable<SetupNetworkResult | undefined> =
	writable<SetupNetworkResult>(undefined);
export const blockNumber = writable(0);
export const count = writable(-1);
export const entities = writable({});
export const components: Writable<ClientComponents | undefined> =
	writable<ClientComponents>(undefined);
export const systemCalls: Writable<SystemCalls | undefined> = writable<SystemCalls>(undefined);

export function createComponentSystem(componentKey: string) {
	get(components)[componentKey].update$.subscribe((update) => {
		// console.log("==>", componentKey, update);
		const [nextValue] = update.value;

		// Single-value components have a "value" property, structs do not
		const newValue =
			nextValue && Object.prototype.hasOwnProperty.call(nextValue, 'value')
				? nextValue.value
				: nextValue;

		const entityID = update.entity;

		entities.update((value) => {
			// Create an empty entity if it does not exist
			if (value[entityID] === undefined) value[entityID] = {};

			// Set or delete
			if (newValue === undefined) {
				delete value[entityID][componentKey];
			} else {
				value[entityID][componentKey] = newValue;
			}

			return value;
		});
	});
}

export const player = derived(
	[components, blockNumber, walletState],
	([$components, $blockNumber, $walletState]) => {
		if (!$walletState.account || !$components?.Player) return;

		if ($blockNumber) {
		}
		const address = encodeEntity({ address: 'address' }, { address: $walletState.account });

		const p = getComponentValue($components?.Player, address);

		return p;
	}
);

export const game = derived([components, blockNumber], ([$components, $blockNumber]) => {
	if (!$components?.Game) return;

	if ($blockNumber) {
		const g = getComponentValue($components?.Game, singletonEntity);

		return g;
	}
});

export const config = derived(
	[entities, components, walletState],
	([$entities, $components, $walletState]) => {
		if (!$components?.Config) return;

		const g = getComponentValue($components?.Config, singletonEntity);

		if (!g) return false;

		return g;
	}
);

export const gameStarted = derived([game, blockNumber], ([$game, $blockNumber]) => {
	if (!$game) return false;

	if ($blockNumber) {
		const blockTime = Math.ceil(new Date().getTime() / 1000);
		return $game.blockTime > blockTime;
	}

	return false;
});

export const canSettle = derived([systemCalls], ([$systemCalls]) => {
	return $systemCalls?.canSettle();
});

export const timeLeft = derived(
	[game, player, config, blockNumber],
	([$game, $player, $config, $blockNumber]) => {
		if (!$game) return 0;

		if ($blockNumber) {
			const roundForPlayer = Math.ceil(
				($player?.lastCheckedTime - $game.startTime) / $config?.roundTimeLength
			);
			let endTime = $game.startTime + ($game.currentRound + 1) * $config?.roundTimeLength;
			const now = new Date().getTime() / 1000;

			// at most add a period once
			if (endTime < now) {
				endTime += $config?.roundTimeLength;
			}

			return Math.ceil(endTime - now);
		}

		return 0;
	}
);

export const burned = derived(
	[game, config, player, blockNumber, network],
	([$game, $config, $player, $blockNumber, $network]) => {
		// console.log("DEBUGGER", $game, $player)
		if (!$game || !$player) return false;

		if ($blockNumber) console.log('tick');
		const lastDeadline = $game.startTime + $game.currentRound * $config.roundTimeLength;
		const deadline = $game.startTime + ($game.currentRound + 1) * $config.roundTimeLength;

		// console.log(lastDeadline, deadline, $player.lastCheckedTime)

		if ($player.status === states.ALIVE) {
			if (
				$player.lastCheckedTime > lastDeadline &&
				$player.lastCheckedTime < deadline &&
				Number($player.burnedAmount) >= Number($config.burnAmountPerRound)
			) {
				return true;
			}
		}
	}
);
