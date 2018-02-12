pragma solidity ^0.4.18;

import './base/CardBase.sol';
import './base/ERC721.sol';

contract CardOwnership is CardsBase, ERC721 {
    //  Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "CryptoCards";
    string public constant symbol = "CC";

    bytes4 constant InterfaceSignature_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('tokensOfOwner(address)')) ^
    bytes4(keccak256('tokenMetadata(uint256,string)'));

    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));
        //PROD ONLY
        //return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    //  Utility Functions

    //  Checks if a given address currently has transferApproval
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return cardIndexToApproved[_tokenId] == _claimant;
    }

    //  Marks address approved to use transferFrom()
    function _approve(uint256 _tokenId, address _approved) internal {
        cardIndexToApproved[_tokenId] = _approved;
    }

    //  Check if given address owns a card
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return cardIndexToOwner[_tokenId] == _claimant;
    }

    //  Get nbr of token owned by a given address
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }
    //  Transfer a Card to another address
    function transfer(
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any kitties (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));

        // You can only send your own cat.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }


    //  Transfer Kitty owned by another address
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any kitties (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    //  Returns total number of cards in existence
    function totalSupply() public view returns (uint) {
        return cards.length - 1;
    }

    //  Returns the address currently assigned to a card
    function ownerOf(uint256 _tokenId)
    external
    view
    returns (address owner)
    {
        owner = cardIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    //  Function to return all card owned by an address
    //  MUST NEVER be called in a smart contract. Too expensive & returns dynamic array
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalCards = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all cats have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 cardID;

            for (cardID = 1; cardID <= totalCards; cardID++) {
                if (cardIndexToOwner[cardID] == _owner) {
                    result[resultIndex] = cardID;
                    resultIndex++;
                }
            }

            return result;
        }
    }

}