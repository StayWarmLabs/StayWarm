/*
 * Create the system calls that the client can use to ask
 * for changes in the World state (using the System contracts).
 */

import type { ClientComponents } from "./createClientComponents";
import type { SetupNetworkResult } from "./setupNetwork";
import { getComponentValue } from "@latticexyz/recs";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import { parseEther } from "viem"

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  /*
   * The parameter list informs TypeScript that:
   *
   * - The first parameter is expected to be a
   *   SetupNetworkResult, as defined in setupNetwork.ts
   *
   *   Out of this parameter, we only care about two fields:
   *   - worldContract (which comes from getContract, see
   *     https://github.com/latticexyz/mud/blob/main/templates/vanilla/packages/client/src/mud/setupNetwork.ts#L63-L69).
   *
   *   - waitForTransaction (which comes from syncToRecs, see
   *     https://github.com/latticexyz/mud/blob/main/templates/vanilla/packages/client/src/mud/setupNetwork.ts#L77-L83).
   *
   * - From the second parameter, which is a ClientComponent,
   *   we only care about Counter. This parameter comes to use
   *   through createClientComponents.ts, but it originates in
   *   syncToRecs
   *   (https://github.com/latticexyz/mud/blob/main/templates/vanilla/packages/client/src/mud/setupNetwork.ts#L77-L83).
   */
  { worldContract, waitForTransaction }: SetupNetworkResult,
  { Game }: ClientComponents
) {

  /**
   * Join game
   * @returns 
   */
  const joinGame = async () => {
    console.log("attempting to join")
    const tx = await worldContract.write.join({ value: parseEther("0.05")})

    await waitForTransaction(tx);
    console.log("transaction done")
    const game = getComponentValue(Game, singletonEntity)
    console.log(game)
    return game;
  }

  /**
   * Propose
   * @param address 
   * @param systemName 
   * @param uri 
   */
  const propose = async (address: string, systemName: string, uri: string) => {
    const tx = await worldContract.write.makeProposal([address, systemName, uri])

    await waitForTransaction(tx);
  }

  /**
   * Burn
   */
  const burn = async (amount = 1) => {
    const tx = await worldContract.write.burn({ value: amount })

    await waitForTransaction(tx);
  }

  return {
    joinGame,
    burn,
    propose
  };
}
