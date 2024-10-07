const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("MyERC721Token", (m) => {
  const token = m.contract("MyERC721Token", ["0x655453e2D0804390bbf410562060Ab8155ffC3A2", 1]);

  return { token };
});

module.exports = TokenModule;