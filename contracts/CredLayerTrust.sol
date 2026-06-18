// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
* @title CredLayer Core Infrastructure Stack
* @notice Combines Identity, Reputation, and Credential Registries as specified by 0G Glileo frontend configuration.
*/
contract CredLayerTrust {
    address public owner;

    // --- STRUCTS MATCHING THE FRONTEND FEATURES ---

    struct Identity {
        string entityType;           // AI Agent, Human User, dApp Protocol
        uint256 registeredAt;        // Timestamp
        bool isInitialized;
    }

    struct TrustProfile {
        uint16 trustScore;           // Scaled 0 to 1000 (e.g, 847)
        uint8 confidence;            // 0 to 100 (%) (e.g, 92%)
        string riskLevel;         // "Low", "Medium", "High"
        string storageRoot;         // Merkle root hash of full report hosted on 0G storage
        uint256 lastUpdated;        // Timestamp
    }

    struct Credential {
        bytes32 documentHash;        // Cryptographic SHA-256 / Keccak hash of the credential payload
        string storageURI;           // Reference link or byte index inside 0G storage
        uint256 timeStamp;             // Anchored block timeStamp
        bool isValid;
    }

    // ------STORAGE MAPPINGS FOR FRONTEND REGISTERIES ---------

    // 1. IdentityRegistry storage
    mapping(address => Identity) public identities;

    //2. ReputationRegistry storage
    mapping(address => TrustProfile) public reputationRegistry;
    mapping(address => bool) public hasReputation;

    //3. CredentialRegistry Storage (Maps a unique credential ID/Hash to its anchor metadata)
    mapping(bytes32 => Credential) public credentialRegistry;

    // --------EVENTS--------
    event IdentityRegistered(address indexed entity, string entityType);
    event ReputationAnchored(address indexed subject, uint16 trustScore, string storageRoot);
    event CredentialAnchored(bytes32 indexed documentHash, address indexed issuer, string storageURI);
    event CredentialRevoked(bytes32 indexed documentHash);

    modifier onlyOwner() {
        require(msg.sender == owner, "CredLayer: Unauthorized caller");
        _;
    }


    constructor() {
        owner = msg.sender;
    }

    //-------- 1. IDENTITY REGISTRY FEATURES
    
    /**
     * @notice Allows entities to claim their identity anchor on-chain or get registered by an agent handler
     */
    function registerIdentity(address _entity, string calldata _entityType) external {
        require(!identities[_entity].isInitialized, "CredLayer: Identity already initialized");
        
        identities[_entity] = Identity({
            entityType: _entityType,
            registeredAt: block.timestamp,
            isInitialized: true
        });

        emit IdentityRegistered(_entity, _entityType);
    }

    
    //--------- 2. REPUTATION REGISTRY FEATURES

    /**
     * @notice Anchors the 0G Compute output and pairs it to the 0G Storage hash
     */
    function anchorReputation(
        address _subject,
        uint16 _trustScore,
        uint8 _confidence,
        string calldata _riskLevel,
        string calldata _storageRoot
    ) external onlyOwner {
        require(_trustScore <= 1000, "CredLayer: Score must be 0-1000 range");
        require(_confidence <= 100, "CredLayer: Confidence cannot exceed 100%");
        
        // Auto-initialize identity if not already done
        if (!identities[_subject].isInitialized) {
            identities[_subject] = Identity({
                entityType: "AI Agent", // Default fallback for automated pipelines
                registeredAt: block.timestamp,
                isInitialized: true
            });
        }

        reputationRegistry[_subject] = TrustProfile({
            trustScore: _trustScore,
            confidence: _confidence,
            riskLevel: _riskLevel,
            storageRoot: _storageRoot,
            lastUpdated: block.timestamp
        });
        
        hasReputation[_subject] = true;

        emit ReputationAnchored(_subject, _trustScore, _storageRoot);
    }

    // ----------3. CREDENTIAL REGISTRY FEATURES

    /**
     * @notice Anchor any document hash to verify against 0G Storage byte-for-byte
     */
    function anchorCredential(bytes32 _documentHash, string calldata _storageURI) external onlyOwner {
        require(!credentialRegistry[_documentHash].isValid, "CredLayer: Credential already exists");

        credentialRegistry[_documentHash] = Credential({
            documentHash: _documentHash,
            storageURI: _storageURI,
            timestamp: block.timestamp,
            isValid: true
        });

        emit CredentialAnchored(_documentHash, msg.sender, _storageURI);
    }

    /**
     * @notice Revokes a credential if behavior analytics on 0G Compute detect malicious activity
     */
    function revokeCredential(bytes32 _documentHash) external onlyOwner {
        require(credentialRegistry[_documentHash].isValid, "CredLayer: Credential not active");
        credentialRegistry[_documentHash].isValid = false;
        
        emit CredentialRevoked(_documentHash);
    }


    //--------- EXTERNAL VIEW FUNCTIONS FOR FRONTEND -------------

    function getFullTrustProfile(address _subject) external view returns (
        string memory entityType,
        uint16 trustScore,
        uint8 confidence,
        string memory riskLevel,
        string memory storageRoot,
        uint256 lastUpdated
    ) {
        require(hasReputation[_subject], "CredLayer: Subject profile does not exist yet");
        Identity memory id = identities[_subject];
        TrustProfile memory rep = reputationRegistry[_subject];
        
        return (id.entityType, rep.trustScore, rep.confidence, rep.riskLevel, rep.storageRoot, rep.lastUpdated);
    }

}