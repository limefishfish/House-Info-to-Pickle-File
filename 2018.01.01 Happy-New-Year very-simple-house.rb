$xybound = ""
$dxybound = ""
$pic_num = []
$house_boundary
$door1_boundary; $door2_boundary; $door3_boundary; $door4_boundary
#$room1_boundary; $room2_boundary; $room3_boundary
#$droom1_boundary;$droom2_boundary;$droom3_boundary

class Folder_initialize
    attr_accessor :dir_path
    def initialize(dir_path); @dir_path =dir_path; end 
    
    def folder_ini
      if File.directory? @dir_path; FileUtils.rm_rf(@dir_path); end
      Dir.mkdir(@dir_path)
    end
end

class Pos_sort 
   attr_accessor :pos 
   
   def initialize(pos)
      @pos = pos
   end
   
   def sorting
     val = [] ; hash_of_pos = {}
     @pos.each{ |pt|  val << (pt.x.to_f + pt.y.to_f + pt.z.to_f) }
     @pos.zip(val) { |pos,val| hash_of_pos[pos] = val }
     hash_of_pos= hash_of_pos.sort{|front,back| front[1] <=> back[1]}
     @pos.clear ; val.clear ;
     hash_of_pos.each {|u| @pos << u[0] ; val << u[1] }
     puts @pos.inspect
   end   
end

class Insert_Comp

  attr_accessor :path , :pos , :angle
  
  def initialize(path,pos,angle,absolute_scale)
    @path = path
    @pos = pos
    @angle = angle
    @absolute_scale = absolute_scale
  end
  
  def insert_rand_comp(fileglob = "*.skp")
    transform = @pos
    skps = nil
    Dir::chdir(@path) {
      skps = Dir[fileglob]
      }
    count = skps.size
    return false if count.zero?
    index = rand(count-1)
    dfile = File.join(@path,skps[index])
    mod = Sketchup.active_model
    ent  = mod.active_entities
    dlist = mod.definitions
    cdef  = dlist.load(dfile) rescue nil # nil on IOError
    return false if cdef.nil?
    inst  = ent.add_instance(cdef,transform)
    inst_bound = inst.bounds 
    bound_ary = []
    0.upto(7) { |item| bound_ary << inst_bound.corner(item) }
    Pos_sort.new(bound_ary).sorting
    puts bound_ary
    bounds = inst.bounds
    scale_factors = [bounds.width, bounds.height, bounds.depth].zip(@absolute_scale).map{ |old, new| new / old }
    scale_transformation = Geom::Transformation.scaling(*scale_factors)
    inst.transformation *= scale_transformation
    vector = Geom::Vector3d.new(0, 0, 1)
    rotation = Geom::Transformation.rotation(@pos, vector, @angle)
    ent.transform_entities rotation, inst
  end 
end

