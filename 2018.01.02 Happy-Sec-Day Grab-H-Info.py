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


f = open('20171216mission.txt', 'r', encoding='UTF-8')

while True:
    line = f.readline()
    volunteer_pattern = re.compile('.*:.*')
