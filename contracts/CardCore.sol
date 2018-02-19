pragma solidity ^0.4.18;

import './CardCreation.sol';


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