// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract Roles is AccessControl {
    /*** Roles ***/    
    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE"); // Grant and revoke Admin roles. Mostly created as a backup in case Owner's account is lost.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); // Grant and revoke institution roles
    bytes32 public constant INSTITUTION_ROLE = keccak256("INSTITUTION_ROLE"); // Read and add medical records

    /*** Events ***/
    event SuperAdminAdded(address indexed _account);
    event SuperAdminRevoked(address indexed _account);
    event AdminAdded(address indexed _account);
    event AdminRevoked(address indexed _account);
    event InstitutionAdded(address indexed _account);
    event InstitutionRevoked(address indexed _account);

    /*** Constructor ***/
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Set roles hierarchy: DEFAULT_ADMIN_ROLE (Owner) > SUPER_ADMIN_ROLE > ADMIN_ROLE > INSTITUTION_ROLE
        _setRoleAdmin(SUPER_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(ADMIN_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(INSTITUTION_ROLE, ADMIN_ROLE);
    }

    /*** Role Checks ***/
    function hasOwnerRole(address _account) internal view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _account);
    }

    function hasSuperAdminRole(address _account) public view returns (bool) {
        return hasRole(SUPER_ADMIN_ROLE, _account);
    }

    function hasAdminRole(address _account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, _account);
    }

    function hasInstitutionRole(address _account) public view returns (bool) {
        return hasRole(INSTITUTION_ROLE, _account);
    }

    /*** Function wrappers to be used like modifiers at this contract and the main one ***/
    function requireOwner(address _account) public view {
        require(hasOwnerRole(_account), "Roles: Only Contract Owner can do this");
    }
    function requireOwnerOrSuperAdmin(address _account) public view {
        require(hasOwnerRole(_account) || hasSuperAdminRole(_account), "Roles: Only Contract Owner or Super Admin can do this");
    }

    function requireAdmin(address _account) public view {
        require(hasAdminRole(_account), "Roles: Only Admin can do this");
    }

    function requireInstitution(address _account) public view {
        require(hasInstitutionRole(_account), "Roles: Not an Institution can do this");
    }

    /*** Role Management ***/
    function addSuperAdmin(address _account) public {
        requireOwnerOrSuperAdmin(msg.sender); // Only Contract Owner or Super Admins can add other Super Admins
        require(!hasSuperAdminRole(_account), "Roles: User is already a Super Admin");
        grantRole(SUPER_ADMIN_ROLE, _account);
        emit SuperAdminAdded(_account);
    }

    function addAdmin(address _account) external {
        requireOwnerOrSuperAdmin(msg.sender); // Only Super Admins can add Admins
        require(!hasAdminRole(_account), "Roles: User is already an Admin");
        grantRole(ADMIN_ROLE, _account);
        emit AdminAdded(_account);
    }

    function addInstitution(address _account) external {
        requireAdmin(msg.sender); // Only Admins can add Institutions
        require(!hasInstitutionRole(_account), "Roles: User is already an Institution");
        grantRole(INSTITUTION_ROLE, _account);
        emit InstitutionAdded(_account);
    }

    /*** Role Revocation ***/
    function revokeSuperAdmin(address _account) external {
        requireOwner(msg.sender); // Only Owner can revoke Super Admins
        require(hasSuperAdminRole(_account), "Roles: User was not a Super Admin");
        revokeRole(SUPER_ADMIN_ROLE, _account);
        emit SuperAdminRevoked(_account);
    }

    function revokeAdmin(address _account) external {
        requireOwnerOrSuperAdmin(msg.sender);
        require(hasAdminRole(_account), "Roles: User was not an Admin");
        revokeRole(ADMIN_ROLE, _account);
        emit AdminRevoked(_account);
    }

    function revokeInstitution(address _account) external {
        requireAdmin(msg.sender);
        require(hasInstitutionRole(_account), "Roles: User was not an Institution");
        revokeRole(INSTITUTION_ROLE, _account);
        emit InstitutionRevoked(_account);
    }
}
