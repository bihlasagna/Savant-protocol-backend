// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

/**SPOperatable abstract contract */

struct SPOperatorData {
  address operator;
  uint256 domain;
  uint256[] permissionIndexes;
}

interface ISPOperatorStore {
  event SetOperator(
    address indexed operator,
    address indexed account,
    uint256 indexed domain,
    uint256[] permissionIndexes,
    uint256 packed
  );

  function permissionsOf(
    address _operator,
    address _account,
    uint256 _domain
  ) external view returns (uint256);

  function hasPermission(
    address _operator,
    address _account,
    uint256 _domain,
    uint256 _permissionIndex
  ) external view returns (bool);

  function hasPermissions(
    address _operator,
    address _account,
    uint256 _domain,
    uint256[] calldata _permissionIndexes
  ) external view returns (bool);

  function setOperator(SPOperatorData calldata _operatorData) external;

  function setOperators(SPOperatorData[] calldata _operatorData) external;
}

interface ISPOperatable {
  function operatorStore() external view returns (ISPOperatorStore);
}

/** 
  @notice
  Modifiers to allow access to functions based on the message sender's operator status.

  @dev
  Adheres to -
  ISPOperatable: General interface for the methods in this contract that interact with the blockchain's state according to the protocol's rules.
*/
abstract contract SPOperatable is ISPOperatable {
  //*********************************************************************//
  // --------------------------- custom errors -------------------------- //
  //*********************************************************************//
  error UNAUTHORIZED();

  //*********************************************************************//
  // ---------------------------- modifiers ---------------------------- //
  //*********************************************************************//

  /** 
    @notice
    Only allows the speficied account or an operator of the account to proceed. 

    @param _account The account to check for.
    @param _domain The domain namespace to look for an operator within. 
    @param _permissionIndex The index of the permission to check for. 
  */
  modifier requirePermission(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex
  ) {
    _requirePermission(_account, _domain, _permissionIndex);
    _;
  }

  /** 
    @notice
    Only allows the speficied account, an operator of the account to proceed, or a truthy override flag. 

    @param _account The account to check for.
    @param _domain The domain namespace to look for an operator within. 
    @param _permissionIndex The index of the permission to check for. 
    @param _override A condition to force allowance for.
  */
  modifier requirePermissionAllowingOverride(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex,
    bool _override
  ) {
    _requirePermissionAllowingOverride(_account, _domain, _permissionIndex, _override);
    _;
  }

  //*********************************************************************//
  // ---------------- public immutable stored properties --------------- //
  //*********************************************************************//

  /** 
    @notice 
    A contract storing operator assignments.
  */
  ISPOperatorStore public immutable override operatorStore;

  //*********************************************************************//
  // -------------------------- constructor ---------------------------- //
  //*********************************************************************//

  /** 
    @param _operatorStore A contract storing operator assignments.
  */
  constructor(ISPOperatorStore _operatorStore) {
    operatorStore = _operatorStore;
  }

  //*********************************************************************//
  // -------------------------- internal views ------------------------- //
  //*********************************************************************//

  /** 
    @notice
    Require the message sender is either the account or has the specified permission.

    @param _account The account to allow.
    @param _domain The domain namespace within which the permission index will be checked.
    @param _permissionIndex The permission index that an operator must have within the specified domain to be allowed.
  */
  function _requirePermission(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex
  ) internal view {
    if (
      msg.sender != _account &&
      !operatorStore.hasPermission(msg.sender, _account, _domain, _permissionIndex) &&
      !operatorStore.hasPermission(msg.sender, _account, 0, _permissionIndex)
    ) revert UNAUTHORIZED();
  }

  /** 
    @notice
    Require the message sender is either the account, has the specified permission, or the override condition is true.

    @param _account The account to allow.
    @param _domain The domain namespace within which the permission index will be checked.
    @param _domain The permission index that an operator must have within the specified domain to be allowed.
    @param _override The override condition to allow.
  */
  function _requirePermissionAllowingOverride(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex,
    bool _override
  ) internal view {
    if (
      !_override &&
      msg.sender != _account &&
      !operatorStore.hasPermission(msg.sender, _account, _domain, _permissionIndex) &&
      !operatorStore.hasPermission(msg.sender, _account, 0, _permissionIndex)
    ) revert UNAUTHORIZED();
  }
}

