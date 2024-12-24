pragma solidity ^0.8.0;
import "@crytic/properties/contracts/ERC721/internal/properties/ERC721BasicProperties.sol";
import "./MyToken.sol";
contract CryticERC721InternalHarness is MyToken, CryticERC721BasicProperties {

    constructor() {
    }
}