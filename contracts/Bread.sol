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

    event EggStakedEvent(address, uint256);
    event EggUnstakedEvent(address, uint256);
    event ClaimedFeedEvent(address, uint256);
    event SwappedEggForBreadEvent(address, uint256);
    event DuckFedEvent(address, uint256, uint256);

    uint256 public MAX_FEED_SUPPLY = 32000000000000000000000000000;
    uint256 public FEED_SWAP_FACTOR = 12;
    address public DUCK_CONTRACT_ADDR;
    address public EGG_CONTRACT_ADDR;
    uint256 public BOOSTER_MULTIPLIER = 1;
    uint256 public FEED_FARMING_FACTOR = 3;

    struct Stake {
        address user;
        uint256 amount;
        uint256 ts;
    }

    mapping(address => Stake) public stakes;

    constructor(address _duckContractAddr, address _eggContractAddr) ERC20("Bread Token", "BREAD") {
        DUCK_CONTRACT_ADDR = _duckContractAddr;
        EGG_CONTRACT_ADDR = _eggContractAddr;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "no egg");
        Egg eggContract = Egg(EGG_CONTRACT_ADDR);
        uint256 available = eggContract.balanceOf(msg.sender);
        require(available >= amount, "not enough egg");
        Stake memory existingStake = stakes[msg.sender];
        if (existingStake.amount > 0) {
            uint256 claimable = claimableFeed(msg.sender);
            _mint(msg.sender, claimable);
            updateStake(msg.sender, existingStake.amount + amount);
        } else {
            updateStake(msg.sender, amount);
        }
        eggContract.burnEgg(msg.sender, amount);

        emit EggStakedEvent(msg.sender, amount);
    }

    function updateStake(address user, uint256 amount) internal {
        stakes[user] = Stake(user, amount, block.timestamp);
    }

    function claimableFeed(address user) public view returns (uint256) {
        Stake memory s = stakes[user];
        require(s.user != address(0), "not staked");
        return ((s.amount * FEED_FARMING_FACTOR) * (((block.timestamp - s.ts) * 10000000000) / 86400) * BOOSTER_MULTIPLIER) / 10000000000;
    }

     function unstakeEgg(uint256 amount) external {
        require(amount > 0, "no egg");
        Stake memory s = stakes[msg.sender];
        require(s.user != address(0), "not staked");
        require(amount <= s.amount, "not enough egg");
        Egg eggContract = Egg(EGG_CONTRACT_ADDR);
        updateStake(msg.sender, s.amount - amount);
        uint256 breakageFee = (amount * 11) / 12;
        eggContract.mintEgg(msg.sender, breakageFee);

        emit EggUnstakedEvent(msg.sender, amount);
    }

    function claimFeed() external {
        uint256 claimable = claimableFeed(msg.sender);
        require(claimable > 0, "no feed");

        Stake memory s = stakes[msg.sender];
        updateStake(msg.sender, s.amount);

        mintFeed(msg.sender, claimable);

        emit ClaimedFeedEvent(msg.sender, claimable);
    }

    function mintFeed(address sender, uint256 feedAmount) internal {
        require(totalSupply() + feedAmount < MAX_FEED_SUPPLY, "over max supply");
        _mint(sender, feedAmount);
    }

    function swapEggForBread(uint256 eggAmount) external {
        require(eggAmount > 0, "no egg");

        Egg eggContract = Egg(EGG_CONTRACT_ADDR);
        eggContract.burnEgg(msg.sender, eggAmount);

        _mint(msg.sender, eggAmount * FEED_SWAP_FACTOR);

        emit SwappedEggForBreadEvent(msg.sender, eggAmount);
    }

    function feedDuck(uint256 duckId, uint256 amount) external {
        require(amount > 0, "no feed");

        IERC721 instance = IERC721(DUCK_CONTRACT_ADDR);

        require(instance.ownerOf(duckId) == msg.sender, "not the owner");
        require(balanceOf(msg.sender) >= amount, "not enough fee");

        Egg eggContract = Egg(EGG_CONTRACT_ADDR);
        (uint256 kg, , , ) = eggContract.getStakedDuck(duckId);
        require(kg > 0, "not staked");

        _burn(msg.sender, amount);
        eggContract.feed(duckId, amount);

        emit DuckFedEvent(msg.sender, duckId, amount);
    }

}