#!/bin/bash

function echo_blue_bold {
    echo -e "\033[1;34m$1\033[0m"
}
echo

if [ ! -f privatekeys.txt ]; then
  echo_blue_bold "Error: privatekeys.txt file not found!"
  exit 1
fi

if ! npm list ethers@5.5.4 >/dev/null 2>&1; then
  echo_blue_bold "Installing ethers..."
  npm install ethers@5.5.4
  echo
else
  echo_blue_bold "Ethers is already installed."
fi
echo

temp_node_file=$(mktemp /tmp/node_script.XXXXXX.js)

cat << EOF > $temp_node_file
const fs = require("fs");
const ethers = require("ethers");
const privateKeys = fs.readFileSync("privatekeys.txt", "utf8").trim().split("\\n");
const providerURL = "https://testnet-rpc.plumenetwork.xyz/http";
const provider = new ethers.providers.JsonRpcProvider(providerURL);
const contractAddress = "0x8Dc5b3f1CcC75604710d9F464e3C5D2dfCAb60d8";
const transactionData = "0x183ff085";
const numberOfTransactions = 1;

async function sendTransaction(wallet) {
    const tx = {
        to: contractAddress,
        value: 0,
        gasLimit: ethers.BigNumber.from(600000),
        gasPrice: ethers.utils.parseUnits("0.3", 'gwei'),
        data: transactionData,
    };

    try {
        const transactionResponse = await wallet.sendTransaction(tx);
        const walletAddress = wallet.address;
        console.log("\033[1;35mTx Hash:\033[0m", transactionResponse.hash);
        const receipt = await transactionResponse.wait();
        console.log("");
    } catch (error) {
        console.error("Error sending transaction:", error);
    }
}

async function main() {
    for (const key of privateKeys) {
        const wallet = new ethers.Wallet(key, provider);
        for (let i = 0; i < numberOfTransactions; i++) {
            console.log("Checking in from wallet:", wallet.address);
            await sendTransaction(wallet);
        }
    }
}

main().catch(console.error);
EOF

NODE_PATH=$(npm root -g):$(pwd)/node_modules node $temp_node_file

rm $temp_node_file
echo
echo_blue_bold "Follow @ZunXBT on X for more guides like this"
echo
