// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import './Verifiers/Verifier.sol';
import './Registry/IRegistry.sol';
import './Ens/INameHash.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

contract SCI is Initializable {
    IRegistry public registry;
    INameHash public nameHashUtils;

    function initialize(address registryAddress, address nameHashAddress) public initializer {
        registry = IRegistry(registryAddress);
        nameHashUtils = INameHash(nameHashAddress);
    }

    /**
     * @dev Returns the owner of the domainHash.
     * @param domainHash The name hash of the domain.
     * @return the address of the owner or the ZERO_ADDRESS if the domain is not registered.
     */
    function domainOwner(bytes32 domainHash) public view returns (address) {
        return registry.domainOwner(domainHash);
    }

    /**
     * @dev Returns if the `contractAddress` deployed in the chain with id `chainId` is verified.
     * to interact with the domain with name hash `domainHash`.
     * @param domainHash The name hash of the domain the contract is interacting with
     * @param contractAddress The address of the contract is being verified.
     * @param chainId The id of the chain the contract is deployed in.
     * @return a bool indicating whether the contract is verified or not.
     *
     * NOTE: If there is no verifier set then it returns false.
     */
    function isVerifiedForDomainHash(
        bytes32 domainHash,
        address contractAddress,
        uint256 chainId
    ) public view returns (bool) {
        (, Verifier verifier) = registry.domainHashToRecord(domainHash);

        if (address(verifier) == address(0)) {
            return false;
        }

        return verifier.isVerified(domainHash, contractAddress, chainId);
    }

    /**
     * @dev Same as isVerifiedForDomainHash but for multiple domains.
     * This is useful to check for subdomains and wildcard verification.
     * For example: subdomain.example.com and *.example.com.
     *
     * @param domainHashes An array of domain hashes.
     * @param contractAddress The address of the contract is being verified.
     * @param chainId The id of the chain the contract is deployed in.
     * @return an array of bool indicating whether the contract address is
     * verified for each domain hash or not.
     *
     * NOTE: If there is no verifier set then it returns false for that `domainHash`.
     */
    function isVerifiedForMultipleDomainHashes(
        bytes32[] memory domainHashes,
        address contractAddress,
        uint256 chainId
    ) public view returns (bool[] memory) {
        bool[] memory domainsVerification = new bool[](domainHashes.length);
        for (uint256 i = 0; i < domainHashes.length; i++) {
            domainsVerification[i] = isVerifiedForDomainHash(
                domainHashes[i],
                contractAddress,
                chainId
            );
        }
        return domainsVerification;
    }

    /**
     * @dev Same as isVerifiedForMultipleDomainHashes but receives the domains
     * and apply the name hash algorithm to them
     *
     * @param domains An array of domains.
     * @param contractAddress The address of the contract is being verified.
     * @param chainId The id of the chain the contract is deployed in.
     * @return an array of bool indicating whether the contract address is verified for each domain or not.

     * NOTE: If there is no verifier set then it returns false for that `domain`.
     */
    function isVerifiedForMultipleDomains(
        string[] memory domains,
        address contractAddress,
        uint256 chainId
    ) public view returns (bool[] memory) {
        bool[] memory domainsVerification = new bool[](domains.length);
        for (uint256 i = 0; i < domains.length; i++) {
            domainsVerification[i] = isVerifiedForDomainHash(
                nameHashUtils.getDomainHash(domains[i]),
                contractAddress,
                chainId
            );
        }
        return domainsVerification;
    }

    /**
    * @dev Same as isVerifiedForDomainHash but receives the domain and apply the name hash algorithm to them
     *
     * @param domain the domain the contract is interacting with.
     * @param contractAddress The address of the contract is being verified.
     * @param chainId The id of the chain the contract is deployed in.
     * @return a bool indicating whether the contract address is verified for the domain or not.

     * NOTE: If there is no verifier set then it returns false.
     */
    function isVerifiedForDomain(
        string memory domain,
        address contractAddress,
        uint256 chainId
    ) public view returns (bool) {
        return
            isVerifiedForDomainHash(nameHashUtils.getDomainHash(domain), contractAddress, chainId);
    }
}