class Simple_house

  attr_accessor :width , :length , :height , :roof_h , :door_w , :door_h , :door_dp , :door_cent_l , :door_cent_w
  def initialize(width=rand(300.cm...3000.cm),length=rand(500.cm...5000.cm),height=rand(900.cm...1100.cm),
      roof_h=1000.cm,door_w=150.cm,door_h=400.cm,door_dp=20.cm,door_cent_l=0.5*length,door_cent_w=0.5*width)
    @width = width ; 
    @length = length ; 
    @height = height ; 
    @roof_h = roof_h ; 
    @door_w = door_w ; 
    @door_h = door_h ; 
    @door_dp = door_dp ; 
    @door_cent_w = door_cent_w ; 
    @door_cent_l = door_cent_l;
  end
  
  def draw_house
    mod = Sketchup.active_model
    ent = mod.entities
    pts=[]
    pts[0] = [0,0,0]; pts[1] = [0,@length,0]; pts[2] = [@width,@length,0]; pts[3] = [@width,0,0]; 
    pts[4] = [0,0,@height]; pts[5] = [0,@length,@height]; pts[6] = [@width,@length,@height]; pts[7] = [@width,0,@height]; 
    ent.clear!
    horizon_face = ent.add_face pts[0],pts[1],pts[2],pts[3]; horizon_face.reverse!;  #horizon_face.pushpull 50.cm
    side1_face = ent.add_face pts[0],pts[1],pts[5],pts[4];   side1_face.pushpull 20.cm
    side2_face = ent.add_face pts[2],pts[3],pts[7],pts[6];   side2_face.pushpull 20.cm
    side3_face = ent.add_face pts[1],pts[2],pts[6],pts[5];   side3_face.pushpull 20.cm
    side4_face = ent.add_face pts[0],pts[3],pts[7],pts[4];   side4_face.pushpull 20.cm
    $xybound = "yxminus = #{pts[0][0]} , yxplus = #{pts[2][0]} , yyminus = #{pts[2][1]} , yyplus = #{pts[0][1]} "
    $house_boundary =  [ pts[0][0..1] , pts[1][0..1] , pts[2][0..1] , pts[3][0..1] ]
  end
  
  def draw_roof
    mod = Sketchup.active_model
    ent = mod.entities
    pts=[]
    pts[0] = [0,0,@height]; pts[1] = [0,@length,@height]; pts[2] = [@width,@length,@height]; pts[3] = [@width,0,@height]; 
    pts[4] = [0.5*@width , 0.5*@length , @height + @roof_h]; 
    ceiling_face = ent.add_face pts[0],pts[1],pts[2],pts[3]; 
    ceiling_face.pushpull 30.cm
  end
  
  def draw_door1
    mod = Sketchup.active_model
    ent = mod.entities
    #exter_door_path= "C:/ProgramData/SketchUp/SketchUp 2017/SketchUp/Components/Components Sampler/door/Exterior"
    exter_door_path= 'D:\door\Exterior' 
    pts=[]
    pts[0] = [0 , @door_cent_l - 0.5*@door_w , 0]; pts[1] = [0 , @door_cent_l + 0.5*@door_w , 0];
    pts[2] = [0 , @door_cent_l + 0.5*@door_w , @door_h]; pts[3] = [0 , @door_cent_l - 0.5*@door_w , @door_h];
    door_face = ent.add_face pts[0],pts[1],pts[2],pts[3];
    door_face.pushpull -@door_dp
    Insert_Comp.new(exter_door_path,pts[1],rand(-180.degrees...0.degrees),[@door_w-20.cm,@door_dp,@door_h+10.cm]).insert_rand_comp
    $dxybound = "ydxminus = #{pts[0][0]},ydxplus =#{pts[0][0]},ydyminus =#{pts[3][2]},ydyplus =#{pts[2][2]}"
    $door1_boundary =  [ pts[0][0..1] , pts[1][0..1] ]
  end
  
  def draw_door2
    mod = Sketchup.active_model
    ent = mod.entities
    exter_door_path= 'D:\door\Exterior' 
    pts=[]
    pts[0] = [@width , @door_cent_l - 0.5*@door_w , 0]; pts[1] = [@width , @door_cent_l+ 0.5*@door_w , 0];
    pts[2] = [@width , @door_cent_l + 0.5*@door_w , @door_h]; pts[3] = [@width , @door_cent_l - 0.5*@door_w , @door_h];    
    door_face = ent.add_face pts[0],pts[1],pts[2],pts[3];
    door_face.pushpull -@door_dp
    Insert_Comp.new(exter_door_path,pts[1],rand(-180.degrees...0.degrees),[@door_w-20.cm,@door_dp,@door_h+10.cm]).insert_rand_comp
    $door2_boundary =  [ pts[0][0..1] , pts[1][0..1] ]
  end
  
  def draw_door3
    mod = Sketchup.active_model
    ent = mod.entities
    exter_door_path= 'D:\door\Exterior' 
    pts=[]
    pts[0] = [@door_cent_w - 0.5*@door_w , 0 , 0]; pts[1] = [@door_cent_w + 0.5*@door_w , 0 , 0];
    pts[2] = [@door_cent_w + 0.5*@door_w , 0 , @door_h]; pts[3] = [@door_cent_w - 0.5*@door_w , 0 , @door_h];    
    door_face = ent.add_face pts[0],pts[1],pts[2],pts[3];
    door_face.pushpull -@door_dp
    Insert_Comp.new(exter_door_path,pts[1],rand(90.degrees...270.degrees),[@door_w+60.cm,@door_dp,@door_h+10.cm]).insert_rand_comp
    $door3_boundary =  [ pts[0][0..1] , pts[1][0..1] ]
  end
  
  def draw_door4
    mod = Sketchup.active_model
    ent = mod.entities
    exter_door_path= 'D:\door\Exterior' 
    pts=[]
    pts[0] = [@door_cent_w - 0.5*@door_w , @length , 0]; pts[1] = [@door_cent_w + 0.5*@door_w , @length , 0];
    pts[2] = [@door_cent_w + 0.5*@door_w , @length , @door_h]; pts[3] = [@door_cent_w - 0.5*@door_w , @length , @door_h];    
    door_face = ent.add_face pts[0],pts[1],pts[2],pts[3];
    door_face.pushpull -@door_dp
    Insert_Comp.new(exter_door_path,pts[1],rand(90.degrees...270.degrees),[@door_w+60.cm,@door_dp,@door_h+10.cm]).insert_rand_comp
    $door4_boundary = [ pts[0][0..1] , pts[1][0..1] ]
  end
  #紅色 : X軸 ; 綠色 : y軸 ; 藍色 : z軸
  def draw_room1
    mod = Sketchup.active_model
    ent = mod.entities
    pts=[]
    room_width = 0.5*@door_cent_w + Random.rand(0.5*@door_cent_w -0.5*@door_w-20.cm) 
    room_length = 0.5*@door_cent_l + Random.rand(0.5*@door_cent_l-0.5*@door_w-60.cm) 
    pts[0] = [51.cm , room_length, 0]; pts[1] = [51.cm , room_length , @height];
    pts[2] = [room_width , room_length, 0]; pts[3] = [room_width , room_length, @height];
    pts[4] = [room_width , 1.cm , 0]; pts[5] = [room_width , 1.cm , @height];
    pts[6] = [room_width , 0.5*room_length+0.5*@door_w, 0]; pts[7] = [room_width , 0.5*room_length+0.5*@door_w, @door_h];
    pts[8] = [room_width , 0.5*room_length-0.5*@door_w, 0]; pts[9] = [room_width , 0.5*room_length-0.5*@door_w, @door_h];
    room_f2 = ent.add_face pts[2],pts[3],pts[5],pts[4]; room_f2.pushpull -50.cm
    room_d2 = ent.add_face pts[6],pts[7],pts[9],pts[8]; room_d2.pushpull -50.cm
    room_f1 = ent.add_face pts[0],pts[1],pts[3],pts[2]; room_f1.pushpull 50.cm
    inter_door_path= 'D:\door\Interior'
    pts[6] = [room_width-@door_dp , 0.5*room_length+0.5*@door_w, 0]
    Insert_Comp.new(inter_door_path,pts[6],rand(-180.degrees...0.degrees),[@door_w,@door_dp,@door_h]).insert_rand_comp
    $room1_boundary = [ pts[0][0..1] , pts[2][0..1] , pts[4][0..1]]
    $droom1_boundary = [ pts[6][0..1] , pts[8][0..1] ]
  end
  
  def draw_room2
    mod = Sketchup.active_model
    ent = mod.entities
    pts=[]
    room_width = @door_cent_w + 0.5*@door_w + Random.rand(0.25*@width-0.5*@door_w) +10.cm 
    pts[0] = [room_width, 1.cm, 0];
    pts[1] = [room_width , @length-1.cm, 0];
    pts[2] = [room_width , @length-1.cm, @height];
    pts[3] = [room_width , 1.cm, @height];
    pts[4] = [room_width,  0.5*@length-0.5*@door_w, 0];
    pts[5] = [room_width , 0.5*@length+0.5*@door_w, 0];
    pts[6] = [room_width , 0.5*@length+0.5*@door_w , @door_h];
    pts[7] = [room_width , 0.5*@length-0.5*@door_w, @door_h];
    room_f = ent.add_face pts[0],pts[1],pts[2],pts[3];  room_f.pushpull 50.cm;
    room_df = ent.add_face pts[4],pts[5],pts[6],pts[7]; room_df.pushpull -50.cm;
    inter_door_path= 'D:\door\Interior'
    pts[5] = [room_width+@door_dp , 0.5*@length+0.5*@door_w, 0];
    Insert_Comp.new(inter_door_path,pts[5],rand(-180.degrees...0.degrees),[@door_w,@door_dp,@door_h]).insert_rand_comp
    $room2_boundary = [ pts[0][0..1] , pts[1][0..1] ]
    $droom2_boundary = [ pts[4][0..1] , pts[5][0..1] ]
  end
  
  def draw_room3
    mod = Sketchup.active_model
    ent = mod.entities
    pts=[]
    room_width = 300.cm + Random.rand(@door_cent_w-0.5*@door_w -300.cm) 
    room_length = @door_cent_l + 0.5* @door_w +20.cm + Random.rand(0.5*@door_cent_l-0.5*@door_w-20.cm)
    pts[0] = [room_width ,@length-1.cm, 0];     pts[1] = [room_width ,@length-1.cm, @height];
    pts[2] = [room_width ,room_length, 0]; pts[3] = [room_width ,room_length, @height];
    pts[4] = [51.cm,room_length, 0];           pts[5] = [51.cm,room_length, @height];
    pts[6] = [0.5*room_width+0.5*@door_w ,room_length, 0]; pts[7] = [0.5*room_width+0.5*@door_w ,room_length, @door_h];
    pts[8] = [0.5*room_width-0.5*@door_w ,room_length, 0]; pts[9] = [0.5*room_width-0.5*@door_w ,room_length, @door_h];    
    room_f2 = ent.add_face pts[2],pts[3],pts[5],pts[4]; room_f2.pushpull -50.cm
    room_d2 = ent.add_face pts[6],pts[7],pts[9],pts[8]; room_d2.pushpull -50.cm
    room_f1 = ent.add_face pts[0],pts[1],pts[3],pts[2]; room_f1.pushpull 50.cm
    inter_door_path= 'D:\door\Interior'
    pts[6] = [0.5*room_width+0.5*@door_w ,room_length+@door_dp, 0]; 
    Insert_Comp.new(inter_door_path,pts[6],rand(-270.degrees...-90.degrees),[@door_w,@door_dp,@door_h]).insert_rand_comp
    $room3_boundary = [ pts[0][0..1] , pts[2][0..1] , pts[4][0..1] ]
    $droom3_boundary = [ pts[6][0..1] , pts[8][0..1] ]
  end
