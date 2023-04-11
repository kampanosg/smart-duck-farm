// contracts/Duck.sol
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
    mapping(address => EnumerableSet.UintSet) private _holderTokens;
    EnumerableSet.UintSet private _listedTokens;
    EnumerableSet.UintSet private _allTokens;

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

    function mint() public payable {
        require(_tokenIdCounter.current() < maxSupply, "max supply reached");
        require(msg.value == mintFeeAmount, "wrong fee");

        _tokenIdCounter.increment();
        uint256 nextTokenId = _tokenIdCounter.current();
        _safeMint(_msgSender(), nextTokenId);
        ducklings[nextTokenId] = Duckling(nextTokenId, _msgSender(), _msgSender(), 0, false, 0);
    }

    function buyToken(uint256 tokenId) public payable {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0), "hackz");
        require(tokenOwner != _msgSender(), "already the owner");
        require(_listedTokens.contains(tokenId), "token not listed");
        require(msg.value == ducklings[tokenId].price, "wrong fee");

        Duckling memory duckling = ducklings[tokenId];
        payable(duckling.owner).transfer(msg.value);

        _transfer(duckling.owner, _msgSender(), tokenId);
    }

    function listToken(uint256 tokenId, uint256 price) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "not the owner");
        require(!_listedTokens.contains(tokenId), "token already listed");
        require(price > 0, "wrong price");
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

    function totalSupply() public view returns (uint256) {
        return _allTokens.length();
    }

    function getDuckling(uint256 tokenId) public view returns (Duckling memory) {
        require(_allTokens.contains(tokenId), "invalid token");
        return ducklings[tokenId];
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

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual override(ERC721Upgradeable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        Duckling memory duckling = ducklings[tokenId];
        duckling.owner = to;
        duckling.forSale = false;
        duckling.price = 0;
        ducklings[tokenId] = duckling;

        if (from == address(0)) {
            // new token has been minted
            _allTokens.add(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            // token has been burned
            _allTokens.remove(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _holderTokens[to].add(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        _holderTokens[from].remove(tokenId);
    }

}