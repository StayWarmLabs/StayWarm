// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {System} from "@latticexyz/world/src/System.sol";

contract MockBurn is System {
    function burn() public payable returns (uint256) {
        return uint256(keccak256(abi.encodePacked("mock burn")));
    }
}
