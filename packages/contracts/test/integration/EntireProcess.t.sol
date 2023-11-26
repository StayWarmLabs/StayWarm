// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {getKeysWithValue} from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import {IWorld} from "../../src/codegen/world/IWorld.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../../src/codegen/index.sol";
import {Player, PlayerData, Proposal} from "../../src/codegen/index.sol";
import {PlayerStatus} from "../../src/codegen/common.sol";
import {Game, GameData} from "../../src/codegen/index.sol";
import {IWorld} from "src/codegen/world/IWorld.sol";

// import {MockBurn} from "src/mock/MockBurn.sol";
import {ChaosBurnSys} from "src/template/ChaosBurnSys.sol";
import {ROOT_NAMESPACE_ID} from "@latticexyz/world/src/constants.sol";

contract GovernTest is MudTest {
    address alice = vm.addr(30);
    address bob = vm.addr(31);
    address carol = vm.addr(32);
    address dave = vm.addr(33);
    
    function testEntireProcess() public {
        // ChaosBurnSys chaos_brun = new ChaosBurnSys();
        console2.log("*** testEntireProcess ***");
        console2.log("##########################");
        console2.log("###### BEFORE Start ######");
        console2.log("##########################");

        uint256 join_fee = Config.getJoinFee();
        uint256 burn_amount = Config.getBurnAmountPerRound();
        uint256 initial_balance = 10 ether;

        // join game
        vm.deal(alice, initial_balance);
        vm.prank(alice);
        IWorld(worldAddress).join{value: join_fee}();
        vm.deal(bob, initial_balance);
        vm.prank(bob);
        IWorld(worldAddress).join{value: join_fee}();
        vm.deal(carol, initial_balance);
        vm.prank(carol);
        IWorld(worldAddress).join{value: join_fee}();
        vm.deal(dave, initial_balance);
        vm.prank(dave);
        IWorld(worldAddress).join{value: join_fee}();

        // skip to game start
        skip(Config.getGameStartWaitingTime() + 1);

        uint256 prize = Game.getEthTotalAmount();

        // check game status
        GameData memory gameData = Game.get();
        address[] memory all_players = gameData.allPlayers;

        assertEq(all_players.length, 4);

        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 0 ######");
        console2.log("#####################");
        console2.log("Everyone just burns");

        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(carol)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(dave)), uint8(PlayerStatus.ALIVE));

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount);
        vm.prank(bob);
        IWorld(worldAddress).burn(burn_amount);
        vm.prank(carol);
        IWorld(worldAddress).burn(burn_amount);
        vm.prank(dave);
        IWorld(worldAddress).burn(burn_amount);

        skip(Config.getRoundTimeLength());

        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 1 ######");
        console2.log("#####################");
        console2.log("settle round 0");

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount); // alice burns again (and settle round 0)
        vm.prank(bob);
        IWorld(worldAddress).burn(burn_amount);
        vm.prank(carol);
        IWorld(worldAddress).burn(burn_amount);

        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(carol)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(dave)), uint8(PlayerStatus.ALIVE));

        console2.log("Dave forgot to burn");

        // dave fogot to burn
        assertEq(Player.getBurnedAmount(alice), burn_amount);
        assertEq(Player.getBurnedAmount(bob), burn_amount);
        assertEq(Player.getBurnedAmount(carol), burn_amount);
        assertEq(Player.getBurnedAmount(dave), 0);


        skip(Config.getRoundTimeLength());

        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 2 ######");
        console2.log("#####################");
        console2.log("settle round 1");

        vm.prank(alice);
        IWorld(worldAddress).burn(burn_amount); // alice burns again (and settle round 1)
        vm.prank(bob);
        IWorld(worldAddress).burn(burn_amount);
        vm.prank(carol);
        IWorld(worldAddress).burn(burn_amount);

        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(carol)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(dave)), uint8(PlayerStatus.DEAD));

        console2.log("Dave is eliminated");

        console2.log("Bob Proposed Chaos Burn System");

        ChaosBurnSys chaos_brun = new ChaosBurnSys();
        console2.log("Chaos Burn address: ", address(chaos_brun));

        vm.prank(bob);
        uint96 proposalId = IWorld(worldAddress).makeProposal(address(chaos_brun), "Burn", "ipfs://");


        vm.prank(alice);
        IWorld(worldAddress).vote(proposalId, 2, false);

        vm.prank(bob);
        IWorld(worldAddress).vote(proposalId, 3, true);

        // carol does not vote

        // dave tried to vote but he is eliminated
        // vm.prank(dave);
        // IWorld(worldAddress).vote(proposalId, 1, true); // error -> revert

        
        skip(Config.getVoteTimeLength() + 1); // skip to vote end

        assertEq(Player.getFtBalance(alice), Config.getInitialBalance() - 4 - burn_amount * 3);
        assertEq(Player.getFtBalance(bob), Config.getInitialBalance() - 9 - burn_amount * 3);
        assertEq(Player.getFtBalance(carol), Config.getInitialBalance() - 0 - burn_amount * 3);


        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 3 ######");
        console2.log("#####################");
        console2.log("settle round 2");

        burn_amount = Config.getBurnAmountPerRound();

        vm.prank(alice);
        assertEq(ChaosBurnSys(worldAddress).burn(burn_amount), true);

        vm.prank(bob);
        // IWorld(worldAddress).burn(burn_amount); // -> this call original burn function
        ChaosBurnSys(worldAddress).burn(burn_amount); // -> this call Chaos Burn System

        vm.prank(carol);
        ChaosBurnSys(worldAddress).burn(burn_amount);

        skip(Config.getRoundTimeLength());

        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 4 ######");
        console2.log("#####################");
        console2.log("settle round 3");

        vm.prank(alice);
        ChaosBurnSys(worldAddress).burn(burn_amount); // it might make alice eliminated if the random value is high.

        // bob and carol does not burn

        skip(Config.getRoundTimeLength());

        console2.log("");
        console2.log("#####################");
        console2.log("###### ROUND 5 ######");
        console2.log("#####################");
        console2.log("settle round 4");

        vm.prank(alice);
        IWorld(worldAddress).settleRound();

        assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
        assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.DEAD));
        assertEq(uint8(Player.getStatus(carol)), uint8(PlayerStatus.DEAD));

        vm.prank(alice);
        IWorld(worldAddress).settleGame();

        assert(address(alice).balance == initial_balance + prize - join_fee);
        assert(address(bob).balance == initial_balance - join_fee);
        assert(address(carol).balance == initial_balance - join_fee);
        assert(address(dave).balance == initial_balance - join_fee);

    }
}