/**ISPProjects interface contract */

struct SPProjectMetadata {
  string content;
  uint256 domain;
}

interface ISPTokenUriResolver {
  function getUri(uint256 _projectId) external view returns (string memory tokenUri);
}

interface ISPProjects is IERC721 {
  event Create(
    uint256 indexed projectId,
    address indexed owner,
    SPProjectMetadata metadata,
    address caller
  );

  event SetMetadata(uint256 indexed projectId, SPProjectMetadata metadata, address caller);

  event SetTokenUriResolver(ISPTokenUriResolver indexed resolver, address caller);

  function count() external view returns (uint256);

  function metadataContentOf(uint256 _projectId, uint256 _domain)
    external
    view
    returns (string memory);

  function tokenUriResolver() external view returns (ISPTokenUriResolver);

  function createFor(address _owner, SPProjectMetadata calldata _metadata)
    external
    returns (uint256 projectId);

  function setMetadataOf(uint256 _projectId, SPProjectMetadata calldata _metadata) external;

  function setTokenUriResolver(ISPTokenUriResolver _newResolver) external;
}

library SPOperations {
  uint256 public constant RECONFIGURE = 1;
  uint256 public constant REDEEM = 2;
  uint256 public constant MIGRATE_CONTROLLER = 3;
  uint256 public constant MIGRATE_TERMINAL = 4;
  uint256 public constant PROCESS_FEES = 5;
  uint256 public constant SET_METADATA = 6;
  uint256 public constant ISSUE = 7;
  uint256 public constant CHANGE_TOKEN = 8;
  uint256 public constant MINT = 9;
  uint256 public constant BURN = 10;
  uint256 public constant CLAIM = 11;
  uint256 public constant TRANSFER = 12;
  uint256 public constant REQUIRE_CLAIM = 13;
  uint256 public constant SET_CONTROLLER = 14;
  uint256 public constant SET_TERMINALS = 15;
  uint256 public constant SET_PRIMARY_TERMINAL = 16;
  uint256 public constant USE_ALLOWANCE = 17;
  uint256 public constant SET_SPLITS = 18;
}

