pragma solidity 0.8.9;
//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract smlXL_Works 
//is IERC721Receiver 
{
//Instanciate the AxieCore ERC721 contract.
address erc721contract=address(0xd346036DAE057209FD193954CaAF6455a3fb5cFc);
IERC721 nftContract = IERC721(erc721contract);



// Link depositors with an array containing the IDs of their Axies and each token ID with depositor
mapping(address => uint[]) private depositorAxies; 
mapping(uint => address) private axieDepositor; 

// Deposit functions. The differnce between depositing one and multiple Axies is that in the former case
// the size of the array is fixed.
event axieDeposited(
        address indexed depositor,
        uint256 tokenId
    );

event multipleAxiesDeposited(
        address indexed depositor,
        uint256[] tokenId
    );

modifier isDepositor(uint _tokenId){
require(msg.sender==axieDepositor[_tokenId]); 
_;
}






function depositAxie(uint256 tokenId) 
external
returns (uint)  // Returns the number of Axies currently held for msg.sender
{
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
depositorAxies[msg.sender].push(tokenId);
axieDepositor[tokenId]=msg.sender;
emit axieDeposited(msg.sender,  tokenId);
return depositorAxies[msg.sender].length;

}

function depositMultipleAxies(uint256[] calldata tokenId)
external
returns (uint)  // Returns the number of Axies currently held for msg.sender
{

for(uint i=0; i<tokenId.length; i++){
nftContract.transferFrom(msg.sender, address(this), tokenId[i]);
depositorAxies[msg.sender].push(tokenId[i]);
axieDepositor[tokenId[i]]=msg.sender;
}
emit multipleAxiesDeposited(msg.sender,  tokenId);
return depositorAxies[msg.sender].length;
}

function viewAxies(address _depositor)
external
view
returns(uint[] memory){
return depositorAxies[msg.sender];

}

function viewDepositor(uint _tokenId)
external
view
returns(address){
return axieDepositor[_tokenId];
    
}


function withdrawAxie(uint256 _tokenId) 
external
isDepositor(_tokenId)
returns (uint)  // Returns the number of Axies currently held for msg.sender
{
axieDepositor[_tokenId]=address(0);
_id=getId(msg.sender,_tokenId);
depositorAxies[msg.sender][_id] = depositorAxie[msg.sender][depositorAxie[msg.sender].length - 1];
depositorAxies[msg.sender].pop();
emit axieWithdrawn(msg.sender, _tokenId);
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
