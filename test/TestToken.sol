pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/MintableToken.sol";


contract TestToken is MintableToken {

    // Metadata
    string public constant symbol = "TT";
    string public constant name = "TestToken";
    uint256 public constant decimals = 18;
    string public constant version = "1.0";

}
