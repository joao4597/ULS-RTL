pkg load sockets;
disconnect(s);
green = [0, 102, 0] ./ 255;

function [x_coords, y_coords] = read_local_maxs(s)
  
  x_coords = zeros(1,13);
  y_coords = zeros(1,13);
  
  for q = 1:1:13
    [config,count] = recv(s, 100);
    char_aux = "";
    for y = 1:1:count
      char_aux(y) = typecast(config(y), "char");
    end
    x_coords(q) = str2num(char_aux);
  
    [config,count] = recv(s, 100);
    char_aux = "";
    for y = 1:1:count
      char_aux(y) = typecast(config(y), "char");
      y_coords(q) = str2num(char_aux);
    end
  end

endfunction



s=socket(AF_INET, SOCK_DGRAM, 0);
bind(s,15002);
buff = [];
char config[100];
char char_aux[100];
char_aux = "";
while 1==1
  [config,count] = recv(s, 100);
  
  if (strcmp(config, "START") == 0)
    fprintf("%s\n", config);
    buff = zeros(1,128);
    for x = 1:1:128
      [config,count] = recv(s, 100);
      
      char_aux = "";
      for y = 1:1:count
        char_aux(y) = typecast(config(y), "char");
      end
      buff(x) = str2num(char_aux);
      
      %fprintf("%s\n", config);
      %fprintf("%d\n", buff(x));
    end
    
    [config,count] = recv(s, 100);
      
    char_aux = "";
    for y = 1:1:count
      char_aux(y) = typecast(config(y), "char");
    end
    x = str2num(char_aux)
      
    [config,count] = recv(s, 100);
      
    char_aux = "";
    for y = 1:1:count
      char_aux(y) = typecast(config(y), "char");
    end
    y = str2num(char_aux) 
    
    [xcoords, ycoords] = read_local_maxs(s);
    
    figure(1)
    plot(0:1:127, "color", "b", buff, '-o');
    hold on
    plot(x,y, "color", "r", 'd', "linewidth", 5);
    hold on
    plot(xcoords, ycoords, "color", green, '-+');
    title("Correlation Peak");
    refresh;
    hold off
    
  end
end


