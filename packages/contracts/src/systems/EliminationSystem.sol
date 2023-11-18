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


contract EliminationSystem is System {
    function eliminate() public returns (bool) {
        
        // TODO: calculate the time.
        GameData memory gameData = Game.get();
        uint start_time = gameData.startTime;
        uint current_round = gameData.currentRound;
        uint last_deadline = start_time + (current_round - 1) * 1 days;
        uint deadline = start_time + (current_round) * 1 days;
        address[] memory all_players = gameData.allPlayers;

        // address player = _msgSender();
        // PlayerData memory playerData = Player.get(player);

        // config
        uint256 burn_amount = Config.getBurnAmountPerRound();



        for (uint32 i = 0; i < all_players.length; i++) {
            address playerAddr = all_players[i];

            PlayerData memory playerData = Player.get(playerAddr);

            if (playerData.status == PlayerStatus.ALIVE) {
                if (playerData.lastCheckedTime > last_deadline
                        && playerData.lastCheckedTime < deadline
                        && playerData.burnedAmount >= burn_amount) {
                    playerData.burnedAmount = 0;
                } else {
                    playerData.status = PlayerStatus.DEAD;
                }
                Player.set(playerAddr, playerData);
            }
        }
        return true;
    }
}
