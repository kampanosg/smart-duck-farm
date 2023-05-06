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
    }

    function updateStake(address user, uint256 amount) internal {
        Stake s = Stake {
            user: user,
            amount: amount,
            ts: block.timestamp
        };
        stakes[user] = s;
    }

}