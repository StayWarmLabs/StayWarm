// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/console2.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";
import {Game, GameData} from "../codegen/index.sol";
// import {PlayerList} from "../codegen/index.sol";

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

contract JoinSystem is System {
    function join() public payable returns (bool) {
        address player = _msgSender();
        PlayerData memory playerData = Player.get(player);
        GameData memory gameData = Game.get();

        // player has already joined
        if (playerData.status != PlayerStatus.UNINITIATED) {
            return false;
        }
        
        if (gameData.startTime == 0) {
            gameData.startTime = uint32(block.timestamp) + Config.getGameStartWaitingTime();
            Game.set(gameData);
        }

        // check if the time is correct
        require(block.timestamp < gameData.startTime, "JoinSystem: game has already started");

        // player has not joined yet
        uint256 join_fee = Config.getJoinFee();
        uint256 initial_balance = Config.getInitialBalance();

        //deposit fee
        require(msg.value == join_fee, "JoinSystem: deposit amount must be 0.05 ether");


        // ADD NEW PLAYER
        playerData.status = PlayerStatus.ALIVE;
        playerData.lastCheckedTime = uint32(block.timestamp);
        playerData.ftBalance = initial_balance;
        playerData.burnedAmount = 0;

        address[] memory all_players = new address[](gameData.allPlayers.length + 1);

        for (uint256 i = 0; i < gameData.allPlayers.length; i++) {
            all_players[i] = gameData.allPlayers[i];
        }

        // console.log("all_players");
        all_players[gameData.allPlayers.length] = player;
        gameData.allPlayers = all_players;
        gameData.ethTotalAmount += join_fee;

        if (gameData.startTime == 0) {
            gameData.startTime = uint32(block.timestamp) + Config.getGameStartWaitingTime();
        }

        // gameData.numPlayers += 1;
        Game.set(gameData);

        Player.set(player, playerData);
        return true;
    }
}
