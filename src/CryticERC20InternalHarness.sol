pragma solidity ^0.8.0;
import "properties/ERC20/internal/properties/ERC20BasicProperties.sol";
import "../src/MyToken.sol";

contract CryticERC20InternalHarness is MyToken, CryticERC20BasicProperties {
    constructor() {
        // Setup balances for USER1, USER2 and USER3:
        _mint(USER1, INITIAL_BALANCE);
        _mint(USER2, INITIAL_BALANCE);
        _mint(USER3, INITIAL_BALANCE);
        // Setup total supply:
        initialSupply = totalSupply();
        isMintableOrBurnable = true;
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, MyToken) {
        super._update(from, to, value);
    }

    function transfer(
        address to,
        uint256 value
    ) public override(ERC20, MyToken) returns (bool) {
        return super.transfer(to, value);
    }

    function approve(address spender, uint256 value) public virtual override(ERC20, MyToken) returns (bool) {
         return super.approve(spender, value);
    }
}
