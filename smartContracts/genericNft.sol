// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract genericNft is ERC721, Ownable 
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "MTK") 
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://media.npr.org/assets/img/2010/11/17/void_wide-aafb8b68b1f476c7ff6070e092dc3f7d20af75a7.jpg";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) 
    {
        return "https://media.npr.org/assets/img/2010/11/17/void_wide-aafb8b68b1f476c7ff6070e092dc3f7d20af75a7.jpg";
    }

    function safeMint() public 
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function getNftContractAddress() public view returns(address)
    {
        return address(this);
    }

    function getSupplyNfts() public view returns(uint)
    {
        return _tokenIdCounter.current() - 1;
    }
}