end

class Draw_points_inface
  attr_accessor :fac , :vert_new , :height 
  
  def initialize(fac , vert_new , height=160.cm)
    @face = fac;
    @vert_new = vert_new;
    @height = height;
  end
  
  def draw_points
     mod = Sketchup.active_model
     ent = mod.entities
     transform_local_to_face = Geom::Transformation.new(@face.bounds.min, @face.normal).inverse
     local_points = @face.mesh.transform!(transform_local_to_face).points
     bounds = Geom::BoundingBox.new
     bounds.add(local_points)
     grid_size = [bounds.width, bounds.height].max / 11.cm 
     puts "#{bounds.width}  #{bounds.height}"
     grid = []
     transform_to_world = transform_local_to_face.inverse
     bounds.min.x.step(bounds.max.x, grid_size).each { |x|
       bounds.min.y.step(bounds.max.y, grid_size).each { |y|
         local_point = Geom::Point3d.new(x, y, 0)
         world_point = local_point.transform(transform_to_world)
         #mod.active_entities.add_cpoint(world_point)  #加入輔助點
         #mod.active_entities.add_cpoint(local_point)  #加入輔助點
         grid << world_point
       }
     }
     points_on_face = grid.select { |point|
         result = @face.classify_point(point)
         result == Sketchup::Face::PointInside
         }
     points_we_want = []
     points_on_face.each { |point| points_we_want << point} 
     #points_we_want.each{|point| @mod.active_entities.add_cpoint(point)}  #輔助點
     #puts "points_we_want = #{@points_we_want}"
     @vert_new.clear;  
     points_we_want.each{|v| 
       point = Geom::Point3d.new v.x,v.y,(v.z+height); 
       @vert_new << point; 
        }
  end
