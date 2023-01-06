#!/usr/bin/python
# -*- coding: utf-8 -*-
# This code comes from the omg project
# https://github.com/kxr/o-must-gather/ 

import difflib
import os
import yaml
import json
import sys
from base64 import b64decode
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from urllib.parse import unquote


def load_file(path, syntax="json", is_mc=False):
    file = open(path)
    if syntax == "json":
        content = json.load(file)
        file.close()
    if syntax == "yaml":
        content = yaml.load(file, Loader=yaml.FullLoader)
    if is_mc:
        content = content['spec']['config']
    return content

def compare(ignition, show_contents, syntax="json", is_mc=False):
    # NOTE TO SELF: Recursion has gone out of hand,
    # probably re-impelement the comparison logic without
    # using recursion
    try:
        if ignition[0]:
            ignition1 = load_file(ignition[0], syntax, is_mc)
    except:
        print("[ERROR] Failed to load ignition file", ignition[0])
        return

    try:
        if ignition[1]:
            ignition2 = load_file(ignition[1], syntax, is_mc)
    except:
        print("[ERROR] Failed to load ignition file", ignition[1])
        return

    # Recursive function to show diff when --show-contents is set
    # We either get both strings in d1 and d2 ([*CHANGE]), or
    # we get on empty string on one and a dict on other ([+ADDED], [-REMOVED])
    def show_diff(d1, d2, indent=1, show_contents=show_contents):
        # print(type(d1))
        # print(type(d2))
        if show_contents:
            if type(d1) in [str, int, bool] and type(d2) in [str, int, bool]:
                if str(d1).startswith("data:"):
                    data1 = decode_content(str(d1))
                else:
                    data1 = str(d1)
                if str(d2).startswith("data:"):
                    data2 = decode_content(str(d2))
                else:
                    data2 = str(d2)
                # Add new line at the end if missing
                if data1[-1:] != "\n" or data2[-1:] != "\n":
                    if data1 != "":
                        data1 += "\n"
                    if data2 != "":
                        data2 += "\n"
                diff = "".join(
                    difflib.ndiff(
                        data1.splitlines(keepends=True), data2.splitlines(keepends=True)
                    )
                )
                for x in diff.splitlines():
                    print("    " * indent + x)
                print("")
            elif type(d1) is dict and d2 == "":
                if len(d1) == 0:
                    show_diff("{}", "", indent)
                for key in d1:
                    print("    " * indent + "-> " + key)
                    show_diff(d1[key], "", indent + 1)
            elif type(d2) is dict and d1 == "":
                if len(d2) == 0:
                    show_diff("", "{}", indent)
                else:
                    for key in d2:
                        print("    " * indent + "-> " + key)
                        show_diff("", d2[key], indent + 1)

    # Recursive function to walk through two machine-configs,
    # and find differences between them
    def mc_diff(d1, d2, path=[]):
        # The two values are equal, nothing to do
        if d1 == d2:
            return
        # One of the two values is None
        elif d1 is None:
            print("[+ADDED]", " -> ".join(path))
            show_diff("", d2)
        elif d2 is None:
            print("[-REMOVED]", " -> ".join(path))
            show_diff(d1, "")
        # The two values are string/int/bool which are not equal
        elif (
            (type(d1) is str and type(d2) is str)
            or (type(d1) is int and type(d2) is int)
            or (type(d1) is bool and type(d2) is bool)
        ):
            print("[*CHANGE]", " -> ".join(path))
            show_diff(str(d1), str(d2))
        # The two values are dict which are not equal
        elif type(d1) is dict and type(d2) is dict:
            for k in set(list(d1.keys()) + list(d2.keys())):
                path.append(k)
                if k not in d2:
                    mc_diff(d1[k], None, path)
                elif k not in d1:
                    mc_diff(None, d2[k])
                else:
                    mc_diff(d1[k], d2[k], path)
                path.pop()
        # The two values are lists which are not equal
        # We need to compare the two lists with some extended logic
        elif type(d1) is list and type(d2) is list:
            # The two lists contain different types of data
            ltypes = set([type(x) for x in d1 + d2])
            if len(ltypes) != 1:
                print("[WARNING] skipping inconsistent list: ", path)
                print("          Found mix types in list: ", ltypes)
                return

            done_lod_keys = []
            # Traverse on both the list items
            for l in d1 + d2:
                # If "list of dict" with kind/name/path keys,
                # we compare based on kind/name/path keys in the dicts
                if type(l) is dict and ("name" in l or "path" in l or "kind" in l):
                    if "kind" in l:
                        lod_key = "kind"
                    elif "name" in l:
                        lod_key = "name"
                    elif "path" in l:
                        lod_key = "path"
                    path.append(l[lod_key])
                    ld1 = [x for x in d1 if x[lod_key] == l[lod_key]]
                    ld2 = [x for x in d2 if x[lod_key] == l[lod_key]]
                    if len(ld1) > 1 and l[lod_key] not in done_lod_keys:
                        print(
                            "    [WARNING] Duplicate (%i) entries found in 1st MachineConfig for %s:%s"
                            % (len(ld1), lod_key, l[lod_key])
                        )
                    if len(ld2) > 1 and l[lod_key] not in done_lod_keys:
                        print(
                            "    [WARNING] Duplicate (%i) entries found in 2nd MachineConfig for %s:%s"
                            % (len(ld2), lod_key, l[lod_key])
                        )

                    if len(ld1) == 0:
                        mc_diff(None, ld2[-1], path)
                    elif len(ld2) == 0:
                        mc_diff(ld1[-1], None, path)
                    elif l[lod_key] not in done_lod_keys:
                        mc_diff(ld1[-1], ld2[-1], path)
                        done_lod_keys.append(l[lod_key])
                    path.pop()
                else:
                    if l not in d2:
                        mc_diff(l, None, path)
                    if l not in d1:
                        mc_diff(None, l, path)
        else:
            print("[WARNING] Unhandled condition at", path)

    mc_diff(ignition1, ignition2)

