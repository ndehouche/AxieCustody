pragma solidity 0.8.9;
//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract smlXL_Works 
//is IERC721Receiver 
{
uint depositId;
event axieDeposited(
       //bytes32 indexed requestId,
        address indexed depositor,
        address erc721contract, //Unnecessary all over contract if only dealing with Axie
        uint256 tokenId
    );

event multipleAxiesDeposited(
       //bytes32 indexed requestId,
        address indexed depositor,
        address erc721contract, //Unnecessary all over contract if only dealing with Axie
        uint256[] tokenId
    );


function depositAxie(address erc721contract, uint256 tokenId) 
public
{
//Instanciate the ERC721 contract for the transfer. Can be gotten rid of if only  working with the Axie core contract contract.

IERC721 nftContract = IERC721(erc721contract);
//Transfer the NFT from the user to the contract
//assumes that a JavaScript call "await axieContract.approve(address(this), expectedTokenId)" has been 
//previously made with the NFT owner's account. "msg.sender" in the external call below will be the contract's address. 
//Though the Axie contract "was deployed before ERC721 was standardized", it implements the standard functions approve, 
//transferFrom and safeTransferFrom. 
//safeTransferFrom checks that msg.sender owns the NFT in question (we also check this offchain).
//Also, it only works if the receiver is either an EOA or a smart contract that implements 
//onERC721Received (implemented in the IERC721Receiver interface). Otherwise the call will revert.
//Here, we use the "unsafe" and simpler transferFrom. safeTransferFrom only exists to avoid 
//transfers to contracts that cannot handle being sent NFT. 
//nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
nftContract.transferFrom(msg.sender, address(this), tokenId);
emit axieDeposited(msg.sender,  erc721contract, tokenId);
}

function depositMultipleAxies(address erc721contract, uint256[] calldata tokenId)
public
{
//We instanciate the contract once
IERC721 nftContract = IERC721(erc721contract);
for(uint i=0; i<tokenId.length; i++){
nftContract.transferFrom(msg.sender, address(this), tokenId[i]);
}
emit multipleAxiesDeposited(msg.sender,  erc721contract, tokenId);
}

function ownerOf(address erc721contract, uint256 tokenId)
public
view
returns(address){
IERC721 nftContract = IERC721(erc721contract);
 return nftContract.ownerOf(tokenId);  
}


// @Required function to instanciate this contract as an IERC721 receiver
//    function onERC721Received(
//        address,
//        address,
//        uint256,
//        bytes calldata
//    ) public virtual override returns (bytes4) {
//        return this.onERC721Received.selector;
//    }


}
