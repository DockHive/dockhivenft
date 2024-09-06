encoded_args=$(cast abi-encode "constructor(address,address)" "0x00000000001616E65bb9FdA42dFBb7155406549b" "0xbb73D47298e9Ddb270FBDA3330D5C3603b3A15C0")

forge verify-contract 0x26E58BF618f97077C02C879CcE6698Ae520c89fB  ./src/NFT.sol:DockHiveNFT \
--constructor-args $encoded_args \
--optimizer-runs 200 \
--chain-id 8453 \
--compiler-version v0.8.26+commit.8a97fa7a \
--verifier-url https://api.basescan.org/api \
--api-key '' \
--watch