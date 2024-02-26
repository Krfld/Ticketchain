import { ethers, config } from 'hardhat'
import { BaseContract } from 'ethers'

export async function configure(ticketchain: BaseContract) {
    console.log(`Configuring ${await ticketchain.getAddress()}...`)

    // console.log('Fund')
    // await (await ethMillions.fallback({ value: networksConfig[config.defaultNetwork].fund })).wait()

    // console.log('SetLotteryConfig')
    // await (await ethMillions.setLotteryConfig([50, 12, 5, 2, 2])).wait()
    // console.log('SetEntryConfig')
    // await (await ethMillions.setEntryConfig([networksConfig[config.defaultNetwork].price, networksConfig[config.defaultNetwork].fee])).wait()

    // console.log('SetPrizeFundDistribution')
    // await (await ethMillions.setPrizeFundDistribution([
    //     [[5, 2], 5000],
    //     [[5, 1], 261],
    //     [[5, 0], 61],
    //     [[4, 2], 19],
    //     [[4, 1], 35],
    //     [[3, 2], 37],
    //     [[4, 0], 26],
    //     [[2, 2], 130],
    //     [[3, 1], 145],
    //     [[3, 0], 270],
    //     [[1, 2], 327],
    //     [[2, 1], 1030],
    //     [[2, 0], 1659]
    // ])).wait()

    // console.log('SetScheduleStart')
    // await (await ethMillions.setScheduleStart(1682895600)).wait()
    // console.log('SetScheduleConfig')
    // await (await ethMillions.setScheduleConfig([24 * 60 * 60, [0]])).wait()

    // console.log('SetVRFCoordinatorConfig')
    // await (await ethMillions.setVRFCoordinatorConfig([
    //     networksConfig[config.defaultNetwork].keyHash,
    //     networksConfig[config.defaultNetwork].subscriptionId,
    //     networksConfig[config.defaultNetwork].callbackGasLimit,
    //     networksConfig[config.defaultNetwork].requestConfirmations
    // ])).wait()

    console.log(`${ticketchain.address} configured`)
}