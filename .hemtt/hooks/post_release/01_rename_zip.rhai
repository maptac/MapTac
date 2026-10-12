// maptac-1.0.0.0.zip -> maptac_1.0.0.zip
let releases = HEMTT_RFS.join("releases");

let src = releases.join(HEMTT.project().prefix() + "-" + HEMTT.project().version().to_string() + ".zip");
let dst = releases.join(HEMTT.project().prefix() + "_" + HEMTT.project().version().to_string_short() + ".zip");

print("Moving zip to " + dst);
if !src.move(dst) {
    fatal("Failed to move " + src + " to " + dst);
}
