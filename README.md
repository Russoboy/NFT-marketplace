# NFT-marketplace
Building NFT marketplace with Typescript and Solidity


1️⃣ Setup Project
Install Node.js if you haven't already.
Initialize a new project:
#In bash
- mkdir nft-marketplace
- cd nft-marketplace
- npm init -y

Install Hardhat & Dependencies
#In bash
- npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers typescript ts-node
- npm install @openzeppelin/contracts

Initialize Hardhat:
#In bash
- npx hardhat

Run your deployment with:
#In bash
- npx hardhat run scripts/deploy.ts --network localhost

Build the Frontend with React & TypeScript 🌐
#In bash
npx create-react-app frontend --template typescript
cd frontend
npm install ethers

Testing and Deployment
Local Testing: Use Hardhat's local node:
npx hardhat node

