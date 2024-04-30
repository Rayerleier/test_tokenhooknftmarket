// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NFTmartket} from "../src/ExtendedNFTMarket.sol";
import {MyExtendedERC20} from "../src/ERC20Extended2.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CounterTest is Test {
    NFTmartket nftmarket;
    MyExtendedERC20 erc20;
    ERC721 erc721;
    address alice; // alice作为卖家，持有NFT的人
    address bob; // bob作为买家，持有ERC20代币的人
    uint256 price;
    uint256 tokenId;

    function setUp() public {
        erc20 = new MyExtendedERC20();
        erc721 = new ERC721("rain","rayer");
        nftmarket = new NFTmartket(address(erc721));
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        price = 1 ether;
        tokenId = 1;
    }

    function test_erc721_mintNFT() public {
        vm.prank(alice);
        erc721._mint(alice, tokenId);
        assertEq(erc721.ownerOf(tokenId), alice);
    }

    // 测试将nft上架到market之前，你需要在nftcontract里面own the nft
    function test_list() public {
        test_erc721_mintNFT();
        vm.prank(alice);
        nftmarket.list(tokenId, price);

        (uint256 _price, address _seller) = nftmarket.listings(tokenId);
        assertEq(_price, price);
        assertEq(_seller, alice);
    }

    function test_erc721_approve() public {
        test_list();
        vm.prank(alice);
        erc721._approve(address(nftmarket), tokenId, alice);
        assertEq(erc721._tokenApprovals(tokenId), address(nftmarket));
    }

    function test_mint() public {
        erc20._mint(bob, price);
        assertEq(erc20.balances(bob), price);
    }

    function test_transferExtended() public{
        test_mint(); // bob获取代币
        test_erc721_approve(); // alice上架NFT，并授权nftmarket合约
        bytes memory data = abi.encodePacked(uint256(1));
        vm.prank(bob);
        erc20.transferExtended(address(nftmarket), alice, price, data); // erc20中购买nft
        assertEq(erc20.balances(bob), 0);  // bob余额为0
        assertEq(erc20.balances(alice), price); // alice获得交易金额
        assertEq(erc721._ownerOf(tokenId), bob); // 721中将nft所有权给bob
        vm.expectRevert("You must own NFT");
        vm.prank(alice);
        nftmarket.list(tokenId, 1 ether);
    }

}
