// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";
import {Counter} from "../codegen/index.sol";
import "@latticexyz/world/src/modules/core/implementations/WorldRegistrationSystem.sol";
import {ResourceId, ResourceIdInstance} from "@latticexyz/store/src/ResourceId.sol";
import {WorldContextConsumer, WORLD_CONTEXT_CONSUMER_INTERFACE_ID} from "@latticexyz/world/src/WorldContext.sol";

contract UpgradeSystem is System {
    function addSystem(ResourceId id, address systemAddress) public returns (bool) {
        WorldRegistrationSystem(_world()).registerSystem(id, WorldContextConsumer(systemAddress), true);
        return true;
    }
}
