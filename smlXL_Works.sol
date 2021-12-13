contract smlXL_Works 
//is IERC721Receiver 
{
//Instanciate the AxieCore ERC721 contract.
address erc721contract=address(0xd346036DAE057209FD193954CaAF6455a3fb5cFc);
IERC721 nftContract = IERC721(erc721contract);



// Link depositors with an array containing the IDs of their Axies, each token with position, 
//and each token ID with depositor. Similar storage pattern to AxieCore.
mapping(address => uint[]) private depositorAxies; 
mapping(uint => uint) private axiePosition; 
mapping(uint => address) private axieDepositor; 

// The scholar struct. Need to discuss what data can really be stored except hashed passwords?
struct scholar {
bytes32 hashedPassword;
}

mapping (address => scholar) scholars;



// Deposit events. Different is one has fixed size tokenId, the other variable size.
// Can be further optimized if Ids often come in the form of three consecutive numbers.
event axieDeposited(
        address indexed depositor,
        uint256 tokenId
    );

event multipleAxiesDeposited(
address indexed depositor,
uint256[] tokenId
);

// Withdrawal events
event axieWithdrawn(
address indexed depositor,
uint tokenId
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
axiePosition[tokenId]=depositorAxies[msg.sender].length-1;
axieDepositor[tokenId]=msg.sender;
emit axieDeposited(msg.sender, tokenId);
return depositorAxies[msg.sender].length;
}

function depositMultipleAxies(uint256[] calldata tokenId)
external
returns (uint)  // Returns the number of Axies currently held for msg.sender
{

for(uint i=0; i<tokenId.length; i++){
nftContract.transferFrom(msg.sender, address(this), tokenId[i]);
depositorAxies[msg.sender].push(tokenId[i]);
axiePosition[tokenId[i]]=depositorAxies[msg.sender].length-1;
axieDepositor[tokenId[i]]=msg.sender;
}
emit multipleAxiesDeposited(msg.sender,  tokenId);
return depositorAxies[msg.sender].length;
}

function viewAxies()
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
uint _position=axiePosition[_tokenId];
axieDepositor[_tokenId]=address(0);
depositorAxies[msg.sender][_position] = depositorAxies[msg.sender][depositorAxies[msg.sender].length - 1];
depositorAxies[msg.sender].pop();
emit axieWithdrawn(msg.sender, _tokenId);
return depositorAxies[msg.sender].length;
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
