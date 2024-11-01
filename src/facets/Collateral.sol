// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IERC721 } from "../interfaces/IERC721.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract Collateral {
    error NotCollateralized();
    error NotOwner();

    function addCollateral(address nftAddress, uint256 tokenId) internal {
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, NotOwner());
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);
        LibDiamond.LoanStorage storage ls = LibDiamond.loanStorage();
        ls.collateralizedNFTs[nftAddress][tokenId] = true;
    }

    function removeCollateral(address nftAddress, uint256 tokenId) internal {
        LibDiamond.LoanStorage storage ls = LibDiamond.loanStorage();
        require(ls.collateralizedNFTs[nftAddress][tokenId], NotCollateralized());
        ls.collateralizedNFTs[nftAddress][tokenId] = false;
        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
    }
}
