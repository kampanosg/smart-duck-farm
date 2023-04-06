// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
// a mutha duckin' upgradeable NFT contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Duck is ERC721Upgradeable {

    using EnumerableSet for EnumerableSet.UintSet;

    string public baseURL;
    uint256 public mintFeeAmount;
    uint256 public constant maxSupply = 10000;
    mapping(uint256 => Duckling) public ducklings;

    address private _owner;
    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    struct Duckling {
        uint256 tokenId;
        address minter;
        address owner;
        uint256 price;
        bool forSale;
        uint256 weight;
    }

    function initialize(address _nftOwner, string memory _baseURL) initializer public {
        __ERC721_init("Duck NFT", "DCK");
        mintFeeAmount = 1000000000000000000;
        baseURL = _baseURL;
        _owner = _nftOwner;
    }
}