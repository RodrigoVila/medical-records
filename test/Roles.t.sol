// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/Roles.sol";

contract RolesTest is Test {
    Roles roles;

    address owner = address(0x1);
    address superAdmin = address(0x2);
    address admin = address(0x3);
    address institution = address(0x4);
    address unauthorized = address(0x5);

    function setUp() public {
        // Deploy the contract
        vm.prank(owner); // Simulate deployment by the owner
        roles = new Roles();
    }

    /*** Basic Role Assignment Tests ***/

    function testOwnerRoleOnDeploy() public view {
        // Check that the deployer has the DEFAULT_ADMIN_ROLE
        assertTrue(roles.hasRole(roles.DEFAULT_ADMIN_ROLE(), owner));
    }

    function testAddSuperAdmin() public {
        // Add Super Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        // Check Super Admin role
        assertTrue(roles.hasSuperAdminRole(superAdmin));
    }

    function testAddAdmin() public {
        // Add Super Admin first
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        // Add Admin
        vm.prank(superAdmin);
        roles.addAdmin(admin);

        // Check Admin role
        assertTrue(roles.hasAdminRole(admin));
    }

    function testAddInstitution() public {
        // Add Super Admin and Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        // Add Institution
        vm.prank(admin);
        roles.addInstitution(institution);

        // Check Institution role
        assertTrue(roles.hasInstitutionRole(institution));
    }

    /*** Role Revocation Tests ***/

    function testRevokeSuperAdmin() public {
        // Add Super Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        // Revoke Super Admin
        vm.prank(owner);
        roles.revokeSuperAdmin(superAdmin);

        // Check Super Admin role
        assertFalse(roles.hasSuperAdminRole(superAdmin));
    }

    function testRevokeAdmin() public {
        // Add Super Admin and Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        // Revoke Admin
        vm.prank(superAdmin);
        roles.revokeAdmin(admin);

        // Check Admin role
        assertFalse(roles.hasAdminRole(admin));
    }

    function testRevokeInstitution() public {
        // Add Super Admin, Admin, and Institution
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.prank(admin);
        roles.addInstitution(institution);

        // Revoke Institution
        vm.prank(admin);
        roles.revokeInstitution(institution);

        // Check Institution role
        assertFalse(roles.hasInstitutionRole(institution));
    }

    /*** Access Control Tests ***/

    function testOnlyOwnerCanRevokeSuperAdmin() public {
        // Add Super Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        // Attempt to revoke Super Admin as unauthorized user
        vm.expectRevert("Roles: Only Contract Owner can do this");
        vm.prank(unauthorized);
        roles.revokeSuperAdmin(superAdmin);
    }

    function testOnlySuperAdminCanAddAdmin() public {
        // Attempt to add Admin as unauthorized user
        vm.expectRevert("Roles: Only Contract Owner or Super Admin can do this");
        vm.prank(unauthorized);
        roles.addAdmin(admin);
    }

    function testOnlyAdminCanAddInstitution() public {
        // Add Super Admin and Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        // Attempt to add Institution as unauthorized user
        vm.expectRevert("Roles: Only Admin can do this");
        vm.prank(unauthorized);
        roles.addInstitution(institution);
    }

    function testOnlySuperAdminCanRevokeAdmin() public {
        // Add Super Admin and Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        // Attempt to revoke Admin as unauthorized user
        vm.expectRevert("Roles: Only Contract Owner or Super Admin can do this");
        vm.prank(unauthorized);
        roles.revokeAdmin(admin);
    }

    /*** Edge Case Tests ***/

    function testCannotAddSameRoleTwice() public {
        // Add Super Admin
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        // Attempt to add same role again
        vm.expectRevert("Roles: User is already a Super Admin");
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);
    }

    function testCannotRevokeRoleNotAssigned() public {
        // Attempt to revoke a Super Admin role from an account without it
        vm.expectRevert("Roles: User was not a Super Admin");
        vm.prank(owner);
        roles.revokeSuperAdmin(superAdmin);
    }
}
