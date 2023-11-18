// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {getKeysWithValue} from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import {IWorld} from "../src/codegen/world/IWorld.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../src/codegen/index.sol";
import {Player, PlayerData} from "../src/codegen/index.sol";
import {PlayerStatus} from "../src/codegen/common.sol";
import {Game, GameData} from "../src/codegen/index.sol";

// Game: {
//       keySchema: {},
//       valueSchema: {
//         startTime: "uint32",
//         ethTotalAmount: "uint256",
//         currentRound: "uint32",
//         executeFuncSig: "bytes32",
//         executeArgs: "bytes32",
//         allPlayers: "address[]",
//       },
//     },
//     //
//     Player: {
//       keySchema: { key: "address" },
//       valueSchema: {
//         status: "PlayerStatus",
//         lastCheckedTime: "uint32",
//         ftBalance: "uint256",
//         burnedAmount: "uint256",
//       },
//     },

contract BurnTest is MudTest {
    function testBurn() public {
        uint256 join_fee = Config.getJoinFee();
        uint256 burn_amount = Config.getBurnAmountPerRound();

        address alice = address(0x1);
        vm.deal(alice, 10 ether);
        vm.prank(alice);

        IWorld(worldAddress).join{value: join_fee}();

        ConfigData memory cfg = Config.get();

        GameData memory gameData = Game.get();
        address[] memory all_players = gameData.allPlayers;

        uint256 wait_time = Config.getGameStartWaitingTime();
        console2.log(wait_time);

        skip(wait_time + 1);

        vm.prank(alice);

        bool test = IWorld(worldAddress).burn();

        PlayerData memory aliceData = Player.get(all_players[0]);
        assert(aliceData.status == PlayerStatus.ALIVE);

        assertEq(test, true);

        console2.log("lastCheckedTime: ", aliceData.lastCheckedTime);
        console2.log("startTime: ", gameData.startTime);
        console2.log("deadLine: ", gameData.startTime + (gameData.currentRound + 1) * 1 days);
        console2.log("ftBalance: ", aliceData.ftBalance);
        console2.log("burnedAmount: ", aliceData.burnedAmount);

        assertEq(aliceData.ftBalance, cfg.initialBalance - burn_amount);
        assertEq(aliceData.burnedAmount, burn_amount);

        assert(aliceData.lastCheckedTime > gameData.startTime + gameData.currentRound * 1 days);
        assert(aliceData.lastCheckedTime < gameData.startTime + (gameData.currentRound + 1) * 1 days);
    }
}
