// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";
import {Game, GameData} from "../codegen/index.sol";
import {IWorld} from "src/codegen/world/IWorld.sol";
import {SystemSwitch} from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";

contract SettleGameSystem is System {
    // return true if the game is over
    // return false if the game is not over
    function settleGame() public payable returns (bool) {
        // call settle round before each tx
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).settleRound, ()));

        GameData memory gameData = Game.get();
        uint256 start_time = gameData.startTime;
        uint256 current_round = gameData.currentRound;
        uint256 penultimate_deadline = start_time + (current_round - 2) * 1 days;
        uint256 last_deadline = start_time + (current_round - 1) * 1 days;
        address[] memory all_players = gameData.allPlayers;

        uint256 numAlives = 0;
        uint256 numLastAlives = 0;

        uint256 prize = address(this).balance;

        // check the number of players
        for (uint32 i = 0; i < all_players.length; i++) {
            address playerAddr = all_players[i];

            PlayerData memory playerData = Player.get(playerAddr);

            if (playerData.status == PlayerStatus.ALIVE) {
                numAlives++;
            }

            if (playerData.lastCheckedTime > penultimate_deadline && playerData.lastCheckedTime < last_deadline) {
                numLastAlives++;
            }
        }

        // if there is only one player, distribute the prize to the player
        if (numAlives == 1) {
            for (uint32 i = 0; i < all_players.length; i++) {
                address playerAddr = all_players[i];

                PlayerData memory playerData = Player.get(playerAddr);
                if (playerData.status == PlayerStatus.ALIVE) {
                    payable(playerAddr).transfer(prize);
                }
            }
            return true;
        }

        // if there is no player,
        // distribute the prize to the players who were alive in last round

        if (numAlives == 0) {
            for (uint32 i = 0; i < all_players.length; i++) {
                address playerAddr = all_players[i];

                PlayerData memory playerData = Player.get(playerAddr);

                if (playerData.status == PlayerStatus.DEAD) {
                    payable(playerAddr).transfer(address(this).balance);
                }

                if (playerData.lastCheckedTime > penultimate_deadline && playerData.lastCheckedTime < last_deadline) {
                    payable(playerAddr).transfer(prize / numLastAlives);
                }
            }
            return true;
        }

        return false;
    }
}
