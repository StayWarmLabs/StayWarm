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


contract JoinSystem is System {
    uint public constant JOIN_FEE = 0.05 ether;
    uint public constant INITIAL_FT = 750;

    // ConfigData cfg = Config.get();
    // uint join_fee = cfg.joinFee;
    // uint initial_ft = cfg.initialFt;


    function join() public payable returns (bool) {
        address player = _msgSender();
        PlayerData memory playerData = Player.get(player);

        // player has already joined
        if (playerData.status != PlayerStatus.UNINITIATED) {
            return false;
        }

        // player has not joined yet

        //deposit fee
        require(msg.value == JOIN_FEE, "JoinSystem: deposit amount must be 0.05 ether");

        playerData.status = PlayerStatus.ALIVE;
        playerData.lastCheckedTime = uint32(block.timestamp);
        playerData.ftBalance = INITIAL_FT;
        playerData.burnedAmount = 0;

        Player.set(player, playerData);
        return true;
    }
}
