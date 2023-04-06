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
    using Counters for Counters.Counter;

    string public baseURL;
    uint256 public mintFeeAmount;
    uint256 public constant maxSupply = 10000;
    mapping(uint256 => Duckling) public ducklings;

    Counters.Counter private _tokenIdCounter;
    address private _owner;
    address private _royaltiesAddr;
    mapping(address => EnumerableSet.UintSet) private _holderTokens;
    EnumerableSet.UintSet private _listedTokens;

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
        _royaltiesAddr = _nftOwner;
    }

    function mint() public payable {
        require(_tokenIdCounter.current() < maxSupply, "Max supply reached");
        require(msg.value == mintFeeAmount, "Not enough fee");
        payable(_royaltiesAddr).transfer(msg.value);

        _tokenIdCounter.increment();
        uint256 nextTokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, nextTokenId);
        ducklings[nextTokenId] = Duckling(nextTokenId, msg.sender, msg.sender, 0, false, 0);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function listToken(uint256 tokenId, uint256 price) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "not the owner");
        require(!_listedTokens.contains(tokenId), "token already listed");
        require(price > 0, "Price must be greater than 0");
        ducklings[tokenId].forSale = true;
        ducklings[tokenId].price = price;
        _listedTokens.add(tokenId);
    }

    function unlistToken(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "not the owner");
        require(_listedTokens.contains(tokenId), "token not listed");
        ducklings[tokenId].forSale = false;
        ducklings[tokenId].price = 0;
        _listedTokens.remove(tokenId);
    }

    function getListedTokens() public view returns (uint256[] memory) {
        uint256[] memory listedTokens = new uint256[](_listedTokens.length());
        for (uint256 i = 0; i < _listedTokens.length(); i++) {
            listedTokens[i] = _listedTokens.at(i);
        }
        return listedTokens;
    }

    function getUserTokens(address _wallet) public view returns (uint256[] memory) {
        uint256[] memory userTokens = new uint256[](_holderTokens[_wallet].length());
        for (uint256 i = 0; i < _holderTokens[_wallet].length(); i++) {
            userTokens[i] = _holderTokens[_wallet].at(i);
        }
        return userTokens;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable) {
        super._burn(tokenId);
    }

}