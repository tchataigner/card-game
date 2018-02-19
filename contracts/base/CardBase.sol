pragma solidity ^0.4.18;

import './CardAccessControl.sol';

contract CardBase is CardAccessControl {
    //Fired everytime a new card is created.
    event Creation(address owner, uint256 cardID);


    //Fired everytime a card ownership is assigned
    event Transfer(address from, address to, uint256 tokenId);

    struct Card {
        //Block Timestamp of when the card was created
        uint64 creationTime;
        bytes32 attributes;
    }

    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    //  Array with all the card struct existing. The ID of the card is the index
    //  ID 0 is the initial card and is invalid
    Card[] cards;

    //  Mapping of card index to owner addresss
    mapping (uint256 => address) public cardIndexToOwner;
    //  Mapping of owner address to nbr of cards owned
    mapping (address => uint256) ownershipTokenCount;
    //  Mapping of cardID to an address approved to call transferFrom()
    mapping (uint256 => address) public cardIndexToApproved;
    // Assigns ownership of a specific Kitty to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of cards is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        cardIndexToOwner[_tokenId] = _to;

        if (_from != address(0)) {
            ownershipTokenCount[_from]--;

            // clear any previously approved ownership exchange
            delete cardIndexToApproved[_tokenId];
        }

        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    function _createCard(
        address _owner,
        bytes32 _attributes
    )
    internal
    returns (uint)
    {

        Card memory _card = Card({
            creationTime: uint64(now),
            attributes: _attributes
            });
        uint256 newCardId = cards.push(_card) - 1;

        require(newCardId == uint256(uint32(newCardId)));

        // emit the birth event
        Creation(
            _owner,
            newCardId
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newCardId);

        return newCardId;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        secondsPerBlock = secs;
    }
}