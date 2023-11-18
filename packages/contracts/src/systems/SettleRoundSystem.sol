// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";
import {Game, GameData} from "../codegen/index.sol";

import "forge-std/console2.sol";
import "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import {ResourceId, ResourceIdInstance} from "@latticexyz/store/src/ResourceId.sol";
import {WorldContextConsumer, WORLD_CONTEXT_CONSUMER_INTERFACE_ID} from "@latticexyz/world/src/WorldContext.sol";

// struct PlayerData {
//   PlayerStatus status;
//   uint32 lastCheckedTime;
//   uint256 ftBalance;
//   uint256 burnedAmount;
// }

contract SettleRoundSystem is System {
    // This function should be called once at every inital burning.
    function settleRound() public {
        uint256 gameStartTime = Game.getStartTime();
        uint256 currentRound = Game.getCurrentRound();
        // game not start
        if (block.timestamp < gameStartTime) {
            return;
        }

        uint256 calCurrentRound = (block.timestamp - gameStartTime) / Config.getRoundTimeLength();

        // console2.log("calCurrentRound: ", calCurrentRound);
        // round count fetched
        if (calCurrentRound == currentRound) {
            return;
        }

        // console2.log("time to settle round");

        GameData memory gameData = Game.get();

        uint256 lastRoundEnd = gameData.startTime + gameData.currentRound * Config.getRoundTimeLength();
        uint256 currentRoundEnd = lastRoundEnd + Config.getRoundTimeLength();

        address[] memory all_players = gameData.allPlayers;

        for (uint32 i = 0; i < all_players.length; i++) {
            address playerAddr = all_players[i];

            PlayerData memory playerData = Player.get(playerAddr);

            if (playerData.status == PlayerStatus.ALIVE) {
                if (
                    playerData.lastCheckedTime > lastRoundEnd && playerData.lastCheckedTime < currentRoundEnd
                        && playerData.burnedAmount >= Config.getBurnAmountPerRound()
                ) {
                    playerData.burnedAmount = 0;
                } else {
                    playerData.burnedAmount = 0;
                    playerData.status = PlayerStatus.DEAD;
                }
                Player.set(playerAddr, playerData);
            }
        }

        // increment round
        Game.setCurrentRound(gameData.currentRound + 1);
        // recusive run it, until no need to update it
        settleRound();
    }
}
