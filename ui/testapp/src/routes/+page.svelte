<script>
  import { ethers } from "ethers";

  const contractAddress = "0x474Bab3Ffdab2f34be69737bb9d8C74e3f581df1"; // DockHiveNFT contract address on Base Sepolia redploy
  
  // Updated ABI with mintWithReferral function
  const abi = [
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "refer",
          "type": "address"
        },
        {
          "internalType": "bytes",
          "name": "data",
          "type": "bytes"
        }
      ],
      "name": "mintWithReferral",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "stateMutability": "payable",
      "type": "function"
    }
  ];

  let provider;
  let signer;
  let contract;
  let address;
  let referralAddress = ''; // New variable to store the referral address


  const RPC_URL = "https://base-sepolia.blastapi.io/6108795a-137e-4af8-a28e-8c4bbd6336c2";
  const CHAIN_ID = 84532;

  const connectWallet = async () => {
    if (window.ethereum) {
      provider = new ethers.BrowserProvider(window.ethereum);
      
      try {
        // Request account access
        await provider.send("eth_requestAccounts", []);
        
        // Check if the current network is Base Sepolia
        const network = await provider.getNetwork();
        if (network.chainId !== BigInt(CHAIN_ID)) {
          // If not on Base Sepolia, request network switch
          try {
            await window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: `0x${CHAIN_ID.toString(16)}` }],
            });
          } catch (switchError) {
            // This error code indicates that the chain has not been added to MetaMask
            if (switchError.code === 4902) {
              try {
                await window.ethereum.request({
                  method: 'wallet_addEthereumChain',
                  params: [{
                    chainId: `0x${CHAIN_ID.toString(16)}`,
                    chainName: 'Base Sepolia',
                    nativeCurrency: {
                      name: 'Ether',
                      symbol: 'ETH',
                      decimals: 18
                    },
                    rpcUrls: [RPC_URL],
                    blockExplorerUrls: ['https://sepolia.basescan.org']
                  }],
                });
              } catch (addError) {
                throw new Error("Failed to add Base Sepolia network");
              }
            } else {
              throw switchError;
            }
          }
          
          // Reconnect provider after network switch
          provider = new ethers.BrowserProvider(window.ethereum);
        }
        
        signer = await provider.getSigner();
        address = await signer.getAddress(); // In v6, use getAddress() instead of .address
        contract = new ethers.Contract(contractAddress, abi, signer);
        
        console.log("Connected to Base Sepolia");
      } catch (error) {
        console.error("Failed to connect wallet:", error);
      }
    } else {
      console.error("MetaMask not detected");
    }
  };

  const mintNFTWithReferral = async (toAddress, referAddress) => {
    try {
      const mintingFee = ethers.parseEther("0.001");
      const tx = await contract.mintWithReferral(toAddress, referAddress, "0x", { value: mintingFee });
      await tx.wait();
      console.log("Minting with referral successful:", tx);
    } catch (error) {
      if (error.code === "CALL_EXCEPTION") {
        console.error("Contract call exception:", error);
      } else if (error.code === "INSUFFICIENT_FUNDS") {
        console.error("Insufficient funds for gas:", error);
      } else if (error.code === "UNPREDICTABLE_GAS_LIMIT") {
        console.error("Unpredictable gas limit:", error);
      } else {
        console.error("Error minting NFT with referral:", error);
      }
    }
  };
</script>



<button on:click="{connectWallet}">Connect Wallet</button>

<!-- Input for the referral address -->
<input type="text" placeholder="Referral Address (optional)" bind:value={referralAddress} />

<!-- Updated button to mint with referral -->
<button on:click="{() => mintNFTWithReferral(address, referralAddress || '0x0000000000000000000000000000000000000000')}">Mint NFT with Referral</button>
