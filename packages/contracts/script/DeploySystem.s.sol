// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";

import {IWorld} from "../src/codegen/world/IWorld.sol";

import {Config, ConfigData} from "../src/codegen/index.sol";

import "src/template/ChaosBurnSys.sol";
import "src/template/NonGovernSys.sol";

contract DeploySystem is Script {
    function run() external {
        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        ChaosBurnSys chaosBurn = new ChaosBurnSys();

        NonGovernSys nonGovern = new NonGovernSys();

        vm.stopBroadcast();

        console2.log("ChaosBurnSys :", address(chaosBurn));

        console2.log("NonGovernSys: ", address(nonGovern));
    }
}
