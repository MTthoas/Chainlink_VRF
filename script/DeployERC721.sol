// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ERC721.sol";

contract DeployMyNFT is Script {
    function run() external {
        // Définissez les paramètres pour le déploiement
        uint64 subscriptionId = 123; // Remplacez par un subscriptionId valide de Chainlink VRF
        address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625; // Sepolia VRF Coordinator
        address priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // ETH/USD Price Feed on Sepolia

        // Commencez la diffusion
        vm.startBroadcast();

        // Déployez le contrat MyNFT
        MyNFT myNFT = new MyNFT(subscriptionId);

        // Affichez les informations
        console.log("MyNFT deployed at:", address(myNFT));
        console.log("Price Feed address:", priceFeed);
        console.log("VRF Coordinator address:", vrfCoordinator);
        console.log("Subscription ID:", subscriptionId);

        vm.stopBroadcast();
    }
}
