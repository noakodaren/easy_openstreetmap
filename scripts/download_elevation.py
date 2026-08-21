#!/usr/bin/env python3
# TODO improve this script, it's hacky

import base64
import os
import shutil
import subprocess

with open("config/elevationurls.txt", "r") as f:
    content = f.read()

global_cache = os.environ['GLOBAL_CACHE']
cache = f"{global_cache}/elevation"
download_dir = f"{global_cache}/elevation/tmpdownload"
os.makedirs(cache, exist_ok=True)

elevation_out = os.environ['ELEVATION_OUT']

for url in content.split('\n'):
    url = url.strip()
    if len(url) == 0:
        continue
    fs_url = base64.b64encode(bytes(url, 'utf-8')).decode('utf-8')
    cached_file = f"{cache}/{fs_url}"
    cached_file_name = f"{cache}/{fs_url}.name"
    if os.path.isfile(cached_file) and os.path.isfile(cached_file_name):
        with open(cached_file_name, "r") as f:
            filename = f.read()
    else:
        assert subprocess.run(["rm", "-rf", "--", download_dir]).returncode == 0
        os.makedirs(download_dir, exist_ok=True)
        subprocess.run(["wget", "--directory-prefix", download_dir, url])
        filename, = os.listdir(path=download_dir)
        os.rename(f"{download_dir}/{filename}", cached_file)
        with open(cached_file_name, "w") as f:
            f.write(filename)
        print(f"Has downloaded file {filename} with url {url} to cache")
    #shutil.copy(cached_file, f"{elevation_out}/{filename}")
    os.symlink(cached_file, f"{elevation_out}/{filename}")
    print(f"Has copied file {filename} with url {url} from cache")
    continue

