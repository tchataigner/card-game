pragma solidity ^0.4.18;

import './CardOwnership.sol';

contract CardCreation is CardOwnership {

    uint256 public autoGenerationFee = 2 finney;

    function setAutoGenerationFee(uint256 val) external onlyCOO {
        autoGenerationFee = val;
    }

    function cardGeneration(address _owner, bytes32 _attributes)
    external
    whenNotPaused
    returns(uint256)
    {

        // Make the new kitten!
        uint256 cardId = _createCard(_owner, _attributes);

        // return the new kitten's ID
        return cardId;
    }
}

contract CardCore is CardCreation  {

    address public newContractAddress;

    function CardCore() {
        paused = true;

        ceoAddress = msg.sender;

        cooAddress = msg.sender;

        _createCard(address(0), 0);
    }



    //  If the contract breaks it marks the contract as upgraded and keep track of the new contract address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    //  Return all relevant infos about a card
    function getCard(uint256 _id)
    external
    view
    returns (
        uint256 creationTime,
        bytes32 attributes
    ) {
        Card storage card = cards[_id];

        // if this variable is 0 then it's not gestating

        creationTime = uint256(card.creationTime);
        attributes = bytes32(card.attributes);

    }

    function unpause() public onlyCEO whenPaused {
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
}