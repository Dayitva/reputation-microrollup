import testResponse from '../test-response.json';

export const getReputation = async (address: string) => {
    const { borrowCount, repayCount, depositCount, liquidateCount, liquidationCount, transferredCount, openPositionCount, closedPositionCount } = testResponse.data.account;
    const squaredAverage = Math.sqrt((borrowCount ** 2 + repayCount ** 2 + depositCount ** 2 + liquidateCount ** 2 + liquidationCount ** 2 + transferredCount ** 2 + openPositionCount ** 2 + closedPositionCount ** 2) / (borrowCount + repayCount + depositCount + liquidateCount + liquidationCount + transferredCount + openPositionCount + closedPositionCount));
    const reputation = squaredAverage + Math.random() * 10
    console.log(reputation)
    return Math.floor(reputation);
};

await getReputation("0x4125caf9dd93ec6ad7a4c668ec55102f8f18203a")