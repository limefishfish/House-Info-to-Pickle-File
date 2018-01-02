# -*- coding: UTF-8 -*-     
# coding=Big5

from glob import glob
from os.path import splitext
from PIL import Image
import pickle as pickle
import gzip
import random
import matplotlib.pyplot as plt
import re
import numpy
import os
import matplotlib.cm as cm
import re
import glob
from numpy import *
import PIL

ins_geo=[];  outs=[];  ins_imgs=[];  ins_geo=[];  ins_imgs=[];  ins_geos=[];   outss=[];   ins_imgss=[];  TmpList = [];
House_str  = [];       Door_str   = [];           door_info  = [];             house_info = [];           door_inHouse = [];
Droom_str  = [];       Room_str   = [];           room_info  = [];             droom_info  = [];          room_inHouse = []; 
droom_inHouse = [];

def line_cutting(p1,p2,numSeg):
	
	if  p1[0]==p2[0] and p1[1]!=p2[1]:
		x = numpy.array([p1[0]]*numSeg)
		y = numpy.linspace(p1[1], p2[1], numSeg)
		coords = [] 
		coords.extend([x,y])
		return numpy.array(coords)	
		
	if  p1[0]!=p2[0] and p1[1]==p2[1]:
		x = numpy.linspace(p1[0], p2[0], numSeg)
		y = numpy.array([p1[1]]*numSeg)
		coords = [] 
		coords.extend([x,y])
		return numpy.array(coords)	
		
	if  p1[0]!=p2[0] and p1[1]!=p2[1]:
		x = numpy.linspace(p1[0], p2[0], numSeg)
		y = numpy.linspace(p1[1], p2[1], numSeg)
		coords = [] 
		coords.extend([x,y])
		return numpy.array(coords)		

#重新命名
f_path = "D:/vsh3"
count=1000000000
for fname in os.listdir(f_path):
    new_fname = 'h'+ str(count)
    os.rename(os.path.join(f_path, fname), os.path.join(f_path, new_fname))
    count = count + 1 
       
count=1
for fname in os.listdir(f_path):
    new_fname = 'h'+ str(count)
    os.rename(os.path.join(f_path, fname), os.path.join(f_path, new_fname))
    count = count + 1  

#處理圖片
for Folder_cnt in range (0,1500):
    house_geo = []
    house_img = []
    Folder_path = f_path + "/h" + "%s" %(Folder_cnt+1)  
    os.chdir(Folder_path)     
    print(Folder_path+"/screentable.txt")
    print(Folder_cnt)
    file_pi = open( Folder_path + "/screentable.txt" , 'r')
	    
    while True:
        content = file_pi.readline() 
        if re.search(r'^House',content)!= None:
            House_str.append(content) 
        if re.search(r'^Door',content)!= None:
            Door_str.append(content)
        if re.search(r'^room',content)!= None:
            Room_str.append(content) 
