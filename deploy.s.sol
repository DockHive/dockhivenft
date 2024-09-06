// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./src/NFT.sol";
import "forge-std/Script.sol";  // Import forge-std

contract DeployScript is Script {
    function run() public {
        // Address arguments for the constructor
        address patchworkProtocolAddress = 0x00000000001616E65bb9FdA42dFBb7155406549b;
        address initialOwner = 0xbb73D47298e9Ddb270FBDA3330D5C3603b3A15C0;

        // Start broadcast
        vm.startBroadcast();

        // Deploy the contract
        DockHiveNFT dockHiveNft = new DockHiveNFT(patchworkProtocolAddress, initialOwner);

        // Log the contract address
        console.log("deployed at:", address(dockHiveNft));

        // Stop broadcast
        vm.stopBroadcast();
    }
}