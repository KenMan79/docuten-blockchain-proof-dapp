pragma solidity ^0.5.0;

import "./Lockable.sol";


/* @title Proof of Existence */
contract ProofOfExistence is Lockable {
  
    // State
    uint256 public lastId = 0;
    mapping(bytes32  => uint256) public idByDocumentHash;
    mapping(uint256  => address) public ownerByDocumentId;
    mapping(uint256  => string) public ipfsHashByDocumentId;
    mapping(uint256  => bytes32) public hashByDocumentId;
    mapping(address  => uint256[]) public documentsByOwnerAddress;
    
    /* @notice Fallback function
    /* @dev It reverts the transaction for security reasons
    */
    function() external {
        revert();
    }

    /* @notice Certify document with hash
    * @dev It registers in the blockchain the proof-of-existence of an external document
    * @param _documentHash - Hash of the document (it should have 32 bytes)
    * @return id - returns certified document id
    */
    function certifyDocument(bytes32 _documentHash) public onlyAuthorizedUsers onlyWhenUnlocked returns(uint256) {
        return certifyDocument(_documentHash, "");
    }
    
    /* @notice Certify document with hash and IPFS hash
    * @dev It registers in the blockchain the proof-of-existence of an external document
    * @param _documentHash - Hash of the document (it should have 32 bytes)
    * @param _ipfsHash - IPFS Hash, if it exists 
    * @return id - returns certified document id
    */
    function certifyDocument(bytes32 _docHash, string memory _ipfsHash) 
    public onlyAuthorizedUsers onlyWhenUnlocked returns(uint256) {
        
        require(idByDocumentHash[_docHash] == 0, "E-POE-001 - There is already a certified document with that hash");
    
        //An auto-incremental identifier will be generated by this method
        lastId++;
        uint256 _id = lastId;
      
        hashByDocumentId[_id] = _docHash; //Add to list of document hashes
        ipfsHashByDocumentId[_id] = _ipfsHash; //Add to list of ipfs hashes
        idByDocumentHash[_docHash] = _id; //Add hash-id mapping information
        ownerByDocumentId[_id] = msg.sender; //Link document to owner      
        documentsByOwnerAddress[msg.sender].push(_id); //Add hash to owner's documents list
      
        return _id;
    }
    
    function bytes32ToString(bytes32 x) private pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        
        return string(bytesStringTrimmed);
    }

  
}