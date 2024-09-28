// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenTest is Test {
  MyToken public instance;

  function setUp() public {
    instance = new MyToken();
  }

  function testName() public view {
    assertEq(instance.name(), "MyToken");
  }
}
