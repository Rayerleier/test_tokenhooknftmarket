// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


interface ITokenReceiver {
    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        bytes memory userData
    ) external;
}


//Write a simple NFT market contract, using your own issued Token to buy and sell NFTs. The functions include:

// list(): Implement the listing function, where the NFT holder can set a price 
// (how many tokens are needed to purchase the NFT) and list the NFT on the NFT market.
// buyNFT(): Implement the purchase function for NFTs,
// where users transfer the specified token quantity and receive the corresponding NFT.
contract NFTmartket is  ITokenReceiver{

    struct listOfNFTs{
        uint256 price;
        address seller;
    }
    IERC721 nftContract;

    // tokenId => ListOfNFTS
    mapping (uint256 => listOfNFTs) public listings;

    event Listed(uint256 indexed tokenId, address seller, uint256 price);
    event Bought(uint256 indexed tokenId, address buyer, address seller, uint256 price);

    address owner;
    constructor(address _nftAdress){
        owner = msg.sender;
        nftContract = IERC721(_nftAdress);
    }

       // 判断是否为合约
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    modifier OnlyContract(address account){
        isContract(account);
        _;
    }

    function list(uint256 tokenId, uint256 price)public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You must own NFT");
        require(price>0, "price must be greater than 0");   
        listings[tokenId] = listOfNFTs(price, msg.sender);
        emit Listed(tokenId, msg.sender, price);
    }


    // 回调函数
    function tokensReceived(
        address from,   //  NFT买家
        address to,     //  NFT卖家的地址，即接收转账的地址
        uint256 amount,     // 买家愿意支付的金额
        bytes memory userData)
        external OnlyContract(msg.sender) {
        uint256 _tokenId = bytesToUint(userData);
        uint256 price = listings[_tokenId].price;
        address seller = listings[_tokenId].seller;
        require(seller == to, "Owner address wrong");
        require(amount >= price, "You must give enough amount");
        // nft从市场转给买家
        nftContract.transferFrom(to, from, _tokenId);
        delete listings[_tokenId];  
        emit Bought(_tokenId, msg.sender, to, price);
    }

    function bytesToUint(bytes memory userData) public pure returns (uint256) {
        require(userData.length == 32, "The bytes array length must be 32.");
        uint256 numValue;  // Changed variable name from 'number' to 'numValue'
        assembly {
            // Load the 32 bytes word from memory starting at the location of `b`
            numValue := mload(add(userData, 32))
        }
        return numValue;
    }


}