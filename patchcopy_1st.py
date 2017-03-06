import os
import re
import shutil
import chardet

mon_dic = {'Jan':'1','Feb':'2','Mar':'3','Apr':'4','May':'5','Jun':'6','Jul':'7','Aug':'8','Sep':'9','Oct':'10','Nov':'11','Dec':'12'}
path_dic = {}
date_dic = {}
err_flag = False

def getpathdic(file_name):
    count = 0
    with open(file_name,'r') as f:
        for i in f.readlines():
            if '\n' == i or '@' in i:
                continue
            if '/' in i:
                temp = i.strip('\n').split()
                path_temp = temp[len(temp)-1].split('/')
                #path_temp = re.sub(r'[\n\s]','',i).split('/')
                path = ''
                for j in range(0,len(path_temp)):
                    path += path_temp[j]
                    path += '-'
            elif '-' in i:
                count += 1
                path_dic[i.strip('\n')] = path
                print(count,')、',i.strip('\n'),' <---> ',temp[len(temp)-1])
                
def gettime(filename,date_str):
    temp = date_str.split()
    time = temp[5].split(':')
    date = temp[4]+'-'+mon_dic[temp[3]]+'-'+temp[2]+'-'+time[0]+'-'+time[1]
    date_dic[filename] = date
    print(filename,' <---> ',date)

#get the codec of the file
def getcode(filename):
    with open(filename,'rb') as f:
        data = f.read()
        enco_dic = dict( chardet.detect(data))

    return enco_dic['encoding']

def gettimecir(filename,log):
    #print(filename)
    global err_flag
    for i in filename:
        if '.patch' in i:
            #print(i)
            try:
                with open(i,'r') as f:
                     gettime(i,f.readlines()[2:3][0])
            except IndexError as reason:
                #print(reason)
                if 'list index out of range' in str(reason):
                    err_flag = True
                    print('[Warning]NULL FiLE:',i,file=log)
                else:
                    raise IndexError(reason)
            except UnicodeDecodeError:
                try:
                    encode = getcode(i)
                    with open(i,'r',encoding=encode) as f:
                        gettime(i,f.readlines()[2:3][0])
                except IndexError as reason:
                    #print(reason)
                    if 'list index out of range' in str(reason):
                        err_flag = True
                        print('[Warning]NULL FiLE:',i,file=log)
                    else:
                        raise IndexError(reason)
                

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
                #print('[Warning]',reason,file=log)
                pass

print('===========   Start  ==============')
if os.path.exists('out'):
    os.system('rm -rf out')
os.mkdir('out')
out = os.getcwd() + '/out/'
f_log = open('log.txt','w')

print('Begin to get the path of patchs......\n')
getpathdic('0302-a444-repoformatpatch.log')
print('\nFinish.\n')

print('Begin to get the commit time of patchs...\n')
os.chdir('patch')
filename_old = os.listdir()
filename_old.sort()
gettimecir(filename_old,f_log)
print('\nFinish.\n')

print('Begin to move patch to direction out...\n')
movepatch(filename_old,out,f_log)
print('\nFinish.\n')

os.chdir('..')
f_log.close()
if err_flag:
    print('[Error]:Some files file to copy...')
else:
    os.system('rf log.txt')
print('============  End ============')
