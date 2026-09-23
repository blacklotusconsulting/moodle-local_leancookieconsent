#!/usr/bin/env bash
set -euo pipefail

# Moodle's installer requires the archive root directory to match the plugin
# name, not the GitHub repository name.  Do not use GitHub's “Download ZIP”
# for releases: it creates local_leancookieconsent-main/ instead.
readonly plugin_name="leancookieconsent"
readonly project_root="$(cd "$(dirname "$0")/.." && pwd)"
readonly output_dir="${project_root}/dist"
readonly archive_path="${output_dir}/${plugin_name}.zip"

mkdir -p "$output_dir"
rm -f "$archive_path"

git -C "$project_root" archive --format=zip --prefix="${plugin_name}/" --output="$archive_path" HEAD

root_entries="$(unzip -Z1 "$archive_path" | awk -F/ 'NF { print $1 }' | sort -u)"
if [[ "$root_entries" != "$plugin_name" ]]; then
    echo "Unexpected Moodle archive root: ${root_entries}" >&2
    exit 1
fi

if ! unzip -Z1 "$archive_path" | grep -qx "${plugin_name}/version.php"; then
    echo "Archive does not contain ${plugin_name}/version.php" >&2
    exit 1
fi

echo "Created and verified ${archive_path}"
