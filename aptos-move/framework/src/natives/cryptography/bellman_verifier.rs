use crate::natives::util::make_native_from_func;
use move_core_types::gas_algebra::{InternalGas, InternalGasPerByte, NumBytes, InternalGasPerArg, NumArgs};
use move_vm_runtime::native_functions::{NativeContext, NativeFunction};
use move_binary_format::errors::PartialVMResult;
use move_vm_types::{
    loaded_data::runtime_types::Type, natives::function::NativeResult, pop_arg, values::Value,
};
use smallvec::smallvec;
use std::{collections::VecDeque, convert::TryFrom};

// bellman dependencies
use serde::{Deserialize, Serialize};
use bellman::groth16::{
    Proof, VerifyingKey,
};
use pairing::{Engine};
use bls12_381::{G1Affine, G2Affine, Bls12};
use ff::PrimeField as Fr;

use bellman::groth16::{prepare_verifying_key, verify_proof};

#[derive(Serialize, Deserialize)]
pub struct ProofStr {
    pub pi_a: Vec<u8>,
    pub pi_b: Vec<u8>,
    pub pi_c: Vec<u8>,
}

#[derive(Serialize, Deserialize)]
pub struct VkeyStr {
    pub alpha_1: Vec<u8>,
    pub beta_2: Vec<u8>,
    pub gamma_2: Vec<u8>,
    pub delta_2: Vec<u8>,
    pub ic: Vec<u8>,
}

pub fn parse_proof<E>(pof: ProofStr) -> Proof<E>
where
    E: Engine<G1Affine = G1Affine, G2Affine = G2Affine>,
{
    let pi_a = pof.pi_a;
    let pi_b = pof.pi_b;
    let pi_c = pof.pi_c;

    let mut a_arr: [u8; 96] = [0; 96];
    let mut b_arr: [u8; 192] = [0; 192];
    let mut c_arr: [u8; 96] = [0; 96];

    for i in 0..pi_a.len() {
        a_arr[i] = pi_a[i];
    }

    for i in 0..pi_b.len() {
        b_arr[i] = pi_b[i];
    }

    for i in 0..pi_c.len() {
        c_arr[i] = pi_c[i];
    }

    let pia_affine = G1Affine::from_uncompressed(&a_arr).unwrap();
    let pib_affine = G2Affine::from_uncompressed(&b_arr).unwrap();
    let pic_affine = G1Affine::from_uncompressed(&c_arr).unwrap();

    Proof{
        a: pia_affine,
        b: pib_affine,
        c: pic_affine,
    }
}

pub fn parse_vkey<E>(vk: VkeyStr) -> VerifyingKey<E>
where
E: Engine<G1Affine = G1Affine, G2Affine = G2Affine>,
{
    let vk_alpha_1 = vk.alpha_1;
    let vk_beta_2 = vk.beta_2;
    let vk_gamma_2 = vk.gamma_2;
    let vk_delta_2 =  vk.delta_2;
    let mut vk_ic = vk.ic;
    let vk_ic_2 = vk_ic.split_off(96);

    let mut alpha1: [u8; 96] = [0; 96];
    let mut beta2: [u8; 192] = [0; 192];
    let mut gamma2: [u8; 192] = [0; 192];
    let mut delta2: [u8; 192] = [0; 192];
    let mut ic_0: [u8; 96] = [0; 96];
    let mut ic_1: [u8; 96] = [0; 96];
    let mut ic = Vec::new();

    for i in 0..vk_alpha_1.len() {
        alpha1[i] = vk_alpha_1[i];
    }

    for i in 0..vk_beta_2.len() {
        beta2[i] = vk_beta_2[i];
    }

    for i in 0..vk_gamma_2.len() {
        gamma2[i] = vk_gamma_2[i];
    }

    for i in 0..vk_delta_2.len() {
        delta2[i] = vk_delta_2[i];
    }

    for i in 0..vk_ic.len() {
        ic_0[i] = vk_ic[i];
    }

    for i in 0..vk_ic_2.len() {
        ic_1[i] = vk_ic_2[i];
    }

    let alpha1_affine = G1Affine::from_uncompressed(&alpha1).unwrap();
    let beta2_affine = G2Affine::from_uncompressed(&beta2).unwrap();
    let gamma2_affine = G2Affine::from_uncompressed(&gamma2).unwrap();
    let delta2_affine = G2Affine::from_uncompressed(&delta2).unwrap();
    let ic0_affine = G1Affine::from_uncompressed(&ic_0).unwrap();
    let ic1_affine = G1Affine::from_uncompressed(&ic_1).unwrap();
    ic.push(ic0_affine);
    ic.push(ic1_affine);

    VerifyingKey{
        alpha_g1: alpha1_affine,
        beta_g1: G1Affine::identity(),
        beta_g2: beta2_affine,
        gamma_g2: gamma2_affine,
        delta_g1: G1Affine::identity(),
        delta_g2: delta2_affine,
        ic,
    }
}

#[derive(Debug, Clone)]
pub struct GasParameters{
    pub base: InternalGas,
    pub per_proof_uncompressed: InternalGasPerArg,
    pub per_vkey_uncompressed: InternalGasPerArg,
    pub per_prepared_vkey_deserialize: InternalGasPerArg,
    //TODO: public的序列化
    // pub per_public_deserialize: InternalGasPerArg,
}


/***************************************************************************************************
 * native fun native_bellman_verifier
 *
 *   gas cost: 
 *
 **************************************************************************************************/

 fn native_bellman_verifier(
    gas_params: &GasParameters,
    _context: &mut NativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> PartialVMResult<NativeResult> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(arguments.len() == 8);

    let mut cost = gas_params.base;

    cost += gas_params.per_vkey_uncompressed * NumArgs::one();

    let ic = pop_arg!(arguments, Vec<u8>);
    let delta_2 = pop_arg!(arguments, Vec<u8>);
    let gamma_2 = pop_arg!(arguments, Vec<u8>);
    let beta_2 = pop_arg!(arguments, Vec<u8>);
    let alpha_1 = pop_arg!(arguments, Vec<u8>);

    let vkey = parse_vkey::<Bls12>(
        VkeyStr{
            alpha_1,
            beta_2,
            gamma_2,
            delta_2,
            ic,
        }
    );

    cost += gas_params.per_proof_uncompressed * NumArgs::one();

    let pi_c = pop_arg!(arguments, Vec<u8>);
    let pi_b = pop_arg!(arguments, Vec<u8>);
    let pi_a = pop_arg!(arguments, Vec<u8>);
    
    let proof = parse_proof::<Bls12>(
        ProofStr {
            pi_a,
            pi_b,
            pi_c,
        }
    );

    cost += gas_params.per_prepared_vkey_deserialize * NumArgs::one();
    let pvk =  prepare_verifying_key(&vkey);

    let verify_result =  verify_proof(&pvk, &proof, &[Fr::from_str_vartime("33").unwrap()]).is_ok();

    Ok(NativeResult::ok(
        cost,
        smallvec![Value::bool(verify_result)],
    ))
}



pub fn make_all(gas_params: GasParameters) -> impl Iterator<Item = (String, NativeFunction)> {
    let mut natives = vec![];
    
    natives.append(&mut vec![
        (
            "bellman_verifier_internal", 
            make_native_from_func(gas_params.clone(), native_bellman_verifier),
        )
    ]);

    crate::natives::helpers::make_module_natives(natives)

}
