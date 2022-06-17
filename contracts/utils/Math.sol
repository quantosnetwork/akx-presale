// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./ABDKMathQuad.sol";

abstract contract AkxMath {



	function mulDiv (uint x, uint y, uint z)
	public pure returns (uint) {
		return
		ABDKMathQuad.toUInt (
			ABDKMathQuad.div (
				ABDKMathQuad.mul (
					ABDKMathQuad.fromUInt (x),
					ABDKMathQuad.fromUInt (y)
				),
				ABDKMathQuad.fromUInt (z)
			)
		);
	}

	function mul(uint x, uint y) public pure returns (uint256) {
		return ABDKMathQuad.toUInt (
		ABDKMathQuad.mul (
		ABDKMathQuad.fromUInt (x),
		ABDKMathQuad.fromUInt (y)
		)
		);
	}

	function div(uint x, uint y) public pure returns (bytes16) {
		return
			ABDKMathQuad.div (
				ABDKMathQuad.fromUInt (x),
				ABDKMathQuad.fromUInt (y)
			);

	}

}