fn greet(name: &str) -> String {
    format!("hello {name}")
}

// Only rust-analyzer's own diagnostics report this: it's inactive code
#[cfg(any())]
fn disabled() {}

// Only the clippy check reports this (needless_return), not cargo check
fn double(x: i32) -> i32 {
    return x * 2;
}

fn main() {
    let message = greet("world");
    println!("{message} {}", double(2));
}
