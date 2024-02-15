import { ethers, config, run } from 'hardhat'
import { verify } from './verify'

const contractName: string = 'Ticketchain'
const confirmations: number = 6

async function setup() {
    if (config.defaultNetwork == 'hardhat' || config.defaultNetwork == 'localhost') {
        console.log('Wrong network')
        return
    }

    // Compile

    console.log(`Compiling ${contractName}...`)
    await run('compile')
    console.log(`${contractName} compiled`)

    const [signer] = await ethers.getSigners()
    const startBalance = await ethers.provider.getBalance(signer)

    const Ticketchain = await ethers.getContractFactory(contractName)

    // Deploy

    console.log(`Deploying ${contractName}...`)
    const ticketchain = await Ticketchain.deploy()
    const address = await ticketchain.getAddress()
    console.log(`${contractName} deployed to ${address}`)

    // Verify

    console.log(`Waiting for ${confirmations} block confirmation${confirmations == 1 ? '' : 's'}...`)
    await ticketchain.deploymentTransaction()!.wait(confirmations)

    await verify(address, [])


    const endBalance = await ethers.provider.getBalance(signer)
    const cost = startBalance - endBalance
    console.log(`Signer spent ${cost} wei (${ethers.formatEther(cost)} ether)`)
}

setup().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})
