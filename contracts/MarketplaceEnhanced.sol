// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Minimal NFT interface with transfer functions.
interface IMyNFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns(address);
}

contract MarketplaceEnhanced {
    // Basic listing for direct sales.
    struct Listing {
        address seller;
        uint256 price;
        bool isListed;
    }
    
    // Auction details for NFT auctions.
    struct Auction {
        address seller;
        uint256 startPrice;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }

    // Mapping for direct sale listings: NFT address => tokenId => Listing
    mapping(address => mapping(uint256 => Listing)) public listings;
    // Mapping for auctions: NFT address => tokenId => Auction
    mapping(address => mapping(uint256 => Auction)) public auctions;

    // 🎉 EVENTS
    event ItemListed(address indexed nftAddress, uint256 indexed tokenId, address seller, uint256 price);
    event ItemDelisted(address indexed nftAddress, uint256 indexed tokenId, address seller);
    event ItemSold(address indexed nftAddress, uint256 indexed tokenId, address seller, address buyer, uint256 price);
    event AuctionStarted(address indexed nftAddress, uint256 indexed tokenId, address seller, uint256 startPrice, uint256 endTime);
    event BidPlaced(address indexed nftAddress, uint256 indexed tokenId, address bidder, uint256 bidAmount);
    event AuctionEnded(address indexed nftAddress, uint256 indexed tokenId, address winner, uint256 finalPrice);

    // ✅ List an NFT for direct sale.
    function listItem(address nftAddress, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be > 0");
        listings[nftAddress][tokenId] = Listing({
            seller: msg.sender,
            price: price,
            isListed: true
        });
        emit ItemListed(nftAddress, tokenId, msg.sender, price);
    }

    // 🚫 Delist an NFT from direct sale.
    function delistItem(address nftAddress, uint256 tokenId) external {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Item not listed");
        require(item.seller == msg.sender, "Not your listing");
        delete listings[nftAddress][tokenId];
        emit ItemDelisted(nftAddress, tokenId, msg.sender);
    }

    // 💰 Buy an NFT that's listed for direct sale.
    function buyItem(address nftAddress, uint256 tokenId) external payable {
        Listing memory item = listings[nftAddress][tokenId];
        require(item.isListed, "Item not listed");
        require(msg.value >= item.price, "Insufficient funds");

        // Transfer payment to seller.
        payable(item.seller).transfer(item.price);
        // Transfer NFT from seller to buyer.
        IMyNFT(nftAddress).transferFrom(item.seller, msg.sender, tokenId);
        // Remove the listing.
        delete listings[nftAddress][tokenId];
        emit ItemSold(nftAddress, tokenId, item.seller, msg.sender, item.price);
    }

    // 🏁 Start an auction for an NFT.
    function startAuction(address nftAddress, uint256 tokenId, uint256 startPrice, uint256 duration) external {
        // Ensure no active auction exists.
        Auction storage auction = auctions[nftAddress][tokenId];
        require(!auction.active, "Auction already active");
        require(duration > 0, "Duration must be > 0");

        auctions[nftAddress][tokenId] = Auction({
            seller: msg.sender,
            startPrice: startPrice,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            active: true
        });
        emit AuctionStarted(nftAddress, tokenId, msg.sender, startPrice, block.timestamp + duration);
    }

    // 📝 Place a bid in an active auction.
    function bid(address nftAddress, uint256 tokenId) external payable {
        Auction storage auction = auctions[nftAddress][tokenId];
        require(auction.active, "Auction not active");
        require(block.timestamp < auction.endTime, "Auction ended");

        // Determine the minimum acceptable bid.
        uint256 minBid = auction.highestBid == 0 ? auction.startPrice : auction.highestBid + 1;
        require(msg.value >= minBid, "Bid too low");

        // Refund the previous highest bidder, if any.
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        // Update highest bid and bidder.
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        emit BidPlaced(nftAddress, tokenId, msg.sender, msg.value);
    }

    // ⏱️ End the auction and transfer NFT to the winner.
    function endAuction(address nftAddress, uint256 tokenId) external {
        Auction storage auction = auctions[nftAddress][tokenId];
        require(auction.active, "Auction not active");
        require(block.timestamp >= auction.endTime, "Auction still running");
        auction.active = false;

        if (auction.highestBidder != address(0)) {
            // Transfer NFT from seller to highest bidder.
            IMyNFT(nftAddress).transferFrom(auction.seller, auction.highestBidder, tokenId);
            // Transfer bid funds to seller.
            payable(auction.seller).transfer(auction.highestBid);
            emit AuctionEnded(nftAddress, tokenId, auction.highestBidder, auction.highestBid);
        } else {
            // No bids received: auction failed.
            emit AuctionEnded(nftAddress, tokenId, address(0), 0);
        }
    }
}
