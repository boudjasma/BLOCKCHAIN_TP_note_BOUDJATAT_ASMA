// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Admin {
	address private _admin;
    event AdminshipTransferred(address indexed currentAdmin, address indexed newAdmin);

	constructor() internal {
		_admin = msg.sender;
        emit AdminshipTransferred(address(0), _admin);
	}

    function admin() public view returns (address) {
        return _admin;
    }

	modifier onlyAdmin() {
		require(msg.sender == _admin, "Only Admin can perform this action.");
		_;
	}

}

contract Vip {
	address private _vip;

	constructor() internal {
		_vip = msg.sender;
	}


    function vip() public view returns (address) {
        return _vip;
    }

	modifier onlyVip() {
		require(msg.sender == _vip, "Only Admin can perform this action.");
		_;
	}

}

contract Whitelist {
	address private _whitelist;

	constructor() internal {
		_whitelist = msg.sender;

	}

    function whitelist() public view returns (address) {
        return _whitelist;
    }

	modifier onlyWhitelist() {
		require(msg.sender == _whitelist, "Only whitelist can perform this action.");
		_;
	}

}

// J'ai eu pleins de problème je n'ai pas réussi à compiler
contract AsmaToken is ERC721, ERC721URIStorage,Ownable {
    string private _name;
    uint256 public nftPrice;

    // Creation des roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VIP_ROLE = keccak256("VIP_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

    // mapping(address => Role) private {VIP_ROLE, WHITELIST_ROLE};
    mapping(address => bool) public isVIP;
    mapping(address => bool) public isWhitelisted;


    constructor(address admin, address vip, address whitelist) ERC721("AsmaToken", "AT") {
        _mint(address(this),5);
        _setupRole(ADMIN_ROLE, admin);
        _setupRole(VIP_ROLE,vip);
        _setupRole(WHITELIST_ROLE, whitelist);
    }
    
      function setPrice(uint256 _price) public onlyOwner {
        nftPrice = _price;
    }
    
    function addToVIP(address _vip) public onlyOwner {
        isVIP[_vip] = true;
    }
    
    function addToWhitelist(address _address) public onlyOwner {
        isWhitelisted[_address] = true;
    }
    
    function removeFromVIP(address _vip) public onlyOwner {
        isVIP[_vip] = false;
    }
    
    function removeFromWhitelist(address _address) public onlyOwner {
        isWhitelisted[_address] = false;
    }

    function name() public view returns (string memory) {
        return string.concat("Token", string(_tokenIds.current()));
    }
   

    // La logique de la fonction buy selon les roles
   function buy() public payable {
        require(msg.sender != address(0), "ERC721: buyer address is not valid");
        require(_exists(tokenId), "ERC721: token does not exist");
        
        if (hasRole(ADMIN_ROLE, sender_adress)) {
            // Admin peut avoir des NFT gratuitement
            _safeMint(msg.sender, tokenId);
            return;
        }
        
        if (hasRole(VIP_ROLE, sender_adress)) {
            // Allow VIP to buy NFT at a discounted price
            require(msg.value >= (nftPrice / 2), "Vous êtes pauvre");
            _safeMint(msg.sender, tokenId);
            payable(owner()).transfer(msg.value);
            return;
        }
        
        if (hasRole(WHITELIST_ROLE, sender_adress)) {
            // Allow Whitelist to buy NFT at the base price
            require(msg.value >= nftPrice, "Vous êtes pauvre");
            _safeMint(msg.sender, tokenId);
            payable(owner()).transfer(msg.value);
            return;
        }

    }
}

}