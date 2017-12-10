use reqwest;
use std;
use std::io::Read;

error_chain! {
    foreign_links {
        ReqError(reqwest::Error);
        IoError(std::io::Error);
    }
}

pub fn check(name: String) -> Result<String> {
    let mut resp = reqwest::get(&format!("https://pypi.python.org/pypi/{}/json", name))?;
    assert!(resp.status().is_success());

    let mut content = String::new();
    resp.read_to_string(&mut content)?;

    Ok(content)
}
