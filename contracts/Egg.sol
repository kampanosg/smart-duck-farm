// contracts/Duck.sol
// SPDX-License-Identifier: MIT
// an eggy contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./Duck.sol";

contract Egg is ERC20 {
    using SafeMath for uint256;

    address public DUCK_CONTRACT_ADDR;

    constructor(address _duckContractAddr) ERC20("Egg Token", "EGG") {
        DUCK_CONTRACT_ADDR = _duckContractAddr;
    }

}