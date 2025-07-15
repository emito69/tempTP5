<!--
**emito69/emito69** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.
Here are some ideas to get you started:
- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...

En el README de github no puedo añadir scrpits de java o css, tengo que trabajar directamente con atributos en html
-->

Solidity_TP4

<div id="header" align="center">
  <h2 align="center"> <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/> TP5 Solidity ETH-KIPU <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/> </h2>
  Code Documentation and Explanation
  <h6 align="center"> This repository contains a Exploit contract targeting vulnerabilities in Grader5.sol.</h6>
   <br>
</div>

## Overview

This contract demonstrates a recursive callback attack on contract Grader5.sol deployed y Sepolia.

## Analysis

```solidity
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
```

## Usage

### 1. Prerequisites
- Sepolia ETH: Fund your wallet with test ETH (faucet).

- Grader5 Address: Have the target Grader5.sol contract address.

- Unique Name: Prepare a unique string (e.g., "Emiliano") not already registered in Grader5.

### 2. Deployment
```javascript
// Example (Hardhat/ethers.js)
const Jaquer = await ethers.getContractFactory("Jaquer");
const jaquer = await Jaquer.deploy(GRADER5_ADDRESS, { value: 12 });
await jaquer.deployed();
```
- Pass the Grader5.sol address to the constructor.

- Send ≥12 wei to cover the attack costs (in msg.value).

###  3. Execute the Attack
```javascript
// Call attack() with your unique name and 12 wei
await jaquer.attack("Emiliano", { value: 12 });
```
What happens:

- 3 recursive calls to Grader5.retrieve() (4 wei each, refunded 1 wei per call).

- Sets counter[jaquerAddress] = 3 in Grader5.

- Finally calls gradeMe("Emiliano") to register your grade (100 if first attacker).

### 4. Verify Success
```javascript
// Check your grade in Grader5
const grade = await grader5.students("Emiliano");
console.log("Grade:", grade); // Should return 100 (if first attacker)
```javascript

### 5. Withdraw Funds
```javascript
// Recover leftover ETH (3 wei remains after attack)
await jaquer.withdraw();
```

## Key Notes
- Timing: Works only if block.timestamp is within Grader5's startTime/deadline (default allows any time).

- Gas: Ensure sufficient gas for the recursive calls (~150k-200k gas).

- Reusability: Each attack requires a new unique name.

## Key Notes
- Timing: Works only if block.timestamp is within Grader5's startTime/deadline (default allows any time).

- Gas: Ensure sufficient gas for the recursive calls (~150k-200k gas).

- Reusability: Each attack requires a new unique name.

## Expected Outcome
- Successfully registers a grade (70-100) in Grader5.sol by exploiting its callback vulnerability.

- Costs 9 wei net (12 sent - 3 refunded).

For troubleshooting, check:

- Grader5’s students mapping for your name.

- Transaction logs for revert reasons.

##  License

```
MIT License
```


<hr>
<h6 align="center"> "El blockchain no es solo tecnología, es una revolución en la forma como intercambiamos valor y confianza." - Anónimo.</h6>

<hr>
<div align="center">
 <h4> 🛠 Lenguages & Tools : </h4>
  <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/>
  <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-original.svg" title="Solidity" alt="Solidity" height="30" width="40"/>
  <img src="https://github.com/devicons/devicon/blob/master/icons/solidity/solidity-plain.svg" title="Solidity" alt="Solidity" height="30" width="40"/>
  <br>
</div>

<hr>

## Contact

 <h4> 🔭 About me : </h4>

- 📝  I am an Instrumentation and Control engineer who constantly trains to keep up with new technologies.

- 📫 How to reach me: [my Linkedin](https://www.linkedin.com/in/emiliano-alvarez-a6677b1b4).

<br>
<div id="badges" align="center">
    <a href="https://www.linkedin.com/in/emiliano-alvarez-a6677b1b4/">
        <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="Linkedin Badge"  style="max-width: 100%;">
    </a> 
</div>
<br>
</div>