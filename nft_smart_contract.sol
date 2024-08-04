// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract NFTContract is ERC721URIStorage{

        constructor() ERC721("MICO","MCO"){}

              using Counters for Counters.Counter;

            Counters.Counter private tokenId; 
            Counters.Counter private nftAvailableForSale;
            Counters.Counter private userId;


            struct nft{
                uint256 tokenId;
                address payable seller;
                address payable owner;
                uint256 price;
                uint256 total;
                uint256 likes;
                string title;
                string description;
            }  

            struct profile{
                address self;
                address[] follower;
                address[] following;
            }
            mapping(uint256 => profile) private profileData;
            mapping(uint256 => nft)  private nftData; 

            event NftCreated(
                uint256 indexed tokenId,
                address payable seller,
                address payable owner,
                uint256 price,
                uint256 total,
                uint256 likes,
                string title,
                string description);


            function createNft(string memory _tokenURI, string memory _title, string memory _description, uint _price, uint _total) public returns(uint256){
                tokenId.increment();
                uint256 newTokenId = tokenId.current();
                _mint(msg.sender, newTokenId);
                _setTokenURI(newTokenId, _tokenURI);
                setNft(newTokenId, _title, _description, _price, _total);
                 nftAvailableForSale.increment();
                return newTokenId;
            }

            function setNft(uint256 _tokenId, string memory _title, string memory _description, uint _price, uint _total) private{
                    nftData[_tokenId].title = _title;    
                    nftData[_tokenId].description = _description;
                    nftData[_tokenId].price = _price;
                    nftData[_tokenId].total = _total;
                    nftData[_tokenId].owner = payable(msg.sender);
                    nftData[_tokenId].seller = payable(msg.sender);
                    nftData[_tokenId].likes = 0;
                    nftData[_tokenId].tokenId = _tokenId;
                    emit NftCreated( _tokenId, payable(msg.sender), payable(msg.sender), _total, _price ,0 , _title, _description );
            }

            function updateNFT(uint256 _tokenId, string memory _title, string memory _description, uint256 _price,uint _total) public{
                require(nftData[_tokenId].owner == msg.sender,"You are not the owner of this NFT");
                setNft(_tokenId,_title,_description, _price,_total);
                nftData[_tokenId].price = _price;
            }

            function likeNFT(uint256 _tokenId) public{
                nftData[_tokenId].likes++;
            }

            function sellNft(uint256 _tokenId, uint256 _price, address _address) public returns(uint256){
                require(nftData[_tokenId].owner == msg.sender,"You are not authorized to do this.");
                
                nftData[_tokenId].price = _price;
                nftData[_tokenId].owner = payable(_address);
              //  nftAvailableForSale.increment();
                return nftAvailableForSale.current();
           }

            function buyNft(uint256 _tokenId) public payable returns(bool){
                uint256 price = nftData[_tokenId].price;
                require(nftData[_tokenId].total > 0, "Sorry, Nfts are not avaiable for sale");  
                require(msg.value  >= price , "Not enough funds to buy the subscription");

                _transfer(nftData[_tokenId].owner, msg.sender, _tokenId);
                nftData[_tokenId].owner = payable(msg.sender);
                payable(nftData[_tokenId].seller).transfer(msg.value);
                nftData[_tokenId].seller = payable(msg.sender);

                nftData[_tokenId].total--;
                
                return true;
            }


             // returns a like of nfts available for sale on market place
            function getNft() public view returns(nft[] memory){
                        uint256 subscriptions = nftAvailableForSale.current();
                uint256 nftCount = tokenId.current();
                nft[] memory nftSubscriptions = new nft[](subscriptions);
                uint256 index = 0;
                for(uint256 i = 1; i <= nftCount; i++){
                    if(nftData[i].owner == address(this)){
                        nftSubscriptions[index] = nftData[i];
                        index++;
                    }
                }
                return nftSubscriptions;
                
            }


            ///@dev this will be the function that displays the list of nfts owned by a perticular user
            function displayOwnedNfts(address _user) public view returns(nft[] memory){
                            uint numberOfNfts = tokenId.current();
                uint ownedCount = 0;
                for(uint i = 1; i <= numberOfNfts; i++){
                    if(nftData[i].owner == _user){
                        ownedCount++;
                    }
                }
                
                nft[] memory ownedNfts = new nft[](ownedCount);
                uint index = 0;
                for(uint i = 1; i <= numberOfNfts; i++){
                    if(nftData[i].owner == _user){
                        ownedNfts[index] = nftData[i];
                        index++;
                    }
                }
                return ownedNfts;
            }
        
        


            function getIndividualNftData(uint256 _tokenId) public view returns(nft memory){
                return nftData[_tokenId];
            }


            function addUser() public returns(uint256 userID, uint256 balance){
                userId.increment(); 
                uint256 newUser = userId.current();
                profileData[newUser].self = msg.sender;
                userID = newUser;
                balance = msg.sender.balance;
            }

            function likeSubscription(uint _tokenId) public{
                nftData[_tokenId].likes++;
            }

            function disLikeSubscription(uint _tokenId) public{
                nftData[_tokenId].likes--;
            }



    }

