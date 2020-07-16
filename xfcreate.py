#!/usr/bin/python
# coding=utf-8
import sys
import os
import shutil
import re

def main():
    try:
        if len(sys.argv) < 2 :
            print("usage: xfcreate helloworld")
            sys.exit()
        project_name = sys.argv[1]    
        src_path = sys.path[0] + '/' + 'template'
        dst_path = os.getcwd() + '/' + project_name
        if os.path.exists(dst_path) :
            print(dst_path, 'is exist')
            sys.exit()  
        shutil.copytree(src_path, dst_path)
        f=open(dst_path+'/CMakeLists.txt','r')
        alllines=f.readlines()
        f.close()
        f=open(dst_path+'/CMakeLists.txt','w+')
        for eachline in alllines:
            a=re.sub(':myproject', project_name, eachline)
            f.writelines(a)
        f.close()        
    except Exception as e:
        print e
        raise e


if __name__ == "__main__":
    main()