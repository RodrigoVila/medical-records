
# Blockchain Role-Based Medical Records

🚧 **DApp Under Construction** 🚧
Please read below for details about the project, technologies used, and future plans.

## Motivation
Managing medical records is a challenging problem globally. Today, records typically belong to healthcare institutions, which rarely communicate with one another, leaving patients responsible for managing and transporting their records. Even modern centralized solutions, such as country-level medical apps, introduce significant limitations:

1) **Cross-Border Portability:** Records may not be accessible if the user moves to another country.
2) **Ownership:** The user never truly owns their records. But centralized institutions do. If such an institution fails, the records risk being lost.
   
## The Solution
This DApp addresses these challenges by using decentralized technologies such as Blockchain (for ownership and immutability) and IPFS (for scalable, cost-efficient and secure storage). The goal is to empower users to have ownership of their medical records (and their data in general) while ensuring accessibility and security globally.

## Technologies Used

**Blockchain**

- Solidity: Smart contract language.
- Foundry: Framework for compiling, deploying, and testing contracts.
- OpenZeppelin: Pre-tested smart contracts for development cases.
- IPFS: Off-chain storage of encrypted medical records.

**Frontend**

- React: Frontend Library
- Wagmi: Wallet integration and interactions
- Ethers.js: Library to interact with Smart Contracts.
- TailwindCSS & shadcn: For a clean and modern user interface.: 

## MVP Goals
The Minimum Viable Product (MVP) will focus on:

**Role-Based Access Control:**
- Users (patients) can access their own records.
- Institutions can add new and read records with patient consent.
- Admins manage institution access.
  
**Medical Records Management:**
- Records are encrypted and stored on IPFS.
- Metadata and permissions are tracked on-chain.

**Security:**
- All records are encrypted to ensure privacy.
- Patients maintain control over their data.
  
## Future Development

- Social Logins with Web3Auth.
- Implement zero-knowledge proofs to validate users or institutions without exposing sensitive data.
- Interoperability with Existing Systems.