end

class Take_pic
   attr_accessor :eye_array ,:pic_path , :n
   
   def initialize(eye_array,pic_path,n=6); 
      @eye_array = eye_array; @pic_path = pic_path ;@n=n
   end
      
   def take_picture(axis=Geom::Vector3d.new(0,0,1))
     mod = Sketchup.active_model 
     ent = mod.entities 
     view = mod.active_view
     camera=view.camera
     target = camera.target
     require 'fileutils'
     cen=Sketchup.active_model.bounds.center
     target.x = cen.x
     target.y = cen.y
	 target.z = 160.cm #cen.z
     count=0 
     gif_counter=0
     page_count = 0
     for i in 0...eye_array.length
       screentable= File.new( @pic_path + "/screentable.txt", "w+" )
       screentable= File.open( @pic_path + "/screentable.txt", "a" )    
       screentable.puts "House info : #{$house_boundary.inspect.to_s}" , "Door1 info : #{$door1_boundary.inspect.to_s}" , "Door2 info : #{$door2_boundary.inspect.to_s}" , "Door3 info : #{$door3_boundary.inspect.to_s}","Door4 info : #{$door4_boundary.inspect.to_s}"
       #screentable.puts "room1 info : #{$room1_boundary.inspect.to_s}" , "room2 info : #{$room2_boundary.inspect.to_s}" , "room3 info : #{$room3_boundary.inspect.to_s}" 
       #screentable.puts "droom1 info : #{$droom1_boundary.inspect.to_s}" , "droom2 info : #{$droom2_boundary.inspect.to_s}" , "droom3 info : #{$droom3_boundary.inspect.to_s}" 
       screentable.close
       screen_array = []

       @n.times{|j|  
          page_count+=1
          path = "#{@pic_path}/Image_#{(i*@n+j).to_s}.jpg"
          count += 1
          keys = {
            :filename => path ,
            :transparent => true
            }
          view.write_image keys 
          trans = Geom::Transformation.rotation target, axis, 360/180.0*Math::PI/@n
          @eye_array[i].transform! trans
          camera.set @eye_array[i],target,[0,0,1]
          vect1 = Geom::Vector3d.new(1,0,0)
          vect2 = Geom::Vector3d.new(target.x- @eye_array[i][0],target.y- @eye_array[i][1],target.z- @eye_array[i][2])
          puts "screentable", (i*@n+j) , eye_array[i], target , (vect2.angle_between vect1)
          screen_array <<  "screentable"
          screen_array <<  (i*@n+j)
          screen_array <<   "(#{eye_array[i][0].to_cm.round(3).to_s} , #{eye_array[i][1].to_cm.round(3).to_s} , #{eye_array[i][2].to_cm.round(3).to_s})"
          screen_array <<  target
          screen_array <<  (vect2.angle_between vect1) 
          #screentable2= File.open( @pic_path + "/screentable#{"_tmp"}.txt", "a" )
          #screentable2.puts "screentable", (i*@n+j) , eye_array[i], target , (vect2.angle_between vect1) 
          #screentable2.close
          
        }
        puts screen_array
        screentable= File.new( @pic_path + "/screentable2.txt", "a+" )
        screentable= File.open( @pic_path + "/screentable2.txt", "a+" )
        screentable.puts screen_array
        screentable.close

     end
     $pic_num << page_count

   end     
