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

        // Make the new card!
        uint256 cardId = _createCard(_owner, _attributes);

        // return the new card's ID
        return cardId;
    }
}
