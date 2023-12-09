import { ethers } from "ethers";
import { stackrConfig } from "../stackr.config";
import { actionInput } from "../src";

const submitToRollup = async () => {
  const wallet = ethers.Wallet.createRandom();

  const data = {
    type: "calculate-reputation",
    address: wallet.address,
    reputation: 0,
  };

  const sign = await wallet.signTypedData(
    stackrConfig.domain,
    actionInput.EIP712TypedData.types,
    data
  );

  const payload = JSON.stringify({
    msgSender: wallet.address,
    signature: sign,
    payload: data,
  });

  console.log(payload);

  const res = await fetch("http://localhost:3000/", {
    method: "POST",
    body: payload,
    headers: {
      "Content-Type": "application/json",
    },
  });

  const json = await res.json();
  console.log(json);
};

const viewRollupState = async () => {
  const res = await fetch("http://localhost:3000/", {
    method: "GET",
  });

  const json = await res.json();
  console.log(json);
};

const run = async () => {
  await submitToRollup();
  await viewRollupState();
}

for(let i = 0; i < 10; i++) {
  await run();
}

// const run = async () => {
//   const start = Date.now();
//   const payload = await getData();

//   const res = await fetch("http://localhost:3000/", {
//     method: "POST",
//     body: payload,
//     headers: {
//       "Content-Type": "application/json",
//     },
//   });

//   const end = Date.now();

//   const json = await res.json();

//   const elapsedSeconds = (end - start) / 1000;
//   const requestsPerSecond = 1 / elapsedSeconds;

//   console.log(`Requests per second: ${requestsPerSecond.toFixed(2)}`);
//   console.log("response : ", json);
// };

// function delay(ms: number) {
//   return new Promise((resolve) => setTimeout(resolve, ms));
// }

// let sent = 0;

// while (true) {
//   sent++;
//   await run();
//   if (sent === 16) {
//     break;
//   }
// }