end

class Make_house_N_pic 
  attr_accessor :dir_path
  
   def initialize(dir_path) 
     @dir_path = dir_path 
   end
     
  def house_maker_analyser 
    house = Simple_house.new();
    house.draw_house 
    house.draw_roof 
    house.draw_door1 
    house.draw_door2  
    house.draw_door3 
    house.draw_door4 
    #house.draw_room1; 
    #house.draw_room2; 
    #house.draw_room3;

    mod = Sketchup.active_model
    ent = mod.entities
    view = mod.active_view
    mat = mod.materials
    require 'fileutils'
    faces = ent.grep(Sketchup::Face) 
    array = Sketchup::Color.names
    chosen_color = array[rand(140)]
    eye_array = []
    tmp_a = []

    faces.each{ |entity|
      x = entity.normal.normalize!.x.to_i;
      y = entity.normal.normalize!.y.to_i;
      z = entity.normal.normalize!.z.to_i;
      status = false ; entity.vertices.map { |v| v.position.z.to_i == 0 ? status = true : status = false ; next } 
    case true
    when z == 0;
       entity.material = chosen_color  #mat_brick;         
    when status == true; 
       entity.material = chosen_color  #mat_brick;
       Draw_points_inface.new(entity,tmp_a).draw_points
       eye_array.concat(tmp_a) 
       tmp_a.clear
    else 
       entity.material = chosen_color  #mat_brick;
    end
    }
   Take_pic.new(eye_array,@dir_path,5).take_picture 
  end
