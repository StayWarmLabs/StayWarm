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

contract SettleRoundTest is MudTest {
    function testSettleRound() public {
        uint256 join_fee = Config.getJoinFee();
        uint256 burn_amount = Config.getBurnAmountPerRound();

        address alice = address(0x1);
        vm.deal(alice, 10 ether);
        vm.prank(alice);
        IWorld(worldAddress).join{value: join_fee}();

        address bob = address(0x2);
        vm.deal(bob, 10 ether);
        vm.prank(bob);
        IWorld(worldAddress).join{value: join_fee}();

        // skip until game start
        skip(Config.getGameStartWaitingTime() + 1);

        console2.log("#####################");
        console2.log("###### ROUND 0 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        vm.prank(bob);
        IWorld(worldAddress).burn(burn_amount);

        PlayerData memory aliceData = Player.get(address(0x1));
        PlayerData memory bobData = Player.get(address(0x2));

        GameData memory gameData = Game.get();

        assertEq(aliceData.burnedAmount, burn_amount);
        assertEq(bobData.burnedAmount, burn_amount);

        // call eliminate function next round.
        skip(Config.getRoundTimeLength());

        console2.log("#####################");
        console2.log("###### ROUND 1 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        assertEq(Player.getBurnedAmount(alice), 0);
        assertEq(Player.getBurnedAmount(bob), 0);
        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.ALIVE));
    }

    function testEliminateAlice() public {
        uint256 join_fee = Config.getJoinFee();
        uint256 burn_amount = Config.getBurnAmountPerRound();

        address alice = address(0x1);
        vm.deal(alice, 10 ether);
        vm.prank(alice);
        IWorld(worldAddress).join{value: join_fee}();

        // ROUND 0
        // skip until game start

        skip(Config.getGameStartWaitingTime() + 1);

        console2.log("#####################");
        console2.log("###### ROUND 0 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 1
        skip(Config.getRoundTimeLength());
        console2.log("#####################");
        console2.log("###### ROUND 1 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 2
        skip(Config.getRoundTimeLength());

        console2.log("#####################");
        console2.log("###### ROUND 2 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 3
        skip(Config.getRoundTimeLength());
        console2.log("#####################");
        console2.log("###### ROUND 3 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 4
        skip(Config.getRoundTimeLength());
        console2.log("#####################");
        console2.log("###### ROUND 4 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        console2.log("alice status: ", uint256(Player.get(address(0x1)).status));
        console2.log("alice balanced: ", Player.get(address(0x1)).ftBalance);
        console2.log("game current round: ", Game.getCurrentRound());

        // ROUND 5
        skip(Config.getRoundTimeLength());
        console2.log("#####################");
        console2.log("###### ROUND 5 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 6
        skip(Config.getRoundTimeLength());
        console2.log("#####################");
        console2.log("###### ROUND 6 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 7
        skip(Config.getRoundTimeLength());
        console2.log("#####################");
        console2.log("###### ROUND 7 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        // ROUND 8
        skip(Config.getRoundTimeLength());
        console2.log("#####################");
        console2.log("###### ROUND 8 ######");
        console2.log("#####################");

        IWorld(worldAddress).settleRound();

        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.DEAD));
    }
}
