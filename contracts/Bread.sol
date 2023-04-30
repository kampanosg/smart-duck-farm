// contracts/Bread.sol
// SPDX-License-Identifier: MIT
// a contract to feed the ducks

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "./Authorizable.sol";
import "./Duck.sol";
import "./Egg.sol";

contract Bread is ERC20, Authorizable {
    using SafeMath for uint256;

    address public DUCK_CONTRACT_ADDR;
    address public EGG_CONTRACT_ADDR;

    constructor(address _duckContractAddr, address _eggContractAddr) ERC20("Bread Token", "BREAD") {
        DUCK_CONTRACT_ADDR = _duckContractAddr;
        EGG_CONTRACT_ADDR = _eggContractAddr;
    }
}