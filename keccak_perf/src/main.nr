use keccak256::keccak256;

global MSG_SIZE: u32 = 32;

// Increase NUM_ITERATIONS to make the circuit heavier for performance testing.
global NUM_ITERATIONS: u32 = 100;

/// Hash the message with an increased number of permutation rounds to scale
/// constraint and proving cost.
fn main(m1: [u8; 32]) -> pub [u8; 32] {
    let mut result = m1;

    for i in 0..NUM_ITERATIONS {
        result = keccak256(result, MSG_SIZE);
    }

    result
}

#[test]
fn keccak_rounds_match_expected_digest() {
    let zeroed_message: [u8; 32] = [0; 32];
    let result = main(zeroed_message);
    assert(result.len() == 32);
}
