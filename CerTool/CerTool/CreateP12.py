#! /usr/bin/python
# -*- coding: UTF-8 -*-
import os,sys
import argparse

# cerDefaultPath = "./cerfile/ios_distribution.cer"
# pemDefaultPath = "./cerfile/myKey.pem"

def parse_args():
    parser = argparse.ArgumentParser(description='生成p12证书.\n')
    parser.add_argument('-c', dest='cerPath', type=str, required=True, help='cer路径')
    parser.add_argument('-p', dest='pemKeyPath', type=str, required=True, help='pem路径')
    parser.add_argument('-d', dest='p12Path', type=str, required=True, help='p12导出路径')
    parser.add_argument('-w', dest='p12Pwd', type=str, required=True, help='p12证书密码')
    args = parser.parse_args()
    return args

def main():
    cerPath = ""
    pemKeyPath = ""
    p12Path = ""
    p12Password = ""
    errorList = []
    app_args = parse_args()
    if app_args.cerPath:
        if os.path.exists(app_args.cerPath):
            cerPath = app_args.cerPath
        else:
            errorList.append("cer文件不存在")
    else:
        errorList.append("请输入cer文件路径 -c [Path]")

    if app_args.pemKeyPath:
        if os.path.exists(app_args.pemKeyPath):
            pemKeyPath = app_args.pemKeyPath
        else:
            errorList.append("pem文件不存在")
    else:
        errorList.append("请输入pem文件路径 -p [Path]")

    if app_args.p12Path:
        p12Path = app_args.p12Path
    else:
        errorList.append("请输入p12导出路径 -d [Path]")

    if app_args.p12Pwd:
        p12Password = app_args.p12Pwd
    else:
        errorList.append("请输入p12证书密码 -w [password]")

    if len(errorList):
        errorStr = "\n".join(errorList)
        print(errorStr)
        exit(1)

    # destPath = os.getcwd() + '/cerfile/'
    # if not os.path.exists(destPath):
    #     os.makedirs(destPath)

    # pemKeyPath = destPath + "myKey.pem"

    # cerFileName = os.path.splitext(os.path.basename(cerPath))[0]
    # cerPemPath = destPath + cerFileName + ".pem"
    cerPemPath = cerPath.replace(".cer",".pem")
    createPemCode = 'openssl x509 -in ' + cerPath + ' -inform DER -outform PEM -out ' + cerPemPath
    os.system(createPemCode)

    # p12Path = destPath + cerFileName + ".p12"
    createP12Code = 'openssl pkcs12 -export -out ' + p12Path + ' -inkey ' + pemKeyPath + ' -in ' + cerPemPath + ' -passout pass:' + p12Password
    os.system(createP12Code)

    if os.path.exists(cerPemPath):
        os.remove(cerPemPath)

    print("p12密码123456")

if __name__ == "__main__":
    main()