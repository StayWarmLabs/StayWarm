// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {getKeysWithValue} from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import {IWorld} from "../../src/codegen/world/IWorld.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../../src/codegen/index.sol";
import {Player, PlayerData} from "../../src/codegen/index.sol";
import {PlayerStatus} from "../../src/codegen/common.sol";
import {Game, GameData} from "../../src/codegen/index.sol";

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

contract JoinTest is MudTest {
    function testJoin() public {
        uint256 join_fee = Config.getJoinFee();

        address alice = address(0x1);
        vm.deal(alice, 10 ether);
        vm.prank(alice);

        IWorld(worldAddress).join{value: join_fee}();

        ConfigData memory cfg = Config.get();

        GameData memory gameData = Game.get();
        address[] memory all_players = gameData.allPlayers;

        assertEq(all_players.length, 1);
        // assertEq(all_players[0], _msgSender());

        PlayerData memory playerData = Player.get(all_players[0]);

        assert(playerData.status == PlayerStatus.ALIVE);

        assertEq(playerData.ftBalance, cfg.initialBalance);
        assertEq(playerData.burnedAmount, 0);

        assertEq(gameData.ethTotalAmount, cfg.joinFee);

        assert(gameData.startTime > 0);
    }
}
