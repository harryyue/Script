#########################      Git format patch classify     ############################
# Rename patch name from xxx.patch to commit_time+commit_path+xxx.patch
# Author : harryyue
# Modify : 2017.03.06
################################################################################

import os
import re                #正则表达式
import shutil           #拷贝
import chardet        #decode

#month dictory,use to change the month
mon_dic = {'Jan':'1','Feb':'2','Mar':'3','Apr':'4','May':'5','Jun':'6','Jul':'7','Aug':'8','Sep':'9','Oct':'10','Nov':'11','Dec':'12'}

#patch path dictory,use to save the commit path of each filename,
#format: Key-Value  =>  filename-commit path
path_dic = {}

#commit date dictory,use to save the commit time of each filename
#format: Key-Value  =>  filename-commit time
date_dic = {}

#use to save the filename of patch file
file_list = []

#If some error occurs,this flag will change to True,and let the error messga output to log.txt
err_flag = False

#Accoding to the filename and time string of patch file,generate a filename-date(K-V) hash table.
#And the time format is YYYY-MM-D-HH-mm.
def maketimehash(filename,date_str):
    temp = date_str.split()
    time = temp[5].split(':')
    date = temp[4]+'-'+mon_dic[temp[3]]+'-'+temp[2]+'-'+time[0]+'-'+time[1]
    date_dic[filename] = date
    print('\b Commit date:',date)

#If the codec of file isn't system default ,then use this method to get the codec of file.
def getcode(filename):
    with open(filename,'rb') as f:
        data = f.read()
        enco_dic = dict( chardet.detect(data))  #get a hash table of encording

    return enco_dic['encoding']

#Compare the curpath with prepath,get same part of them and return it as a new path
def procpath(prepath,curpath):
    prelist = prepath.split('/')
    curlist = curpath.split('/')
    limit = min(len(prelist),len(curlist))
    count = 0   #count is the first index that prelist[count] isn't equal to curlist

    #Function Test print message
    #print('prelist:',prelist) 
    #print('curlist:',curlist)

    while True:
        #Avoid to throws Index Exception,so make sure the count(index) is less than limit
        if count == limit:
            break
        if prelist[count] != curlist[count]:
            break
        count += 1

    path = ''
    #print(count)
    for i in range(0,count):
        path += prelist[i]
        path += '/'
    return path

#According the filename and commit path , generate a filename-path(K-V) hash table
def makepathhash(filename,path,limit):
    #If the deepth of direction is great than limit,then cut off 
    if path.count('/') > limit:
        pathlist = path.split('/',limit)
        path = ''
        for i in range(0,limit):
            path += pathlist[i]
            path += '/'

    path = path.replace('/','-')
    #print(path)
    path_dic[filename] = path
    print('\b Commit path:',path)

#Get the date and path sring of patch,and use other method process its.
def getkeymsg(fd,f_name,log):
    global err_flag
    fir_path = True     #The flag of first get path string,default True,if not first,this flag will change to False
    if os.path.getsize(f_name) == 0:
        err_flag = True
        print('[Warning]NULL FiLE:',f_name,file=log)
    else:
        print('\n',f_name)
        for i in fd.readlines():
            if i.startswith('Date:'):
                maketimehash(f_name,i)
            elif i.startswith('diff') and '--git' in i:
                cur_path = i.split()[2].rsplit('/',1)[0]
                if fir_path:
                    pre_path = cur_path+'/'
                    fir_path = False
                else:
                    pre_path = procpath(pre_path,cur_path)
        #print(pre_path)
        makepathhash(f_name,pre_path,3)

#Read the context of patch , and generate path and date hash table.
def procpatch(filename,log):
    #global err_flag
    for i in filename:
        try:
            with open(i,'r') as f:
                getkeymsg(f,i,log)
        except UnicodeDecodeError:
            encode = getcode(i)
            with open(i,'r',encoding=encode) as f:
                getkeymsg(f,i,log)
                
#Copy the patch to output path,and rename the patch to commit_time+commit_path+xxx.patch
def movepatch(src,dst,log):
    global err_flag
    for i in src:
        if '.patch' in i:
            try:
                filename = dst + date_dic[i]+'-'+path_dic[i] + i
                shutil.copy(i,filename)
                print(i,'  ===>  ',filename)
            except KeyError as reason:
                err_flag = True
                print('[Warning]',reason,file=log)
                pass

#According to the filename list(patlist) ,separating the patch file from other files,and return the new patch list(file_list).
def findpatch(patlist):
    for i in patlist:
        if i.endswith('.patch') and '-' in i:
            file_list.append(i)
    file_list.sort()
    print(file_list)

def main():
    print('===========   Start  ==============')
    #Prepare the output path.
    print('Preparing the output path...\n')
    if os.path.exists('out'):
        os.system('rm -rf out')
    os.mkdir('out')
    out = os.getcwd() + '/out/'
    f_log = open('log.txt','w')

    #Open the patch directory,and get a list of file which under patch directory
    os.chdir('patch')
    filename_old = os.listdir()
    findpatch(filename_old)

    #According to the file list,get the commit path and commit date from path,then generate path and date hash table.
    print('Begin to get the path and commit date of patchs......\n')
    procpatch(file_list,f_log)
    print('\nFinish.\n')

    #Copy the patch to output path.
    print('Begin to copy patch to output path...\n')
    movepatch(file_list,out,f_log)
    print('\nFinish.\n')

    #Output the end message
    lenbr = len(file_list)
    os.chdir('..')
    f_log.close()
    if err_flag:
        lenaf = len(os.listdir('out'))
        lenfail = lenbr - lenaf
        print('\033[1;31m')
        print('[Error]: %d file(s) file to copy,you can view log.txt for details...'%lenfail)
        print('\033[0m')
    else:
        os.system('rf log.txt')
        print('\033[1;32m')
        print(' %d file(s) copy successful...'%lenbr)
        print('\033[0m')
    print('============  End ============')

main()
