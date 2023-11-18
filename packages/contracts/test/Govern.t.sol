// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {getKeysWithValue} from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../src/codegen/index.sol";
import {Player, PlayerData, Proposal} from "../src/codegen/index.sol";
import {PlayerStatus} from "../src/codegen/common.sol";
import {Game, GameData} from "../src/codegen/index.sol";
import {IWorld} from "src/codegen/world/IWorld.sol";

import {MockBurn} from "src/mock/MockBurn.sol";
import {ROOT_NAMESPACE_ID} from "@latticexyz/world/src/constants.sol";

contract GovernTest is MudTest {
    address alice = vm.addr(30);
    address bob = vm.addr(31);

    function testProposalAndExecute() public {
        MockBurn bs = new MockBurn();

        uint256 join_fee = Config.getJoinFee();

        // join game
        hoax(alice);
        IWorld(worldAddress).join{value: join_fee}();
        hoax(bob);
        IWorld(worldAddress).join{value: join_fee}();

        // skip to game start
        skip(Config.getGameStartWaitingTime() + 100);

        // alice make proposal
        vm.prank(alice);
        uint96 proposalId = IWorld(worldAddress).makeProposal(address(bs), "BurnSystem", "ipfs://");

        // bob vote for with 3 power
        vm.prank(bob);
        IWorld(worldAddress).vote(proposalId, 3, true);
        assertEq(Player.getFtBalance(bob), Config.getInitialBalance() - 9);
        assertEq(Proposal.getSupport(proposalId), 3);
        assertEq(Proposal.getReject(proposalId), 0);

        // alice vote againt with 2 power
        vm.prank(alice);
        IWorld(worldAddress).vote(proposalId, 2, false);
        assertEq(Player.getFtBalance(alice), Config.getInitialBalance() - 4);
        assertEq(Proposal.getSupport(proposalId), 3);
        assertEq(Proposal.getReject(proposalId), 2);

        skip(Config.getVoteTimeLength() + 100);

        IWorld(worldAddress).executeProposal(proposalId);

        assertEq(MockBurn(worldAddress).burn(0), uint256(keccak256(abi.encodePacked("mock burn"))));
    }
}
