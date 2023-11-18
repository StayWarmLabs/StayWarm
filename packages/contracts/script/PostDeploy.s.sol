// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {StoreSwitch} from "@latticexyz/store/src/StoreSwitch.sol";

import {IWorld} from "../src/codegen/world/IWorld.sol";

import {Config, ConfigData} from "../src/codegen/index.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        // Specify a store so that you can use tables directly in PostDeploy
        StoreSwitch.setStoreAddress(worldAddress);

        // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        // ------------------ EXAMPLES ------------------

        // Call increment on the world via the registered function selector
        // uint32 newValue = IWorld(worldAddress).increment();
        // console.log("Increment via IWorld:", newValue);

        ConfigData memory configData = Config.get();
        // configData.gameStartWaitingTime = 1 days;
        configData.gameStartWaitingTime = 2 days;
        configData.roundTimeLength = 1 days;
        configData.voteTimeLength = 1 days;
        configData.burnAmountPerRound = 100;
        configData.joinFee = 0.05 ether;
        configData.initialBalance = 750;

        Config.set(configData);

        vm.stopBroadcast();
    }
}
