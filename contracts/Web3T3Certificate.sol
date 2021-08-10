// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract Web3T3Certificate is ERC721, ERC721Enumerable, AccessControl, EIP712 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant TOKEN_CLAIM_HASH_STRUCT =
        keccak256(
            "TokenClaim(uint256 tokenId,string tokenUri,uint256 expires)"
        );

    mapping(uint256 => string) public _tokenUri;

    constructor()
        ERC721("Web3T3 Certificate", "W3T3")
        EIP712("Web3T3 Certificate", "1")
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _setTokenUri(uint256 tokenId, string memory tokenUri) internal {
        _tokenUri[tokenId] = tokenUri;
    }

    function safeMint(
        address to,
        uint256 tokenId,
        string memory tokenUri
    ) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
        _setTokenUri(tokenId, tokenUri);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _tokenUri[tokenId];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _getTokenClaimSigner(
        bytes memory signature,
        uint256 tokenId,
        string memory tokenUri,
        uint256 expires
    ) internal view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    TOKEN_CLAIM_HASH_STRUCT,
                    tokenId,
                    keccak256(abi.encodePacked(tokenUri)),
                    expires
                )
            )
        );

        address signer = ECDSA.recover(digest, signature);

        return signer;
    }

    function checkSignature(
        bytes memory signature,
        uint256 tokenId,
        string memory tokenUri,
        uint256 expires
    ) internal view {
        require(block.timestamp < expires, "Expired");

        address signer = _getTokenClaimSigner(
            signature,
            tokenId,
            tokenUri,
            expires
        );

        require(signer != address(0), "Invalid signature");
        require(hasRole(MINTER_ROLE, signer), "Ineligible signer");
    }

    function claimToken(
        bytes memory signature,
        uint256 tokenId,
        string memory tokenUri,
        uint256 expires
    ) public {
        checkSignature(signature, tokenId, tokenUri, expires);

        // _safeMint makes sure that token hasn't been minted already
        // Also emits a Transfer event so we don't have to worry about events :D
        _safeMint(msg.sender, tokenId);

        _setTokenUri(tokenId, tokenUri);
    }
}
