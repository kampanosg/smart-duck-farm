// contracts/Duck.sol
// SPDX-License-Identifier: MIT
// an eggy contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./Duck.sol";

contract Egg is ERC20 {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    address public DUCK_CONTRACT_ADDR;

    uint256 public LVL_BASE = 25;
    uint256 public LVL_RATE = 2;
    uint256 public COOLDOWN_RATE_SECS = 7200;

    EnumerableSet.UintSet private _stakedDucks;

    constructor(address _duckContractAddr) ERC20("Egg Token", "EGG") {
        DUCK_CONTRACT_ADDR = _duckContractAddr;
    }

    // calculate the amount of $BREAD required to level up a duck
    function feedLevelingRate(uint256 kg) public view returns (uint256) {
        return LVL_BASE * ((kg / 100) ** LVL_RATE);
    }

    // calculate the amount of time required to cool down before a duck can be fed again, based on its weight
    function cooldownRate(uint256 kg) public view returns (uint256) {
        return (kg / 100) * COOLDOWN_RATE_SECS;
    }

    // calculate the amount of $EGG that is claimable from a duck, based on its weight
    function claimableEgg(uint256 tokenId) public view returns (uint256) {
        
    }

}