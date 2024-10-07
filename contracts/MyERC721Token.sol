// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyERC721Token
 * @dev ERC721 токен с возможностью хранения URI для каждого токена и функцией минтинга.
 */
contract MyERC721Token is ERC721, ERC721URIStorage, Ownable {
    uint256 private _tokenIds = 0;
    uint256 private _PRICE = 1;
    uint256 public constant MAX_ELEMENTS = 7;
    string public baseTokenURI = 
        "https://ipfs.io/ipfs/QmfGCCNUfTCd7thUP5FGd9AuvdRQ4MmNDcH13aGBbGAae9/";

    /// @dev Эмитируется при создании нового токена (пингвина).
    event CreatePenguin(uint256 indexed id);

    /**
     * @dev Конструктор контракта. Устанавливает начальную стоимость за токен и владельца.
     * @param initialOwner Адрес начального владельца контракта.
     * @param PRICE Стоимость одного токена в wei.
     */
    constructor(
        address initialOwner,
        uint256 PRICE
    ) ERC721("MyERC721Token", "MTK721") Ownable(initialOwner) {
        _PRICE = PRICE;
    }

    /**
     * @notice Минт нескольких токенов указанному адресу.
     * @dev Выполняет проверку на максимальное количество токенов и корректную оплату.
     * @param _to Адрес, которому будут минтиться токены.
     * @param _count Количество токенов для минтинга.
     */
    function mint(address _to, uint256 _count) public payable {
        uint256 total = _totalSupply();
        require(total + _count < MAX_ELEMENTS, "Max limit");
        require(total < MAX_ELEMENTS, "Sale end");
        require(msg.value >= _PRICE * _count, "Value below price");

        for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(_to);
        }
    }

    /**
     * @dev Минт одного токена и увеличивает количество токенов.
     * @param _to Адрес получателя токена.
     */
    function _mintAnElement(address _to) private {
        uint id = _totalSupply();
        _tokenIds++;
        _safeMint(_to, id);
    }

    /**
     * @notice Возвращает стоимость указанного количества токенов.
     * @param _count Количество токенов для расчета стоимости.
     * @return Возвращает сумму в wei, равную стоимости `_count` токенов.
     */
    function price(uint256 _count) public view returns (uint256) {
        return _PRICE * _count;
    }

    /**
     * @notice Возвращает текущее количество сгенерированных токенов.
     * @return Текущее общее количество токенов.
     */
    function _totalSupply() internal view returns (uint) {
        return _tokenIds;
    }

    /**
     * @notice Возвращает общее количество сминченных токенов.
     * @return Общее количество токенов.
     */
    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }

    /**
     * @notice Возвращает базовый URI для всех токенов.
     * @dev Переопределяет метод _baseURI для использования baseTokenURI.
     * @return Базовый URI для токенов.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @notice Устанавливает новый базовый URI для токенов.
     * @dev Только владелец может вызвать эту функцию.
     * @param baseURI Новый базовый URI для токенов.
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    /**
     * @notice Возвращает URI для указанного токена.
     * @dev Переопределяет метод tokenURI из ERC721 и ERC721URIStorage.
     * @param tokenId Идентификатор токена.
     * @return Полный URI для данного токена.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        _requireOwned(tokenId);
        return super.tokenURI(tokenId);
    }

    /**
     * @notice Проверяет поддержку интерфейсов.
     * @dev Переопределяет метод supportsInterface из ERC721 и ERC721URIStorage.
     * @param interfaceId Идентификатор интерфейса.
     * @return Возвращает true, если интерфейс поддерживается, иначе false.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
