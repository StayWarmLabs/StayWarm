// // SPDX-License-Identifier: MIT
// pragma solidity >=0.8.21;

// import "forge-std/Test.sol";
// import "forge-std/console2.sol";

// import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
// import {getKeysWithValue} from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
// import {IWorld} from "../../src/codegen/world/IWorld.sol";
// import {System} from "@latticexyz/world/src/System.sol";
// import {Config, ConfigData} from "../../src/codegen/index.sol";
// import {Player, PlayerData, Proposal} from "../../src/codegen/index.sol";
// import {PlayerStatus} from "../../src/codegen/common.sol";
// import {Game, GameData} from "../../src/codegen/index.sol";
// import {IWorld} from "src/codegen/world/IWorld.sol";

// // import {MockBurn} from "src/mock/MockBurn.sol";
// import {ChaosBurnSys} from "src/template/ChaosBurnSys.sol";
// import {ROOT_NAMESPACE_ID} from "@latticexyz/world/src/constants.sol";

// contract GovernTest is MudTest {
//     address alice = vm.addr(30);
//     address bob = vm.addr(31);
//     address carol = vm.addr(32);
//     address dave = vm.addr(33);
    
//     function testEntireProcess() public {
//         // ChaosBurnSys chaos_brun = new ChaosBurnSys();

//         uint256 join_fee = Config.getJoinFee();
//         uint256 burn_amount = Config.getBurnAmountPerRound();
//         uint256 initial_burn_amount = Config.getBurnAmountPerRound();

//         // join game
//         hoax(alice);
//         IWorld(worldAddress).join{value: join_fee}();
//         hoax(bob);
//         IWorld(worldAddress).join{value: join_fee}();
//         hoax(carol);
//         IWorld(worldAddress).join{value: join_fee}();
//         hoax(dave);
//         IWorld(worldAddress).join{value: join_fee}();

//         // skip to game start
//         skip(Config.getGameStartWaitingTime() + 1);


//         // check game status
//         GameData memory gameData = Game.get();
//         address[] memory all_players = gameData.allPlayers;

//         assertEq(all_players.length, 2);
//         // assertEq(all_players[0], _msgSender());

//         PlayerData memory alice_data = Player.get(all_players[0]);
//         assert(alice_data.status == PlayerStatus.ALIVE);

//         PlayerData memory bob_data = Player.get(all_players[1]);
//         assert(bob_data.status == PlayerStatus.ALIVE);


//         // alice make proposal
//         console2.log("Chaos Burn address: ", address(chaos_brun));

//         vm.prank(alice);
//         uint96 proposalId = IWorld(worldAddress).makeProposal(address(chaos_brun), "Burn", "ipfs://");

//         console2.log("proposalId: ", proposalId);

//         // bob vote for with 3 power
//         vm.prank(bob);
//         IWorld(worldAddress).vote(proposalId, 3, true);
//         assertEq(Player.getFtBalance(bob), Config.getInitialBalance() - 9);
//         assertEq(Proposal.getSupport(proposalId), 3);
//         assertEq(Proposal.getReject(proposalId), 0);

//         // alice vote againt with 2 power
//         vm.prank(alice);
//         IWorld(worldAddress).vote(proposalId, 2, false);
//         assertEq(Player.getFtBalance(alice), Config.getInitialBalance() - 4);
//         assertEq(Proposal.getSupport(proposalId), 3);
//         assertEq(Proposal.getReject(proposalId), 2);

//         // We have to burn for ROUND 1 because VoteTimeLength > roundLength
//         vm.prank(alice);
//         IWorld(worldAddress).burn(burn_amount);

//         vm.prank(bob);
//         IWorld(worldAddress).burn(burn_amount);

//         skip(Config.getVoteTimeLength() + 1);

//         IWorld(worldAddress).executeProposal(proposalId); // there is a settleRound in executeProposal

//         vm.prank(alice);
//         assertEq(ChaosBurnSys(worldAddress).burn(0), true);
//         assertEq(Player.getFtBalance(alice), Config.getInitialBalance() - 4 - initial_burn_amount);

//         burn_amount = Config.getBurnAmountPerRound();

//         console2.log("Current Brun Amount Per Round: ", burn_amount);

//         vm.prank(alice);
//         assertEq(ChaosBurnSys(worldAddress).burn(burn_amount), true);

//         assertEq(Player.getFtBalance(alice), Config.getInitialBalance() - 4 - initial_burn_amount - burn_amount);


//         skip(Config.getRoundTimeLength());
//         vm.prank(alice);
//         IWorld(worldAddress).settleRound();

//         // Bob does not burn, so he is eliminated

//         assertEq(uint8(Player.getStatus(alice)), uint8(PlayerStatus.ALIVE));
//         assertEq(uint8(Player.getStatus(bob)), uint8(PlayerStatus.DEAD));
//     }
// }
