// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Roles} from "../src/Roles.sol";

contract Deploy is Script {
    Roles public roles;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        roles = new Roles();

        console.log("Roles contract deployed at:", address(roles));

        vm.stopBroadcast();
    }
}
