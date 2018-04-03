#!/bin/env  python
#-*- encoding:utf-8 -*-

import os
import json
import hashlib
import urlparse
import functools
import requests


#1.获取镜像tag列表
TAG_LIST_URL = "http://127.0.0.1:5000/v2/ubuntu/tags/list"
#2.获取镜像的manifest
MANIFEST_INFO_URL = "http://127.0.0.1:5000/v2/ubuntu/manifests/16.04"
#3.获取服务中的仓库列表
REPOSITORIES_LIST_URL = "http://127.0.0.1:5000/v2/_catalog"

headers = {
    'Accept': 'application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.docker.distribution.manifest.v1+prettyjws, application/json, application/vnd.docker.distribution.manifest.v2+json'
}


DOMAIN = "http://127.0.0.1:5000/v2/"
DOCKERPATH = "/var/lib/docker"
DOCKERPATH = "/data/docker"
DOCKERDRIVER = "overlay2"

def read_json(fn, key, default=None):
    """get data from json file"""
    if not os.path.exists(fn):
        return default
    with open(fn) as fd:
        data = fd.read()
        try:
            return json.loads(data).get(key, default)
        except:
            pass
    return default

def read_data(fn):
    """read data from normal file"""
    if not os.path.exists(fn):
        return ""
    with open(fn) as fd:
        return fd.read().strip()
    return ""

def get_manifest_info(image, tag):
    """request image manifest, which contains config and layers info"""
    url = urlparse.urljoin(DOMAIN, image+"/manifests/"+tag)
    rep = requests.get(url, headers=headers)
    headdigest = rep.headers['docker-content-digest'].split(":")[1]
    contdigest = hashlib.sha256(rep.text).hexdigest()
    if headdigest == contdigest:
        print(rep.text)
        return rep.text
    return ""

def echo_image_info(imageid):
    path = os.path.join(DOCKERPATH, "image", DOCKERDRIVER,
                        "imagedb/content/sha256", imageid)
    if not os.path.exists(path):
        print("Image[%s] metadata:%s not exists "%(imageid, path))
        return
    diffids = read_json(path, "rootfs", {}).get("diff_ids", [])
    laymeta = diffid_to_layermetadata(diffids)
    laymeta = map(lambda x:
                  DOCKERPATH+"/image/"+DOCKERDRIVER+"/layerdb/sha256/"+x,
                  laymeta)
    layers = map(laymeta_to_layer, laymeta)
    imageinfo = {
        "image_metadata": path,
        "diff_ids": diffids,
        "layers_metapath": laymeta,
        "layers_path": layers,
    }
    print(json.dumps(imageinfo, indent=4))

def laymeta_to_layer(laypath):
    layer = read_data(laypath+"/cache-id")
    return DOCKERPATH+"/"+DOCKERDRIVER+"/"+layer if layer else ""

def diffid_to_layermetadata(diffids):
    """通过diffid计算各层layer的目录名,layer元数据的存放位置"""
    if not diffids: return diffids
    digest = []
    digest.append(diffids[0].split(":")[1])
    def calc_chainid(sli, x, y):
        chainid = hashlib.sha256(x + " " + y).hexdigest()
        sli.append(chainid)
        return "sha256:"+chainid
    reduce(functools.partial(calc_chainid, digest), diffids)
    return digest

def calc_chainid(diffids):
    """chainid的计算方法"""
    difflen = len(diffids)
    if difflen == 1:
        return diffids[0]
    elif difflen == 2:
        return "sha256:"+hashlib.sha256(diffids[0] + " " +
                                        diffids[1]).hesdigest()
    return calc_chainid([calc_chainid(diffids[:difflen-1]), diffids[difflen-1]])

def main():
    data = get_manifest_info("ubuntu", "16.04")
    imageid = json.loads(data).get("config", {}).get("digest", "").split(":")[1]
    print("Image:[ubuntu:16.04] ID:[%s]"%imageid)
    echo_image_info(imageid)


if __name__ == "__main__":
    main()

