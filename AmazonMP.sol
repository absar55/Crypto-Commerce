
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol"; //Used for Counters
import "@openzeppelin/contracts/access/Ownable.sol"; //ERC20 modifier adds onlyOwner, which can be applied to functions to restrict their use to the owner.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; //ERC20 Token for AUSD (Stable Currency pegged to USD for Store Items)
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; //Inherts from ERC721, enables settting Token URIs (CID)
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //Modifier for the Security purpose since we are entering Contract to Contract
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; //ERC721 Token for NFTs (Store Items)

contract AmazonUSD is ERC20, Ownable {
    constructor() ERC20("Amazon USD", "AUSD") {
        _mint(msg.sender, 10000000000000 * 10 ** 2);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}


contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //Using as counters for NFT Token IDs within the Contract (Default = 0)
    address contractAddress; //Address of the main Contract AmazonMarket allowin it to handle NFTs internally
    address public ownAddress; //Tacle Mallware
    address public owner;

    constructor(address marketplaceAddress) ERC721("Amazon Products", "AMZ") { //ERC721 Contract NFT Name and Symbol
        contractAddress = marketplaceAddress; //Will take main contract address as input
        ownAddress = address(this);
        owner = msg.sender;
    }

    function createToken(string memory tokenURI) public returns (uint) { //Takes CID as URI for NFT
        uint256 newItemId = _tokenIds.current(); //Sets the vurrent counter value as NFT Item ID
        _tokenIds.increment(); //Function to add 1 to counter
        _mint(msg.sender, newItemId); //Mints the new NFT with Sender as the Owner with Counter value as Unique NFT ID
        _setTokenURI(newItemId, tokenURI); //Sets Token URI (CID)
        setApprovalForAll(contractAddress, true); //Allows access to the main Contract to transfer owmership of the NFT
        return newItemId; //Returns NFT Unique ID (from Counter value)
    }
}


