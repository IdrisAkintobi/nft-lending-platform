// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IERC721 } from "../../src/interfaces/IERC721.sol";

contract MockNFT is IERC721 {
    mapping(uint256 => address) private _owners;

    function mint(address to, uint256 tokenId) external {
        _owners[tokenId] = to;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return _owners[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(_owners[tokenId] == from, "Not owner");
        _owners[tokenId] = to;
    }
}
