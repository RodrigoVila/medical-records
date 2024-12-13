// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Roles.sol";

contract MedicalRecords {
    /*** Structs and Enums ***/
    struct Record {
        address patient;
        address institution;
        uint256 timestamp;
        string ipfsHash;
        uint256 version;
    }

    /*** Storage ***/
    Roles public rolesContract; // Reference to the Roles contract
    uint256 public recordCounter; // Incremental ID for records

    mapping(uint256 => Record) public records; // Record ID -> Record
    mapping(address => uint256[]) public patientRecords; // Patient Address -> List of Record IDs
    mapping(address => mapping(address => bool)) public accessControl; // Patient Address -> Authorized Address -> Access Granted

    /*** Events ***/
    event RecordAdded(uint256 indexed recordId, address indexed patient, address indexed institution, string ipfsHash, uint256 timestamp);
    event AccessGranted(address indexed patient, address indexed authorized);
    event AccessRevoked(address indexed patient, address indexed authorized);

    /*** Constructor ***/
    constructor(address _rolesContract) {
        rolesContract = Roles(_rolesContract);
    }

    /*** Modifiers ***/
    modifier onlyInstitution() {
        rolesContract.requireInstitution(msg.sender);
        _;
    }

    modifier onlyPatient(uint256 _recordId) {
        require(records[_recordId].patient == msg.sender, "MedicalRecords: Not the patient");
        _;
    }

    modifier hasAccess(uint256 _recordId) {
        require(
            records[_recordId].patient == msg.sender || accessControl[records[_recordId].patient][msg.sender],
            "MedicalRecords: Access denied"
        );
        _;
    }

    /*** Core Functions ***/
    function addRecord(address _patient, string calldata _ipfsHash) external onlyInstitution {
        require(_patient != address(0), "MedicalRecords: Invalid patient address");
        require(bytes(_ipfsHash).length > 0, "MedicalRecords: IPFS hash required");

        uint256 recordId = ++recordCounter;

        records[recordId] = Record({
            patient: _patient,
            institution: msg.sender,
            timestamp: block.timestamp,
            ipfsHash: _ipfsHash,
            version: 1
        });

        patientRecords[_patient].push(recordId);

        emit RecordAdded(recordId, _patient, msg.sender, _ipfsHash, block.timestamp);
    }

    function listRecords() external view returns (uint256[] memory) {
        return patientRecords[msg.sender];
    }

    function getRecord(uint256 _recordId) external view hasAccess(_recordId) returns (Record memory) {
        return records[_recordId];
    }

    function grantAccess(address _authorized) external {
        require(_authorized != address(0), "MedicalRecords: Invalid address");
        accessControl[msg.sender][_authorized] = true;
        emit AccessGranted(msg.sender, _authorized);
    }

    function revokeAccess(address _authorized) external {
        require(accessControl[msg.sender][_authorized], "MedicalRecords: No access to revoke");
        accessControl[msg.sender][_authorized] = false;
        emit AccessRevoked(msg.sender, _authorized);
    }

    function addNewVersion(uint256 _recordId, string calldata _ipfsHash) external onlyPatient(_recordId) {
        require(bytes(_ipfsHash).length > 0, "MedicalRecords: IPFS hash required");

        Record storage record = records[_recordId];
        record.version++;
        record.ipfsHash = _ipfsHash;

        emit RecordAdded(_recordId, record.patient, record.institution, _ipfsHash, block.timestamp);
    }

    /*** Optional Emergency Access ***/
    function emergencyAccess(address _patient) external onlyInstitution {
        // Grant temporary access to the institution for the patient's records.
        accessControl[_patient][msg.sender] = true;
        emit AccessGranted(_patient, msg.sender);
    }
}
