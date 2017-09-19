#########################      Git format patch classify     ############################
# Rename patch name from xxx.patch to commit_time+commit_path+xxx.patch
# or commit_path+commit_time+xxx.patch
#
# Author : harryyue
# Modify : 2017.03.09
################################################################################

import os
import shutil           #copy
import chardet        #decode
import time

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
count = 0



#Accoding to the filename and time string of patch file,generate a filename-commit time(K-V) hash table.
#And the time format is YYYY-MM-D-HH-mm.
def maketimehash(filename,date_str):
    temp = date_str.split()
    time = temp[5].split(':')
    date = temp[4]+'-'+mon_dic[temp[3]]+'-'+temp[2]+'-'+time[0]+'-'+time[1]
    date_dic[filename] = date
    print('\t Commit date:',date)

#If the coding of file isn't system default ,then use this method to get the coding of file.
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
    print('\t Commit path:',path)

#Get the date and path sring of patch,and use other method process its.
def getkeymsg(fd,f_name,log,depth):
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
        makepathhash(f_name,pre_path,depth)

#Read the context of patch , and generate path and date hash table.
def procpatch(filename,log,depth):
    #global err_flag
    for i in filename:
        try:
            with open(i,'r') as f:
                getkeymsg(f,i,log,depth)
        except UnicodeDecodeError:
            encode = getcode(i)
            with open(i,'r',encoding=encode) as f:
                getkeymsg(f,i,log,depth)
                
#Copy the patch to output path,and rename the patch to commit_time+commit_path+xxx.patch
def movepatch(src,dst,log,choice):
    global err_flag
    global count
    for i in src:
        if '.patch' in i:
            try:
                if choice == 1 :
                    filename = dst + date_dic[i]+'-'+path_dic[i] + i
                elif choice == 2 :
                    filename = dst + path_dic[i]+'-'+date_dic[i] + i
                shutil.copy(i,filename)
                print(i,'  ===>  ',filename)
            except KeyError as reason:
                err_flag = True
                count += 1
                print('[Warning]',reason,file=log)

#According to the filename list(patlist) ,separating the patch file from other files,and return the new patch list(file_list).
def findpatch(patlist):
    for i in patlist:
        if i.endswith('.patch') and '-' in i:
            file_list.append(i)
    file_list.sort()
    print(file_list)

def main(choice=1,pathdep=3):
    global count
    global file_list
    file_list = []
    count = 0
    print('#'*10,'   Start   ','#'*10)
    #Prepare the output path.
    print('Preparing the output path...\n')
    curtime = time.localtime()
    if choice == 1 :
        if os.path.exists('out_time'):
            os.system('rm -rf out_time')
        os.mkdir('out_time')
        out = os.getcwd() + '/out_time/'
        logfile = 'log_time%d%d%d%d%d.txt'%(curtime.tm_year,curtime.tm_mon,curtime.tm_mday,curtime.tm_hour,curtime.tm_min)
        f_log = open(logfile,'w')
    elif choice == 2 :
        if os.path.exists('out_path'):
            os.system('rm -rf out_path')
        os.mkdir('out_path')
        out = os.getcwd() + '/out_path/'
        logfile = 'log_path%d%d%d%d%d.txt'%(curtime.tm_year,curtime.tm_mon,curtime.tm_mday,curtime.tm_hour,curtime.tm_min)
        f_log = open(logfile,'w')

    #Open the patch directory,and get a list of file which under patch directory
    os.chdir('patch')
    filename_old = os.listdir()
    findpatch(filename_old)

    #According to the file list,get the commit path and commit date from path,then generate path and date hash table.
    print('Begin to get the path and commit date of patchs......\n')
    procpatch(file_list,f_log,pathdep)
    print('\nFinish.\n')

    #Copy the patch to output path.
    print('Begin to copy patch to output path...\n')
    movepatch(file_list,out,f_log,choice)
    print('\nFinish.\n')

    #Output the end message
    lenbr = len(file_list)
    os.chdir('..')
    f_log.close()
    if err_flag:
        print('\033[1;31m')
        print('[Error]: %d file(s) fail to copy,you can view log.txt for details...'%count)
        print('\033[0m')
    else:
        os.remove(logfile)
        print('\033[1;32m')
        print(' %d file(s) copy successful...'%lenbr)
        print('\033[0m')
    print('#'*10,'    End    ','#'*10)

print('#'*50)
print('# Please choose the rename format of patch')
print('#     1.commit_time+commit_path+xxx.patch(default)')
print('#     2.commit_path+commit_time+xxx.patch')
print('#  other number will quit this program.')
print('#'*50)

while True:
    instr = input('\nPlease input the number you choose(1or 2):')
    #print(instr,type(instr))
    if instr.isdigit() :
        choicenum = int(instr)
        if choicenum == 1 or choicenum == 2:
            main(choicenum)
    elif instr == '':
        main()
    else :
        break
print('Close this application...')
