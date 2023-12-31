// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "forge-std/console2.sol";

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {Game, GameData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";
import {IWorld} from "src/codegen/world/IWorld.sol";
import {SystemSwitch} from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";

/**
 * @notice this system make the amount of token into a random things.
 */
contract ChaosBurnSys is System {
    // skip implementation to limit players to change burn_amount once per round.
    // mapping(uint256 => bool) public hasBurnedThisRound;

    function getRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encode(blockhash(block.number - 1), block.number, gasleft())));
    }

    function setBurnAmountPerRound(uint256 burn_amount) public payable returns (bool) {
        // require(hasBurnedThisRound[Game.getCurrentRound()] == false, "ChaosBurnSys: already burned this round");
        Config.setBurnAmountPerRound(burn_amount);
        // hasBurnedThisRound[Game.getCurrentRound()] = true;
        return true;
    }


    // Burn burn_amount of FT
    // Set new BurnAmountPerRound if it is the first time to burn in this round
    function burn(uint256 burn_amount) public payable returns (bool) {
        console2.log("THIS IS CHAOS BURN");
        // call settle round before each tx
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).settleRound, ()));

        address player = _msgSender();
        PlayerData memory playerData = Player.get(player);
        require(playerData.ftBalance > 0, "ChaosBurnSys: player does not have enough FT");
        require(playerData.status == PlayerStatus.ALIVE, "ChaosBurnSystem: player is not alive");

        // check if the new burn amount is set in this round
        

        // if (hasBurnedThisRound[Game.getCurrentRound()] == false) {
        uint256 burn_amount_per_round = getRandomNumber() % playerData.ftBalance;
        setBurnAmountPerRound(burn_amount_per_round);
        // }

        require(playerData.ftBalance >= burn_amount, "ChaosBurnSystem: player does not have enough FT");

        playerData.lastCheckedTime = uint32(block.timestamp);
        playerData.burnedAmount += burn_amount;
        playerData.ftBalance -= burn_amount;

        Player.set(player, playerData);

        return true;
    }
}
