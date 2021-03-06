// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Base64} from "./Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./HexStrings.sol";
import "./ToColor.sol";

/// @title NFTSVG
/// @notice Provides a function for generating an SVG associated with a Uniswap NFT
library MetadataGenerator {
    using Strings for uint256;
    using HexStrings for uint160;
    using ToColor for bytes3;

    function generateSVGofTokenById(
        address owner,
        uint256 tokenId,
        bytes3 color,
        uint256 chubbiness
    ) internal pure returns (string memory) {
        string memory svg = string(
            abi.encodePacked(
                '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg"><g id="eye1">',
                '<ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_1" cy="154.5" cx="181.5" stroke="#000" fill="#fff"/>',
                '<ellipse ry="3.5" rx="2.5" id="svg_3" cy="154.5" cx="173.5" stroke-width="3" stroke="#000" fill="#000000"/>',
                '</g><g id="head"><ellipse fill="#',
                color.toColor(),
                '" stroke-width="3" cx="204.5" cy="211.80065" id="svg_5" rx="',
                chubbiness.toString(),
                '" ry="51.80065" stroke="#000"/></g>',
                '<g id="eye2"><ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_2" cy="168.5" cx="209.5" stroke="#000" fill="#fff"/><ellipse ry="3.5" rx="3" id="svg_4" cy="169.5" cx="208" stroke-width="3" fill="#000000" stroke="#000"/>',
                "</g></svg>"
            )
        );

        return svg;
    }

    function tokenURI(
        address owner,
        uint256 tokenId,
        bytes3 color,
        uint256 chubbiness
    ) internal pure returns (string memory) {
        string memory name = string(abi.encodePacked("Loogie #", tokenId.toString()));
        string memory description = string(
            abi.encodePacked(
                "This Loogie is the color #",
                color.toColor(),
                " with a chubbiness of ",
                uint2str(chubbiness),
                "!!!"
            )
        );
        string memory image = Base64.encode(bytes(generateSVGofTokenById(owner, tokenId, color, chubbiness)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
