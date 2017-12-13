use reqwest;
use std;
use std::collections::HashMap;
use serde_json;
use semver::Version;

error_chain! {
    foreign_links {
        ReqError(reqwest::Error);
        IoError(std::io::Error);
        Json(serde_json::Error);
    }
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Release {
    #[serde(rename = "ref")]
    reference: Option<String>,
    url: String,
    md5_digest: String,
    packagetype: String,
    size: i64,
}

#[derive(Deserialize, Debug)]
pub struct External {
    releases: HashMap<String, Vec<Release>>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Internal {
    #[serde(rename = "ref")]
    reference: String,
}

pub fn http_json(name: &str) -> Result<External> {
    let resp = reqwest::get(&format!("https://pypi.python.org/pypi/{}/json", name))?;
    if !resp.status().is_success() {
        bail!("Received non 2xx from pypi");
    }

    let v = serde_json::from_reader(resp)?;
    Ok(v)
}

fn semver_cmp(a: &str, b: &str) -> std::cmp::Ordering {
    let a1 = a.char_indices().filter(|&(_,c)|c=='.').count();
    let b1 = b.char_indices().filter(|&(_,c)|c=='.').count();
    if a1 != b1 {
        return a1.cmp(&b1);
    }
    match (Version::parse(a), Version::parse(b)) {
        (Ok(a2), Ok(b2)) => a2.cmp(&b2),
        _=> a.cmp(&b),
    }
}

pub fn check(name: &str) -> Result<Vec<Internal>> {
    let v1: External = http_json(name)?;
    let mut v2 : Vec<&String> = v1.releases.keys().collect();
    v2.sort_by(|a,b| semver_cmp(b,a));
    let v3 : Vec<Internal> = v2.iter().take(10).map(|r| Internal { reference: (*r).clone() }).collect();
    Ok(v3)
}
