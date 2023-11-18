// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";
import {Game, GameData} from "../codegen/index.sol";

// import {Counter} from "../codegen/index.sol";
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
        // return if this function is called at this round or not
        if (Game.getCurrentRound() != 0) {
            if (block.timestamp < Game.getStartTime() + (Game.getCurrentRound() + 1) * Config.getRoundTimeLength()) {
                return;
            }

            if (block.timestamp > Game.getStartTime() + (Game.getCurrentRound() + 2) * Config.getRoundTimeLength()) {
                return;
            }
        }
        // else {
        //     if (block.timestamp < Game.getStartTime() + Config.getRoundTimeLength()) {
        //         return;
        //     }
        // }
        

        GameData memory gameData = Game.get();
        gameData.currentRound++;
        Game.set(gameData);

        uint256 last_deadline = gameData.startTime + (gameData.currentRound - 1) * Config.getRoundTimeLength();
        uint256 deadline = gameData.startTime + (gameData.currentRound) * Config.getRoundTimeLength();
        address[] memory all_players = gameData.allPlayers;


        for (uint32 i = 0; i < all_players.length; i++) {
            address playerAddr = all_players[i];

            PlayerData memory playerData = Player.get(playerAddr);

            if (playerData.status == PlayerStatus.ALIVE) {
                if (
                    playerData.lastCheckedTime > last_deadline
                        && playerData.lastCheckedTime < deadline
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
    }
}