contract AmazonMP is ReentrancyGuard { //Main Contract using Security Modifier
    using Counters for Counters.Counter;
    Counters.Counter private itemCount; //Using another instance of Counters this time for Item IDs (previous for NFT ID)
    address nftContract;
    // AmazonUSD AUSD;
    ERC20 public AUSD; //For ERC20 Token
    address payable public owner; //Address of the Owner of this Contract
    address public ownAddress; //Tacle Mallware

    constructor() { //("address _AUSDAddress" Removed)
        owner = payable(msg.sender); //Sets Sender Adddress as Owner of Contract Address at initiation
        // AUSD = AmazonUSD(_AUSDAddress); //ERC20 Token Created
        AUSD = new AmazonUSD(); //ERC20 Token Created
        AUSD.approve(address(this), AUSD.totalSupply());
        ownAddress = address(this);
    }

    struct item { //Structure for the Item
        uint id; //Unique Item ID from Counters
        address nftContract; //NFT Address
        uint256 tokenId; //NFT Unique ID from Counters
        address payable owner; //Owner Address
        uint256 price; //Sale price of the Item
        uint category; //Range 1 - 4
        string uriAddress; //URI from NFT
    }

    mapping(uint256 => item) private items; //For mapping Unique Item ID to their respective Item Structure

    event itemCreated ( //Event for when New Item is Created
        uint indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address owner,
        uint256 price,
        uint category,
        string uriAddress
    );

    function setNftContract(address _address) public nonReentrant{ //Sets NFT Contract Address to Main Contract
        require(msg.sender == owner, "Only Owner of this contract can set NFT Contract Address!");
        nftContract = _address;
    }

    function getItem(uint256 _id) public view returns (item memory) {
        return items[_id];
    }

    function getBalance() public view returns (uint256) { //Senders USD Balance
        return AUSD.balanceOf(msg.sender);
    }

    function getContractBalanceETH() public view returns (uint256) { //Contracts ETH Balance
        require(msg.sender == owner);
        return address(this).balance;
    }

    function getContractBalanceUSD() public view returns (uint256) { //Contracts USD Balance
        require(msg.sender == owner);
        return AUSD.balanceOf(address(this));
    }

    function deposit(uint256 rateUSD) public payable nonReentrant{ //Deposits Ether -> USD
        require(msg.value > 0, "AUSD is not for free");
        uint256 amountETH = (msg.value*99/100);
        uint256 amountUSD = (amountETH * rateUSD)/10**18;
        require(AUSD.balanceOf(address(this)) >= amountUSD, "Insufficient AUSD");
        AUSD.transfer(msg.sender, amountUSD);
    }

    function withdraw(uint256 rateUSD, uint256 _amountUSD) public nonReentrant{ //Withdraws USD -> Ether
        require(_amountUSD > 0 && _amountUSD <= AUSD.balanceOf(msg.sender));
        uint256 amountUSD = (_amountUSD*99)/100;
        uint256 amountETH = (amountUSD/rateUSD)*10**18;
        require(address(this).balance >= amountETH, "Insufficient ETH");
        AUSD.approve(address(this), _amountUSD);
        AUSD.transferFrom(msg.sender, address(this), _amountUSD);
        payable(msg.sender).transfer(amountETH);
    }

    function addItem(uint256 tokenId, uint256 price, uint category, bool instock) public payable nonReentrant { //Creates new Item with NFT address
        require(price > 0, "Price must be at least 1 wei"); //Item should nor be FREE
        require(msg.sender == IERC721(nftContract).ownerOf(tokenId));
        uint256 id = itemCount.current(); //Sets Item ID to the Counter Value
        itemCount.increment(); //Increments Counter by 1
        string memory _uri = ERC721(nftContract).tokenURI(tokenId);
        items[id] =  item(id, nftContract, tokenId, payable(msg.sender), price, category, _uri); //Maps Item ID to Item Structure where Owner is the Sender Address

        if (instock) {
            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId); //Transfers ownership of the NFT from its Owner to the Main Contract Address as Item is for Sale so Contract itself can transfer ownership to its buyer address (New Owner)
        }

        emit itemCreated(id, nftContract, tokenId, msg.sender, price, category, _uri); //Logs Details
    }

    function editItem(uint _id, uint _price, bool _instock) public nonReentrant { //Can change Price for Item and on Sale availablity
        require(items[_id].owner == msg.sender);
        require(_price > 0);
        items[_id].price = _price;
        if (_instock && IERC721(nftContract).ownerOf(items[_id].tokenId) != address(this)) {
            IERC721(nftContract).transferFrom(msg.sender, address(this), items[_id].tokenId); //Transfer ownership to Contract Address (For Sale)
        } else if (!_instock && IERC721(nftContract).ownerOf(items[_id].tokenId) == address(this)){
            IERC721(nftContract).transferFrom(address(this), items[_id].owner, items[_id].tokenId); ////Transfer ownership to Sender Address (Not For Sale)
        }
    }

    function buyItem(uint _id, uint _price) public nonReentrant { //Transfers Item and NFT ownership to its new Owner(Buyer)
        require(_id < itemCount.current(), "Invalid Item ID!");
        require(_price == items[_id].price, "Invalid Price!");
        require(IERC721(nftContract).ownerOf(items[_id].tokenId) == address(this), "Not for Sale!");
        require(msg.sender != items[_id].owner);
        require(AUSD.balanceOf(msg.sender) >= items[_id].price);
        AUSD.transferFrom(msg.sender, items[_id].owner, items[_id].price);
        IERC721(nftContract).transferFrom(address(this), msg.sender, items[_id].tokenId); //Transfer ownership of NFT from Contract address to new owner address(buyer/sender)
        items[_id].owner = payable(msg.sender);
    }

    function getItems(uint8 _category) public view returns(item[] memory, uint8){ //Returns a List of Items for Sale
        item[] memory _items = new item[](itemCount.current());
        // string[] storage uriAddresses;
        uint8 itemNum = 0;
        if (_category != 0){ //For specific Category in range 1-4
            for (uint i = 0; i < itemCount.current(); i++) {
                item memory _item = items[i];
                if(_item.category == _category && IERC721(nftContract).ownerOf(_item.tokenId) == address(this) && _item.owner != msg.sender){
                    _items[itemNum] = _item;
                    itemNum++;
                }
            }
        }else { //For All Categories
            for (uint i = 0; i < itemCount.current(); i++) {
                item memory _item = items[i];
                if(IERC721(nftContract).ownerOf(_item.tokenId) == address(this) && _item.owner != msg.sender){
                    _items[itemNum] = _item;
                    itemNum++;
                }
            }
        }
        return (_items, itemNum);
    }

    function getMyItems(uint8 _category) public view returns(item[] memory, uint8){ //Returns a List of Items owned by the Sender
        item[] memory _items = new item[](itemCount.current());
        uint8 itemNum = 0;
        if (_category == 0){ //For All Categories
            for (uint i = 0; i < itemCount.current(); i++) {
                item memory _item = items[i];
                if(_item.owner == msg.sender){
                    _items[itemNum] = _item;
                    itemNum++;
                }
            }
        } else{ //For specific Category in range 1-4
            for (uint i = 0; i < itemCount.current(); i++) {
                item memory _item = items[i];
                if(_item.owner == msg.sender && _item.category == _category){
                    _items[itemNum] = _item;
                    itemNum++;
                }
            }
        }
        return (_items, itemNum);
    }
}
AmazonMP.sol.txt
External
Displaying AmazonMP.sol.txt.
