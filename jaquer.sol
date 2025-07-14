// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IGrader5 {
    function retrieve() external payable;
    function gradeMe(string calldata name) external;
    function counter(address) external view returns (uint256);
}

contract Jaquer {
    IGrader5 public grader;
    
    constructor(address graderAddress) payable {
        grader = IGrader5(graderAddress);
    }
    
    function attack(string calldata name) external payable {
        // Primero llamamos a retrieve() 2 veces para establecer counter > 1
        // Necesitamos enviar más de 3 wei cada vez (pero solo 1 wei es devuelto)
        for (uint i = 0; i < 2; i++) {
            grader.retrieve{value: 4}();
        }
        
        // Verificamos que counter > 1
        require(grader.counter(address(this)) > 1, "Counter not set correctly");
        
        // Llamamos a gradeMe con el nombre proporcionado
        grader.gradeMe(name);
    }
    
    // Función para recibir ETH (necesario para las devoluciones de retrieve)
    receive() external payable {}
    
    // Función para retirar fondos del contrato
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}