def decode_content(content):
    """
    Decodes url/bas64 encoded content found in machine-configs
    Certificate data is also converted to human readable format
    """
    split = content.split(",", 1)
    head = split[0]
    data = split[1]
    if head.startswith("data:"):
        if len(data) == 0:
            return ""
        form = head[5:].split(";")
        if "base64" in form:
            charset = next((x[8:] for x in form if x[0:8] == "charset="), "utf-8")
            dec_data = b64decode(data).decode(charset)
        else:
            dec_data = unquote(data)

        if dec_data.startswith("-----BEGIN CERTIFICATE-----"):
            certs = []
            cert = []
            for cert_line in dec_data.splitlines():
                if cert_line != "-----END CERTIFICATE-----":
                    cert.append(cert_line)
                else:
                    cert.append(cert_line)
                    certs.append("\n".join(cert))
                    cert = []
            dec_certs = []
            for c in certs:
                dec_cert = []
                parse_cert = x509.load_pem_x509_certificate(
                    str.encode(c), default_backend()
                )
                dec_cert.append("~~~~~BEGIN CERTIFICATE~~~~~")
                dec_cert.append("SUBJECT    : " + parse_cert.subject.rfc4514_string())
                dec_cert.append("ISSUER     : " + parse_cert.issuer.rfc4514_string())
                dec_cert.append("SERIAL     : " + str(parse_cert.serial_number))
                dec_cert.append(
                    "NOT BEFORE : " + parse_cert.not_valid_before.isoformat()
                )
                dec_cert.append(
                    "NOT AFTER  : " + parse_cert.not_valid_after.isoformat()
                )
                dec_cert.append("~~~~~END CERTIFICATE~~~~~")
                dec_certs.append("\n".join(dec_cert))
            return "\n".join(dec_certs)
        else:
            return dec_data
    else:
        print('[Warning] Unable to recognize content (not starting with "data:")')
        return content

