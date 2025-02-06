import React, { useState } from 'react';
import { ethers } from 'ethers';

// Replace with your deployed contract addresses
const NFT_ADDRESS = "YOUR_MY_NFT_CONTRACT_ADDRESS";
const MARKETPLACE_ADDRESS = "YOUR_MARKETPLACE_CONTRACT_ADDRESS";

// ABI snippets (you can extract these from your artifacts)
import MyNFTABI from "../abis/MyNFT.json";
import MarketplaceABI from "../abis/Marketplace.json";

const NFTMarketplace: React.FC = () => {
  const [account, setAccount] = useState<string>("");

  const connectWallet = async () => {
    if ((window as any).ethereum) {
      const accounts = await (window as any).ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);
    } else {
      alert("Please install MetaMask!");
    }
  };

  // Function to mint an NFT
  const mintNFT = async () => {
    if (!account) return alert("Connect your wallet first!");
    const provider = new ethers.providers.Web3Provider((window as any).ethereum);
    const signer = provider.getSigner();
    const nftContract = new ethers.Contract(NFT_ADDRESS, MyNFTABI, signer);
    const tokenURI = "https://my-json-server.typicode.com/your-api/metadata/1"; // Replace with actual metadata URI
    const tx = await nftContract.mintNFT(tokenURI);
    await tx.wait();
    alert("NFT Minted!");
  };

  return (
    <div style={{ padding: "20px" }}>
      <h1>NFT Marketplace</h1>
      <button onClick={connectWallet}>Connect Wallet 🔌</button>
      <br /><br />
      <button onClick={mintNFT}>Mint NFT 🎨</button>
    </div>
  );
};

export default NFTMarketplace;
