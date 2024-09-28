// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenScript is Script {
  function setUp() public {}

  function run() public {
    vm.startBroadcast();
    MyToken instance = new MyToken();
    console.log("Contract deployed to %s", address(instance));
    vm.stopBroadcast();
  }
}
