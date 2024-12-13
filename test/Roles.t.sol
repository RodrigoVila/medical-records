// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Roles.sol";

contract RolesTest is Test {
    Roles roles;

    address owner = address(0x1); // Default Admin Role (Owner)
    address superAdmin = address(0x2);
    address admin = address(0x3);
    address institution = address(0x4);
    address unauthorized = address(0x5);

    function setUp() public {
        // Deploy the Roles contract as the owner
        vm.prank(owner);
        roles = new Roles();
    }

    /*** Role Assignment Tests ***/

    function testOwnerIsDefaultAdminOnDeploy() public view {
        assertTrue(roles.hasRole(roles.DEFAULT_ADMIN_ROLE(), owner));
    }

    function testAddSuperAdminByOwner() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        assertTrue(roles.hasSuperAdminRole(superAdmin));
    }

    function testAddAdminBySuperAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        assertTrue(roles.hasAdminRole(admin));
    }

    function testAddInstitutionByAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.prank(admin);
        roles.addInstitution(institution);

        assertTrue(roles.hasInstitutionRole(institution));
    }

    /*** Role Revocation Tests ***/

    function testRevokeSuperAdminByOwner() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(owner);
        roles.revokeSuperAdmin(superAdmin);

        assertFalse(roles.hasSuperAdminRole(superAdmin));
    }

    function testRevokeAdminBySuperAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.prank(superAdmin);
        roles.revokeAdmin(admin);

        assertFalse(roles.hasAdminRole(admin));
    }

    function testRevokeInstitutionByAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.prank(admin);
        roles.addInstitution(institution);

        vm.prank(admin);
        roles.revokeInstitution(institution);

        assertFalse(roles.hasInstitutionRole(institution));
    }

    /*** Access Control Tests ***/

    function testOnlyOwnerCanAddSuperAdmin() public {
        vm.expectRevert("Roles: Only Contract Owner or Super Admin can do this");
        vm.prank(unauthorized);
        roles.addSuperAdmin(superAdmin);
    }

    function testOnlySuperAdminCanAddAdmin() public {
        vm.expectRevert("Roles: Only Contract Owner or Super Admin can do this");
        vm.prank(unauthorized);
        roles.addAdmin(admin);
    }

    function testOnlyAdminCanAddInstitution() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.expectRevert("Roles: Only Admin can do this");
        vm.prank(unauthorized);
        roles.addInstitution(institution);
    }

    function testOnlyOwnerCanRevokeSuperAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.expectRevert("Roles: Only Contract Owner can do this");
        vm.prank(superAdmin);
        roles.revokeSuperAdmin(superAdmin);
    }

    function testInstitutionCannotAddOtherRoles() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.prank(admin);
        roles.addInstitution(institution);

        vm.expectRevert("Roles: Only Admin can do this");
        vm.prank(institution);
        roles.addInstitution(unauthorized);
    }

    /*** Edge Case Tests ***/

    function testCannotAddDuplicateSuperAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.expectRevert("Roles: User is already a Super Admin");
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);
    }

    function testCannotAddDuplicateAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.expectRevert("Roles: User is already an Admin");
        vm.prank(superAdmin);
        roles.addAdmin(admin);
    }

    function testCannotAddDuplicateInstitution() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.prank(superAdmin);
        roles.addAdmin(admin);

        vm.prank(admin);
        roles.addInstitution(institution);

        vm.expectRevert("Roles: User is already an Institution");
        vm.prank(admin);
        roles.addInstitution(institution);
    }

    function testCannotRevokeNonexistentRole() public {
        vm.expectRevert("Roles: User was not a Super Admin");
        vm.prank(owner);
        roles.revokeSuperAdmin(superAdmin);
    }

    function testSuperAdminCannotRevokeOwner() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        vm.expectRevert("Roles: Only Contract Owner can do this");
        vm.prank(superAdmin);
        roles.revokeSuperAdmin(owner);
    }

    function testOwnerCanGrantSuperAdmin() public {
        vm.prank(owner);
        roles.addSuperAdmin(superAdmin);

        assertTrue(roles.hasSuperAdminRole(superAdmin));
    }
}
