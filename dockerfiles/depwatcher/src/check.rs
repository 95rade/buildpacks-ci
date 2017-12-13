#[macro_use]
extern crate error_chain;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;
extern crate serde;
extern crate reqwest;
extern crate semver;

use std::io;
use std::io::Read;

mod pypi;

#[derive(Serialize, Deserialize)]
struct Source {
    #[serde(rename = "type")]
    kind: String,
    name: String,
}
#[derive(Serialize, Deserialize)]
struct Outer {
    source: Source,
}

fn main() {
    let mut data = String::new();
    let stdin = io::stdin();
    stdin.lock().read_to_string(&mut data).expect("Could not read line");
    let v: Outer = serde_json::from_str(&data).expect("Could not parse stdin");
    let data = match v.source.kind.as_ref() {
        "pypi" => serde_json::to_string(&pypi::check(&v.source.name).expect("Could not parse json")),
        x => Ok(format!("Unknown: {:?} -- {:?}", x, v.source.name)),
    };
    println!("{}", data.expect("Could not serialise"));
}
