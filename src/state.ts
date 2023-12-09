import { RollupState, STF } from "@stackr/stackr-js/execution";
import { ethers } from "ethers";
import MerkleTree from "merkletreejs";

export type StateVariable = {
  leaves: Account[];
};

type Account = {
  address: string;
  balance: number;
};

class MerkleTreeTransport {
  public merkleTree: MerkleTree;
  public leaves: Account[];

  constructor(leaves: Account[]) {
    this.merkleTree = this.createTree(leaves);
    this.leaves = leaves;
  }

  createTree(leaves: Account[]) {
    const hashedLeaves = leaves.map((leaf: Account) => {
      return ethers.solidityPackedKeccak256(
        ["address", "uint"],
        [leaf.address, leaf.balance]
      );
    });
    return new MerkleTree(hashedLeaves);
  }
}

export type ReputationActionInput = {
  type: "calculate-reputation";
  address: string;
  reputation: number;
};

export class ReputationRollup extends RollupState<
  StateVariable,
  MerkleTreeTransport
> {
  constructor(count: StateVariable) {
    super(count);
  }

  createTransport(state: StateVariable): MerkleTreeTransport {
    return new MerkleTreeTransport(state.leaves);
  }

  getState(): StateVariable {
    return { leaves: this.transport.leaves };
  }

  calculateRoot(): ethers.BytesLike {
    return this.transport.merkleTree.getHexRoot();
  }
}

export const reputationSTF: STF<ReputationRollup, ReputationActionInput> = {
  identifier: "reputationSTF",

  apply(inputs: ReputationActionInput, state: ReputationRollup): void {
    let newState = state.getState();

    const index = newState.leaves.findIndex(
      (leaf: Account) => leaf.address === inputs.address
    );
    if (index === -1) {
      newState.leaves.push({
        address: inputs.address,
        balance: inputs.reputation,
      });
    } else {
      newState.leaves[index].balance += inputs.reputation;
    }

    console.log({ inputs, state: JSON.stringify(state.getState().leaves), leaves: newState.leaves });

    state.transport.leaves = newState.leaves;
  },
};
