/*
 * The supported chains.
 * By default, there are only two chains here:
 *
 * - mudFoundry, the chain running on anvil that pnpm dev
 *   starts by default. It is similar to the viem anvil chain
 *   (see https://viem.sh/docs/clients/test.html), but with the
 *   basefee set to zero to avoid transaction fees.
 * - latticeTestnet, our public test network.
 *
 */

import type { MUDChain } from '@latticexyz/common/chains';
import { latticeTestnet, mudFoundry } from '@latticexyz/common/chains';

export const baseSepolia = /*#__PURE__*/ {
	id: 84532,
	network: 'base-sepolia',
	name: 'Base Sepolia',
	nativeCurrency: { name: 'Sepolia Ether', symbol: 'ETH', decimals: 18 },
	rpcUrls: {
		alchemy: {
			http: ['https://base-sepolia.g.alchemy.com/v2'],
			webSocket: ['wss://base-sepolia.g.alchemy.com/v2']
		},
		default: {
			http: ['https://sepolia.base.org']
		},
		public: {
			http: ['https://sepolia.base.org']
		}
	},
	blockExplorers: {
		etherscan: {
			name: 'Basescan',
			url: 'https://sepolia.basescan.org'
		},
		default: {
			name: 'Basescan',
			url: 'https://sepolia.basescan.org'
		}
	},

	testnet: true,
	sourceId: 5 // goerli
};

/*
 * See https://mud.dev/tutorials/minimal/deploy#run-the-user-interface
 * for instructions on how to add networks.
 */
export const supportedChains: MUDChain[] = [mudFoundry, latticeTestnet, baseSepolia];
