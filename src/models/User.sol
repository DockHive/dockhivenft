// SPDX-License-Identifier: UNLICENSED
//0x9349FA3d7e715f4530Ce83fD8d9709F4B3594B49
pragma solidity ^0.8.26;

import "@patchwork/Patchwork721.sol";
import "@patchwork/interfaces/IPatchworkMintable.sol";
import "@patchwork/PatchworkUtils.sol";

contract UserNFTContract is Patchwork721, IPatchworkMintable {

    struct Metadata {
        uint256 nfts_held_count;
        uint256 minted_nfts_count;
        uint256 token_id;
        uint256 minted_at;
        address wallet_address;
        address owner;
    }

    mapping(uint256 => string) internal _dynamicStringStorage; // tokenId => string

    uint256 internal _nextTokenId;

    constructor(address _manager, address _owner)
        Patchwork721("undefined", "UserNFTContract", "UNFT", _manager, _owner)
    {}

    function schemaURI() pure external override returns (string memory) {
        return "ipfs://example-schema-uri";
    }

    function imageURI(uint256 tokenId) pure external override returns (string memory) {
    return string(abi.encodePacked("ipfs://<your_ipfs_hash>/", Strings.toString(tokenId), ".png"));
}

    function _baseURI() internal pure virtual override returns (string memory) {
        return "";
    }

    function supportsInterface(bytes4 interfaceID) public view virtual override returns (bool) {
        return type(IPatchworkMintable).interfaceId == interfaceID ||
            super.supportsInterface(interfaceID);
    }

    function storeMetadata(uint256 tokenId, Metadata memory data) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId] = packMetadata(data);
    }

    function loadMetadata(uint256 tokenId) public view returns (Metadata memory data) {
        return unpackMetadata(_metadataStorage[tokenId]);
    }

    function schema() pure external override returns (MetadataSchema memory) {
        MetadataSchemaEntry[] memory entries = new MetadataSchemaEntry[](7);
        entries[0] = MetadataSchemaEntry(2, 0, FieldType.UINT256, 1, FieldVisibility.PUBLIC, 0, 0, "nfts_held_count");
        entries[1] = MetadataSchemaEntry(3, 0, FieldType.UINT256, 1, FieldVisibility.PUBLIC, 1, 0, "minted_nfts_count");
        entries[2] = MetadataSchemaEntry(4, 0, FieldType.UINT256, 1, FieldVisibility.PUBLIC, 2, 0, "token_id");
        entries[3] = MetadataSchemaEntry(7, 0, FieldType.UINT256, 1, FieldVisibility.PUBLIC, 3, 0, "minted_at");
        entries[4] = MetadataSchemaEntry(1, 0, FieldType.ADDRESS, 1, FieldVisibility.PUBLIC, 4, 0, "wallet_address");
        entries[5] = MetadataSchemaEntry(6, 0, FieldType.STRING, 1, FieldVisibility.PUBLIC, 4, 0, "token_uri");
        entries[6] = MetadataSchemaEntry(5, 0, FieldType.ADDRESS, 1, FieldVisibility.PUBLIC, 4, 0, "owner");
        return MetadataSchema(1, entries);
    }

    function packMetadata(Metadata memory data) public pure returns (uint256[] memory slots) {
        slots = new uint256[](5);
        slots[0] = uint256(data.nfts_held_count);
        slots[1] = uint256(data.minted_nfts_count);
        slots[2] = uint256(data.token_id);
        slots[3] = uint256(data.minted_at);
        slots[4] = uint256(uint160(data.wallet_address)) | uint256(uint160(data.owner));
        return slots;
    }

    function unpackMetadata(uint256[] memory slots) public pure returns (Metadata memory data) {
        uint256 slot = slots[0];
        data.nfts_held_count = uint256(slot);
        slot = slots[1];
        data.minted_nfts_count = uint256(slot);
        slot = slots[2];
        data.token_id = uint256(slot);
        slot = slots[3];
        data.minted_at = uint256(slot);
        slot = slots[4];
        data.wallet_address = address(uint160(slot));
        data.owner = address(uint160(slot));
        return data;
    }

    function mint(address to, bytes calldata data) public payable returns (uint256 tokenId) {
        if (msg.sender != _manager) {
            return IPatchworkProtocol(_manager).mint{value: msg.value}(to, address(this), data);
        }
        return _mintSingle(to, data);
    }

    function mintBatch(address to, bytes calldata data, uint256 quantity) public payable returns (uint256[] memory tokenIds) {
        if (msg.sender != _manager) {
            return IPatchworkProtocol(_manager).mintBatch{value: msg.value}(to, address(this), data, quantity);
        }
        tokenIds = new uint256[](quantity);
        for (uint256 i = 0; i < quantity; i++) {
            tokenIds[i] = _mintSingle(to, data);
        }
    }

    function _mintSingle(address to, bytes calldata /* data */) internal returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _metadataStorage[tokenId] = new uint256[](5);
        _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    // Load Only nfts_held_count
    function loadNftsheldcount(uint256 tokenId) public view returns (uint256) {
        uint256 value = uint256(_metadataStorage[tokenId][0]);
        return uint256(value);
    }

    // Store Only nfts_held_count
    function storeNftsheldcount(uint256 tokenId, uint256 nfts_held_count) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId][0] = uint256(nfts_held_count);
    }

    // Load Only minted_nfts_count
    function loadMintednftscount(uint256 tokenId) public view returns (uint256) {
        uint256 value = uint256(_metadataStorage[tokenId][1]);
        return uint256(value);
    }

    // Store Only minted_nfts_count
    function storeMintednftscount(uint256 tokenId, uint256 minted_nfts_count) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId][1] = uint256(minted_nfts_count);
    }

    // Load Only token_id
    function loadTokenid(uint256 tokenId) public view returns (uint256) {
        uint256 value = uint256(_metadataStorage[tokenId][2]);
        return uint256(value);
    }

    // Store Only token_id
    function storeTokenid(uint256 tokenId, uint256 token_id) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId][2] = uint256(token_id);
    }

    // Load Only minted_at
    function loadMintedat(uint256 tokenId) public view returns (uint256) {
        uint256 value = uint256(_metadataStorage[tokenId][3]);
        return uint256(value);
    }

    // Store Only minted_at
    function storeMintedat(uint256 tokenId, uint256 minted_at) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId][3] = uint256(minted_at);
    }

    // Load Only wallet_address
    function loadWalletaddress(uint256 tokenId) public view returns (address) {
        uint256 value = uint256(_metadataStorage[tokenId][4]);
        return address(uint160(value));
    }

    // Store Only wallet_address
    function storeWalletaddress(uint256 tokenId, address wallet_address) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        uint256 mask = (1 << 160) - 1;
        uint256 cleared = uint256(_metadataStorage[tokenId][4]) & ~(mask);
        _metadataStorage[tokenId][4] = cleared | (uint256(uint160(wallet_address)) & mask);
    }

    // Load Only token_uri
    function loadTokenuri(uint256 tokenId) public view returns (string memory) {
        return _dynamicStringStorage[tokenId];
    }

    // Store Only token_uri
    function storeTokenuri(uint256 tokenId, string memory token_uri) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _dynamicStringStorage[tokenId] = token_uri;
    }

    // Load Only owner
    function loadOwner(uint256 tokenId) public view returns (address) {
        uint256 value = uint256(_metadataStorage[tokenId][4]);
        return address(uint160(value));
    }

    // Store Only owner
    function storeOwner(uint256 tokenId, address owner) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        uint256 mask = (1 << 160) - 1;
        uint256 cleared = uint256(_metadataStorage[tokenId][4]) & ~(mask);
        _metadataStorage[tokenId][4] = cleared | (uint256(uint160(owner)) & mask);
    }
}