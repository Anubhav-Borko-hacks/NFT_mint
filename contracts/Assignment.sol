//Made in Remix IDE
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts@4.7.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.3/utils/Counters.sol";

//imports taken from Open Zeppelin Contract wizard 

contract ASK is ERC721, Ownable {
    using Counters for Counters.Counter; //prebuilt smart contract Counters, used to increment and keeping track of _tokenId

    Counters.Counter private _tokenId;
    uint256 public maxSupply; //How many NFTs are allowed in circulation
    uint256 public price=1 ether;
    bool public isMinted; //false by default
    mapping(address=>uint256) public addMinted; //to keep track of how many addresses have minted an NFT

    constructor() ERC721("ASK", "AG") {
        maxSupply=2;
    }

    function isMintSwitch() external onlyOwner{ //to enable minting
        isMinted= !isMinted; 
    }

    function AlterSupply(uint256 _maxSupply) external onlyOwner{ //can change the maxSupply
        maxSupply=_maxSupply;
    }

    function mint() external payable {
        require(isMinted,"Minting not allowed");
        require(addMinted[msg.sender] < 1,"exceeds max per wallet");//to restrict the number of addresses that can mint
        //only 1 NFT can be minted for 1 wallet address
        require(msg.value == price,"pay exact price");
        uint256 tokenId = _tokenId.current();//stored locally to save gas 
        require(maxSupply>tokenId,"No more NFTs left to mint");
        _tokenId.increment();
        addMinted[msg.sender]++;
        _safeMint(msg.sender, tokenId);
    }

    //_safeMint takes the address and tokenId
    //it calls _mint in the parent contract
    //_safeMint is an internal call in the parent contract 
    //so we avoid re-entrancy vulnerability when this is used
}
