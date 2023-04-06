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
    uint256 public royaltiesPercentage;
    mapping(uint256 => Duckling) public ducklings;

    Counters.Counter private _tokenIdCounter;
    address private _owner;
    address private _royaltiesAddress;
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

    function initialize(address _nftOwner, string memory _baseURL, uint256 _royaltyPercentage) initializer public {
        __ERC721_init("Duck NFT", "DCK");
        mintFeeAmount = 1000000000000000000;
        baseURL = _baseURL;
        _owner = _nftOwner;
        royaltiesPercentage = _royaltyPercentage;
        _royaltiesAddress = _nftOwner;
    }

    function mint() public payable {
        require(_tokenIdCounter.current() < maxSupply, "Max supply reached");
        require(msg.value == mintFeeAmount, "Not enough fee");
        payable(_royaltiesAddress).transfer(msg.value);

        _tokenIdCounter.increment();
        uint256 nextTokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, nextTokenId);
        ducklings[nextTokenId] = Duckling(nextTokenId, msg.sender, msg.sender, 0, false, 0);
    }

    function buyToken(uint256 tokenId) public payable {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0));
        require(tokenOwner != msg.sender);
        require(_listedTokens.contains(tokenId), "token not listed");
        require(msg.value == ducklings[tokenId].price, "not enough fee");

        Duckling memory duckling = ducklings[tokenId];
        uint256 amount = msg.value;
        uint256 royaltiesAmount = (amount * royaltiesPercentage) / 100;
        uint256 sellerAmount = amount - royaltiesAmount;
        payable(_royaltiesAddress).transfer(royaltiesAmount);
        payable(duckling.owner).transfer(sellerAmount);

        safeTransferFrom(duckling.owner, msg.sender, tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length();
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

    // function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721Upgradeable) {
    //     super._beforeTokenTransfer(from, to, tokenId, 1);
    //     Duckling memory duckling = ducklings[tokenId];
    //     duckling.owner = to;
    //     duckling.forSale = false;
    //     ducklings[tokenId] = duckling;

    //     if (from == address(0)) {
    //         // new token has been minted
    //         _allTokens.add(tokenId);
    //     } else if (from != to) {
    //         _removeTokenFromOwnerEnumeration(from, tokenId);
    //     }
    //     if (to == address(0)) {
    //         // token has been burned
    //         _allTokens.remove(tokenId);
    //     } else if (to != from) {
    //         _addTokenToOwnerEnumeration(to, tokenId);
    //     }
    // }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _holderTokens[to].add(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        _holderTokens[from].remove(tokenId);
    }

}