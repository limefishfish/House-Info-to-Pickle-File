# Dir : https://ruby-doc.org/core-1.9.3/Dir.html
# fnmatch  :  https://ruby-doc.org/core-2.2.0/File.html
# file operation : http://blog.xuite.net/yschu/wretch/104913069-Ruby+-+Chapter+16++File%E9%A1%9E%E5%88%A5%E8%88%87Dir%E9%A1%9E%E5%88%A5

require 'find'
require 'fileutils'
path_PicExist = "D:/vsh3"

status = false

picExist_path = []
picNotExist_path = []
#allHpath = []

Dir.open(path_PicExist){ |dir|
    dir.each{ |name|
        Dir.open("#{path_PicExist}/#{name}"){ |dirs|
            dirs.each{ |pic|   
                if(File.fnmatch('*.jpg', pic)==true)
                    status = true 
                    break
                end   
                }
            picExist_path << "#{path_PicExist}/#{name}" if status == true
            picNotExist_path << "#{path_PicExist}/#{name}" if status == false
            status = false
        }
    }
}

#拿掉串列第一項
picExist_path.shift()
picNotExist_path.shift() 

#刪除沒有照片的資料夾
picNotExist_path.each { |f|
    FileUtils.rm_rf(picNotExist_path)
    }
#FileUtils.rm_rf(picNotExist_path)

picExist_array = []

picExist_path.each{ |f|
    Dir.open(f){ |dir|
            picNum = 0
            dir.each{ |pic|
                picNum+=1  if File.fnmatch('*.jpg', pic)==true 
                } 
            picExist_array << picNum 
    }
}

pic_num2copy = []
picExist_array.each{ |num|
    pic_num2copy << picExist_array.max - num
}

# 複製Image_1
counter = -1
picExist_path.each { |path|
    counter += 1
    Dir.open(path){ |dir|
        for i in 0...pic_num2copy[counter]
            FileUtils.cp_r("#{path}/Image_1.jpg", "#{path}/Image_#{(picExist_array[counter]+i).to_s}.jpg" )
        end
    }
}

count = 0
picExist_path.each { |path|
    count_Keyword = 0
    count_readline = 0
	f= File.open( "#{path}/screentable.txt", "a+" )
	puts("#{path}/screentable.txt")
	while true
		count_readline += 1
		line = f.readline
		sentense = line.match('screentable').to_s
		#puts("Match : #{sentense}")
		#puts(status)
		count_Keyword += 1 if (sentense <=> "screentable") == 0
		break if count_Keyword == 2
		break if (f.eof?)
	end
	f.close()
	
    puts("The num of count_readline is #{count_readline.to_s}")
	g = File.open( "#{path}/screentable.txt", "a+" )
	for i in 0..count_readline
		g.readline
		#puts(g.readline)
	end
	info = []
	for i in 0...3
		info << g.readline 
	end
	print("count is #{count.to_s}\n")
	print("pic_num2copy[count] is #{pic_num2copy[count].to_s}\n")
	print("picExist_array[count] is #{picExist_array[count].to_s}\n")
	for i in 0...pic_num2copy[count]
		g.puts "screentable", (picExist_array[count]+i).to_s , info
	end 
	count+=1
	g.close()
	
	#print("count_Keyword is #{count_Keyword.to_s}\n")
    #print("count_readline is #{count_readline.to_s}\n")
}


#展示結果
print("\n\n")
print(picExist_path.inspect)
print("\n\n")
print(picNotExist_path.inspect)
print("\n\n")
print("The length of picExist_path is #{picExist_path.length.to_s}")
print("\n\n")
print(picExist_array)
print("\n\n")
print(pic_num2copy)
