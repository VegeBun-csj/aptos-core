module publiser::verfier{
    use std::signer;
    use std::vector;

    use aptos_std::bellman_verifier;

    struct ProofAndVkey has key{
        proof_a: vector<u8>,
        proof_b: vector<u8>,
        proof_c: vector<u8>,
        alpha_g1: vector<u8>,
        beta_g2: vector<u8>,
        gamma_g2: vector<u8>,
        delta_g2: vector<u8>,
        ic: vector<u8>,
    }

    struct verificationResult has key{
        result: bool
    }

    public entry fun setProofAndVkey(
        account: signer,
        proof_a: vector<u8>,
        proof_a: vector<u8>,
        proof_c: vector<u8>,
        alpha_g1: vector<u8>,
        beta_g2: vector<u8>,
        gamma_g2: vector<u8>,
        delta_g2: vector<u8>,
        ic: vector<u8>,
    ) acquires ProofAndVkey{
        let addr = signer::address_of(&account);
        if(!exists<ProofAndVkey>(addr)){
            move_to(
                &account,
                ProofAndVkey{
                    proof_a,
                    proof_b,
                    proof_c,
                    alpha_g1,
                    beta_g2,
                    gamma_g2
                    delta_g2,
                    ic,
                }
            )
        }else{
            let old_proof_and_vkey = borrow_global_mut<ProofAndVkey>(addr);
            old_proof_and_vkey.proof_a = proof_a;
            old_proof_and_vkey.proof_b = proof_b;
            old_proof_and_vkey.proof_c = proof_c;
            old_proof_and_vkey.alpha_g1 = alpha_g1;
            old_proof_and_vkey.beta_g2 = beta_g2;
            old_proof_and_vkey.gamma_g2 = gamma_g2;
            old_proof_and_vkey.delta_g2 = delta_g2;
            old_proof_and_vkey.ic = ic;
        }
    }

    public entry fun verify_proof(
        account: signer,
    ) acquires verificationResult{
        let addr = signer::address_of(&account);
        let proof_and_vkey = *&borrow_global<ProofAndVKey>(addr);
        let result = bellman_verifier(
            proof_and_vkey.proof_a,
            proof_and_vkey.proof_b,
            proof_and_vkey.proof_c,
            proof_and_vkey.alpha_g1,
            proof_and_vkey.beta_g2,
            proof_and_vkey.gamma_g2,
            proof_and_vkey.delta_g2,
            proof_and_vkey.ic,
        )
        if(!exists<VerificationResult>(addr)){
            move_to(
                &account,
                VerificationResult{
                    result
                }
            )
        }else{
            let old_result = borrow_global_mut<VerificationResult>(addr);
            old_result.result = result;
        }
    }
}