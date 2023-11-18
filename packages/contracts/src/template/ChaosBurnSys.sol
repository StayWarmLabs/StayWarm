// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";

/**
 * @notice this system make the amount of token into a random things.
 */
contract ChaosBurnSys is System {
    function getRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encode(blockhash(block.number - 1), block.number, gasleft())));
    }

    function burn(uint256 burn_amount) public payable {
        address player = _msgSender();
        PlayerData memory playerData = Player.get(player);

        burn_amount = getRandomNumber() % playerData.ftBalance;

        require(playerData.status == PlayerStatus.ALIVE, "BurnSystem: player is not alive");
        require(playerData.ftBalance >= burn_amount, "BurnSystem: player does not have enough FT");

        playerData.lastCheckedTime = uint32(block.timestamp);
        playerData.burnedAmount += burn_amount;
        playerData.ftBalance -= burn_amount;

        Player.set(player, playerData);
    }
}
