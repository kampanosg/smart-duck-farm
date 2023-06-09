// contracts/Egg.sol
// SPDX-License-Identifier: MIT
// an eggy contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./Authorizable.sol";
import "./Duck.sol";

contract Egg is ERC20, Authorizable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    event EggStakedEvent(uint256);
    event EggUnstakedEvent(uint256);
    event EggClaimedEvent(uint256, uint256);
    event DucklingFedEvent(uint256, uint256);
    event DuckUpgradedEvent(uint256, uint256);

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

    function getStakedDuck(uint256 tokenId) public view returns (uint256, uint256, uint256, uint256) {
        StakedDuckling memory stakedDuckling = stakedDucklings[tokenId];
        return (stakedDuckling.weight, stakedDuckling.lastTimeFarmedTs, stakedDuckling.amountFed, stakedDuckling.cooldownTime);
    }

    // calculate the amount of $BREAD required to level up a duck
    function feedLevellingRate(uint256 kg) public view returns (uint256) {
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
        emit EggStakedEvent(tokenId);
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
        emit EggUnstakedEvent(tokenId);
    }

    function claimEgg(uint256 tokenId) external{
        Duck duck = Duck(DUCK_CONTRACT_ADDR);
        require(duck.ownerOf(tokenId) == msg.sender, "not the owner");

        StakedDuckling memory stakedDuck = stakedDucklings[tokenId];
        require(stakedDuck.weight > 0, "not staked");

        uint256 claimable = claimableEgg(tokenId);
        if (claimable > 0) {
            _mint(msg.sender, claimable);
            stakedDuck.lastTimeFarmedTs = block.timestamp;
            stakedDucklings[tokenId] = stakedDuck;
        }
        emit EggClaimedEvent(tokenId, claimable);
    }

    function feed(uint256 tokenId, uint256 breadAmount) external onlyAuthorized {
        require(breadAmount > 0, "no feed");
        StakedDuckling memory duck = stakedDucklings[tokenId];
        require(duck.weight > 0, "not staked");
        duck.amountFed = uint48(breadAmount / 1e18) + duck.amountFed;
        stakedDucklings[tokenId] = duck;
        emit DucklingFedEvent(tokenId, breadAmount);
    }

    // this could also live in the duck contract
    // but it's here for convenience since all the other staking logic and data structures are here
    function upgradeDuck(uint256 tokenId) external {
        StakedDuckling memory stakedDuck = stakedDucklings[tokenId];
        require(stakedDuck.weight > 0, "not staked");
        require(stakedDuck.amountFed >= feedLevellingRate(stakedDuck.weight), "not fed enough");
        require(block.timestamp >= stakedDuck.cooldownTime, "still cooling down");

        Duck duck = Duck(DUCK_CONTRACT_ADDR);
        require(duck.ownerOf(tokenId) == msg.sender, "not the owner");

        stakedDuck.weight = stakedDuck.weight + 100;
        stakedDuck.amountFed = 0;
        stakedDuck.cooldownTime = block.timestamp + cooldownRate(stakedDuck.weight);
        stakedDucklings[tokenId] = stakedDuck;

        duck.setWeight(tokenId, stakedDuck.weight);
        emit DuckUpgradedEvent(tokenId, stakedDuck.weight);
    }

    function burnEgg(address sender, uint256 eggsAmount) external onlyAuthorized {
        require(balanceOf(sender) >= eggsAmount, "NOT ENOUGH EGG");
        _burn(sender, eggsAmount);
    }

    function mintEgg(address sender, uint256 eggsAmount) external onlyAuthorized {
        _mint(sender, eggsAmount);
    }

}