end

class Dataset_pic
   attr_accessor :dir_path , :house_num
   
   def initialize(dir_path,house_num=50) 
     @dir_path = dir_path 
     @house_num = house_num
   end
   
   def make_dataset 
     require 'fileutils'
     counter = 1
     Folder_initialize.new(@dir_path).folder_ini
     while counter <= @house_num
        pic_info = []
        folder_path = "#{@dir_path}/h#{counter}"
        Dir.mkdir(folder_path)
        Make_house_N_pic.new(folder_path).house_maker_analyser 
        f= File.open( folder_path + "/screentable.txt", "a+" )
        g= File.open( folder_path + "/screentable2.txt", "a+" )
        pic_info << g.read
        f.puts pic_info
        #FileUtils.cp_r(g, f)
        f.close
        g.close
        #File.delete "#{folder_path}/screentable2.txt"
        counter+=1
     end
   end
end

pic_path = "D:/vsh-with-1to4_v#{rand(10000000)}-doors"
Folder_initialize.new(pic_path).folder_ini
Dataset_pic.new(pic_path,1000).make_dataset

#Folder_initialize.new(pic_path).folder_ini
#Take_pic.new(eye_array,pic_path,6).take_picture 

fill_pic_num = []
hp_folder = []

Dir.open(pic_path) { |dir|
    dir.each{|name| if File.fnmatch('h*', name) ; hp_folder << name ; end }
}
pic_num = hp_folder.length
hp_folder = []

0.upto(pic_num-1){ |item|
    hp_folder << "h#{item+1}"
}

puts hp_folder

0.upto($pic_num.length - 1) {|pt| fill_pic_num << $pic_num.max-$pic_num[pt]} 
puts $pic_num.length; puts fill_pic_num.length; puts hp_folder.length;
puts $pic_num.inspect; puts fill_pic_num.inspect;
puts $house_boundary.inspect

for i in 0...hp_folder.length #hp_folder.length #第39開始不行
   puts pic_path +"/"+ hp_folder[i].to_s + "/screentable.txt"
   strr = pic_path +"/"+ hp_folder[i].to_s
   screentable= File.open( pic_path + "/" + hp_folder[i].to_s + "/screentable.txt", "a+" )
     
#   loop do
#     screentable.readline 
#     puts screentable.readline 
#     break if screentable.readline.scan(/screentable/).length != 0
     #/#{place}/.match(screentable.readline)
#   end  
   for item in 0...5
       screentable.readline 
   end
   screentable.readline 
   screentable.readline
   
   info = []
   for j in 0...3
     info << screentable.readline 
   end
   num = (fill_pic_num[i]).to_i
   for k in 1..num
      screentable.puts "screentable", ($pic_num[i]+k-1).to_s , info
      FileUtils.cp_r("#{strr}/Image_0.jpg", "#{strr}/Image_#{($pic_num[i]+k-1).to_s}.jpg" )
   end
   screentable.close
end
