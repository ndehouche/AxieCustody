pragma solidity 0.8.9;
//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
contract smlXL_Works is IERC721Receiver {
uint depositId;
event axieDeposited(
       //bytes32 indexed requestId,
        address indexed depositor,
        address erc721contract, //may be unnecessary all over contract if only dealing with Axie
        uint256 tokenId
    );


function depositAxie(address erc721contract, uint256 tokenId) 
public
{
//Instanciate the ERC721 contract for the transfer

IERC721 nftContract = IERC721(erc721contract);
//Transfer the NFT from the user to the contract
//assumes that a JavaScript call "await axieContract.approve(address(this), expectedTokenId)" has been 
//previously made with the NFT owner's account. "msg.sender" in the external call below will be the contract's address. 
//safeTransferFrom checks that msg.sender owns the NFT in question (we also check this offchain).
//Also, it only works if the receiver is either an EOA or a smart contract that implements 
//onERC721Received (implemented in the IERC721Receiver interface). Otherwise the call will revert.
//We can also use the "unsafe" and simpler transferFrom. safeTransferFrom only exists to avoid 
//transfers to contracts that cannot handle being sent NFT. 
nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
emit axieDeposited(msg.sender,  erc721contract, tokenId);
}

function depositMultipleAxies(address erc721contract, uint256[] calldata tokenId)
public
{
//check what happens if msg.sender only owns some of the tokens in the tolkenId array but not all. 
//Write appriate logic if the whole transaction does not revert
for(uint i=0; i<tokenId.length; i++){
depositAxie(erc721contract, i);
}
}

function ownerOf(address erc721contract, uint256 tokenId)
public
view
returns(address){
IERC721 nftContract = IERC721(erc721contract);
 return nftContract.ownerOf(tokenId);  
}


// @Required function to instanciate this contract as an IERC721 receiver
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }


}