def write_unit(systemd_path, unit):
    os.makedirs(systemd_path, exist_ok=True)
    name = unit["name"]
    if "enabled" in unit:
        if unit["enabled"] is not True:
            name += ".disabled"
    if "contents" in unit:
        abs_fil = os.path.join(systemd_path, name)
        with open(abs_fil, "w") as fh:
            print("Systemd unit: " + abs_fil)
            fh.write(unit["contents"])

def extract(dest_dir, ignition_file=None, syntax="json", is_mc=False):
    if ignition_file:
        ign = load_file(ignition_file, syntax)
    else:
        if syntax == "json":
            ign = json.load(sys.stdin)
        elif syntax == "yaml":
            ign = yaml.load(sys.stdin)
        else:
            bailout("syntax not supported")
    if is_mc:
        ign = ign['spec']['config']
    os.makedirs(dest_dir, exist_ok=True)
    storage_path = os.path.join(dest_dir, 'storage')

    storage = systemd = passwd = {}
    if "storage" in ign:
        os.makedirs(storage_path, exist_ok=True)
        storage = ign['storage']
    if "files" in storage:
        for fi in storage["files"]:
            path = fi["path"]
            rel_fil = path[1:]
            rel_dir = os.path.dirname(rel_fil)
            abs_dir = os.path.join(storage_path, rel_dir)
            abs_fil = os.path.join(storage_path, rel_fil)
            os.makedirs(abs_dir, exist_ok=True)
            with open(abs_fil, "w") as fh:
                print("Storage: " + abs_fil)
                if "contents" in fi:
                  fh.write(decode_content(fi["contents"]["source"]))
                else:
                  fh.write('') 
    # TODO directories, links, disks, raid, filesystems
    # systemd
    if "systemd" in ign:
        systemd = ign['systemd']
        systemd_path = os.path.join(dest_dir, "systemd")
    if "units" in systemd:
        for unit in systemd["units"]:
            if "dropins" in unit:
                systemd_path = os.path.join(
                    dest_dir, "systemd/" + unit["name"] + ".d"
                )
                for unit in unit["dropins"]:
                    write_unit(systemd_path, unit)
            else:
                write_unit(systemd_path, unit)
    # passwd
    if "passwd" in ign:
        passwd = ign["passwd"]
        passwd_path = os.path.join(dest_dir, "passwd")
    if "users" in passwd:
        for user in passwd["users"]:
            os.makedirs(passwd_path, exist_ok=True)
            name = user["name"]
            abs_fil = os.path.join(passwd_path, name)
            with open(abs_fil, "w") as fh:
                print("User: " + abs_fil)
                fh.write(yaml.dump(user))
    # TODO groups
    # TODO networkd

def bailout(error):
    print("ERROR: ", error)
    sys.exit(-1)

if __name__ == '__main__':
    import optparse
    usage = "%prog [OPTIONS]"
    opt = optparse.OptionParser(usage=usage)
    opt.add_option('-d', dest='diff', default=False, action='store_true',
            help='perform a diff between two ignition files')
    opt.add_option('-c', dest='show_contents', default=False, action='store_true',
            help='show content of the diff')
    opt.add_option('-f', dest='files', default=[], action='append',
            help='file to load, use "-" for stdin. ')
    opt.add_option('-o', dest='output_dir', default=None,
            help='outout directory where the ignition file should be extracted')
    opt.add_option('-s', dest='syntax', default="json",
            help='syntax of the files (json or yaml)')
    opt.add_option('-m', dest='machine_config', default=False, action='store_true',
            help='the loaded content is a MachineConfig')

    options, args = opt.parse_args(sys.argv[1:])

    if options.diff:
        if len(options.files) != 2:
            bailout("You must define 2 files to load")
        compare(options.files, options.show_contents, syntax=options.syntax, is_mc=options.machine_config)
    else:
        if len(options.files) != 1:
            bailout("With extract mode you must define 1 file to load")
        if options.output_dir == None:
            bailout("You must define the output dir with -o")
        if options.files[0] == '-':
            extract(options.output_dir, ignition_file=None, syntax=options.syntax, is_mc=options.machine_config)
        else:
            extract(options.output_dir, ignition_file=options.files[0], syntax=options.syntax, is_mc=options.machine_config)
