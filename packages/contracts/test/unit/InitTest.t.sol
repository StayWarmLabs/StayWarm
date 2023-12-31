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

// configData.gameStartWaitingTime = 2 days;
//     configData.roundTimeLength = 1 days;
//     configData.voteTimeLength = 1 days;
//     configData.burnAmountPerRound = 100;
//     configData.joinFee = 0.05 ether;
//     configData.initialBalance = 750;

contract InitTest is MudTest {
    function testWorldExists() public {
        uint256 codeSize;
        address addr = worldAddress;
        assembly {
            codeSize := extcodesize(addr)
        }
        assertTrue(codeSize > 0);
    }

    function testInit() public {
        uint256 round_time_length = Config.getRoundTimeLength();
        uint256 vote_time_length = Config.getVoteTimeLength();
        uint256 burn_amount = Config.getBurnAmountPerRound();
        uint256 join_fee = Config.getJoinFee();
        uint256 initial_balance = Config.getInitialBalance();

        // // for actual play
        // assertEq(round_time_length, 1 days);
        // assertEq(vote_time_length, 1 days);
        // assertEq(burn_amount, 100);
        // assertEq(join_fee, 0.05 ether);
        // assertEq(initial_balance, 750);

        // // for test
        // configData.gameStartWaitingTime = 10 seconds;
        // configData.roundTimeLength = 60 seconds;
        // configData.voteTimeLength = 60 seconds;
        // configData.burnAmountPerRound = 100;
        // configData.joinFee = 0.05 ether;
        // configData.initialBalance = 750;

        assertEq(round_time_length, 60 seconds);
        assertEq(vote_time_length, 60 seconds);
        assertEq(burn_amount, 100);
        assertEq(join_fee, 0.05 ether);
        assertEq(initial_balance, 750);
    }
}
