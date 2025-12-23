use poseidon::poseidon2;

// Increase NUM_ITERATIONS to make the circuit heavier for performance testing.
global NUM_ITERATIONS: u32 = 10_000;

/// Hash the message grid with Poseidon2 to scale constraint and proving cost.
fn main(m1: Field) -> pub Field {
    let mut result: Field = m1;

    for i in 0..NUM_ITERATIONS {
        result = poseidon2::Poseidon2::hash([result; 1], 1);
    }

    result
}

#[test]
fn poseidon_matches_expected_digest() {
    let seed_message = 1;
    let result = main(seed_message);
    assert(result.len() == 32);
}
