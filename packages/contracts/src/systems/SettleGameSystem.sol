// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/console2.sol";

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
        console2.log("THIS IS SETTLE GAME");

        // call settle round before each tx
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).settleRound, ()));


        GameData memory gameData = Game.get();
        address[] memory all_players = gameData.allPlayers;

        uint256 numAlives = 0;
        uint256 numLastAlives = 0;

        uint256 prize = address(this).balance;


        for (uint32 i = 0; i < all_players.length; i++) {
            address playerAddr = all_players[i];

            PlayerData memory playerData = Player.get(playerAddr);

            if (playerData.status == PlayerStatus.ALIVE) {
                numAlives++;
            }
        }

        if (numAlives == 1) {
            for (uint32 i = 0; i < all_players.length; i++) {
                address playerAddr = all_players[i];

                if (Player.getStatus(playerAddr) == PlayerStatus.ALIVE) {
                    (bool success, ) = payable(playerAddr).call{value: prize}("");
                    require(success, "SettleGameSystem: failed to transfer prize to player");
                    Player.deleteRecord(playerAddr);
                } else {
                    Player.deleteRecord(playerAddr);
                }
            }
            Game.deleteRecord();
            return true;
        }

        if (numAlives != 0) {
            return false;
        }

        // if num Alives == 0, distribute the prize to the players who were alive in last round

        // treat 0 and 1 round as a special case
        if (Game.getCurrentRound() == 0) {
            return false;
        } else if (Game.getCurrentRound() == 1) {
            for (uint32 i = 0; i < all_players.length; i++) {
                address playerAddr = all_players[i];

                (bool success, ) = payable(playerAddr).call{value: prize / all_players.length}("");
                require(success, "SettleGameSystem: failed to transfer prize to player");
                Player.deleteRecord(playerAddr);
            }
            Game.deleteRecord();
            return true;
        }
        
        
        // require(Game.getCurrentRound() > 1, "SettleGameSystem: should not calle settleGame before round 2");

        uint256 start_time = gameData.startTime;
        uint256 current_round = gameData.currentRound;
        uint256 penultimate_deadline = start_time + (current_round - 2) * Config.getRoundTimeLength();
        uint256 last_deadline = start_time + (current_round - 1) * Config.getRoundTimeLength();

        console2.log("prize: ", prize);

        // check the number of players
        for (uint32 i = 0; i < all_players.length; i++) {
            address playerAddr = all_players[i];

            PlayerData memory playerData = Player.get(playerAddr);

            if (playerData.lastCheckedTime > penultimate_deadline
                    && playerData.lastCheckedTime < last_deadline) {
                numLastAlives++;
            }

            console2.log("player: ", playerAddr);
            console2.log("player status: ", playerData.lastCheckedTime);
        }

        console2.log("Current round: ", current_round);
        console2.log("penultimate_deadline: ", penultimate_deadline);
        console2.log("last_deadline: ", last_deadline);
        console2.log("block time", block.timestamp);

        console2.log("numAlives: ", numAlives);
        console2.log("numLastAlives: ", numLastAlives);

        // if there is no player,
        // distribute the prize to the players who were alive in last round
        for (uint32 i = 0; i < all_players.length; i++) {
            address playerAddr = all_players[i];

            if (Player.getLastCheckedTime(playerAddr) > penultimate_deadline
                    && Player.getLastCheckedTime(playerAddr) < last_deadline) {
                if (numLastAlives != 0) {
                    (bool success, ) = payable(playerAddr).call{value: prize / numLastAlives}("");
                    require(success, "SettleGameSystem: failed to transfer prize to player");
                } else {
                    (bool success, ) = payable(playerAddr).call{value: prize / all_players.length}("");
                    require(success, "SettleGameSystem: failed to transfer prize to player");
                }
                Player.deleteRecord(playerAddr);
            } else {
                Player.deleteRecord(playerAddr);
            }
        }
        Game.deleteRecord();
        return true;

    }
}
