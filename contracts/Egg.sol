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
    uint256 public EGGS_PER_DAY_PER_KG = 250000000000000000; // the number of $EGG per duckling per day per kg: 0.25 $egg per $duck / day / weight
    uint256 public BASE_HOLDER_EGGS = 750000000000000000;    // the base number of $EGG per duckling: 0.75 $egg
    uint256 public ONE_DAY_IN_SECS = 86400;

    struct StakedDuckling {
        uint256 weight;
        uint256 lastTimeFarmedTs;
        uint256 amountFed;
        uint256 cooldownTime;
    }

    mapping(uint256 => StakedDuckling) public stakedDucklings;

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
        StakedDuckling memory stakedDuckling = stakedDucklings[tokenId];
        if (stakedDuckling.weight == 0) {
            return 0;
        }
        uint256 eggPerDay = ((EGGS_PER_DAY_PER_KG * (stakedDuckling.weight / 100)) + BASE_HOLDER_EGGS);
        uint256 deltaSeconds = block.timestamp - stakedDuckling.lastTimeFarmedTs;
        return deltaSeconds * (eggPerDay / ONE_DAY_IN_SECS);
    }

    function stake(uint256 tokenId) external {
        Duck duck = Duck(DUCK_CONTRACT_ADDR);
        require(duck.ownerOf(tokenId) == msg.sender, "not the owner");

        (, , , , , uint256 weight) = duck.ducklings(tokenId);
        StakedDuckling memory stakedDuck = stakedDucklings[tokenId];
        require(stakedDuck.weight == 0, "already staked");

        uint256 nowTs = block.timestamp;
        stakedDucklings[tokenId] = StakedDuckling(weight, nowTs, 0, nowTs + cooldownRate(weight));
    }

    function unstake(uint256 tokenId) external {
        Duck duck = Duck(DUCK_CONTRACT_ADDR);
        require(duck.ownerOf(tokenId) == msg.sender, "not the owner");

        StakedDuckling memory stakedDuck = stakedDucklings[tokenId];
        require(stakedDuck.weight > 0, "not staked");

        uint256 claimable = claimableEgg(tokenId);
        if (claimable > 0) {
            _mint(msg.sender, claimable);
        }

        delete stakedDucklings[tokenId];
    }

}