#        if re.search(r'^droom',content)!= None:
#            Droom_str.append(content)
        if re.search(r'screentable',content)!= None: 
            break
    
    for item in range(0,len(House_str)):
        house_info = re.findall(r'\d+\.?\d*',House_str[item])
        for ele in range(0,len(house_info)):
            house_info[ele]=float(house_info[ele])
        house_info = numpy.array(house_info)
        house_info = house_info.reshape(-1,2)         #使用此，(5,36)->(5,12,2)
    TmpList.extend(house_info)  
    House_str = []

   
    for item in range(0,len(Door_str)):
        door_info = re.findall(r'\d+\.?\d*',Door_str[item])
        del door_info[0]
        for ele in range(0,len(door_info)):
            door_info[ele]=float(door_info[ele])
        door_info = numpy.array(door_info)
        door_info = door_info.reshape(-1,2)            #使用此，(5,36)->(5,12,2)
        door_inHouse.extend(door_info)
    TmpList.extend(door_inHouse)
    Door_str = []
	
   
               
    while True:
        if content == "":            
            break
        re.findall('(screentable)', content)  
                    
        content = file_pi.readline()
        m = re.match(r'\d+', content)
        n_img = int(m.group(0))            
        im = Image.open(Folder_path + "\Image_%d.jpg"  % n_img)
        nim=im.resize((56,56), Image.BILINEAR)
        content = file_pi.readline()
        m=re.findall(r"\d+\.?\d*", content)             
        xx = float(m[0]); xy = float(m[1])
        content = file_pi.readline()
        content = file_pi.readline()
        m = re.search('((\d+)(\.*)(\d*))', content)      
        orient = float( m.group(0))                       
        nim_array = numpy.asarray(nim, dtype=numpy.uint8)  
        geo_array = numpy.asarray([xx, xy, orient])       	  
        house_img.append(nim_array)
        house_geo.append(geo_array)
        content = file_pi.readline()
	  	  
    outss.append(TmpList)
    ins_geos.append(house_geo)
    ins_imgss.append(house_img)
    TmpList = []
    door_inHouse = []
    room_inHouse = []
    droom_inHouse = []
    file_pi.close()

outss = numpy.array(outss)
outss = outss.reshape(outss.shape[0],-1) 
print("outss :",outss.shape) 

'''
numSeg = 20
outsss  = []
outssss = []

for i in range(0,outss.shape[0]): 
	for j in range(0,4):
		if j+1 == 4:
			outsss.extend(line_cutting(outss[i][j],outss[i][0],numSeg))
		else:
			outsss.extend(line_cutting(outss[i][j],outss[i][j+1],numSeg))
		num = len(outsss)
		print("num =" , num )
	for j in range( 0 , 11 ):
		outsss.extend(line_cutting(outss[i][2*j+4],outss[i][2*j+5],numSeg))
	outssss.append(outsss)	
	print ("outsss = ", numpy.array(outsss).shape )
	outsss = []

	
print ("outssss = ", numpy.array(outssss).shape)
outssss = numpy.array(outssss)
outssss = outssss.reshape(outssss.shape[0],outssss.shape[1]*outssss.shape[2])
#print ("outssss = ", outssss , '\n') 
path_pkl = 'D:\data_1to10_20171031.pkl' 
data = (ins_geos, ins_imgss, outssss)
''' 
  
path_pkl = 'HappyNewYear2Everyone_20171231.pkl' 
data = (ins_geos, ins_imgss, outss)


#####################################################################

file_po = open(path_pkl, 'wb')  # w : 寫字串 / wb : 寫binary
pickle.dump(data,file_po)

f = open(path_pkl, 'rb')

(Xgeo, Ximg, Y) = pickle.load(f)
Xgeo = numpy.asanyarray(Xgeo)
Ximg = numpy.asanyarray(Ximg)
Y = numpy.asanyarray(Y)

print ('\n'," Xgeo, Ximg, Y : ", Xgeo.shape, Ximg.shape, Y.shape)
#print ("Y = ", Y , '\n' )
#print ("Xgeo = ", Xgeo , '\n' )
#numpy.savetxt("D:/Y_v8.csv", Y, delimiter=",")
#numpy.savetxt("D:/Xgeo_v888.csv", Xgeo, delimiter=",")

#print ("Y = ", Y , '\n' )
#print ("Xgeo = ", Xgeo , '\n' )

#numpy.savetxt("D:/Y.csv", Y, delimiter=",")
#numpy.savetxt("D:/Xgeo.csv", Xgeo.reshape(Xgeo.shape[0]*Xgeo.shape[1],Xgeo.shape[2]), delimiter=",",fmt='%.18e') # fmt='float64')


for i in range(0,len(Ximg)):
    for j in range(0,len(Ximg[i])):
        img = Image.fromarray(Ximg[i][j])
        #img.show()
        img.save('D:/section/Image'+str(random.randint(0,1000))+'.jpg' )

