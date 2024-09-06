// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "@patchwork/Patchwork721.sol";
import "@patchwork/interfaces/IPatchworkMintable.sol";
import "@patchwork/PatchworkUtils.sol";

enum FieldType { UINT256, ADDRESS, STRING }
enum FieldVisibility { PUBLIC, PRIVATE }

struct MetadataSchemaEntry {
    uint8 field_id;
    uint8 parent_id;
    FieldType field_type;
    uint8 length;
    FieldVisibility visibility;
    uint8 position;
    uint8 max_size;
    string field_name;
}

struct MetadataSchema {
    uint8 schema_version;
    MetadataSchemaEntry[] entries;
}

contract DockHiveNFT is Patchwork721, IPatchworkMintable {
    struct Metadata {
        uint256 token_id;
        uint256 minted_at;
        address owner;
    }

    mapping(uint256 => string) private _tokenURIs;
    uint256 private _nextTokenId;
    MetadataSchemaEntry[] private _entries;

    constructor(address _manager, address _owner)
        Patchwork721("DockHive", "DockHiveNFT", "DHN", _manager, _owner)
    {
        MetadataSchemaEntry[4] memory tempEntries = [
            MetadataSchemaEntry(1, 0, FieldType.UINT256, 1, FieldVisibility.PUBLIC, 0, 0, "token_id"),
            MetadataSchemaEntry(2, 0, FieldType.UINT256, 1, FieldVisibility.PUBLIC, 1, 0, "minted_at"),
            MetadataSchemaEntry(3, 0, FieldType.ADDRESS, 1, FieldVisibility.PUBLIC, 2, 0, "owner"),
            MetadataSchemaEntry(4, 0, FieldType.STRING, 1, FieldVisibility.PUBLIC, 3, 0, "token_uri")
        ];
        for (uint256 i = 0; i < tempEntries.length; i++) {
            _entries.push(tempEntries[i]);
        }
    }

    function schemaURI() pure external override returns (string memory) {
        return "ipfs://dockhive-schema-uri";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }
        return string(abi.encodePacked("https://dockhive.io/nft/", Strings.toString(tokenId)));
    }

    function imageURI(uint256 tokenId) external pure override returns (string memory) {
        return string(abi.encodePacked("https://dockhive.io/nft/badge.svg", Strings.toString(tokenId)));
    }

    function _baseURI() internal pure virtual override returns (string memory) {
        return "https://dockhive.io/nft/";
    }

    function supportsInterface(bytes4 interfaceID) public view virtual override returns (bool) {
        return interfaceID == type(IPatchworkMintable).interfaceId || super.supportsInterface(interfaceID);
    }

    function schema() view external override returns (MetadataSchema memory) {
        return MetadataSchema(1, _entries);
    }

    // Original mint function from the interface
    function mint(address to, bytes calldata data) public payable override returns (uint256 tokenId) {
        require(msg.value == 0.000777 ether, "Incorrect minting fee");
        tokenId = _mintSingle(to, data);
        payable(owner()).transfer(msg.value);
    }

    // New mint function with referral logic
    function mintWithReferral(address to, address refer, bytes calldata data) public payable returns (uint256 tokenId) {
        tokenId = mint(to, data);
        if (refer != address(0)) {
            uint256 referTokenId = _mintSingle(refer, data);
            emit MintWithReferral(tokenId, referTokenId, refer);
        }
    }

    function mintBatch(address to, bytes calldata data, uint256 quantity) public payable override returns (uint256[] memory tokenIds) {
        require(msg.value == 0.000777 ether * quantity, "Incorrect minting fee");
        tokenIds = new uint256[](quantity);
        for (uint256 i = 0; i < quantity; i++) {
            tokenIds[i] = _mintSingle(to, data);
        }
        payable(owner()).transfer(msg.value);
    }

    function _mintSingle(address to, bytes calldata) internal returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenMetadata(tokenId, to);
        return tokenId;
    }

    function _setTokenMetadata(uint256 tokenId, address to) internal {
        Metadata memory data = Metadata({
            token_id: tokenId,
            minted_at: block.timestamp,
            owner: to
        });
        _metadataStorage[tokenId] = packMetadata(data);
    }

function packMetadata(Metadata memory data) public pure returns (uint256[] memory slots) {
    slots = new uint256[](3); // Initialize with size 3
    slots[0] = data.token_id;
    slots[1] = data.minted_at;
    slots[2] = uint256(uint160(data.owner));
    return slots;
}


    function unpackMetadata(uint256[] memory slots) public pure returns (Metadata memory data) {
        data.token_id = slots[0];
        data.minted_at = slots[1];
        data.owner = address(uint160(slots[2]));
        return data;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
        require(_checkTokenWriteAuth(tokenId), "Not authorized");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function getTokenId(uint256 tokenId) public view returns (uint256) {
        return uint256(_metadataStorage[tokenId][0]);
    }

    function getMintedAt(uint256 tokenId) public view returns (uint256) {
        return uint256(_metadataStorage[tokenId][1]);
    }

    function getOwner(uint256 tokenId) public view returns (address) {
        return address(uint160(_metadataStorage[tokenId][2]));
    }

    function setMintedAt(uint256 tokenId, uint256 minted_at) public {
        require(_checkTokenWriteAuth(tokenId), "Not authorized");
        _metadataStorage[tokenId][1] = minted_at;
    }

    function setOwner(uint256 tokenId, address newOwner) public {
        require(_checkTokenWriteAuth(tokenId), "Not authorized");
        _metadataStorage[tokenId][2] = uint256(uint160(newOwner));
    }

    event MintWithReferral(uint256 tokenId, uint256 referTokenId, address refer);
}
