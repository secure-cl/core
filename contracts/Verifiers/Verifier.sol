// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

/**
 * @dev Required interface of a Verifier compliant contract for the SCI IRegistry.sol.
 */
interface Verifier {
    /**
     * @dev Verifies if a contract in a specific chain is authorized
     * to interact within a domain.
     * @param domainHash The domain's name hash.
     * @param contractAddress The address of the contract trying to be verified.
     * @param chainId The chain where the contract is deployed.
     * @return a bool indicating whether the sender is authorizer or not.
     */
    function isVerified(
        bytes32 domainHash,
        address contractAddress,
        uint256 chainId
    ) external view returns (bool);
}
