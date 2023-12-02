// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {getKeysWithValue} from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import {IWorld} from "../../src/codegen/world/IWorld.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../../src/codegen/index.sol";
import {Player, PlayerData} from "../../src/codegen/index.sol";
import {PlayerStatus} from "../../src/codegen/common.sol";
import {Game, GameData} from "../../src/codegen/index.sol";


contract SettleGameTest is MudTest {
    function testSettleGame() public {
        uint256 join_fee = Config.getJoinFee();
        uint256 burn_amount = Config.getBurnAmountPerRound();
        uint256 initial_balance = 10 ether;

        address alice = address(0x1);
        vm.deal(alice, initial_balance);
        vm.prank(alice);
        IWorld(worldAddress).join{value: join_fee}();

        address bob = address(0x2);
        vm.deal(bob, initial_balance);
        vm.prank(bob);
        IWorld(worldAddress).join{value: join_fee}();

        // skip until game start
        skip(Config.getGameStartWaitingTime() + 1);

        uint256 prize = Game.getEthTotalAmount();

        console2.log("#####################");
        console2.log("###### ROUND 0 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        // bob does not burn
        // vm.prank(bob);
        // IWorld(worldAddress).burn(burn_amount);

        skip(Config.getRoundTimeLength());

        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 1 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.DEAD));

        vm.prank(alice);
        IWorld(worldAddress).settleGame();

        console2.log(Game.getEthTotalAmount());

        console2.log("alice balance: ", address(alice).balance);
        console2.log("bob balance: ", address(bob).balance);
        console2.log("initial balance: ", initial_balance);
        console2.log("join fee: ", join_fee);

        assert(address(alice).balance == initial_balance + prize - join_fee);
        assert(address(bob).balance == initial_balance - join_fee);
    }

    function testSettleGameTwoWinners() public {
        uint256 join_fee = Config.getJoinFee();
        uint256 burn_amount = Config.getBurnAmountPerRound();
        uint256 initial_balance = 10 ether;

        address alice = address(0x1);
        vm.deal(alice, initial_balance);
        vm.prank(alice);
        IWorld(worldAddress).join{value: join_fee}();

        address bob = address(0x2);
        vm.deal(bob, initial_balance);
        vm.prank(bob);
        IWorld(worldAddress).join{value: join_fee}();

        address carol = address(0x3);
        vm.deal(carol, initial_balance);
        vm.prank(carol);
        IWorld(worldAddress).join{value: join_fee}();

        address dave = address(0x4);
        vm.deal(dave, initial_balance);
        vm.prank(dave);
        IWorld(worldAddress).join{value: join_fee}();

        // skip until game start
        skip(Config.getGameStartWaitingTime() + 1);

        uint256 prize = Game.getEthTotalAmount();

        console2.log("#####################");
        console2.log("###### ROUND 0 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);

        vm.prank(bob);
        IWorld(worldAddress).burn(burn_amount);

        // carol and dave do not burn

        skip(Config.getRoundTimeLength());

        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 1 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(carol)), uint8(PlayerStatus.DEAD));
        assertEq(uint8(Player.getStatus(dave)), uint8(PlayerStatus.DEAD));

        // try to settle game but failed
        vm.prank(alice);
        assert(IWorld(worldAddress).settleGame() == false);

        // alice and bob do not burn

        skip(Config.getRoundTimeLength());
        
        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 2 ######");
        console2.log("#####################");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        vm.prank(alice);
        IWorld(worldAddress).settleGame();

        console2.log("alice balance: ", address(alice).balance);
        console2.log("bob balance: ", address(bob).balance);
        console2.log("carol balance: ", address(carol).balance);
        console2.log("dave balance: ", address(dave).balance);
        console2.log("initial balance: ", initial_balance);
        console2.log("join fee: ", join_fee);

        assert(address(alice).balance == initial_balance + prize / 2 - join_fee);
        assert(address(bob).balance == initial_balance + prize / 2 - join_fee);
        assert(address(carol).balance == initial_balance - join_fee);
        assert(address(dave).balance == initial_balance - join_fee);
    }
}