/** 
  @notice 
  Stores project ownership and metadata.

  @dev
  Projects are represented as ERC-721's.

  @dev
  Adheres to -
  ISPProjects: General interface for the methods in this contract that interact with the blockchain's state according to the protocol's rules.

  @dev
  Inherits from -
  SPOperatable: Includes convenience functionality for checking a message sender's permissions before executing certain transactions.
  ERC721Votes: A checkpointable standard definition for non-fungible tokens (NFTs).
  Ownable: Includes convenience functionality for checking a message sender's permissions before executing certain transactions.
*/
contract SPProjects is ISPProjects, SPOperatable, ERC721Votes, Ownable {
  //*********************************************************************//
  // --------------------- public stored properties -------------------- //
  //*********************************************************************//

  /** 
    @notice 
    The number of projects that have been created using this contract.

    @dev
    The count is incremented with each new project created. 
    The resulting ERC-721 token ID for each project is the newly incremented count value.
  */
  uint256 public override count = 0;

  /** 
    @notice 
    The metadata for each project, which can be used across several domains.

    _projectId The ID of the project to which the metadata belongs.
    _domain The domain within which the metadata applies. Applications can use the domain namespace as they wish.
  */
  mapping(uint256 => mapping(uint256 => string)) public override metadataContentOf;

  /**
    @notice
    The contract resolving each project ID to its ERC721 URI.
  */
  ISPTokenUriResolver public override tokenUriResolver;

  //*********************************************************************//
  // -------------------------- public views --------------------------- //
  //*********************************************************************//

  /**
    @notice 
    Returns the URI where the ERC-721 standard JSON of a project is hosted.

    @param _projectId The ID of the project to get a URI of.

    @return The token URI to use for the provided `_projectId`.
  */
  function tokenURI(uint256 _projectId) public view override returns (string memory) {
    // If there's no resolver, there's no URI.
    if (tokenUriResolver == ISPTokenUriResolver(address(0))) return '';

    // Return the resolved URI.
    return tokenUriResolver.getUri(_projectId);
  }

  /**
    @notice
    Indicates if this contract adheres to the specified interface.

    @dev 
    See {IERC165-supportsInterface}.

    @param _interfaceId The ID of the interface to check for adherance to.
  */
  function supportsInterface(bytes4 _interfaceId)
    public
    view
    virtual
    override(IERC165, ERC721)
    returns (bool)
  {
    return
      _interfaceId == type(ISPProjects).interfaceId ||
      _interfaceId == type(ISPOperatable).interfaceId ||
      super.supportsInterface(_interfaceId);
  }

  //*********************************************************************//
  // -------------------------- constructor ---------------------------- //
  //*********************************************************************//

  /** 
    @param _operatorStore A contract storing operator assignments.
  */
  constructor(ISPOperatorStore _operatorStore)
    ERC721('SavantProtocol Projects', 'SAVANTPROTOCOL')
    EIP712('SavantProtocol Projects', '1')
    SPOperatable(_operatorStore)
  // solhint-disable-next-line no-empty-blocks
  {

  }

  //*********************************************************************//
  // ---------------------- external transactions ---------------------- //
  //*********************************************************************//

  /**
    @notice 
    Create a new project for the specified owner, which mints an NFT (ERC-721) into their wallet.

    @dev 
    Anyone can create a project on an owner's behalf.

    @param _owner The address that will be the owner of the project.
    @param _metadata A struct containing metadata content about the project, and domain within which the metadata applies.

    @return projectId The token ID of the newly created project.
  */
  function createFor(address _owner, SPProjectMetadata calldata _metadata)
    external
    override
    returns (uint256 projectId)
  {
    // Increment the count, which will be used as the ID.
    projectId = ++count;

    // Mint the project.
    _safeMint(_owner, projectId);

    // Set the metadata if one was provided.
    if (bytes(_metadata.content).length > 0)
      metadataContentOf[projectId][_metadata.domain] = _metadata.content;

    emit Create(projectId, _owner, _metadata, msg.sender);
  }

  /**
    @notice 
    Allows a project owner to set the project's metadata content for a particular domain namespace. 

    @dev 
    Only a project's owner or operator can set its metadata.

    @dev 
    Applications can use the domain namespace as they wish.

    @param _projectId The ID of the project who's metadata is being changed.
    @param _metadata A struct containing metadata content, and domain within which the metadata applies. 
  */
  function setMetadataOf(uint256 _projectId, SPProjectMetadata calldata _metadata)
    external
    override
    requirePermission(ownerOf(_projectId), _projectId, SPOperations.SET_METADATA)
  {
    // Set the project's new metadata content within the specified domain.
    metadataContentOf[_projectId][_metadata.domain] = _metadata.content;

    emit SetMetadata(_projectId, _metadata, msg.sender);
  }

  /**
    @notice 
    Sets the address of the resolver used to retrieve the tokenURI of projects.

    @param _newResolver The address of the new resolver.
  */
  function setTokenUriResolver(ISPTokenUriResolver _newResolver) external override onlyOwner {
    // Store the new resolver.
    tokenUriResolver = _newResolver;

    emit SetTokenUriResolver(_newResolver, msg.sender);
  }
}
