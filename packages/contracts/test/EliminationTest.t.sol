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

contract EliminationTest is MudTest {
    function testEliminate() public {
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

        vm.prank(alice);
        bool alice_Burned = IWorld(worldAddress).burn(burn_amount);

        vm.prank(bob);
        bool bob_Burned = IWorld(worldAddress).burn(burn_amount);

        PlayerData memory aliceData = Player.get(address(0x1));
        PlayerData memory bobData = Player.get(address(0x2));

        assertEq(alice_Burned, true);
        assertEq(bob_Burned, true);

        GameData memory gameData = Game.get();

        console2.log("startTime: ", gameData.startTime);
        console2.log("deadLine: ", gameData.startTime + (gameData.currentRound + 1) * 1 days);
        console2.log("Alice burned", alice_Burned);
        console2.log("Bob burned: ", bob_Burned);

        console2.log("Alice burned ammount: ", aliceData.burnedAmount);
        console2.log("Bob burned ammount: ", bobData.burnedAmount);
        console2.log("Config.getRoundTimeLength: ", Config.getRoundTimeLength());

        assertEq(aliceData.burnedAmount, burn_amount);
        assertEq(bobData.burnedAmount, burn_amount);

        // call eliminate function next round.
        skip(Config.getRoundTimeLength());

        // gameData.currentRound += 1; in eliminate function
        uint256 last_deadline = gameData.startTime + (gameData.currentRound + 1) * 1 days;
        uint256 deadline = gameData.startTime + (gameData.currentRound + 2) * 1 days;

        console2.log("last_deadline: ", last_deadline);
        console2.log("deadline: ", deadline);
        console2.log("current time: ", block.timestamp);

        vm.prank(alice);
        IWorld(worldAddress).eliminate();

        aliceData = Player.get(address(0x1));
        bobData = Player.get(address(0x2));

        assertEq(aliceData.burnedAmount, 0);
        assertEq(bobData.burnedAmount, 0);
        assert(aliceData.status == PlayerStatus.ALIVE);
        assert(bobData.status == PlayerStatus.ALIVE);
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

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 1
        skip(Config.getRoundTimeLength());

        vm.prank(alice);
        IWorld(worldAddress).eliminate();

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        console2.log("alice status: ", uint256(Player.get(address(0x1)).status));
        console2.log("alice balanced: ", Player.get(address(0x1)).ftBalance);

        console2.log("game current round: ", Game.getCurrentRound());
        console2.log("game start time: ", Game.getStartTime());
        console2.log("last deadline:", Game.getStartTime() + Game.getCurrentRound() * 1 days);
        console2.log("deadline:", Game.getStartTime() + (Game.getCurrentRound() + 1) * 1 days);
        console2.log("current time:", block.timestamp);

        // ROUND 2
        skip(Config.getRoundTimeLength());

        vm.prank(alice);
        IWorld(worldAddress).eliminate();

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 3
        skip(Config.getRoundTimeLength());
        vm.prank(alice);
        IWorld(worldAddress).eliminate();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 4
        skip(Config.getRoundTimeLength());
        vm.prank(alice);
        IWorld(worldAddress).eliminate();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 5
        skip(Config.getRoundTimeLength());
        vm.prank(alice);
        IWorld(worldAddress).eliminate();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // ROUND 6
        skip(Config.getRoundTimeLength());
        vm.prank(alice);
        IWorld(worldAddress).eliminate();
        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        console2.log("alice status: ", uint256(Player.get(address(0x1)).status));
        console2.log("alice balanced: ", Player.get(address(0x1)).ftBalance);

        // ROUND 7
        skip(Config.getRoundTimeLength());
        vm.prank(alice);
        IWorld(worldAddress).eliminate();
        // assert(IWorld(worldAddress).burn() == false); // cannot burn

        console2.log("alice status: ", uint256(Player.get(address(0x1)).status));
        console2.log("alice balanced: ", Player.get(address(0x1)).ftBalance);

        // ROUND 8
        vm.prank(alice);
        IWorld(worldAddress).eliminate();

        console2.log("alice status: ", uint256(Player.get(address(0x1)).status));
        console2.log("alice balanced: ", Player.get(address(0x1)).ftBalance);

        assert(Player.get(address(0x1)).status == PlayerStatus.DEAD);
    }
}
