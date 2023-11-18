// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";
import {IWorld} from "src/codegen/world/IWorld.sol";
import {SystemSwitch} from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";

contract BurnSystem is System {
    function burn(uint256 burn_amount) public payable returns (bool) {
        // call settle round before each tx
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).settleRound, ()));

        address player = _msgSender();
        PlayerData memory playerData = Player.get(player);

        require(playerData.status == PlayerStatus.ALIVE, "BurnSystem: player is not alive");
        require(playerData.ftBalance >= burn_amount, "BurnSystem: player does not have enough FT");

        playerData.lastCheckedTime = uint32(block.timestamp);
        playerData.burnedAmount += burn_amount;
        playerData.ftBalance -= burn_amount;

        Player.set(player, playerData);
        return true;
    }
}
