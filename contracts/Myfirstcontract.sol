pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}



/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}


contract CardAccessControl {
    // This facet controls access control for CryptoCards. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the CardsCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from CardsCore and its auction contracts.
    //
    //     - The COO: The COO can release gen0 cards to auction, and mint promo cards.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.


    event ContractUpgrade(address newContract);

    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    bool public paused = false;

    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}


contract CardsBase {
    //Fired everytime a new card is created.
    event Creation(address owner, uint256 cardID);


    //Fired everytime a card ownership is assigned
    event Transfer(address from, address to, uint256 tokenId);

    struct Card {
        //Block Timestamp of when the card was created
        uint64 creationTime;
    }

    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    //  Array with all the card struct existing. The ID of the card is the index
    //  ID 0 is the initial card and is invalid
    Card[] cards;

    //  Mapping of card index to owner addresss
    mapping (uint256 => address) public cardIndextoOwner;
    //  Mapping of owner address to nbr of cards owned
    mapping (address => uint256) ownershipTokenCount;
    //  Mapping of cardID to an address approved to call transferFrom()
    mapping (uint256 => address) public cardIndexToApproved;
    // Assigns ownership of a specific Kitty to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of cards is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        cardIndextoOwner[_tokenId] = _to;

        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    function _createCard(
        address _owner
    )
    internal
    returns (uint)
    {

        Card memory _card = Card({
            creationTime: uint64(now)
            });
        uint256 newCardId = cards.push(_card) - 1;

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
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
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
}

contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function getMetadata(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}

contract CardOwnership is CardsBase, ERC721 {
    //  Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "CryptoCards";
    string public constant symbol = "CC";

    //  Contract to retrieve Cards Metadata
    ERC721Metadata public erc721Metadata;

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

    ///  Set the address of the sibling contract that tracks metadata.
    ///  CEO only.
    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
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

    //  Marks an address as being approved for transferFrom()
    function _approve(uint256 _tokenId, address _approved) internal {
        cardIndexToApproved[_tokenId] = _approved;
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

            for (cardID = 1; cardID <= totalCats; cardID++) {
                if (kittyIndexToOwner[cardID] == _owner) {
                    result[resultIndex] = cardID;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    //  Functions to get metadata from URI => Bytes => String

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _memcpy(uint _dest, uint _src, uint _len) private view {
        // Copy word-length chunks while possible
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }

    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
        var outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }

    /// @notice Returns a URI pointing to a metadata package for this token conforming to
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)
    /// @param _tokenId The ID number of the Kitty whose metadata should be returned.
    function f(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {
        require(erc721Metadata != address(0));
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);

        return _toString(buffer, count);
    }

}

contract CardCreation is CardOwnership {

    uint256 public autoGenerationFee = 2 finney;

    function setAutoGenerationFee(uint256 val) external onlyCOO {
        autoGenerationFee = val;
    }

    function cardGeneration(address _owner)
    external
    whenNotPaused
    returns(uint256)
    {

        // Make the new kitten!
        uint256 cardId = _createCard(_owner);

        // return the new kitten's ID
        return cardId;
    }
}

contract CardCore is CardCreation  {

    address public newContractAddress;

    function CardCore() {
        paused = true;

        ceoAdress = msg.sender;

        cooAdress = msg.sender;

        _createCard(address(0));
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
        uint256 genes
    ) {
        Card storage card = cards[_id];

        // if this variable is 0 then it's not gestating

        birthTime = uint256(card.birthTime);
    }

    function unpause() public onlyCEO whenPaused {
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
}