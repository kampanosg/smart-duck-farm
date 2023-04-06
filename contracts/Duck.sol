// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
// a mutha duckin' upgradeable NFT contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Duck is ERC721Upgradeable {

    address private _owner;

    uint256 public mintFeeAmount;
    uint256 public constant maxSupply = 10000;

    constructor() ERC721("Duck NFT", "DCK") {
    }
}