#! /usr/bin/python
# -*- coding: UTF-8 -*-
import os,sys
import argparse


def parse_args():
    parser = argparse.ArgumentParser(description='生成CSR文件.\n')
    parser.add_argument('-c', dest='csrPath', type=str, required=True, help='csr路径')
    parser.add_argument('-p', dest='pemPath', type=str, required=True, help='pem路径')
    args = parser.parse_args()
    return args

def main():
#    destPath = os.getcwd() + '/cerfile/'
    csrPath = ""
    pemPath = ""
    app_args = parse_args()
    if app_args.csrPath and app_args.pemPath:
        csrPath = app_args.csrPath
        pemPath = app_args.pemPath
    else:
        if not app_args.csrPath:
            print("请输入CSR文件导出路径")
        elif not app_args.pemPath:
            print("请输入PEM文件导出路径")
        exit(1)

    # pemPath = destPath + "/myKey.pem"
    createPemCode = "openssl genrsa -out " + pemPath
    os.system(createPemCode)

    # csrPath = destPath + "/CertificateSigningRequest.certSigningRequest"
    createCSRCode = 'openssl req -new -key ' + pemPath + ' -out ' + csrPath + " -subj " + '\"/emailAddress=mac/CN=mac/C=CN/ST=GuangDong/L=Guangzhou/O=mac/OU=IT\"'
    os.system(createCSRCode)


# def parse_args():
#     parser = argparse.ArgumentParser(description='生成CSR文件.\n')
#     parser.add_argument('-c', dest='csrPath', type=str, required=True, help='csr路径')
#     args = parser.parse_args()
#     return args

# def main():
# #    destPath = os.getcwd() + '/cerfile/'
#     destPath = ""
#     app_args = parse_args()
#     if app_args.csrPath:
#         destPath = app_args.csrPath
#     else:
#         print("请输入CSR文件导出路径")
#         exit(1)
    
#     if not os.path.exists(destPath):
#         os.makedirs(destPath)

#     pemPath = destPath + "/myKey.pem"
#     createPemCode = "openssl genrsa -out " + pemPath
#     os.system(createPemCode)

#     csrPath = destPath + "/CertificateSigningRequest.certSigningRequest"
#     createCSRCode = 'openssl req -new -key ' + pemPath + ' -out ' + csrPath + " -subj " + '\"/emailAddress=mac/CN=mac/C=CN/ST=GuangDong/L=Guangzhou/O=mac/OU=IT\"'
#     os.system(createCSRCode)

if __name__ == "__main__":
    main()
