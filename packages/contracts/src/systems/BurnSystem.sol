// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Config, ConfigData} from "../codegen/index.sol";
import {Player, PlayerData} from "../codegen/index.sol";
import {PlayerStatus} from "../codegen/common.sol";

// import {Counter} from "../codegen/index.sol";
import "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import {ResourceId, ResourceIdInstance} from "@latticexyz/store/src/ResourceId.sol";
import {WorldContextConsumer, WORLD_CONTEXT_CONSUMER_INTERFACE_ID} from "@latticexyz/world/src/WorldContext.sol";

// struct PlayerData {
//   PlayerStatus status;
//   uint32 lastCheckedTime;
//   uint256 ftBalance;
//   uint256 burnedAmount;
// }


contract BurnSystem is System {

    // ConfigData cfg = Config.get();
    // uint burn_amount = cfg.burnAmountPerRound;

    function burn() public payable returns (bool) {
        address player = _msgSender();
        PlayerData memory playerData = Player.get(player);

        uint256 burn_amount = Config.getBurnAmountPerRound();

        require(playerData.status == PlayerStatus.ALIVE, "BurnSystem: player is not alive");
        require(playerData.ftBalance >= burn_amount, "BurnSystem: player does not have enough FT");

        playerData.lastCheckedTime = uint32(block.timestamp);
        playerData.burnedAmount += burn_amount;
        playerData.ftBalance -= burn_amount;

        Player.set(player, playerData);
        return true;
    }
}
