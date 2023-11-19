<script lang="ts">
	import type { ClientComponents } from '$lib/mud/createClientComponents';
	import { components, player, blockNumber, systemCalls } from '$lib/stores';
	import { getComponentValue } from '@latticexyz/recs';
	import { singletonEntity } from '@latticexyz/store-sync/recs';

	let config: ClientComponents['Config'] | undefined;
	let canSettle = false;

	$: {
		if ($components?.Config) {
			$components?.Config.update$.subscribe(() => {
				config = getComponentValue($components.Config, singletonEntity);
			});
		}
	}

	$: if ($blockNumber % 10 === 0 && $systemCalls?.canSettle()) {
		callSettleSystem();
	}

	const burn = async () => {
		try {
			await $systemCalls?.burn(100n);
		} catch (error) {
			console.error(error);
		}
	};

	const settleGame = async () => {
		try {
			await $systemCalls?.settleGame();
		} catch (error) {
			console.error(error);
		}
	};

	const callSettleSystem = async () => {
		console.log('$systemCalls: ', $systemCalls);

		canSettle = await $systemCalls.canSettle();
	};

	// // call once at first
	// callSettleSystem();
</script>

<!-- {#if $player} -->
	<button class="burn" on:click={burn}> Burn </button>
<!-- {/if} -->
{#if canSettle}
	<button class="burn" on:click={settleGame}> Settle Game </button>
{/if}

<!-- {#if $canSettle} -->
<!-- {/if} -->

<style>
	.burn {
		padding: 0.5rem 1rem;
		background: orangered;
		border: transparent;
		font-size: 16px;
		border-radius: 5px;
		margin-top: 0.5rem;
		cursor: pointer;
	}

	.burn:hover {
		background: white;
		color: orangered;
	}
</style>
