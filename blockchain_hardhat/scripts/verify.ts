import { ethers, config, run } from 'hardhat'
import { log } from 'console'

export async function verify(address: string, constructorArguments: any[]) {
    log(`Verifying ${address}...`)
    await run('verify:verify', {
        address: address,
        constructorArguments: constructorArguments
    })
    log(`${address} verified`)
}

async function main() {
    const address: string = ''
    const args: any[] = []

    await verify(address, args)
}

// main().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
// });
