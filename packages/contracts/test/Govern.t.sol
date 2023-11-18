// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";
import {getKeysWithValue} from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import {IWorld} from "../src/codegen/world/IWorld.sol";
import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../src/codegen/index.sol";
import {Player, PlayerData} from "../src/codegen/index.sol";
import {PlayerStatus} from "../src/codegen/common.sol";
import {Game, GameData} from "../src/codegen/index.sol";
import {IWorld} from "src/codegen/world/IWorld.sol";

import {MockBurn} from "src/mock/MockBurn.sol";
import {ROOT_NAMESPACE_ID} from "@latticexyz/world/src/constants.sol";

contract GovernTest is MudTest {
    address alice = vm.addr(30);
    address bob = vm.addr(31);

    function testUpgradeBurnSystem() public {
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

        // bob vote for
        vm.prank(bob);
        IWorld(worldAddress).vote(proposalId, 1, true);

        skip(Config.getVoteTimeLength() + 100);

        IWorld(worldAddress).executeProposal(proposalId);

        assertEq(MockBurn(worldAddress).burn(0), uint256(keccak256(abi.encodePacked("mock burn"))));
    }
}
