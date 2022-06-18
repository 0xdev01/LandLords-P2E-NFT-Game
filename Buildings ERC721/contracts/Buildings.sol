// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Buildings is ERC721A, Ownable{
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 100000;
    uint256 public constant SALE_PRICE = .05 ether;   //or 100 $LAND tokens
    uint256 public constant MAX_MINT = 1;

    string private  baseTokenUri;

    bool public isRevealed;
    bool public isGameStarted;
    bool public pause;

    mapping(address => uint256) public totalOwnerMint;


    constructor() ERC721A("LandLords Buildings", "LLB"){

    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Cannot be called by a contract");
        _;
    }

  function OwnerMint(uint256 _quantity) external payable callerIsUser{
        require(isGameStarted, "Not Yet Active.");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "Beyond Max Supply");
        require((totalOwnerMint[msg.sender] +_quantity) <= MAX_MINT, "Already minted!");
        require(msg.value >= (SALE_PRICE * _quantity), "Below ");

        totalOwnerMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    //return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        //string memory baseURI = _baseURI();
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, tokenId.toString(), ".json")) : "";
    }

    /// @dev walletOf() function shouldn't be called on-chain due to gas consumption
    function walletOf() external view returns(uint256[] memory){
        address _owner = msg.sender;
        uint256 numberOfOwnedNFT = balanceOf(_owner);
        uint256[] memory ownerIds = new uint256[](numberOfOwnedNFT);

        for(uint256 index = 0; index < numberOfOwnedNFT; index++){
            ownerIds[index] = tokenOfOwnerByIndex(_owner, index);
        }

        return ownerIds;
    }

    function setTokenUri(string memory _baseTokenUri) external onlyOwner{
        baseTokenUri = _baseTokenUri;
    }

    function togglePause() external onlyOwner{
        pause = !pause;
    }


    function toggleGame() external onlyOwner{
        isGameStarted = !isGameStarted;
    }

    function toggleReveal() external onlyOwner{
        isRevealed = !isRevealed;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Failed to withdraw payment");
    }
}