// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMyNFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract Marketplace {
    struct Listing {
        address seller;
        uint256 price;
    }

    // token contract address => tokenId => Listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    // List NFT for sale
    function listItem(address nftAddress, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than zero");
        listings[nftAddress][tokenId] = Listing(msg.sender, price);
    }

    // Buy NFT
    function buyItem(address nftAddress, uint256 tokenId) external payable {
        Listing memory item = listings[nftAddress][tokenId];
        require(msg.value >= item.price, "Insufficient funds");
        // Transfer funds to seller
        payable(item.seller).transfer(item.price);
        // Transfer NFT to buyer
        IMyNFT(nftAddress).transferFrom(item.seller, msg.sender, tokenId);
        // Remove the listing
        delete listings[nftAddress][tokenId];
    }
}
